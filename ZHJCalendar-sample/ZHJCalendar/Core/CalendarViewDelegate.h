//
//  CalendarDelegate.h
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 Sword.Zhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZHJCalendar_Enum.h"
@class CalendarView;
@class CalDay;

@protocol CalendarViewDelegate <NSObject>
@optional
- (void) calendarViewDidSelectDay:(CalendarView*)calendarView calDay:(CalDay*)calDay;
- (void) calendarViewDidSelectPeriodType:(CalendarView*)calendarView periodType:(PeriodType)periodType;
@end
