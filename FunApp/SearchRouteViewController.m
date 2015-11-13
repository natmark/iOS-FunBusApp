//
//  SearchRouteViewController.m
//  FunApp
//
//  Created by Atsuya Sato on 2015/11/12.
//  Copyright © 2015年 Atsuya Sato. All rights reserved.
//

#import "SearchRouteViewController.h"

@interface SearchRouteViewController ()

@end

@implementation SearchRouteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSDictionary* getOn = [[BusSearchManager sharedManager]GetOnBusStop];
    NSDictionary* getOff = [[BusSearchManager sharedManager]GetOffBusStop];
    
    NSLog(@"乗車バス停:%@",[getOn objectForKey:@"name"]);
    NSLog(@"降車バス停:%@",[getOff objectForKey:@"name"]);

    if(getOn && getOff){
        [[BusSearchManager sharedManager]isSystemMeintenanceWithcompletionHandler:^(BOOL meintenanceFlg){
            if(!meintenanceFlg){
                [[BusSearchManager sharedManager]isExistRouteWithGetOn:[[getOn objectForKey:@"code"]intValue] getOff:[[getOff objectForKey:@"code"]intValue] completionHandler:^(BOOL flg){
                    if(flg){
                        NSLog(@"直通路線はあります。");
                        [[BusSearchManager sharedManager]isOutOfServiceWithGetOn:[[getOn objectForKey:@"code"]intValue] getOff:[[getOff objectForKey:@"code"]intValue] completionHandler:^(BOOL flg2){
                            if(!flg2){
                                NSLog(@"バスあります");
                                [[BusSearchManager sharedManager]GETRouteSearchResultWithGetOn:[[getOn objectForKey:@"code"]intValue] GetOff:[[getOff objectForKey:@"code"]intValue] completionHandler:^(NSArray* array){
                                    NSLog(@"時間:%@",[[array objectAtIndex:0]objectForKey:@"time"]);
                                    NSLog(@"行き先:%@",[[array objectAtIndex:0]objectForKey:@"destination"]);
                                    NSLog(@"遅延情報:%@",[[array objectAtIndex:0]objectForKey:@"detail"]);
                                    NSLog(@"URL:%@",[[array objectAtIndex:0]objectForKey:@"url"]);
                                    [[BusSearchManager sharedManager]GETArrivedTimeWithURL:[[array objectAtIndex:0]objectForKey:@"url"] completionHandler:^(NSArray* array2){
                                        for(NSDictionary* dict in array2){
                                            if([[dict objectForKey:@"name"] isEqualToString:[getOff objectForKey:@"name"]]
                                               ){
                                                NSLog(@"バス停到着時間:%@",[dict objectForKey:@"time"]);
                                            }
                                        }
                                    }];
                                }];
                                
                            }else{
                                NSLog(@"営業時間終了");
                            }
                        }];
                    }else{
                        NSLog(@"直通路線はありません。");
                    }
                }];
            }else{
                NSLog(@"システムメンテナンス中");
            }
        }];
    }
}
/*[{
 if(存在){
 [{検索して、Arrayを取得}]
 }else{
 for(){
 [{
 if(存在){
 {[
 if(存在){
 配列に追加
 }
 ]}
 }else{
 }
 }]
 }
 }
 }]
 */

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
