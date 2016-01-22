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
    
    // システムで用意されている画像を使った生成例
    UIBarButtonItem *refleshButton =
    [[UIBarButtonItem alloc]
     initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh  // スタイルを指定
     target:self  // デリゲートのターゲットを指定
     action:@selector(reflesh:)  // ボタンが押されたときに呼ばれるメソッドを指定
     ];
    self.navigationItem.rightBarButtonItem = refleshButton;

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
    
    leftButton = [[UIButton alloc]initWithFrame:CGRectMake(10, 150, 90, 30)];
    [leftButton setTitle:@"◀︎前の便" forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [leftButton setTitleColor:[UIColor colorWithRed:184/255.0 green:29/255.0 blue:31/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    
    [leftButton.titleLabel setFont:[UIFont systemFontOfSize:20]];
    
    [leftButton addTarget:self action:@selector(leftPressed:) forControlEvents:UIControlEventTouchUpInside];
    leftButton.layer.cornerRadius = 10;
    leftButton.layer.borderColor = [[UIColor orangeColor]CGColor];
    leftButton.layer.borderWidth = 1.0;
    
    [self.view addSubview:leftButton];
    
    rightButton = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-100, 150, 90, 30)];
    [rightButton setTitle:@"次の便▶︎" forState:UIControlStateNormal];
    [rightButton.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [rightButton setTitleColor:[UIColor orangeColor] forState:UIControlStateNormal];
    [rightButton setTitleColor:[UIColor colorWithRed:184/255.0 green:29/255.0 blue:31/255.0 alpha:1.0] forState:UIControlStateHighlighted];
    [rightButton addTarget:self action:@selector(rightPressed:) forControlEvents:UIControlEventTouchUpInside];
    rightButton.layer.cornerRadius = 10;
    rightButton.layer.borderColor = [[UIColor orangeColor]CGColor];
    rightButton.layer.borderWidth = 1.0;

    [self.view addSubview:rightButton];
    
    leftButton.hidden = true;
    rightButton.hidden = true;
    
    timeLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 150, self.view.frame.size.width - 200, 30)];
    timeLabel.textColor = [UIColor blackColor];
    timeLabel.font = [UIFont systemFontOfSize:26];
    timeLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:timeLabel];
    timeLabel.hidden = true;

    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *result = [formatter stringFromDate:now];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationItem.title = [NSString stringWithFormat:@"更新[%@]",result];

    [self routeSearch];
}
#pragma mark 更新ボタン
-(void)reflesh:(UIBarButtonItem*)btn{
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *result = [formatter stringFromDate:now];
    
    self.navigationItem.title = [NSString stringWithFormat:@"更新[%@]",result];
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
    
#pragma mark 乗車バス停・降車バス停が同じ
    if([getOn objectForKey:@"code"] == [getOff objectForKey:@"code"]){
        NSLog(@">乗車バス停・降車バス停が同じ");
        errorLabel.text = @"乗車バス停・降車バス停が同じです";
        errorLabel.hidden = false;
        [indicator stopAnimating];
        indicator.hidden = true;
        return;
    }
    if(getOn && getOff){
        [RouteSearchManager getRouteWithGetOn:getOn getOff:getOff completionHandler:^(NSDictionary* dict,NSError *error){
            //処理
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
-(int)strTimeToCalculableIntegerValueWithString:(NSString*)str{
    NSDictionary* dict = [self strTimeToCalculableValueWithString:str];
    int time = [[dict objectForKey:@"hour"]intValue] * 60 + [[dict objectForKey:@"min"]intValue];
    return time;
}
#pragma mark これいるのかな？ 複数乗り継ぎのときのやつ
/*
-(void)searchEarlyest{
    organizeConnectionArray = [NSMutableArray new];
    // Do any additional setup after loading the view.
    NSDictionary* getOn = [[BusSearchManager sharedManager]GetOnBusStop];
    NSDictionary* getOff = [[BusSearchManager sharedManager]GetOffBusStop];
    int search_size = 0;
    for(int i = 0; i < [connectionSearchResultArray count];i++){
        NSDictionary* dict = [connectionSearchResultArray objectAtIndex:i];
        NSArray* firstArray = [dict objectForKey:@"first"];
        for (int j = 0; j < [firstArray count]; j++) {
            search_size++;
        }
    }
    
    __block int searchCount = 0;
    __block bool isNoConnection = true;
    
    for(int i = 0; i < [connectionSearchResultArray count];i++){
        NSDictionary* dict = [connectionSearchResultArray objectAtIndex:i];
        NSArray* firstArray = [dict objectForKey:@"first"];
        NSArray* secondArray = [dict objectForKey:@"second"];
        NSDictionary* via = [dict objectForKey:@"via"];
        
        for(int j = 0;j < [firstArray count];j++){
            NSDictionary* earlyestRide = [firstArray objectAtIndex:j];
            
            [[BusSearchManager sharedManager]GETArrivedTimeWithURL:[earlyestRide objectForKey:@"url"] completionHandler:^(NSArray* array){
                for(NSDictionary* dict2 in array){
                    if([[dict2 objectForKey:@"name"] isEqualToString:[via objectForKey:@"name"]]
                       ){
#warning 経由バス到着時間に合わせて、array3の要素を削る
                        NSDictionary* timeDic = [self strTimeToCalculableValueWithString:[dict2 objectForKey:@"time"]];
                        int cnt = 0;//カウンタ
                        
                        for(NSDictionary* viaDict in secondArray){
                            NSDictionary* timeDic2 = [self strTimeToCalculableValueWithString:[viaDict objectForKey:@"time"]];
                            if(([[timeDic objectForKey:@"hour"]intValue] * 60 + [[timeDic objectForKey:@"min"]intValue]) > ([[timeDic2 objectForKey:@"hour"]intValue] * 60 + [[timeDic2 objectForKey:@"min"]intValue])){
                                cnt++;
                            }
                        }
                        
                        if(cnt >= [secondArray count]){
                            NSLog(@"経由先乗り継ぎ便なし。");
                            searchCount++;
                            if(search_size == searchCount){
                                NSLog(@"終わり");
                                if(isNoConnection){
                                    NSLog(@"error:経由できない");
                                    errorLabel.text = @"上記路線の本日の運行は終了しました。";
                                    errorLabel.hidden = false;
                                    [indicator stopAnimating];
                                    indicator.hidden = true;
                                }else{
                                    [self showSearchResult];
                                }
                            }
                            return;
                        }
                        NSDictionary* earlyestVia = [secondArray objectAtIndex:cnt];
                        
                        [[BusSearchManager sharedManager]GETArrivedTimeWithURL:[earlyestVia objectForKey:@"url"] completionHandler:^(NSArray* array2){
                            for(NSDictionary* dict3 in array2){
                                if([[dict3 objectForKey:@"name"] isEqualToString:[getOff objectForKey:@"name"]]
                                   ){
                                    isNoConnection = false;
                                    searchCount++;
                                    
                                    int depTime = [self strTimeToCalculableIntegerValueWithString:[earlyestRide objectForKey:@"time"]];
                                    
                                    int arrTime = [self strTimeToCalculableIntegerValueWithString:[dict3 objectForKey:@"time"]];
                                    
                                    

                                    NSDictionary* organizedDict = [[NSDictionary alloc]initWithObjectsAndKeys:
                                                                   [earlyestRide objectForKey:@"destination"],@"firstDestination",
                                                                   [getOn objectForKey:@"name"],@"firstName",
                                                                   [earlyestRide objectForKey:@"time"],@"firstDeparturesTime",
                                                                   [dict2 objectForKey:@"time"],@"firstArraivalTime",
                                                                   [earlyestRide objectForKey:@"detail"],@"firstDetail",
                                                                   [earlyestRide objectForKey:@"url"],@"firstURL",
                                                                   [earlyestVia objectForKey:@"destination"],@"secondDestination",
                                                                   [dict2 objectForKey:@"name"],@"secondName",
                                                                   [earlyestVia objectForKey:@"time"],@"secondDeparturesTime",
                                                                   [dict3 objectForKey:@"time"],@"secondArraivalTime",
                                                                   [earlyestVia objectForKey:@"detail"],@"secondDetail",
                                                                   [earlyestVia objectForKey:@"url"],@"secondURL",
                                                                   [getOff objectForKey:@"name"],@"getOff",
                                                                   [NSNumber numberWithInt:depTime],@"depIntTime",
                                                                   [NSNumber numberWithInt:depTime],@"arrIntTime",
                                                                   nil];
                                    [organizeConnectionArray addObject:organizedDict];

                                    if(search_size == searchCount){
                                        NSLog(@"終わり");
                                        if(isNoConnection){
                                            NSLog(@"error:経由できない");
                                            errorLabel.text = @"上記路線の本日の運行は終了しました。";
                                            errorLabel.hidden = false;
                                            [indicator stopAnimating];
                                            indicator.hidden = true;
                                        }else{
                                            [self showSearchResult];
                                        }
                                    }
                                }
                            }
                        }];
                    }
                }
            }];
            
        }
    }
}
 */
-(void)showSearchResult{
    // Do any additional setup after loading the view.
    NSDictionary* getOn = [[BusSearchManager sharedManager]GetOnBusStop];
    NSDictionary* getOff = [[BusSearchManager sharedManager]GetOffBusStop];
    
    if(connection){
        //ソート対象となるキーを指定した、NSSortDescriptorの生成
        NSSortDescriptor *sortDepTime;
        NSSortDescriptor *sortArrTime;
        sortDepTime = [[NSSortDescriptor alloc] initWithKey:@"depIntTime" ascending:YES];
        sortArrTime = [[NSSortDescriptor alloc] initWithKey:@"arrIntTime" ascending:YES];
        
        NSArray *sortAscendingArray;
        // NSSortDescriptorを配列にセット departures -> arrival の順にソートする
        sortAscendingArray = [NSArray arrayWithObjects:sortDepTime, sortArrTime, nil];
        
        // ソートの実行
        NSArray *sortArray;
        sortArray = [organizeConnectionArray sortedArrayUsingDescriptors:sortAscendingArray];
        
        NSDictionary* info = [sortArray objectAtIndex:showCnt];
        [indicator stopAnimating];
        indicator.hidden = true;
        connectionView.hidden = false;
        leftButton.hidden = false;
        rightButton.hidden = false;
        leftButton.enabled = true;
        rightButton.enabled = true;
        timeLabel.hidden = false;
        
        /*
         NSDictionary* organizedDict = [[NSDictionary alloc]initWithObjectsAndKeys:
         [earlyestRide objectForKey:@"destination"],@"firstDestination",
         [getOn objectForKey:@"name"],@"firstName",
         [earlyestRide objectForKey:@"time"],@"firstDeparturesTime",
         [dict2 objectForKey:@"time"],@"firstArraivalTime",
         [earlyestRide objectForKey:@"detail"],@"firstDetail",
         [earlyestRide objectForKey:@"url"],@"firstURL",
         [earlyestVia objectForKey:@"destination"],@"secondDestination",
         [dict2 objectForKey:@"name"],@"secondName",
         [earlyestVia objectForKey:@"time"],@"secondDeparturesTime",
         [dict3 objectForKey:@"time"],@"secondArraivalTime",
         [earlyestVia objectForKey:@"detail"],@"secondDetail",
         [earlyestVia objectForKey:@"url"],@"secondURL",
         [getOff objectForKey:@"name"],@"getOff",
         depTime,@"depIntTime",
         arrTime,@"arrIntTime",
         nil];

         */
        timeLabel.text = [NSString stringWithFormat:@"%@発",[info objectForKey:@"firstDeparturesTime"]];
        connectionView.getOnLabel1.text = [info objectForKey:@"firstName"];
        connectionView.getOffLabel1.text = [info objectForKey:@"secondName"];
        connectionView.departureLabel1.text = [info objectForKey:@"firstDeparturesTime"];
        connectionView.destinationLabel1.text = [NSString stringWithFormat:@"%@ 行き",[info objectForKey:@"firstDestination"]];
        connectionView.detailLabel1.text = [info objectForKey:@"firstDetail"];
        connectionView.arrivalLabel1.text = [info objectForKey:@"firstArraivalTime"];
        connectionView.getOnLabel2.text = [info objectForKey:@"secondName"];
        connectionView.getOffLabel2.text = [info objectForKey:@"getOff"];
        connectionView.departureLabel2.text = [info objectForKey:@"secondDeparturesTime"];
        connectionView.destinationLabel2.text = [NSString stringWithFormat:@"%@ 行き",[info objectForKey:@"secondDestination"]];
        connectionView.detailLabel2.text = [info objectForKey:@"secondDetail"];
        connectionView.arrivalLabel2.text = [info objectForKey:@"secondArraivalTime"];
        
        if(showCnt == 0){
            leftButton.hidden = true;
        }
        if(showCnt == [organizeConnectionArray count]-1){
            rightButton.hidden = true;
        }

        /*
        NSLog(@"|経路:%d",i);
        NSLog(@"|路線:%d",j);
        NSLog(@"ー｜乗車バス行き先:%@",[earlyestRide objectForKey:@"destination"]);
        NSLog(@"ー｜乗車バス停:%@",[getOn objectForKey:@"name"]);
        NSLog(@"ー｜乗車バス停 発車時間:%@",[earlyestRide objectForKey:@"time"]);
        NSLog(@"ー｜経由バス停 到着時間:%@",[dict2 objectForKey:@"time"]);
        NSLog(@"ー｜遅延情報:%@",[earlyestRide objectForKey:@"detail"]);
        NSLog(@"ー｜URL:%@",[earlyestRide objectForKey:@"url"]);
        
        NSLog(@"ーー｜経由バス行き先:%@",[earlyestVia objectForKey:@"destination"]);
        NSLog(@"ーー｜経由バス停:%@",[dict2 objectForKey:@"name"]);
        NSLog(@"ーー｜経由バス停 発車時間:%@",[earlyestVia objectForKey:@"time"]);
        NSLog(@"ーー｜降車バス停 到着時間:%@",[dict3 objectForKey:@"time"]);
        NSLog(@"ーー｜遅延情報:%@",[earlyestVia objectForKey:@"detail"]);
        NSLog(@"ーー｜URL:%@",[earlyestVia objectForKey:@"url"]);
        NSLog(@"ーーー｜降車バス停:%@",[getOff objectForKey:@"name"]);
         */
    }else{
        NSLog(@"searchResult = %@",searchResultArray);
        [[BusSearchManager sharedManager]GETArrivedTimeWithURL:[[searchResultArray objectAtIndex:showCnt]objectForKey:@"url"] completionHandler:^(NSArray* array2,NSError * error){
#warning エラー処理
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
                    
                    if(showCnt == 0){
                        leftButton.hidden = true;
                    }
                    if(showCnt == [searchResultArray count]-1){
                        rightButton.hidden = true;
                    }
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
        if(showCnt > (int)[organizeConnectionArray count]-1){
            showCnt = MIN(showCnt, (int)[organizeConnectionArray count]-1);
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
