//
//  CalendarView.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 Sword.Zhou. All rights reserved.
//

#import "CalendarView.h"
#import "CalMonth.h"
#import "ITTDebug.h"
#import "CalendarWeekHintView.h"

#define MARGIN_LEFT                              0
#define MARGIN_TOP                               0
#define PADDING_VERTICAL                         0
#define PADDING_HORIZONTAL                       0
#define HORIZONTAL_SWIPE_HEIGHT_CONSTRAINT       80
#define HORIZONTAL_SWIPE_WIDTH_CONSTRAINT        90
#define SWIPE_TIMER_INTERVAL                      0.4

@interface CalendarView ()

@property(strong, nonatomic) CalMonth *calMonth;

@property(strong, nonatomic) IBOutlet UIView *weekHintView;
@property(strong, nonatomic) IBOutlet UIView *headerView;
@property(strong, nonatomic) IBOutlet UIView *footerView;
@property(strong, nonatomic) IBOutlet CalendarScrollView *gridScrollView;

- (void)initParameters;

- (void)layoutGridCells;

- (void)recycleAllGridViews;

- (void)resetSelectedIndicesMatrix;

- (void)resetFocusMatrix;

- (void)updateSelectedGridViewState;

- (void)removeGridViewAtRow:(NSUInteger)row column:(NSUInteger)column;

- (void)addGridViewAtRow:(CalendarGridView *)gridView row:(NSUInteger)row column:(NSUInteger)column;

- (BOOL)isGridViewSelectedEnableAtRow:(NSUInteger)row column:(NSUInteger)column;

/*
 * caculate rows of calendar view based on month
 */
- (NSUInteger)getRows;

/*
 * caculate month day based on row and column on calendar view
 */
- (NSUInteger)getMonthDayAtRow:(NSUInteger)row column:(NSUInteger)column;

/*
 * caculate grid view frame based on row and column on calendar view
 */
- (CGRect)getFrameForRow:(NSUInteger)row column:(NSUInteger)column;

- (NSString *)findMonthDescription;

- (NSArray *)findWeekTitles;

/*
 * @return:current day or first day of a month
 */
- (CalDay *)getFirstSelectedAvailableDay;

- (CalendarViewHeaderView *)findHeaderView;

- (CalendarViewFooterView *)findFooterView;

- (CalendarGridView *)findGridViewAtRow:(NSUInteger)row column:(NSUInteger)column calDay:(CalDay *)calDay;

- (CalendarGridView *)findDisableGridViewAtRow:(NSUInteger)row column:(NSUInteger)column calDay:(CalDay *)calDay;

- (CalendarGridView *)getGridViewAtRow:(NSUInteger)row column:(NSUInteger)column;

/*
 * The selected calyday on calendar view
 */
@property(strong, nonatomic, readwrite) CalDay *selectedDay;


@end

@implementation CalendarView

@synthesize appear;
@synthesize gridSize = _gridSize;
@synthesize selectedPeriod = _selectedPeriod;
@synthesize calMonth = _calMonth;
@synthesize weekHintView = _weekHintView;
@synthesize selectedDay = _selectedDay;
@synthesize date = _date;
@synthesize minimumDate = _minimumDate;
@synthesize maximumDate = _maximumDate;
@synthesize delegate = _delegate;
@synthesize dataSource = _dataSource;
@synthesize headerView = _headerView;
@synthesize footerView = _footerView;
@synthesize gridScrollView = _gridScrollView;
@synthesize allowsMultipleSelection = _allowsMultipleSelection;

- (void)initParameters {
    _allowsMultipleSelection = FALSE;
    _firstLayout = TRUE;
    _selectedPeriod = PeriodTypeAllDay;
    _previousSelectedIndex.row = NSNotFound;
    _previousSelectedIndex.column = NSNotFound;

    _gridSize = CGSizeMake(45.71, 45.71);
    _date = [NSDate date];
    _selectedDay = [[CalDay alloc] initWithDate:_date];
    _calMonth = [[CalMonth alloc] initWithDate:_date];
    _gridViewsArray = [[NSMutableArray alloc] init];
    _monthGridViewsArray = [[NSMutableArray alloc] init];
    _recycledGridSetDic = [[NSMutableDictionary alloc] init];

    NSUInteger n = 6;
    _selectedIndicesMatrix = (bool **) malloc(sizeof(bool *) * n);
    _focusMatrix = (bool **) malloc(sizeof(bool *) * n);
    for (NSUInteger i = 0 ;i < n ;i++){
        _selectedIndicesMatrix[i] = malloc(sizeof(bool) * NUMBER_OF_DAYS_IN_WEEK);
        memset(_selectedIndicesMatrix[i], FALSE, NUMBER_OF_DAYS_IN_WEEK);

        _focusMatrix[i] = malloc(sizeof(bool) * NUMBER_OF_DAYS_IN_WEEK);
        memset(_focusMatrix[i], FALSE, NUMBER_OF_DAYS_IN_WEEK);

    }
    for (NSUInteger index = 0 ;index < n ;index++){
        NSMutableArray *rows = [[NSMutableArray alloc] init];
        [_gridViewsArray addObject:rows];
    }
}

- (void)freeMatrix {
    NSInteger n = 6;
    for (int i = 0 ;i < n ;i++){
        free(_selectedIndicesMatrix[i]);
        _selectedIndicesMatrix[i] = NULL;
        free(_focusMatrix[i]);
        _focusMatrix[i] = NULL;
    }
    free(_selectedIndicesMatrix);
    _selectedIndicesMatrix = NULL;
    free(_focusMatrix);
    _focusMatrix = NULL;

}

- (void)updateCalendar {
    _firstLayout = TRUE;
    [self recycleAllGridViews];
    [self setNeedsLayout];
}

- (void)updateCalendar:(BOOL)animated {
    _firstLayout = TRUE;
    [self recycleAllGridViews];
    [self setNeedsLayout];
}

- (void)setDate:(NSDate *)date {
    if (_date){
        _date = nil;
    }
    _date = date;
    CalMonth *cm = [[CalMonth alloc] initWithDate:_date];
    self.calMonth = cm;
}

- (void)setSelectedDay:(CalDay *)selectedDay {
    _selectedDay = selectedDay;
    // TODO: gridViewを渡せるなら渡す
    if (_selectedDay != nil){
        [self calendarGridViewDidSelectGrid:nil];
    }
}


- (void)setCalMonth:(CalMonth *)calMonth {
    [self recycleAllGridViews];
    if (_calMonth){
        _calMonth = nil;
    }
    _calMonth = calMonth;
    self.selectedDay = [self getFirstSelectedAvailableDay];
    _firstLayout = TRUE;
    [self setNeedsLayout];
}

- (void)setMinimumDate:(NSDate *)minimumDate {
    _minimumDate = minimumDate;
    _minimumDay = [[CalDay alloc] initWithDate:_minimumDate];
    _firstLayout = TRUE;
    [self recycleAllGridViews];
    [self setNeedsLayout];
}

- (void)setMaximumDate:(NSDate *)maximumDate {
    if (_maximumDate){
        _maximumDate = nil;
    }
    _maximumDate = maximumDate;
    if (_maximumDay){
        _maximumDay = nil;
    }
    _maximumDay = [[CalDay alloc] initWithDate:_maximumDate];

    _firstLayout = TRUE;
    [self recycleAllGridViews];
    [self setNeedsLayout];
}

- (NSUInteger)getRows {
    NSUInteger offsetRow = [[_calMonth firstDay] getWeekDay] - 1;
    NSUInteger row = (offsetRow + _calMonth.days - 1) / NUMBER_OF_DAYS_IN_WEEK;
    return row + 1;
}

- (NSUInteger)getMonthDayAtRow:(NSUInteger)row column:(NSUInteger)column {
    NSUInteger offsetRow = [[_calMonth firstDay] getWeekDay] - 1;
    NSUInteger day = (row * NUMBER_OF_DAYS_IN_WEEK + 1 - offsetRow) + column;
    return day;
}

- (BOOL)isValidGridViewIndex:(GridIndex)index {
    BOOL valid = TRUE;
    if (index.column < 0 ||
        index.row < 0 ||
        index.column >= NUMBER_OF_DAYS_IN_WEEK ||
        index.row >= [self getRows]){
        valid = FALSE;
    }
    return valid;
}

- (GridIndex)getGridViewIndex:(CalendarScrollView *)calendarScrollView touches:(NSSet *)touches {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:calendarScrollView];
    GridIndex index;
    NSInteger row = (location.y - MARGIN_TOP + PADDING_VERTICAL) / (PADDING_VERTICAL + _gridSize.height);
    NSInteger column = (location.x - MARGIN_LEFT + PADDING_HORIZONTAL) / (PADDING_HORIZONTAL + _gridSize.width);
    ITTDINFO(@"row %d column %d", row, column);
    index.row = row;
    index.column = column;
    return index;
}

- (NSString *)findMonthDescription {
    NSString *title = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendarView:titleForMonth:)]){
        title = [_dataSource calendarView:self titleForMonth:_calMonth];
    }
    if (!title || ![title length]){
        title = [NSString stringWithFormat:@"%d年%d月", [_calMonth getYear], [_calMonth getMonth]];
    }
    return title;
}

- (NSArray *)findWeekTitles {
    NSArray *titles = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(weekTitlesForCalendarView:)]){
        titles = [_dataSource weekTitlesForCalendarView:self];
    }
    if (!titles || ![titles count]){
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setCalendar:[NSCalendar currentCalendar]];
        [formatter setLocale:[NSLocale currentLocale]];
        NSArray *daySymbols = [formatter shortWeekdaySymbols];
        titles = daySymbols;
    }
    return titles;
}

- (void)recycleAllGridViews {
    /*
     * recycled all grid views
     */
    NSMutableSet *recycledGridSet;
    for (NSMutableArray *rowGridViewsArray in _gridViewsArray){
        for (CalendarGridView *gridView in rowGridViewsArray){
            recycledGridSet = [_recycledGridSetDic objectForKey:gridView.identifier];
            if (!recycledGridSet){
                recycledGridSet = [[NSMutableSet alloc] init];
                [_recycledGridSetDic setObject:recycledGridSet forKey:gridView.identifier];
            }
            gridView.selected = FALSE;
            [gridView removeFromSuperview];
            [recycledGridSet addObject:gridView];
        }
        [rowGridViewsArray removeAllObjects];
    }
    [_monthGridViewsArray removeAllObjects];
}

- (CalendarGridView *)getGridViewAtRow:(NSUInteger)row column:(NSUInteger)column {
    CalendarGridView *gridView = nil;
    NSMutableArray *rowGridViewsArray = [_gridViewsArray objectAtIndex:row];
    gridView = [rowGridViewsArray objectAtIndex:column];
    return gridView;
}

- (BOOL)isGridViewSelectedEnableAtRow:(NSUInteger)row column:(NSUInteger)column {
    BOOL selectedEnable = TRUE;
    NSUInteger day = [self getMonthDayAtRow:row column:column];
    if (day < 1 || day > _calMonth.days){
        selectedEnable = FALSE;
    }
    else {
        CalDay *calDay = [_calMonth calDayAtDay:day];
        ITTDINFO(@"day is %d", day);
        if ([self isEarlierMinimumDay:calDay] || [self isAfterMaximumDay:calDay]){
            selectedEnable = FALSE;
        }
    }
    return selectedEnable;
}

- (void)resetSelectedIndicesMatrix {
    NSInteger n = 6;
    for (NSInteger row = 0 ;row < n ;row++){
        memset(_selectedIndicesMatrix[row], FALSE, NUMBER_OF_DAYS_IN_WEEK);
        memset(_focusMatrix[row], FALSE, NUMBER_OF_DAYS_IN_WEEK);
    }
}

- (void)resetFocusMatrix {
    NSInteger n = 6;
    for (NSInteger row = 0 ;row < n ;row++){
        memset(_focusMatrix[row], FALSE, NUMBER_OF_DAYS_IN_WEEK);
    }
}

/*
 * update grid state
 */
- (void)updateSelectedGridViewState {
    CalendarGridView *gridView = nil;
    NSInteger rows = [self getRows];
    for (NSInteger row = 0 ;row < rows ;row++){
        for (NSInteger column = 0 ;column < NUMBER_OF_DAYS_IN_WEEK ;column++){
            gridView = [self getGridViewAtRow:row column:column];
            /*
             * grid selected status and current seleted status are different
             */
            if (gridView.selected ^ _selectedIndicesMatrix[row][column]){
                gridView.selected = _selectedIndicesMatrix[row][column];
            }
        }
    }
}

- (BOOL)isEarlierMinimumDay:(CalDay *)calDay {
    BOOL early = FALSE;
    if (self.minimumDate != nil){
        if (NSOrderedAscending == [calDay compare:_minimumDay]){
            early = TRUE;
        }
    }
    return early;
}

- (BOOL)isAfterMaximumDay:(CalDay *)calDay {
    BOOL after = FALSE;
    if (_maximumDate){
        if (NSOrderedDescending == [calDay compare:_maximumDay]){
            after = TRUE;
        }
    }
    ITTDINFO(@"calday %@ is after maximuday %@ %d", calDay, _maximumDay, after);
    return after;

}

- (void)removeGridViewAtRow:(NSUInteger)row column:(NSUInteger)column {
    NSMutableArray *rowGridViewsArray = [_gridViewsArray objectAtIndex:row];
    if (column < [rowGridViewsArray count]){
        [rowGridViewsArray removeObjectAtIndex:column];
    }
}

- (void)addGridViewAtRow:(CalendarGridView *)gridView row:(NSUInteger)row
        column:(NSUInteger)column {
    NSMutableArray *rowGridViewsArray = [_gridViewsArray objectAtIndex:row];
    NSInteger count = [rowGridViewsArray count];
    if (column > count || column < count){
        if (column > count){
            NSInteger offsetCount = column - count + 1;
            for (NSInteger offset = 0 ;offset < offsetCount ;offset++){
                [rowGridViewsArray addObject:[NSNull null]];
            }
        }
        [rowGridViewsArray replaceObjectAtIndex:column withObject:gridView];
    }
    else if (column == count){
        [rowGridViewsArray insertObject:gridView atIndex:column];
    }
}

- (void)layoutGridCells {
    BOOL hasSelectedDay = FALSE;
    NSInteger count;
    NSInteger row = 0;
    NSInteger column = 0;
    CGFloat maxHeight = 0;
    CGFloat maxWidth = 0;
    CGRect frame;
    CalDay *calDay;
    CalendarGridView *gridView = nil;
    /*
     * layout grid view before selected month on calendar view
     */
    calDay = [_calMonth firstDay];
    if ([calDay getWeekDay] > 1){
        count = [calDay getWeekDay];
        CalMonth *previousMonth = [_calMonth previousMonth];
        row = 0;
        for (NSInteger day = previousMonth.days ;count > 0 && day >= 1 ;day--){
            calDay = [previousMonth calDayAtDay:day];
            column = [calDay getWeekDay] - 1;
            gridView = [self findDisableGridViewAtRow:row column:column calDay:calDay];
            if (gridView == nil){
                count--;
                continue;
            }
            gridView.delegate = self;
            gridView.calDay = calDay;
            gridView.row = row;
            gridView.column = column;
            frame = [self getFrameForRow:row column:column];
            gridView.frame = frame;
            [gridView setNeedsLayout];
            [self.gridScrollView addSubview:gridView];
            [self addGridViewAtRow:gridView row:row column:column];
            count--;
        }
    }
    NSUInteger offsetRow = [[_calMonth firstDay] getWeekDay] - 1;
    for (NSInteger day = 1 ;day <= _calMonth.days ;day++){
        calDay = [_calMonth calDayAtDay:day];
        row = (offsetRow + day - 1) / NUMBER_OF_DAYS_IN_WEEK;
        column = [calDay getWeekDay] - 1;
        gridView = [self findGridViewAtRow:row column:column calDay:calDay];
        if (gridView == nil){
            continue;
        }
        gridView.delegate = self;
        gridView.calDay = calDay;
        gridView.row = row;
        gridView.column = column;
        gridView.selectedEnable = ([self isEarlierMinimumDay:calDay] || [self isAfterMaximumDay:calDay]) ? FALSE : TRUE;
        if ([calDay isEqualToDay:self.selectedDay]){
            hasSelectedDay = TRUE;
            gridView.selected = TRUE;
            _selectedIndicesMatrix[row][column] = TRUE;
        }
        frame = [self getFrameForRow:row column:column];
        gridView.frame = frame;
        [gridView setNeedsLayout];
        [self.gridScrollView addSubview:gridView];
        [_monthGridViewsArray addObject:gridView];
        [self addGridViewAtRow:gridView row:row column:column];
        if (CGRectGetMaxX(frame) > maxWidth){
            maxWidth = CGRectGetMaxX(frame);
        }
        if (CGRectGetMaxY(frame) > maxHeight){
            maxHeight = CGRectGetMaxY(frame);
        }
    }
    if (!hasSelectedDay && [_monthGridViewsArray count] > 0){
        CalendarGridView *selectedGridView = [_monthGridViewsArray objectAtIndex:0];
        _selectedIndicesMatrix[selectedGridView.row][selectedGridView.column] = TRUE;
        selectedGridView.selected = TRUE;
    }
    self.gridScrollView.contentSize = CGSizeMake(maxWidth, maxHeight + 5);
    /*
     * layout grid view after selected month on calendar view
     */
    calDay = [_calMonth lastDay];
    if ([calDay getWeekDay] < NUMBER_OF_DAYS_IN_WEEK){
        NSUInteger days = NUMBER_OF_DAYS_IN_WEEK - [calDay getWeekDay];
        CalMonth *previousMonth = [_calMonth nextMonth];
        for (NSInteger day = 1 ;day <= days ;day++){
            calDay = [previousMonth calDayAtDay:day];
            column = [calDay getWeekDay] - 1;
            gridView = [self findDisableGridViewAtRow:row column:column calDay:calDay];
            if (gridView == nil){
                continue;
            }
            gridView.delegate = self;
            gridView.calDay = calDay;
            gridView.row = row;
            gridView.column = column;
            frame = [self getFrameForRow:row column:column];
            gridView.frame = frame;
            [gridView setNeedsLayout];
            [self.gridScrollView addSubview:gridView];
            [self addGridViewAtRow:gridView row:row column:column];
        }
    }
}

- (CGRect)getFrameForRow:(NSUInteger)row column:(NSUInteger)column {
    CGFloat x = MARGIN_LEFT + (column - 1) * PADDING_HORIZONTAL + column * _gridSize.width;
    CGFloat y = MARGIN_TOP + (row - 1) * PADDING_VERTICAL + row * _gridSize.height;
    CGRect frame = CGRectMake(x, y, _gridSize.width, _gridSize.height);
    return frame;
}

- (CalDay *)getFirstSelectedAvailableDay {
    CalDay *selectedCalDay = nil;
    for (NSInteger day = 1 ;day <= _calMonth.days ;day++){
        CalDay *calDay = [_calMonth calDayAtDay:day];
        if ([calDay isToday]){
            selectedCalDay = calDay;
            break;
        }
    }
    if (!selectedCalDay){
        selectedCalDay = [_calMonth firstDay];
    }
    return selectedCalDay;
}

- (CalendarViewHeaderView *)findHeaderView {
    CalendarViewHeaderView *headerView = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(headerViewForCalendarView:)]){
        headerView = [_dataSource headerViewForCalendarView:self];
    }
    return headerView;
}

- (CalendarWeekHintView *)findWeekHintView {
    CalendarWeekHintView *weekHintView = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(weekHintViewForCalendarView:)]){
        weekHintView = [_dataSource weekHintViewForCalendarView:self];
    }
    return weekHintView;
}

- (CalendarViewFooterView *)findFooterView {
    CalendarViewFooterView *footerView = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(footerViewForCalendarView:)]){
        footerView = [_dataSource footerViewForCalendarView:self];
    }
    return footerView;
}

- (CalendarGridView *)findGridViewAtRow:(NSUInteger)row column:(NSUInteger)column calDay:(CalDay *)calDay {
    CalendarGridView *gridView = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendarView:calendarGridViewForRow:column:calDay:)]){
        gridView = [_dataSource calendarView:self calendarGridViewForRow:row column:column calDay:calDay];
    }
    return gridView;
}

- (CalendarGridView *)findDisableGridViewAtRow:(NSUInteger)row column:(NSUInteger)column calDay:(CalDay *)calDay {
    CalendarGridView *gridView = nil;
    if (_dataSource && [_dataSource respondsToSelector:@selector(calendarView:calendarDisableGridViewForRow:column:calDay:)]){
        gridView = [_dataSource calendarView:self calendarDisableGridViewForRow:row column:column calDay:calDay];
    }
    return gridView;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (!self){
        return nil;
    }

    return self;
}

- (CalendarGridView *)dequeueCalendarGridViewWithIdentifier:(NSString *)identifier {
    CalendarGridView *gridView = nil;
    NSMutableSet *recycledGridSet = [_recycledGridSetDic objectForKey:identifier];
    if (recycledGridSet){
        gridView = [recycledGridSet anyObject];
        if (gridView){
            [recycledGridSet removeObject:gridView];
        }
    }
    return gridView;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/
- (BOOL)appear {
    return (self.alpha > 0);
}

- (void)animationChangeMonth:(BOOL)next {
//    CATransition *animation = [CATransition animation];
//    animation.type = kCATransitionPush;
//    if (next)
//    {
//        animation.subtype = kCATransitionFromLeft;
//        [self.gridScrollView.layer addAnimation:animation forKey:@"NextMonth"];
//    }
//    else
//    {
//        animation.subtype = kCATransitionFromRight;
//        [self.gridScrollView.layer addAnimation:animation forKey:@"PreviousMonth"];
//    }
    UIViewAnimationTransition options;
    if (next){
        options = UIViewAnimationTransitionCurlUp;
    }
    else {
        options = UIViewAnimationTransitionCurlDown;
    }
    _calendarHeaderView.nextMonthButton.userInteractionEnabled = FALSE;
    _calendarHeaderView.previousMonthButton.userInteractionEnabled = FALSE;
    CalMonth *month = nil;
    if (next){
        month = [_calMonth nextMonth];
    }
    else {
        month = [_calMonth previousMonth];
    }
    if (_date){
        _date = nil;
    }
    _date = [month firstDay].date;
    self.calMonth = month;
    [UIView animateWithDuration:0.3 animations:^{
        [UIView setAnimationTransition:options forView:self.gridScrollView cache:TRUE];
    } completion:^(BOOL finished) {
        if (finished){
            _calendarHeaderView.nextMonthButton.userInteractionEnabled = TRUE;
            _calendarHeaderView.previousMonthButton.userInteractionEnabled = TRUE;
        }
    }];
}

- (void)nextMonth {
    [self resetSelectedIndicesMatrix];
    [self animationChangeMonth:TRUE];
}

- (void)previousMonth {
    [self resetSelectedIndicesMatrix];
    [self animationChangeMonth:FALSE];
}

- (void)layoutSubviews {
    if (_dataSource && _firstLayout){
        [self layoutGridCells];
        /*
         * layout header view
         */
        if (!_calendarHeaderView){
            CalendarViewHeaderView *calendarHeaderView = [self findHeaderView];
            if (calendarHeaderView){
                if (_calendarHeaderView){
                    [_calendarHeaderView removeFromSuperview];
                }
                CGRect frame = calendarHeaderView.bounds;
                frame.origin.x = (CGRectGetWidth(self.headerView.bounds) - CGRectGetWidth(frame)) / 2;
                frame.origin.y = (CGRectGetHeight(self.headerView.bounds) - CGRectGetHeight(frame)) / 2;
                calendarHeaderView.delegate = self;
                calendarHeaderView.frame = frame;
                _calendarHeaderView = calendarHeaderView;
                [self.headerView addSubview:_calendarHeaderView];
            }
        }
        /*
         * layout footer view
         */
        if (!_calendarFooterView){
            CalendarViewFooterView *calendarFooterView = [self findFooterView];
            if (calendarFooterView){
                if (_calendarFooterView){
                    [_calendarFooterView removeFromSuperview];
                }
                CGRect frame = calendarFooterView.bounds;
                frame.origin.x = (CGRectGetWidth(self.footerView.bounds) - CGRectGetWidth(frame)) / 2;
                frame.origin.y = (CGRectGetHeight(self.footerView.bounds) - CGRectGetHeight(frame)) / 2;
                calendarFooterView.delegate = self;
                calendarFooterView.frame = frame;
                _calendarFooterView = calendarFooterView;
                [self.footerView addSubview:_calendarFooterView];
            }
        }
        /*
         * layout week hint labels
         */

        for (UIView *subview in self.weekHintView.subviews){
            /*
             * subview is not background imageview
             */
            if (![subview isKindOfClass:[UIImageView class]]){
                [subview removeFromSuperview];
            }
        }
        CGFloat totalWidth = self.gridScrollView.contentSize.width;
        CGFloat width = totalWidth / NUMBER_OF_DAYS_IN_WEEK;
        CGFloat marginX = 0;
        NSArray *titles = [self findWeekTitles];
        for (NSInteger i = 0 ;i < NUMBER_OF_DAYS_IN_WEEK ;i++){
            // 曜日のラベルボタン
            CalendarWeekHintView *weekHintView = [self findWeekHintView];
            weekHintView.frame = CGRectMake(marginX, 0, width, CGRectGetHeight(self.weekHintView.bounds));
            [weekHintView setTitle:[titles objectAtIndex:i]];
            enum ZHJ_DayOfWeek week = (enum ZHJ_DayOfWeek) i;
            [weekHintView setDayOfWeek:week];// 0,1... == Sun,Mon,....
            [weekHintView setNeedsLayout];
            [self.weekHintView addSubview:weekHintView];
            marginX += width;
        }
        _firstLayout = FALSE;
    }
    _calendarHeaderView.title = [self findMonthDescription];
}

- (void)swipe:(UISwipeGestureRecognizer *)gesture {
    if (UISwipeGestureRecognizerDirectionLeft == gesture.direction){
        [self nextMonth];
    }
    else {
        [self previousMonth];
    }
}


- (void)awakeFromNib {
    [super awakeFromNib];
    self.alpha = 0.0;
    self.multipleTouchEnabled = TRUE;
    self.gridScrollView.calendarDelegate = self;
    [self initParameters];
//    /*
//     * add left and right swipe gesture
//     */
//    UISwipeGestureRecognizer *leftSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
//    leftSwipeGesture.direction = UISwipeGestureRecognizerDirectionLeft;
//    [self addGestureRecognizer:leftSwipeGesture];
//    [leftSwipeGesture release];
//
//    UISwipeGestureRecognizer *rightSwipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipe:)];
//    rightSwipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
//    [self addGestureRecognizer:rightSwipeGesture];
//    [rightSwipeGesture release];
}

- (NSDate *)selectedDate {
    return self.selectedDay.date;
}

- (NSArray *)selectedDateArray {
    if (!_allowsMultipleSelection){
        return nil;
    }
    else {
        NSUInteger rows = [self getRows];
        NSMutableArray *selectedDates = [NSMutableArray array];
        for (NSUInteger row = 0 ;row < rows ;row++){
            for (NSUInteger column = 0 ;column < NUMBER_OF_DAYS_IN_WEEK ;column++){
                if (_selectedIndicesMatrix[row][column]){
                    NSUInteger day = [self getMonthDayAtRow:row column:column];
                    CalDay *calDay = [_calMonth calDayAtDay:day];
                    [selectedDates addObject:calDay.date];
                    ITTDINFO(@"selected day %d", day);
                }
            }
        }
        return selectedDates;
    }
}

+ (id)viewFromNib {
    return [[[NSBundle mainBundle] loadNibNamed:@"CalendarView" owner:self options:nil] objectAtIndex:0];
}

- (void)dealloc {
    [self freeMatrix];
    _delegate = nil;
    _calendarHeaderView = nil;
    _recycledGridSetDic = nil;
    _gridViewsArray = nil;
    _monthGridViewsArray = nil;
    _minimumDay = nil;
    _maximumDay = nil;
}
#pragma mark - CalendarViewHeaderViewDelegate
- (void)calendarViewHeaderViewNextMonth:(CalendarViewHeaderView *)calendarHeaderView {
    [self nextMonth];
}

- (void)calendarViewHeaderViewPreviousMonth:(CalendarViewHeaderView *)calendarHeaderView {
    [self previousMonth];
}

- (void)calendarViewHeaderViewDidCancel:(CalendarViewHeaderView *)calendarHeaderView {
    [self hide];
}

- (void)calendarViewHeaderViewDidSelection:(CalendarViewHeaderView *)calendarHeaderView {
    if (_delegate && [_delegate respondsToSelector:@selector(calendarViewDidSelectDay:calDay:)]){
        [_delegate calendarViewDidSelectDay:self calDay:self.selectedDay];
    }
    [self hide];
}
#pragma mark - CalendarViewFooterViewDelegate
- (void)calendarViewFooterViewDidSelectPeriod:(CalendarViewFooterView *)footerView periodType:(PeriodType)type {
    self.selectedPeriod = type;
    if (_delegate && [_delegate respondsToSelector:@selector(calendarViewDidSelectPeriodType:periodType:)]){
        [_delegate calendarViewDidSelectPeriodType:self periodType:type];
    }
}
#pragma mark - CalendarGridViewDelegate
- (void)calendarGridViewDidSelectGrid:(CalendarGridView *)gridView {
    if (_delegate && [_delegate respondsToSelector:@selector(calendarViewDidSelectDay:calDay:)]){
        [_delegate calendarViewDidSelectDay:self calDay:self.selectedDay];
    }
}

- (void)hide:(BOOL)animated {
    [UIView animateWithDuration:0.3 animations:^{
        [self hide];
    }];
}

- (void)hide {
    if (_shieldView != nil){
        _shieldView.alpha = 0.0;
    }
    self.alpha = 0.0;
}

- (void)show:(BOOL)animated {
    [UIView animateWithDuration:0.4 animations:^{
        [self show];
    }];
}

- (void)show {
    self.alpha = 1.0;
    if (_shieldView != nil){
        _shieldView.alpha = 0.6;
    }
}

- (void)showInView:(UIView *)view {
    [self addShieldInView:view];
    if (![self isDescendantOfView:view]){
        [view addSubview:self];
    }
    [self show:YES];
}

- (void)addShieldInView:(UIView *)view {
    if (!_shieldView){
        _shieldView = [[UIView alloc] initWithFrame:view.bounds];
        _shieldView.alpha = 0.0;
        _shieldView.backgroundColor = [UIColor whiteColor];
        [view addSubview:_shieldView];
    } else if (![_shieldView isDescendantOfView:view]){
        _shieldView.alpha = 0.0;
        [_shieldView removeFromSuperview];
        _shieldView.frame = view.bounds;
        [view addSubview:_shieldView];
    }
}

#pragma mark - CalendarScrollViewDelegate
- (void)calendarScrollViewTouchesBegan:(CalendarScrollView *)calendarScrollView touches:(NSSet *)touches
        withEvent:(UIEvent *)event {
    _moved = FALSE;
    UITouch *beginTouch = [touches anyObject];
    _beginTimeInterval = beginTouch.timestamp;
    _beginPoint = [beginTouch locationInView:calendarScrollView];
}

- (void)calendarScrollViewTouchesMoved:(CalendarScrollView *)calendarScrollView touches:(NSSet *)touches
        withEvent:(UIEvent *)event {
    _moved = TRUE;
    GridIndex index = [self getGridViewIndex:calendarScrollView touches:touches];
    if ([self isValidGridViewIndex:index]){
        if (_allowsMultipleSelection){
            BOOL selectedEnable = FALSE;
            /*
             * the grid is on unselected state
             */
            if (!_selectedIndicesMatrix[index.row][index.column]){
                [self resetFocusMatrix];
                _focusMatrix[index.row][index.column] = TRUE;
                selectedEnable = !_selectedIndicesMatrix[index.row][index.column];
                selectedEnable = (selectedEnable & [self isGridViewSelectedEnableAtRow:index.row column:index.column]);
                _selectedIndicesMatrix[index.row][index.column] = selectedEnable;
            }
        }
        else {
            //do nothing
        }
        _previousSelectedIndex = index;
        [self updateSelectedGridViewState];
    }
}

- (void)calendarScrollViewTouchesEnded:(CalendarScrollView *)calendarScrollView touches:(NSSet *)touches
        withEvent:(UIEvent *)event {
    GridIndex index = [self getGridViewIndex:calendarScrollView touches:touches];
    if ([self isValidGridViewIndex:index]){
        BOOL selectedEnable = TRUE;
        if (!_moved){
            if (!_allowsMultipleSelection){
                [self resetSelectedIndicesMatrix];
                selectedEnable = TRUE;
                selectedEnable = selectedEnable & [self isGridViewSelectedEnableAtRow:index.row column:index.column];
                _selectedIndicesMatrix[index.row][index.column] = selectedEnable;
            }
            else {
                selectedEnable = _selectedIndicesMatrix[index.row][index.column];
                _selectedIndicesMatrix[index.row][index.column] = !selectedEnable;
            }
        }
        [self updateSelectedGridViewState];
        if (!_allowsMultipleSelection){
            if (!_moved){
                NSInteger day = [self getMonthDayAtRow:index.row column:index.column];
                if (day >= 1 && day <= _calMonth.days){
                    self.selectedDay = [_calMonth calDayAtDay:day];
                }
            }
        }
    }
    UITouch *endTouch = [touches anyObject];
    if (endTouch.timestamp - _beginTimeInterval <= SWIPE_TIMER_INTERVAL){
        CGPoint endPoint = [endTouch locationInView:calendarScrollView];
        if (fabs(endPoint.y - _beginPoint.y) < HORIZONTAL_SWIPE_HEIGHT_CONSTRAINT){
            if (fabs(endPoint.x - _beginPoint.x) > HORIZONTAL_SWIPE_WIDTH_CONSTRAINT){
                //swipe right
                if (endPoint.x > _beginPoint.x){
                    [self previousMonth];
                }
                else {
                    [self nextMonth];
                }
            }
        }
    }
}
@end
