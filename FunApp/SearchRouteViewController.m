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
    if(getOn && getOff){
        [[BusSearchManager sharedManager]isExistRouteWithGetOn:[[getOn objectForKey:@"code"]intValue] getOff:[[getOff objectForKey:@"code"]intValue] completionHandler:^(BOOL flg){
            if(flg){
                NSLog(@"直通路線はあります。");
                [[BusSearchManager sharedManager]isOutOfServiceWithGetOn:[[getOn objectForKey:@"code"]intValue] getOff:[[getOff objectForKey:@"code"]intValue] completionHandler:^(BOOL flg2){
                    if(!flg2){
                        NSLog(@"バスあります");
                        [[BusSearchManager sharedManager]GETRouteSearchResultWithGetOn:[[getOn objectForKey:@"code"]intValue] GetOff:[[getOff objectForKey:@"code"]intValue] completionHandler:^(NSString* data){
                            //Arrayで受け取って1つめを表示
                            //Arrayはグローバルで定義
                            //Arrayのindexを保存する変数をグローバルで取得
                            //到着時間を取得する関数も必要かも
                        }];

                    }else{
                        NSLog(@"営業時間終了");
                    }
                }];
            }else{
                NSLog(@"直通路線はありません。");
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
