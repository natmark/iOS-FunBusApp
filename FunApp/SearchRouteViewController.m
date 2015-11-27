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
    [self.view addSubview:indicator];
    /*==========================*/
    
    //経由なしの表示用
    /*==========================*/
    showCnt = 0;
    noConnectionView = [[NoConnectionView alloc]initWithFrame:CGRectMake(10, 190, self.view.frame.size.width - 20, self.view.frame.size.width - 20)];
    [self.view addSubview:noConnectionView];
    noConnectionView.hidden = true;
    
    connectionView = [[ConnectionView alloc]initWithFrame:CGRectMake(10, 190, self.view.frame.size.width - 20, self.view.frame.size.width - 20)];
    [self.view addSubview:connectionView];
    connectionView.hidden = true;
    
    leftButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 150, 100, 30)];
    [leftButton setTitle:@"◀︎前の便" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor colorWithRed:184/255.0 green:29/255.0 blue:31/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    
    [leftButton.titleLabel setFont:[UIFont systemFontOfSize:20]];
    
    [leftButton addTarget:self action:@selector(leftPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftButton];
    
    rightButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-100, 150, 100, 30)];
    [rightButton setTitle:@"次の便▶︎" forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [rightButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor colorWithRed:184/255.0 green:29/255.0 blue:31/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(rightPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightButton];
    
    leftButton.hidden = true;
    rightButton.hidden = true;
    
    timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 150, self.view.frame.size.width - 200, 30)];
    timeLabel.textColor = [UIColor blackColor];
    timeLabel.font = [UIFont systemFontOfSize:26];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:timeLabel];
    timeLabel.hidden = true;
    
    /*==========================*/
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    [timer fire];
}
#pragma mark 1分おきに自動更新
-(void)timerAction:(NSTimer*)timer{
    [self routeSearch];
}
-(void)routeSearch{
    noConnectionView.hidden = true;
    connectionView.hidden = true;
    timeLabel.hidden = true;
    rightButton.hidden = true;
    leftButton.hidden = true;
    errorLabel.hidden = true;
    [self.view bringSubviewToFront:indicator];
    indicator.hidden = false;
    [indicator startAnimating];
    
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
                        connection = false;
                        [[BusSearchManager sharedManager]isOutOfServiceWithGetOn:[[getOn objectForKey:@"code"]intValue] getOff:[[getOff objectForKey:@"code"]intValue] completionHandler:^(BOOL flg2){
                            if(!flg2){
                                NSLog(@">バスあります");
                                [[BusSearchManager sharedManager]GETRouteSearchResultWithGetOn:[[getOn objectForKey:@"code"]intValue] GetOff:[[getOff objectForKey:@"code"]intValue] completionHandler:^(NSArray* array){
                                    searchResultArray = array;
                                    [self showSearchResult];
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
                        connection = true;
                        connectionSearchResultArray = [NSMutableArray new];
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
                        
#warning 接続路線の処理
#pragma mark TODO-LIST
//TODO:直通路線なし・営業時間終了に優先度をもたせる。
//TODO:営業時間終了を一度でも通れば、その後の直通路線なしで上書きさせない。
//TODO:一路線でもバスがあれば、直通路線なし・営業時間終了の文字は消してしまう。
//TODO:ただし、[indicator stopAnimating]および、ラベルの表示は全件検索終了後に表示したい
//TODO:for文に変えたので、i = [candidateArray count]のときに変更でもいいかもしれない
/*
 //TODO:もしくは、直通路線なし(乗車->経由)、直通路線なし(経由->降車)、営業時間終了、路線発見の
どれかを通るため、純粋にカウントして、count = [canditateArray count]でラベル表示&[stop Animating]でもよいかも
 //TODO:上記方法なら、路線発見カウンタも用意し、カウンタ == 0のときラベル表示&[stop Animating]
 カウンタ != 0 のとき、路線表示でもよいかもしれない。
 */
/*
 counta = [canditateArray count]のとき、route_flg = trueのとき、営業時間終了
 data_flg = trueのとき、ルート表示。
 */
   
                        __block bool route_flg = false;
                        __block bool data_flg = false;
                        __block int counta = 0;
                        
                        for(int i = 0;i < [candidateArray count];i++){
                            NSDictionary* dict = [candidateArray objectAtIndex:i];
                            
                            [[BusSearchManager sharedManager]isExistRouteWithGetOn:[[getOn objectForKey:@"code"]intValue] getOff:[[dict objectForKey:@"code"]intValue] completionHandler:^(BOOL flg2){
                                if(flg2){
                                    [[BusSearchManager sharedManager]isExistRouteWithGetOn:[[dict objectForKey:@"code"]intValue] getOff:[[getOff objectForKey:@"code"]intValue] completionHandler:^(BOOL flg3){
                                        if(flg3){
                                            NSLog(@">経由路線発見");
                                            [[BusSearchManager sharedManager]isOutOfServiceWithGetOn:[[getOn objectForKey:@"code"]intValue] getOff:[[dict objectForKey:@"code"]intValue] completionHandler:^(BOOL flg4){
                                                if(!flg4){
                                                    NSLog(@">乗車->乗り継ぎ バス営業中");
                                                    [[BusSearchManager sharedManager]GETRouteSearchResultWithGetOn:[[getOn objectForKey:@"code"]intValue] GetOff:[[dict objectForKey:@"code"]intValue] completionHandler:^(NSArray* array){
                                                        [[BusSearchManager sharedManager]isOutOfServiceWithGetOn:[[dict objectForKey:@"code"]intValue] getOff:[[getOff objectForKey:@"code"]intValue] completionHandler:^(BOOL flg5){
                                                            if(!flg5){
                                                                NSLog(@">乗り継ぎ->降車 バス営業中");
                                                                [[BusSearchManager sharedManager]GETRouteSearchResultWithGetOn:[[dict objectForKey:@"code"]intValue] GetOff:[[getOff objectForKey:@"code"]intValue] completionHandler:^(NSArray* array3){
                                                                    [[BusSearchManager sharedManager]GETArrivedTimeWithURL:[[array3 objectAtIndex:0]objectForKey:@"url"] completionHandler:^(NSArray* array2){
                                                                        NSDictionary* dict = [[NSDictionary alloc]initWithObjectsAndKeys:array,@"ride",
                                                                        array2,@"via",nil];
                                                                        [connectionSearchResultArray addObject:dict];
                                                                        counta++;
                                                                        data_flg = true;
                                                                        if (counta == 8 && data_flg == true) {
                                                                            [self showSearchResult];
                                                                        }else if(counta == 8 && route_flg == true){
                                                                            errorLabel.text = @"上記路線の本日の運行は終了しました。";
                                                                            errorLabel.hidden = false;
                                                                            [indicator stopAnimating];
                                                                            indicator.hidden = true;
                                                                        }else if(counta == 8 && route_flg == false){
                                                                            errorLabel.text = @"上記路線の本日の運行は終了しました";
                                                                            errorLabel.hidden = false;
                                                                            [indicator stopAnimating];
                                                                            indicator.hidden = true;
                                                                        }

                                                                    }];
                                                                }];
                                                            }else{
                                                                NSLog(@">営業時間終了");
                                                                counta++;
                                                                route_flg = true;
                                                                if (counta == 8 && data_flg == true) {
                                                                    [self showSearchResult];
                                                                }else if(counta == 8 && route_flg == true){
                                                                    errorLabel.text = @"上記路線の本日の運行は終了しました。";
                                                                    errorLabel.hidden = false;
                                                                    [indicator stopAnimating];
                                                                    indicator.hidden = true;
                                                                }else if(counta == 8 && route_flg == false){
                                                                    errorLabel.text = @"上記路線の本日の運行は終了しました";
                                                                    errorLabel.hidden = false;
                                                                    [indicator stopAnimating];
                                                                    indicator.hidden = true;
                                                                }
                                                            }
                                                        }];
                                                    }];
                                                }else{
                                                    NSLog(@">営業時間終了");
                                                    counta++;
                                                    route_flg = true;
                                                    if (counta == 8 && data_flg == true) {
                                                        [self showSearchResult];
                                                    }else if(counta == 8 && route_flg == true){
                                                        errorLabel.text = @"上記路線の本日の運行は終了しました。";
                                                        errorLabel.hidden = false;
                                                        [indicator stopAnimating];
                                                        indicator.hidden = true;
                                                    }else if(counta == 8 && route_flg == false){
                                                        errorLabel.text = @"上記路線の本日の運行は終了しました";
                                                        errorLabel.hidden = false;
                                                        [indicator stopAnimating];
                                                        indicator.hidden = true;
                                                    }
                                                }
                                            }];
                                        }else{
                                            NSLog(@">直通路線なし");
                                            counta++;
                                            NSLog(@"counta:%d",counta);

                                            if (counta == 8 && data_flg == true) {
                                                [self showSearchResult];
                                            }else if(counta == 8 && route_flg == true){
                                                errorLabel.text = @"上記路線の本日の運行は終了しました。";
                                                errorLabel.hidden = false;
                                                [indicator stopAnimating];
                                                indicator.hidden = true;
                                            }else if(counta == 8 && route_flg == false){
                                                errorLabel.text = @"上記路線の本日の運行は終了しました";
                                                errorLabel.hidden = false;
                                                [indicator stopAnimating];
                                                indicator.hidden = true;
                                            }
                                        }
                                    }];
                                }else{
                                    NSLog(@">直通路線なし");
                                    counta++;
                                    if (counta == 8 && data_flg == true) {
                                        [self showSearchResult];
                                    }else if(counta == 8 && route_flg == true){
                                        errorLabel.text = @"上記路線の本日の運行は終了しました。";
                                        errorLabel.hidden = false;
                                        [indicator stopAnimating];
                                        indicator.hidden = true;
                                    }else if(counta == 8 && route_flg == false){
                                        errorLabel.text = @"上記路線の本日の運行は終了しました";
                                        errorLabel.hidden = false;
                                        [indicator stopAnimating];
                                        indicator.hidden = true;
                                    }
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
    }else{
        //データ取得に失敗
        [self.navigationController popToRootViewControllerAnimated:YES];
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
    // Do any additional setup after loading the view.
    NSDictionary* getOn = [[BusSearchManager sharedManager]GetOnBusStop];
    NSDictionary* getOff = [[BusSearchManager sharedManager]GetOffBusStop];
    
    if(connection){
        [indicator stopAnimating];
        indicator.hidden = true;
        
        #warning やることリスト
        /*
         //TODO:辞書のなかの構造がわからなくなってしまった。
         乗車バス情報:[[connectionSearchResult objectAtIndex:i]objectForKey:@"ride"];
         経由バス情報:[[connectionSearchResult objectAtIndex:i]objectForKey:@"via"];
         一旦この中身をのぞく必要がありそう。
         */
        
        /*
         //ここからわけわからない
        //最短経路を探す
        for(int i = 0; i < [connectionSearchResultArray count];i++){
            NSDictionary* dict = [connectionSearchResultArray objectAtIndex:i];
            NSArray* rideArray = [dict objectForKey:@"ride"];
            NSArray* viaArray = [dict objectForKey:@"via"];
            
            NSDictionary* earlyestGetOn = [rideArray firstObject];
            NSDictionary* earlyestVia = [viaArray firstObject];
            [[BusSearchManager sharedManager]GETArrivedTimeWithURL:[earlyestGetOn objectForKey:@"url"] completionHandler:^(NSArray* array){
                for(NSDictionary* dict in array){
                    if([[dict objectForKey:@"name"] isEqualToString:[earlyestVia objectForKey:@"name"]]
                       ){
                        NSLog(@"経由地 到着時間:%@",[dict objectForKey:@"time"]);
                        [[BusSearchManager sharedManager]GETArrivedTimeWithURL:[earlyestVia objectForKey:@"url"] completionHandler:^(NSArray* array2){
                            for(NSDictionary* dict2 in array2){
                                if([[dict2 objectForKey:@"name"] isEqualToString:[getOff objectForKey:@"name"]]
                                   ){
                                    NSLog(@"目的地 到着時間:%@",[dict2 objectForKey:@"time"]);
                                    
                                    #warning 経由バス到着時間に合わせて、array3の要素を削る
                                    NSDictionary* timeDic = [self strTimeToCalculableValueWithString:[dict objectForKey:@"time"]];
                                    int cnt = 0;//カウンタ
                                    for(int i = 0;i < [[dict2 objectForKey:@"time"] count];i++){
                                        NSDictionary* timeDic2 = [self strTimeToCalculableValueWithString:[[array3 objectAtIndex:i] objectForKey:@"time"]];
                                        
                                        if(([[timeDic objectForKey:@"hour"]intValue] * 60 + [[timeDic objectForKey:@"min"]intValue]) > ([[timeDic2 objectForKey:@"hour"]intValue] * 60 + [[timeDic2 objectForKey:@"min"]intValue])){
                                            cnt++;
                                        }
                                    }
                                }
                            }
                        }];
                    }
                }
            }];
        }
         */
        /*
         //これは乗り継ぎなしのやつ。
        [[BusSearchManager sharedManager]GETArrivedTimeWithURL:[[searchResultArray objectAtIndex:showCnt]objectForKey:@"url"] completionHandler:^(NSArray* array2){
            for(NSDictionary* dict in array2){
                if([[dict objectForKey:@"name"] isEqualToString:[getOff objectForKey:@"name"]]
                   ){
                    noConnectionView.hidden = false;
                    [indicator stopAnimating];
                    indicator.hidden = true;
                    leftButton.hidden = false;
                    rightButton.hidden = false;
                    leftButton.enabled = true;
                    rightButton.enabled = true;
                    timeLabel.hidden = false;
                    timeLabel.text = [NSString stringWithFormat:@"%@発",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"time"]];
                    NSLog(@"乗車バス停:%@",[getOn objectForKey:@"name"]);
                    
                    NSLog(@"発車時間:%@",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"time"]);
                    NSLog(@"行き先:%@",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"destination"]);
                    NSLog(@"遅延情報:%@",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"detail"]);
                    NSLog(@"URL:%@",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"url"]);
                    NSLog(@"降車バス停:%@",[getOff objectForKey:@"name"]);
                    NSLog(@"降車バス停到着時間:%@",[dict objectForKey:@"time"]);
                    noConnectionView.getOnLabel.text = [getOn objectForKey:@"name"];
                    noConnectionView.getOffLabel.text = [getOff objectForKey:@"name"];
                    noConnectionView.departureLabel.text = [NSString stringWithFormat:@"%@",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"time"]];
                    noConnectionView.destinationLabel.text = [NSString stringWithFormat:@"%@ 行き",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"destination"]];
                    noConnectionView.detailLabel.text = [NSString stringWithFormat:@"%@",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"detail"]];
                    noConnectionView.arrivalLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"time"]];
                }
            }
        }];
        */
        
        /*
         //これはもともとrouteSearchの中にあったやつ
         for(NSDictionary* dict3 in array4){
         if([[dict3 objectForKey:@"name"] isEqualToString:[getOff objectForKey:@"name"]]
         ){
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
         }
         }
         */

    }else{
        NSLog(@"searchResult = %@",searchResultArray);
        [[BusSearchManager sharedManager]GETArrivedTimeWithURL:[[searchResultArray objectAtIndex:showCnt]objectForKey:@"url"] completionHandler:^(NSArray* array2){
            for(NSDictionary* dict in array2){
                if([[dict objectForKey:@"name"] isEqualToString:[getOff objectForKey:@"name"]]
                   ){
                    noConnectionView.hidden = false;
                    [indicator stopAnimating];
                    indicator.hidden = true;
                    leftButton.hidden = false;
                    rightButton.hidden = false;
                    leftButton.enabled = true;
                    rightButton.enabled = true;
                    timeLabel.hidden = false;
                    timeLabel.text = [NSString stringWithFormat:@"%@発",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"time"]];
                    NSLog(@"/*===================================*/");
                    NSLog(@"乗車バス停:%@",[getOn objectForKey:@"name"]);
                    
                    NSLog(@"発車時間:%@",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"time"]);
                    NSLog(@"行き先:%@",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"destination"]);
                    NSLog(@"遅延情報:%@",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"detail"]);
                    NSLog(@"URL:%@",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"url"]);
                    NSLog(@"降車バス停:%@",[getOff objectForKey:@"name"]);
                    NSLog(@"降車バス停到着時間:%@",[dict objectForKey:@"time"]);
                    NSLog(@"/*===================================*/");
                    noConnectionView.getOnLabel.text = [getOn objectForKey:@"name"];
                    noConnectionView.getOffLabel.text = [getOff objectForKey:@"name"];
                    noConnectionView.departureLabel.text = [NSString stringWithFormat:@"%@",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"time"]];
                    noConnectionView.destinationLabel.text = [NSString stringWithFormat:@"%@ 行き",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"destination"]];
                    noConnectionView.detailLabel.text = [NSString stringWithFormat:@"%@",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"detail"]];
                    noConnectionView.arrivalLabel.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"time"]];
                }
            }
        }];
    }
}
-(void)leftPressed:(UIButton*)sender{
    showCnt--;
    if(showCnt < 0){
        showCnt = MAX(showCnt, 0);
    }else{
        connectionView.hidden = true;
        noConnectionView.hidden = true;
        [indicator startAnimating];
        indicator.hidden = false;
        leftButton.enabled = false;
        rightButton.enabled = false;
        [self showSearchResult];
    }
}
-(void)rightPressed:(UIButton*)sender{
    showCnt++;
    if(connection){
        if(showCnt > (int)[connectionSearchResultArray count]-1){
            showCnt = MIN(showCnt, (int)[connectionSearchResultArray count]-1);
        }else{
            connectionView.hidden = true;
            noConnectionView.hidden = true;
            [indicator startAnimating];
            indicator.hidden = false;
            leftButton.enabled = false;
            rightButton.enabled = false;
            [self showSearchResult];
        }
        
    }else{
        if(showCnt > (int)[searchResultArray count]-1){
            showCnt = MIN(showCnt, (int)[searchResultArray count]-1);
        }else{
            connectionView.hidden = true;
            noConnectionView.hidden = true;
            [indicator startAnimating];
            indicator.hidden = false;
            leftButton.enabled = false;
            rightButton.enabled = false;
            [self showSearchResult];
        }
        
    }
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
