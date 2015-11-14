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
    //エラー表示用
    /*==========================*/
    errorLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height / 2 - 30, self.view.frame.size.width, 60)];
    errorLabel.textColor = [UIColor colorWithRed:184/255.0 green:29/255.0 blue:31/255.0 alpha:1.0];
    errorLabel.font = [UIFont systemFontOfSize:22];
    errorLabel.hidden = true;
    errorLabel.numberOfLines = 0;
    errorLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:errorLabel];
    /*==========================*/
    
    //インジケーター
    /*==========================*/
    indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.frame = CGRectMake(0, 0, 100, 100);
    indicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    indicator.backgroundColor = [UIColor colorWithRed:184/255.0 green:29/255.0 blue:31/255.0 alpha:1.0];
    indicator.layer.cornerRadius = indicator.frame.size.width * 0.1;
    [indicator startAnimating];
    [self.view addSubview:indicator];
    /*==========================*/
    
    //経由なしの表示用
    /*==========================*/
    showCnt = 0;
    noConnectionView = [[NoConnectionView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - 20, self.view.frame.size.width - 20)];
    
    noConnectionView.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [self.view addSubview:noConnectionView];
    noConnectionView.hidden = true;
    
    leftButton = [[UIButton alloc]initWithFrame:CGRectMake(20, self.view.frame.size.height - 30, 20, 20)];
    [leftButton setTitle:@"◀︎" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [leftButton.titleLabel setFont:[UIFont systemFontOfSize:20]];
    
    [leftButton addTarget:self action:@selector(leftPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftButton];
    
    rightButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-40, self.view.frame.size.height - 30, 20, 20)];
    [rightButton setTitle:@"▶︎" forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(rightPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightButton];
    
    leftButton.hidden = true;
    rightButton.hidden = true;
    
    /*==========================*/
    

    
    // Do any additional setup after loading the view.
    NSDictionary* getOn = [[BusSearchManager sharedManager]GetOnBusStop];
    NSDictionary* getOff = [[BusSearchManager sharedManager]GetOffBusStop];
    
    self.getOnLabel.text = [getOn objectForKey:@"name"];
    self.getOffLabel.text = [getOff objectForKey:@"name"];
    
    if(getOn && getOff){
        [[BusSearchManager sharedManager]isSystemMeintenanceWithcompletionHandler:^(BOOL meintenanceFlg){
            if(!meintenanceFlg){
                [[BusSearchManager sharedManager]isExistRouteWithGetOn:[[getOn objectForKey:@"code"]intValue] getOff:[[getOff objectForKey:@"code"]intValue] completionHandler:^(BOOL flg){
                    if(flg){
                        NSLog(@">直通路線はあります。");
                        [[BusSearchManager sharedManager]isOutOfServiceWithGetOn:[[getOn objectForKey:@"code"]intValue] getOff:[[getOff objectForKey:@"code"]intValue] completionHandler:^(BOOL flg2){
                            if(!flg2){
                                NSLog(@">バスあります");
                                [[BusSearchManager sharedManager]GETRouteSearchResultWithGetOn:[[getOn objectForKey:@"code"]intValue] GetOff:[[getOff objectForKey:@"code"]intValue] completionHandler:^(NSArray* array){
                                    searchResultArray = array;
                                    [self showSearchResult];
                                    [indicator stopAnimating];
                                    indicator.hidden = true;
                                    leftButton.hidden = false;
                                    rightButton.hidden = false;

                                }];
                                
                            }else{
                                NSLog(@">営業時間終了");
                                errorLabel.text = @"上記路線の本日の運行は終了しました。";
                                errorLabel.hidden = false;
                                [indicator stopAnimating];
                                indicator.hidden = true;
                            }
                        }];
                    }else{
                        NSLog(@">直通路線はありません。");
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
                                    [[BusSearchManager sharedManager]isExistRouteWithGetOn:[[dict objectForKey:@"code"]intValue] getOff:[[getOff objectForKey:@"code"]intValue] completionHandler:^(BOOL flg3){
                                        if(flg3){
                                            NSLog(@">経由路線発見");
                                            //TODO:乗車バス停→経由バス停
                                            [[BusSearchManager sharedManager]isOutOfServiceWithGetOn:[[getOn objectForKey:@"code"]intValue] getOff:[[dict objectForKey:@"code"]intValue] completionHandler:^(BOOL flg4){
                                                if(!flg4){
                                                    NSLog(@">バスあります");
                                                    [[BusSearchManager sharedManager]GETRouteSearchResultWithGetOn:[[getOn objectForKey:@"code"]intValue] GetOff:[[dict objectForKey:@"code"]intValue] completionHandler:^(NSArray* array){
                                                        [[BusSearchManager sharedManager]GETArrivedTimeWithURL:[[array objectAtIndex:0]objectForKey:@"url"] completionHandler:^(NSArray* array2){
                                                            for(NSDictionary* dict2 in array2){
                                                                if([[dict2 objectForKey:@"name"] isEqualToString:[dict objectForKey:@"name"]]
                                                                   ){
                                                                    [[BusSearchManager sharedManager]isOutOfServiceWithGetOn:[[dict objectForKey:@"code"]intValue] getOff:[[getOff objectForKey:@"code"]intValue] completionHandler:^(BOOL flg5){
                                                                        if(!flg5){
                                                                            NSLog(@">バスあります");
                                                                            [[BusSearchManager sharedManager]GETRouteSearchResultWithGetOn:[[dict objectForKey:@"code"]intValue] GetOff:[[getOff objectForKey:@"code"]intValue] completionHandler:^(NSArray* array3){
                                                                                [[BusSearchManager sharedManager]GETArrivedTimeWithURL:[[array3 objectAtIndex:0]objectForKey:@"url"] completionHandler:^(NSArray* array4){
                                                                                    for(NSDictionary* dict3 in array4){
                                                                                        if([[dict3 objectForKey:@"name"] isEqualToString:[getOff objectForKey:@"name"]]
                                                                                           ){
                                                                                            NSLog(@"/*===================================*/");
                                                                                            NSLog(@"乗車バス停:%@",[getOn objectForKey:@"name"]);
                                                                                            NSLog(@"乗車バス停発車時間:%@",[[array objectAtIndex:0]objectForKey:@"time"]);
                                                                                            NSLog(@"行き先:%@",[[array objectAtIndex:0]objectForKey:@"destination"]);
                                                                                            NSLog(@"遅延情報:%@",[[array objectAtIndex:0]objectForKey:@"detail"]);
                                                                                            NSLog(@"URL:%@",[[array objectAtIndex:0]objectForKey:@"url"]);
                                                                                            NSLog(@"経由バス停:%@",[dict objectForKey:@"name"]);
                                                                                            NSLog(@"経由バス停到着時間:%@",[dict2 objectForKey:@"time"]);
                                                                                            #warning 経由バス到着時間に合わせて、array3の要素を削る
                                                                                            NSDictionary* timeDic = [self strTimeToCalculableValueWithString:[dict2 objectForKey:@"time"]];
                                                                                            int cnt = 0;//カウンタ
                                                                                            for(int i = 0;i < [array3 count];i++){
                                                                                                NSDictionary* timeDic2 = [self strTimeToCalculableValueWithString:[[array3 objectAtIndex:i] objectForKey:@"time"]];
                                                                                                
                                                                                                if(([[timeDic objectForKey:@"hour"]intValue] * 60 + [[timeDic objectForKey:@"min"]intValue]) > ([[timeDic2 objectForKey:@"hour"]intValue] * 60 + [[timeDic2 objectForKey:@"min"]intValue])){
                                                                                                    cnt++;
                                                                                                }
                                                                                            }
                                                                                            //TODO:経由バス停→降車バス停
                                                                                            NSLog(@"経由バス停発車時間:%@",[[array3 objectAtIndex:cnt]objectForKey:@"time"]);
                                                                                            NSLog(@"行き先:%@",[[array3 objectAtIndex:cnt]objectForKey:@"destination"]);
                                                                                            NSLog(@"遅延情報:%@",[[array3 objectAtIndex:cnt]objectForKey:@"detail"]);
                                                                                            NSLog(@"URL:%@",[[array3 objectAtIndex:cnt]objectForKey:@"url"]);
                                                                                            NSLog(@"降車バス停:%@",[getOff objectForKey:@"name"]);
                                                                                            NSLog(@"降車バス停到着時間:%@",[dict3 objectForKey:@"time"]);
                                                                                            NSLog(@"/*===================================*/");
                                                                                        }
                                                                                    }
                                                                                }];
                                                                            }];
                                                                        }else{
                                                                            NSLog(@">営業時間終了");
                                                                            errorLabel.text = @"上記路線の本日の運行は終了しました。";
                                                                            errorLabel.hidden = false;
                                                                            [indicator stopAnimating];
                                                                            indicator.hidden = true;
                                                                        }
                                                                    }];
                                                                    
                                                                }
                                                            }
                                                        }];
                                                    }];
                                                    
                                                }else{
                                                    NSLog(@">営業時間終了");
                                                    errorLabel.text = @"上記路線の本日の運行は終了しました";
                                                    errorLabel.hidden = false;
                                                    [indicator stopAnimating];
                                                    indicator.hidden = true;
                                                }
                                            }];

                                        }else{
                                            NSLog(@">直通路線なし");
                                            errorLabel.text = @"上記路線間の運行ルートが見つかりません。";
                                            errorLabel.hidden = false;
                                            [indicator stopAnimating];
                                            indicator.hidden = true;
                                        }
                                    }];

                                }else{
                                    NSLog(@">直通路線なし");
                                    errorLabel.text = @"上記路線間の運行ルートが見つかりません。";
                                    errorLabel.hidden = false;
                                    [indicator stopAnimating];
                                    indicator.hidden = true;
                                }
                            }];
                            
                        }
                    }
                }];
            }else{
                NSLog(@">システムメンテナンス中");
                errorLabel.text = @"システムメンテナンス中です。";
                errorLabel.hidden = false;
                [indicator stopAnimating];
                indicator.hidden = true;
            }
        }];
    }
}
-(NSDictionary*)strTimeToCalculableValueWithString:(NSString*)str{
    NSError *error = nil;
    NSString *pattern = @"([0-9]+):([0-9]+)";
    
    // パターンから正規表現を生成する
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    
    // 正規表現を適用して結果を得る
    NSTextCheckingResult *match = [regexp firstMatchInString:str options:0 range:NSMakeRange(0, str.length)];
  
    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[str substringWithRange:[match rangeAtIndex:1]],@"hour",
                          [str substringWithRange:[match rangeAtIndex:2]],@"min",nil];
    return dict;
    
}
-(void)showSearchResult{
#pragma mark 検索時間の割に処理が長すぎるので、UI描画のスレッドをしっかり管理
    // Do any additional setup after loading the view.
    noConnectionView.hidden = false;

    NSDictionary* getOn = [[BusSearchManager sharedManager]GetOnBusStop];
    NSDictionary* getOff = [[BusSearchManager sharedManager]GetOffBusStop];
    
    NSLog(@"searchResult = %@",searchResultArray);
    [[BusSearchManager sharedManager]GETArrivedTimeWithURL:[[searchResultArray objectAtIndex:showCnt]objectForKey:@"url"] completionHandler:^(NSArray* array2){
        for(NSDictionary* dict in array2){
            if([[dict objectForKey:@"name"] isEqualToString:[getOff objectForKey:@"name"]]
               ){
                NSLog(@"/*===================================*/");
                NSLog(@"乗車バス停:%@",[getOn objectForKey:@"name"]);
                
                NSLog(@"発車時間:%@",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"time"]);
                NSLog(@"行き先:%@",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"destination"]);
                NSLog(@"遅延情報:%@",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"detail"]);
                NSLog(@"URL:%@",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"url"]);
                NSLog(@"降車バス停:%@",[getOff objectForKey:@"name"]);
                NSLog(@"降車バス停到着時間:%@",[dict objectForKey:@"time"]);
                NSLog(@"/*===================================*/");
                noConnectionView.departureLabel.text = [NSString stringWithFormat:@"出発時刻:%@",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"time"]];
                noConnectionView.destinationLabel.text = [NSString stringWithFormat:@"行き先:%@",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"destination"]];
                noConnectionView.detailLabel.text = [NSString stringWithFormat:@"遅延情報:%@",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"detail"]];
                noConnectionView.arrivalLabel.text = [NSString stringWithFormat:@"到着時刻:%@",[dict objectForKey:@"time"]];
            }
        }
    }];
}
-(void)leftPressed:(UIButton*)sender{
    showCnt = MAX(showCnt, 0);
}
-(void)rightPressed:(UIButton*)sender{
    showCnt = MIN(showCnt, (int)[searchResultArray count]);
}
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
