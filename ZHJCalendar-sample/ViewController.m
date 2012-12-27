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
    // カレンダーを読み込んで表示する
    [self loadCalendarView];
}

- (void)loadCalendarView {
    if (self.calendarView == nil){
        BaseDataSourceImp *dataSource = [[BaseDataSourceImp alloc] init];
        self.calendarView = [CalendarView viewFromNib];
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
    NSLog(@"選択した日付 = %@", self.selectDate);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // 更新し直す
    [self.calendarView updateCalendar];
}

@end
