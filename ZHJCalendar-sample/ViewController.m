//
//  ViewController.m
//  ZHJCalendar-sample
//
//  Created by azu on 12/12/14.
//  Copyright (c) 2012年 plusr. All rights reserved.
//

#import "ViewController.h"
#import "BaseDataSourceImp.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)loadView {
    [super loadView];
    [self loadCalendarView];
}

- (void)loadCalendarView {
    if (self.calendarView == nil){
        BaseDataSourceImp *dataSource = [[BaseDataSourceImp alloc] init];
        self.calendarView = [CalendarView viewFromNib];
        // 44 + (35*6) + 28 = 282
        self.calendarView.frame = CGRectMake(0, 0, 320, self.calendarView.frame.size.height);
        self.calendarView.gridSize = CGSizeMake(45.5, 35);
        self.calendarView.dataSource = dataSource;
        self.calendarView.delegate = self;
        [self.view addSubview:self.calendarView];
    }
    [self.calendarView show];
    // calendarViewDidSelectDay:は初回は起きないので初期選択の日付を取得する
    NSDate *date = self.calendarView.selectedDate;
    self.selectDate = date;
}

- (void)calendarViewDidSelectDay:(CalendarView *)calendarView calDay:(CalDay *)calDay {
    self.selectDate = calDay.date;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
