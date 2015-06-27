//
//  TodayViewController.m
//  Widget
//
//  Created by Atsuya Sato on 2015/06/27.
//  Copyright (c) 2015年 Atsuya Sato. All rights reserved.
//

#import "TodayViewController.h"
#import <NotificationCenter/NotificationCenter.h>

@interface TodayViewController () <NCWidgetProviding>

@end

@implementation TodayViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 高さ変更
    self.preferredContentSize = CGSizeMake(0, 100);
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    label.text = @"Next";
    label.textColor = [UIColor orangeColor];
    [self.view addSubview:label];
    
    UILabel* label2 = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
    label2.text = @"函館駅前 行";
    label2.textAlignment = NSTextAlignmentCenter;
    label2.textColor = [UIColor whiteColor];
    [self.view addSubview:label2];
    
    UILabel* label3 = [[UILabel alloc]initWithFrame:CGRectMake(0, 50, self.view.frame.size.width-120, 40)];
    label3.font = [UIFont systemFontOfSize:32];
    label3.text = @"18:00";
    label3.textAlignment = NSTextAlignmentCenter;
    label3.textColor = [UIColor orangeColor];
    [self.view addSubview:label3];
    
    NSCalendar* calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* comps = [calendar components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    
    NSDateFormatter* df = [[NSDateFormatter alloc] init];
    df.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ja"];
    
    //comps.weekdayは 1-7の値が取得できるので-1する
    NSString* weekDayStr = df.shortWeekdaySymbols[comps.weekday-1];
    NSLog(@"%@",weekDayStr);
    
    // 現在日付を取得
    NSDate *now = [NSDate date];
    
    NSCalendar *calendar2 = [NSCalendar currentCalendar];
    NSUInteger flags;
    NSDateComponents *comps2;
    
    // 時・分・秒を取得
    flags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    comps2 = [calendar2 components:flags fromDate:now];
    
    NSInteger hour = comps2.hour;
    NSInteger minute = comps2.minute;
    NSInteger second = comps2.second;
    
    NSLog(@"%ld時 %ld分 %ld秒", hour, minute, second);
    NSBundle* bundle = [NSBundle mainBundle];
    //読み込むファイルパスを指定
    NSString* path = [bundle pathForResource:@"bus_data" ofType:@"plist"];
    NSDictionary* dic = [NSDictionary dictionaryWithContentsOfFile:path];
    NSDictionary* weekdayData;
    if([weekDayStr isEqualToString:@"土"] || [weekDayStr isEqualToString:@"日"]){
        weekdayData = [dic objectForKey:@"holiday"];
    }else{
        weekdayData = [dic objectForKey:@"weekday"];
    }
    
    NSArray *items =[NSArray arrayWithArray:[weekdayData objectForKey:@"dataset"]];
    
    bool flg = false;
    
    for(NSDictionary* str in items){
        if(flg == false){
            NSLog(@"%@",[str objectForKey:@"departure"]);
            NSLog(@"%@",[str objectForKey:@"destination"]);
            
            NSString *bus_hour = [[str objectForKey:@"departure"] substringToIndex:2];
            
            // ３文字目から後ろを取得
            NSString *bus_minute = [[str objectForKey:@"departure"] substringFromIndex:3];
            if((int)hour * 60 + (int)minute <= [bus_hour integerValue] * 60 + [bus_minute integerValue]){
                
                flg = true;
                label3.font = [UIFont systemFontOfSize:35];
                label3.text = [str objectForKey:@"departure"];
                label2.text = [NSString stringWithFormat:@"%@ 行",[str objectForKey:@"destination"]];
            }
        }
    }
    if(flg == false){
        label3.font = [UIFont systemFontOfSize:15];
        label3.text = @"本日の営業は終了しました。";
        label2.text = @"";
        return;
    }


}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)widgetPerformUpdateWithCompletionHandler:(void (^)(NCUpdateResult))completionHandler {
    NSLog(@"update");
    // Perform any setup necessary in order to update the view.
    
    // If an error is encountered, use NCUpdateResultFailed
    // If there's no update required, use NCUpdateResultNoData
    // If there's an update, use NCUpdateResultNewData

    completionHandler(NCUpdateResultNewData);
}

@end
