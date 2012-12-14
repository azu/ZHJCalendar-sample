//
//  BaseCalendarGridView.h
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 Sword.Zhou. All rights reserved.
//

#import "CalendarGridView.h"

@interface BaseCalendarGridView : CalendarGridView

@property(weak, nonatomic) IBOutlet UIImageView *checkDoseImageView;
@property(weak, nonatomic) IBOutlet UIImageView *conditionImageView;
@property(weak, nonatomic) IBOutlet UIImageView *visitHospitalImageView;
@property(weak, nonatomic) IBOutlet UIImageView *seizureImageView;
@end