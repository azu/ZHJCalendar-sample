//
//  ViewController.h
//  ZHJCalendar-sample
//
//  Created by azu on 12/12/14.
//  Copyright (c) 2012年 plusr. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CalendarViewDelegate.h"

@class CalendarView;

@interface ViewController : UIViewController <CalendarViewDelegate>

@property (nonatomic,strong)CalendarView *calendarView;
@property (nonatomic,strong)NSDate *selectDate;
@end
