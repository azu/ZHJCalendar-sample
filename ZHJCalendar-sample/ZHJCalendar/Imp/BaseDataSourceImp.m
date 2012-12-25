//
//  BaseDataSourceImp.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 Sword.Zhou. All rights reserved.
//

#import "BaseDataSourceImp.h"
#import "BaseCalendarGridView.h"
#import "BaseCalendarDisableGridView.h"
#import "BaseCalendarViewHeaderView.h"
#import "CalMonth.h"
#import "CalendarWeekHintView.h"
#import "BaseCalendarWeekHintView.h"

@implementation BaseDataSourceImp

- (void)updateVisibleCells {
    // セルの表示更新
}

- (void)updateGridView:(CalendarGridView *)calendarView calendarGridViewForRow:(NSInteger)row
        column:(NSInteger)column calDay:(CalDay *)calDay {
    BaseCalendarGridView *gridView = (BaseCalendarGridView *) calendarView;
    // セルのアイコンを表示するかを制御する
    if (row % 2 == 0){
        gridView.iconImageView.hidden = YES;
    } else{
        gridView.iconImageView.hidden = NO;
    }
}

- (CalendarGridView *)calendarView:(CalendarView *)calendarView calendarGridViewForRow:(NSInteger)row
                      column:(NSInteger)column calDay:(CalDay *)calDay {
    static NSString *identifier = @"BaseCalendarGridView";
    CalendarGridView *gridView = [calendarView dequeueCalendarGridViewWithIdentifier:identifier];
    if (!gridView){
        gridView = [BaseCalendarGridView viewFromNibWithIdentifier:identifier];
    }
    [self updateGridView:gridView calendarGridViewForRow:row column:column calDay:calDay];
    return gridView;
}

- (CalendarGridView *)calendarView:(CalendarView *)calendarView calendarDisableGridViewForRow:(NSInteger)row
                      column:(NSInteger)column calDay:(CalDay *)calDay {
    static NSString *identifier = @"BaseCalendarDisableGridView";
    CalendarGridView *gridView = [calendarView dequeueCalendarGridViewWithIdentifier:identifier];
    if (!gridView){
        gridView = [BaseCalendarDisableGridView viewFromNibWithIdentifier:identifier];
    }
    return gridView;
}

- (CalendarViewHeaderView *)headerViewForCalendarView:(CalendarView *)calendarView {
    return [BaseCalendarViewHeaderView viewFromNib];
}

// Sun,Mon,Tsu ... カレンダーの曜日部分
- (CalendarWeekHintView *)weekHintViewForCalendarView:(CalendarView *)calendarView {
    return [BaseCalendarWeekHintView viewFromNib];
}
//- (NSArray *)weekTitlesForCalendarView:(CalendarView *)calendarView {
//    return [NSArray arrayWithObjects:@"日", @"月", @"火", @"水", @"木", @"金", @"土", nil];
//}

- (NSString *)calendarView:(CalendarView *)calendarView titleForMonth:(CalMonth *)calMonth {
    NSString *title = [NSString stringWithFormat:@"%d/%d", [calMonth getYear], [calMonth getMonth]];
    return title;
}
@end
