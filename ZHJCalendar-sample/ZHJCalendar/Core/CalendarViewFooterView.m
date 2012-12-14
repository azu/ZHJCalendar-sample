//
//  CalendarViewFooterView.m
//  ZHJCalendar
//
//  Created by huajian zhou on 12-4-12.
//  Copyright (c) 2012年 Sword.Zhou. All rights reserved.
//

#import "CalendarViewFooterView.h"

@implementation CalendarViewFooterView

@synthesize selectedButton = _selectedButton;
@synthesize delegate = _delegate;

- (void) dealloc
{
    _delegate = nil;
}
+ (CalendarViewFooterView*) viewFromNib
{
    return [[[NSBundle mainBundle] loadNibNamed:[[self class] description] owner:self options:nil] objectAtIndex:0];
}
@end
