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

@implementation BaseDataSourceImp

- (void)updateVisibleCells {
    // セルの表示更新
}

- (void)updateGridView:(CalendarGridView *)calendarView calendarGridViewForRow:(NSInteger)row
        column:(NSInteger)column calDay:(CalDay *)calDay {
    BaseCalendarGridView *gridView = (BaseCalendarGridView *) calendarView;

    if (row % 2 == 0 && column % 3 == 0){
        [gridView.checkDoseImageView setImage:[UIImage imageNamed:@"icon_drugcheck_calendar.png"]];
        [gridView.checkDoseImageView setHidden:NO];
    } else {
        [gridView.checkDoseImageView setHidden:YES];
    }
    if (row % 4 == 0){
        [gridView.conditionImageView setImage:[UIImage imageNamed:@"icon_record_calendar.png"]];
        [gridView.conditionImageView setHidden:NO];
    } else {
        [gridView.conditionImageView setHidden:YES];
    }

    if (row % 5 == 0){
        [gridView.visitHospitalImageView setImage:[UIImage imageNamed:@"icon_hospital_calendar.png"]];
        [gridView.visitHospitalImageView setHidden:NO];
    } else {
        [gridView.visitHospitalImageView setHidden:YES];
    }

    if (row % 6 == 0){
        [gridView.seizureImageView setImage:[UIImage imageNamed:@"icon_fit_calendar.png"]];
        [gridView.seizureImageView setHidden:NO];
    } else {
        [gridView.seizureImageView setHidden:YES];
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

//- (NSArray *)weekTitlesForCalendarView:(CalendarView *)calendarView {
//    return [NSArray arrayWithObjects:@"日", @"月", @"火", @"水", @"木", @"金", @"土", nil];
//}

- (NSString *)calendarView:(CalendarView *)calendarView titleForMonth:(CalMonth *)calMonth {
    NSString *title = [NSString stringWithFormat:@"%d/%d", [calMonth getYear], [calMonth getMonth]];
    return title;
}
@end
