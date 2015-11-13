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
#pragma mark TODO-LIST
//TODO:バスの情報を、アプリを落としても確認できるクリップボード機能(検索結果画面・メイン画面(できればガジェットも)からコピー、保存したバス情報から確認)
//TODO:登録した路線(上下線)の直近情報を、アプリを開いて&ガジェットですぐ確認できる機能
//TODO:検索画面で、現在時刻から、最後のバスまで確認できるUI ボタン+スワイプかな？
//TODO:各種設定画面(路線登録とか、乗り継ぎ時間とか...)

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
                        /*乗り継ぎバス停を検索*/
                        /*乗り継ぎバス停は以下8つのみ*/
                        /*現状2回以上の乗り継ぎは対応しない方向で*/
                        /*
                         ・函館駅前 id:3 code:3
                         ・五稜郭 id:144 code:149
                         ・湯倉神社前 id:454 code:465
                         ・テーオーデパート前 id:357 code:363
                         ・ガス会社前 id:7 code:7
                         ・深堀町 id:361 code:367
                         ・花園町 id:450 code:461
                         ・亀田支所前 id:150 code:155
                         */
                        NSDictionary* dict1 = [[BusSearchManager sharedManager]getBusInfo:3];
                        NSDictionary* dict2 = [[BusSearchManager sharedManager]getBusInfo:144];
                        NSDictionary* dict3 = [[BusSearchManager sharedManager]getBusInfo:454];
                        NSDictionary* dict4 = [[BusSearchManager sharedManager]getBusInfo:357];
                        NSDictionary* dict5 = [[BusSearchManager sharedManager]getBusInfo:7];
                        NSDictionary* dict6 = [[BusSearchManager sharedManager]getBusInfo:361];
                        NSDictionary* dict7 = [[BusSearchManager sharedManager]getBusInfo:450];
                        NSDictionary* dict8 = [[BusSearchManager sharedManager]getBusInfo:150];
                        NSArray* candidateArray = [NSArray arrayWithObjects:dict1,dict2,dict3,dict4,dict5,dict6,dict7,dict8, nil];
                        
                        for(NSDictionary* dict in candidateArray){

                            [[BusSearchManager sharedManager]isExistRouteWithGetOn:[[getOn objectForKey:@"code"]intValue] getOff:[[dict objectForKey:@"code"]intValue] completionHandler:^(BOOL flg2){
                                if(flg2){
                                    [[BusSearchManager sharedManager]isExistRouteWithGetOn:[[dict objectForKey:@"code"]intValue] getOff:[[dict objectForKey:@"code"]intValue] completionHandler:^(BOOL flg3){
                                        if(flg3){
                                            NSLog(@"経由路線発見");
                                            //TODO:乗車バス停→経由バス停
                                            [[BusSearchManager sharedManager]isOutOfServiceWithGetOn:[[getOn objectForKey:@"code"]intValue] getOff:[[dict objectForKey:@"code"]intValue] completionHandler:^(BOOL flg4){
                                                if(!flg4){
                                                    NSLog(@"バスあります");
                                                    [[BusSearchManager sharedManager]GETRouteSearchResultWithGetOn:[[getOn objectForKey:@"code"]intValue] GetOff:[[dict objectForKey:@"code"]intValue] completionHandler:^(NSArray* array){
                                                        NSLog(@"時間:%@",[[array objectAtIndex:0]objectForKey:@"time"]);
                                                        NSLog(@"行き先:%@",[[array objectAtIndex:0]objectForKey:@"destination"]);
                                                        NSLog(@"遅延情報:%@",[[array objectAtIndex:0]objectForKey:@"detail"]);
                                                        NSLog(@"URL:%@",[[array objectAtIndex:0]objectForKey:@"url"]);
                                                        [[BusSearchManager sharedManager]GETArrivedTimeWithURL:[[array objectAtIndex:0]objectForKey:@"url"] completionHandler:^(NSArray* array2){
                                                            for(NSDictionary* dict2 in array2){
                                                                if([[dict2 objectForKey:@"name"] isEqualToString:[dict objectForKey:@"name"]]
                                                                   ){
                                                                    NSLog(@"経由バス停到着時間:%@",[dict2 objectForKey:@"time"]);
                                                                    #warning 経由バス到着時間に合わせて、array3の要素を削る
                                                                    //TODO:経由バス停→降車バス停
                                                                    [[BusSearchManager sharedManager]isOutOfServiceWithGetOn:[[dict objectForKey:@"code"]intValue] getOff:[[getOff objectForKey:@"code"]intValue] completionHandler:^(BOOL flg5){
                                                                        if(!flg5){
                                                                            NSLog(@"バスあります");
                                                                            [[BusSearchManager sharedManager]GETRouteSearchResultWithGetOn:[[dict objectForKey:@"code"]intValue] GetOff:[[getOff objectForKey:@"code"]intValue] completionHandler:^(NSArray* array3){
                                                                                NSLog(@"時間:%@",[[array3 objectAtIndex:0]objectForKey:@"time"]);
                                                                                NSLog(@"行き先:%@",[[array3 objectAtIndex:0]objectForKey:@"destination"]);
                                                                                NSLog(@"遅延情報:%@",[[array3 objectAtIndex:0]objectForKey:@"detail"]);
                                                                                NSLog(@"URL:%@",[[array3 objectAtIndex:0]objectForKey:@"url"]);
                                                                                [[BusSearchManager sharedManager]GETArrivedTimeWithURL:[[array3 objectAtIndex:0]objectForKey:@"url"] completionHandler:^(NSArray* array4){
                                                                                    for(NSDictionary* dict3 in array4){
                                                                                        if([[dict3 objectForKey:@"name"] isEqualToString:[getOff objectForKey:@"name"]]
                                                                                           ){
                                                                                            NSLog(@"バス停到着時間:%@",[dict3 objectForKey:@"time"]);
                                                                                        }
                                                                                    }
                                                                                }];
                                                                            }];
                                                                        }else{
                                                                            NSLog(@"営業時間終了");
                                                                        }
                                                                    }];
                                                                    
                                                                }
                                                            }
                                                        }];
                                                    }];
                                                    
                                                }else{
                                                    NSLog(@"営業時間終了");
                                                }
                                            }];

                                        }else{
                                            NSLog(@"直通路線なし");
                                        }
                                    }];

                                }else{
                                    NSLog(@"直通路線なし");
                                }
                            }];
                            
                        }
                        
                        
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
