//
//  SearchRouteViewController.m
//  FunApp
//
//  Created by Atsuya Sato on 2015/11/12.
//  Copyright © 2015年 Atsuya Sato. All rights reserved.
//

#import "SearchRouteViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SearchRouteViewController ()

@end

@implementation SearchRouteViewController
typedef enum
{
    MapButtonTagNoConnection = 0,
    MapButtonTagConnection1,
    MapButtonTagConnection2
} MapButtonTag;

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
    
    [noConnectionView.mapButton addTarget:self action:@selector(tapMap:) forControlEvents:UIControlEventTouchUpInside];
    noConnectionView.mapButton.tag = MapButtonTagNoConnection;
    [noConnectionView.twitter addTarget:self action:@selector(tweet:) forControlEvents:UIControlEventTouchUpInside];
    [noConnectionView.timerList addTarget:self action:@selector(showTimerList:) forControlEvents:UIControlEventTouchUpInside];
    [noConnectionView.bookmark addTarget:self action:@selector(addBookmark:) forControlEvents:UIControlEventTouchUpInside];
    
    connectionView = [[ConnectionView alloc]initWithFrame:CGRectMake(10, 190, self.view.frame.size.width - 20, self.view.frame.size.width - 20)];
    [self.view addSubview:connectionView];
    connectionView.hidden = true;

    [connectionView.mapButton1 addTarget:self action:@selector(tapMap:) forControlEvents:UIControlEventTouchUpInside];
    connectionView.mapButton1.tag = MapButtonTagConnection1;
    [connectionView.mapButton2 addTarget:self action:@selector(tapMap:) forControlEvents:UIControlEventTouchUpInside];
    connectionView.mapButton2.tag = MapButtonTagConnection2;
    [connectionView.twitter addTarget:self action:@selector(tweet:) forControlEvents:UIControlEventTouchUpInside];
    [connectionView.timerList addTarget:self action:@selector(showTimerList:) forControlEvents:UIControlEventTouchUpInside];
    [connectionView.bookmark addTarget:self action:@selector(addBookmark:) forControlEvents:UIControlEventTouchUpInside];

    
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
#pragma mark UI部品タッチハンドラ
-(void)tapMap:(UIButton*)sender{
    if((RouteType)[[dataDictionary objectForKey:@"type"]intValue] == RouteTypeComplex){
        NSDictionary* dict = [dataDictionary objectForKey:@"data"];
        NSArray* firstArray = [dict objectForKey:@"first"];
        NSArray* secondArray = [dict objectForKey:@"second"];
        NSDictionary* via = [dict objectForKey:@"via"];
    }else{
        NSArray* searchResultArray = [dataDictionary objectForKey:@"data"];
    }
}
-(void)tweet:(UIButton*)sender{
    /*
     connectionView.getOnLabel1.text = [info objectForKey:@"firstName"];
     connectionView.getOffLabel1.text = [info objectForKey:@"secondName"];
     connectionView.departureLabel1.text = [info objectForKey:@"firstDeparturesTime"];
     connectionView.destinationLabel1.text = [NSString stringWithFormat:@"%@ 行き",[info objectForKey:@"firstDestination"]];
     connectionView.detailLabel1.text = [info objectForKey:@"firstDetail"];
     connectionView.arrivalLabel1.text = [info objectForKey:@"firstArraivalTime"];

     */
    if((RouteType)[[dataDictionary objectForKey:@"type"]intValue] == RouteTypeComplex){
        NSString* setText = [NSString stringWithFormat:@"%@(%@)→%@(%@)\n%@\n\n%@(%@)→%@(%@)\n%@\n\n#はこバス",connectionView.getOnLabel1.text,connectionView.departureLabel1.text,connectionView.getOffLabel1.text,connectionView.arrivalLabel1.text, [connectionView.detailLabel1.text stringByReplacingOccurrencesOfString:@"*****" withString:@"遅延情報はありません。"],connectionView.getOnLabel2.text,connectionView.departureLabel2.text,connectionView.getOffLabel2.text,connectionView.arrivalLabel2.text,[connectionView.detailLabel2.text stringByReplacingOccurrencesOfString:@"*****" withString:@"遅延情報はありません。"]];
        
        //投稿用画面のインスタンスを作成
        SLComposeViewController* composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [composeController setInitialText:setText]; //コメントのセット
        
        //投稿が完了したかの確認
        [composeController setCompletionHandler:^(SLComposeViewControllerResult result) {
            if (result == SLComposeViewControllerResultCancelled) {
                // キャンセルした場合
                NSLog(@"キャンセルしました");
            } else if (result == SLComposeViewControllerResultDone) {
                // 投稿に成功した場合
                NSLog(@"投稿しました");
            }
            //serviceTypeがtwitterの場合
            //Twitterの画面だと戻るボタンを押しても前の画面に遷移しない為、このメソッドを入れる。
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [self presentViewController:composeController animated:YES completion:nil];
    }else{
        NSString* setText = [NSString stringWithFormat:@"%@(%@)→%@(%@)\n%@\n\n#はこバス",noConnectionView.getOnLabel.text,noConnectionView.departureLabel.text,noConnectionView.getOffLabel.text,noConnectionView.arrivalLabel.text,[noConnectionView.detailLabel.text stringByReplacingOccurrencesOfString:@"*****" withString:@"遅延情報はありません。"]];
        
        //投稿用画面のインスタンスを作成
        SLComposeViewController* composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [composeController setInitialText:setText]; //コメントのセット
        
        //投稿が完了したかの確認
        [composeController setCompletionHandler:^(SLComposeViewControllerResult result) {
            if (result == SLComposeViewControllerResultCancelled) {
                // キャンセルした場合
                NSLog(@"キャンセルしました");
            } else if (result == SLComposeViewControllerResultDone) {
                // 投稿に成功した場合
                NSLog(@"投稿しました");
            }
            //serviceTypeがtwitterの場合
            //Twitterの画面だと戻るボタンを押しても前の画面に遷移しない為、このメソッドを入れる。
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [self presentViewController:composeController animated:YES completion:nil];
    }
}
-(void)showTimerList:(UIButton*)sender{
    if((RouteType)[[dataDictionary objectForKey:@"type"]intValue] == RouteTypeComplex){
        NSDictionary* dict = [dataDictionary objectForKey:@"data"];
        NSArray* firstArray = [dict objectForKey:@"first"];
        NSArray* secondArray = [dict objectForKey:@"second"];
        NSDictionary* via = [dict objectForKey:@"via"];
    }else{
        NSArray* searchResultArray = [dataDictionary objectForKey:@"data"];
    }
}
-(void)addBookmark:(UIButton*)sender{
    if((RouteType)[[dataDictionary objectForKey:@"type"]intValue] == RouteTypeComplex){
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        // NSArrayの保存
        NSMutableArray* array = [NSMutableArray array];
        array = [[defaults objectForKey:@"Favorite"]mutableCopy];
        if(!array){
            array = [NSMutableArray array];
        }
        NSDictionary* data = [[NSDictionary alloc]initWithObjectsAndKeys:[BusSearchManager sharedManager].GetOffBusStop,@"getOff",[BusSearchManager sharedManager].GetOnBusStop,@"getOn",[BusSearchManager sharedManager].viaBusStop,@"via",nil];
        
        NSDictionary* dict = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:RouteTypeComplex],@"type",data,@"data",nil];
        
        if([array containsObject:dict]){
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ブックマーク" message:@"既にブックマークに登録されています。" preferredStyle:UIAlertControllerStyleAlert];
            // addActionした順に左から右にボタンが配置されます
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }else{
            [array addObject:dict];
            if([array count] > 100){
                [array removeObject:[array firstObject]];
            }
            [defaults setObject:array forKey:@"Favorite"];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ブックマーク" message:@"路線をブックマークに登録しました。" preferredStyle:UIAlertControllerStyleAlert];
            // addActionした順に左から右にボタンが配置されます
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
    }else{
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        // NSArrayの保存
        NSMutableArray* array = [NSMutableArray array];
        array = [[defaults objectForKey:@"Favorite"]mutableCopy];
        if(!array){
            array = [NSMutableArray array];
        }
        
        NSDictionary* data = [[NSDictionary alloc]initWithObjectsAndKeys:[BusSearchManager sharedManager].GetOffBusStop,@"getOff",[BusSearchManager sharedManager].GetOnBusStop,@"getOn",nil];
        
        NSDictionary* dict = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:RouteTypeSimple],@"type",data,@"data",nil];
        
        if([array containsObject:dict]){
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ブックマーク" message:@"既にブックマークに登録されています。" preferredStyle:UIAlertControllerStyleAlert];
            // addActionした順に左から右にボタンが配置されます
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
            
        }else{
            [array addObject:dict];
            if([array count] > 100){
                [array removeObject:[array firstObject]];
            }
            [defaults setObject:array forKey:@"Favorite"];
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"ブックマーク" message:@"路線をブックマークに登録しました。" preferredStyle:UIAlertControllerStyleAlert];
            // addActionした順に左から右にボタンが配置されます
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }

    }
}
-(void)viewDidLayoutSubviews{
    self.switchButton.clipsToBounds = YES;
    self.switchButton.layer.cornerRadius = self.switchButton.frame.size.height / 4;
    self.switchButton.layer.masksToBounds = NO;
    self.switchButton.layer.shadowOffset = CGSizeMake(2,2); // 上向きの影
    self.switchButton.layer.shadowRadius = 2.0f;
    self.switchButton.layer.shadowOpacity = 0.6f;
}
#pragma mark 乗車と降車を入れ替え
- (IBAction)switchBusStop:(id)sender {
    // Do any additional setup after loading the view.
    NSDictionary* getOn = [[BusSearchManager sharedManager]GetOnBusStop];
    NSDictionary* getOff = [[BusSearchManager sharedManager]GetOffBusStop];
    
    [BusSearchManager sharedManager].GetOnBusStop = getOff;
    [BusSearchManager sharedManager].GetOffBusStop = getOn;
    showCnt = 0;
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
    NSDictionary* via = [[BusSearchManager sharedManager]viaBusStop];
    
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
        if(!via){
            [[RouteSearchManager sharedManager]getRouteWithGetOn:getOn getOff:getOff completionHandler:^(NSDictionary* dict,NSError *error){
                if(error){
                    NSLog(@"%@",error.localizedDescription);
                    errorLabel.text = error.localizedDescription;
                    errorLabel.hidden = false;
                    [indicator stopAnimating];
                    indicator.hidden = true;
                }else{
                    dataDictionary = dict;
                    [self showSearchResult];
                }
            }];
        }else{
            [[RouteSearchManager sharedManager]getRouteWithGetOn:getOn getOff:getOff via:via completionHandler:^(NSDictionary* dict,NSError *error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(error){
                        NSLog(@"%@",error.localizedDescription);
                        errorLabel.text = error.localizedDescription;
                        errorLabel.hidden = false;
                        [indicator stopAnimating];
                        indicator.hidden = true;
                    }else{
                        dataDictionary = dict;
                        [self showSearchResult];
                    }
                });
            }];
        }
        
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
-(void)showSearchResult{
    // Do any additional setup after loading the view.
    NSDictionary* getOn = [[BusSearchManager sharedManager]GetOnBusStop];
    NSDictionary* getOff = [[BusSearchManager sharedManager]GetOffBusStop];
    
    if((RouteType)[[dataDictionary objectForKey:@"type"]intValue] == RouteTypeComplex){
        NSDictionary* dict = [dataDictionary objectForKey:@"data"];
        NSArray* firstArray = [dict objectForKey:@"first"];
        NSArray* secondArray = [dict objectForKey:@"second"];
        NSDictionary* via = [dict objectForKey:@"via"];
        
        [[BusSearchManager sharedManager]GETArrivedTimeWithURL:[[firstArray objectAtIndex:showCnt] objectForKey:@"url"] completionHandler:^(NSArray* array,NSError *error){
            if(error){
                NSLog(@"%@",error.localizedDescription);
                errorLabel.text = error.localizedDescription;
                errorLabel.hidden = false;
                [indicator stopAnimating];
                indicator.hidden = true;
                
                connectionView.hidden = true;
                leftButton.hidden = true;
                rightButton.hidden = true;
                leftButton.enabled = false;
                rightButton.enabled = false;
                timeLabel.hidden = true;

                return;
            }
            for(NSDictionary* dict2 in array){
                if([[dict2 objectForKey:@"name"] isEqualToString:[via objectForKey:@"name"]]
                   ){
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
                        errorLabel.text = @"上記路線の本日の運行は終了しました。";
                        errorLabel.hidden = false;
                        [indicator stopAnimating];
                        indicator.hidden = true;
                        
                        connectionView.hidden = true;
                        [indicator stopAnimating];
                        indicator.hidden = true;
                        leftButton.hidden = true;
                        rightButton.hidden = false;
                        leftButton.enabled = false;
                        rightButton.enabled = true;
                        timeLabel.hidden = false;
                        
                        return;
                    }
                    
                    [[BusSearchManager sharedManager]GETArrivedTimeWithURL:[[secondArray objectAtIndex:cnt] objectForKey:@"url"] completionHandler:^(NSArray* array2,NSError *error){
                        if(error){
                            NSLog(@"%@",error.localizedDescription);
                            errorLabel.text = error.localizedDescription;
                            errorLabel.hidden = false;
                            [indicator stopAnimating];
                            indicator.hidden = true;

                            connectionView.hidden = true;
                            leftButton.hidden = true;
                            rightButton.hidden = true;
                            leftButton.enabled = false;
                            rightButton.enabled = false;
                            timeLabel.hidden = true;

                            return;
                        }
                        
                        for(NSDictionary* dict3 in array2){
                            if([[dict3 objectForKey:@"name"] isEqualToString:[getOff objectForKey:@"name"]]
                               ){
                                
                                connectionView.hidden = false;
                                [indicator stopAnimating];
                                indicator.hidden = true;
                                leftButton.hidden = false;
                                rightButton.hidden = false;
                                leftButton.enabled = true;
                                rightButton.enabled = true;
                                timeLabel.hidden = false;

                                
                                NSDictionary* info = [[NSDictionary alloc]initWithObjectsAndKeys:
                                 [[firstArray objectAtIndex:showCnt] objectForKey:@"destination"],@"firstDestination",
                                 [getOn objectForKey:@"name"],@"firstName",
                                 [[firstArray objectAtIndex:showCnt] objectForKey:@"time"],@"firstDeparturesTime",
                                 [dict2 objectForKey:@"time"],@"firstArraivalTime",
                                 [[firstArray objectAtIndex:showCnt] objectForKey:@"detail"],@"firstDetail",
                                 [[firstArray objectAtIndex:showCnt] objectForKey:@"url"],@"firstURL",
                                 [[firstArray objectAtIndex:showCnt] objectForKey:@"map"],@"firstMap",
                                 [[secondArray objectAtIndex:cnt] objectForKey:@"destination"],@"secondDestination",
                                 [dict2 objectForKey:@"name"],@"secondName",
                                 [[secondArray objectAtIndex:cnt] objectForKey:@"time"],@"secondDeparturesTime",
                                 [dict3 objectForKey:@"time"],@"secondArraivalTime",
                                 [[secondArray objectAtIndex:cnt] objectForKey:@"detail"],@"secondDetail",
                                 [[secondArray objectAtIndex:cnt] objectForKey:@"url"],@"secondURL",
                                 [[secondArray objectAtIndex:cnt] objectForKey:@"map"],@"secndMap",
                                 [getOff objectForKey:@"name"],@"getOff",nil];
                                
                                 timeLabel.text = [NSString stringWithFormat:@"%@発",[info objectForKey:@"firstDeparturesTime"]];
                                 connectionView.getOnLabel1.text = [info objectForKey:@"firstName"];
                                 connectionView.getOffLabel1.text = [info objectForKey:@"secondName"];
                                 connectionView.departureLabel1.text = [info objectForKey:@"firstDeparturesTime"];
                                 connectionView.destinationLabel1.text = [NSString stringWithFormat:@"%@ 行き",[info objectForKey:@"firstDestination"]];
                                 connectionView.detailLabel1.text = [info objectForKey:@"firstDetail"];
                                 connectionView.arrivalLabel1.text = [info objectForKey:@"firstArraivalTime"];
                                //[[firstArray objectAtIndex:showCnt] objectForKey:@"url"]
                                //[[secondArray objectAtIndex:cnt] objectForKey:@"url"]
                                if([[info objectForKey:@"firstMap"] isEqualToString:@""]){
                                    connectionView.mapButton1.hidden = true;
                                }else{
                                    connectionView.mapButton1.hidden = false;
                                }
                                 connectionView.getOnLabel2.text = [info objectForKey:@"secondName"];
                                 connectionView.getOffLabel2.text = [info objectForKey:@"getOff"];
                                 connectionView.departureLabel2.text = [info objectForKey:@"secondDeparturesTime"];
                                 connectionView.destinationLabel2.text = [NSString stringWithFormat:@"%@ 行き",[info objectForKey:@"secondDestination"]];
                                 connectionView.detailLabel2.text = [info objectForKey:@"secondDetail"];
                                 connectionView.arrivalLabel2.text = [info objectForKey:@"secondArraivalTime"];
                                if([[info objectForKey:@"secondMap"] isEqualToString:@""]){
                                    connectionView.mapButton2.hidden = true;
                                }else{
                                    connectionView.mapButton2.hidden = false;
                                }
                                
                                 if(showCnt == 0){
                                     leftButton.hidden = true;
                                 }
                                
                                //1個次のデータも見ておく(あまり綺麗なやり方ではないが)
                                if([firstArray count] > showCnt + 1){
                                    [[BusSearchManager sharedManager]GETArrivedTimeWithURL:[[firstArray objectAtIndex:showCnt + 1] objectForKey:@"url"] completionHandler:^(NSArray* array3,NSError *error){
                                        for(NSDictionary* dict4 in array3){
                                            if([[dict4 objectForKey:@"name"] isEqualToString:[via objectForKey:@"name"]]
                                               ){
                                                NSDictionary* timeDic3 = [self strTimeToCalculableValueWithString:[dict4 objectForKey:@"time"]];
                                                int cnt2 = 0;//カウンタ
                                                for(NSDictionary* viaDict2 in secondArray){
                                                    NSDictionary* timeDic4 = [self strTimeToCalculableValueWithString:[viaDict2 objectForKey:@"time"]];
                                                    if(([[timeDic3 objectForKey:@"hour"]intValue] * 60 + [[timeDic3 objectForKey:@"min"]intValue]) > ([[timeDic4 objectForKey:@"hour"]intValue] * 60 + [[timeDic4 objectForKey:@"min"]intValue])){
                                                        cnt2++;
                                                    }
                                                }
                                                if(cnt2 >= [secondArray count]){
                                                    rightButton.hidden = true;
                                                }else{
                                                    if(showCnt == [[[dataDictionary objectForKey:@"data"]objectForKey:@"first"] count]-1){
                                                        rightButton.hidden = true;
                                                    }
                                                }
                                            }
                                        }
                                    }];
                                }else{
                                    if(showCnt == [[[dataDictionary objectForKey:@"data"]objectForKey:@"first"] count]-1){
                                        rightButton.hidden = true;
                                    }
                                }
                            }
                        }
                    }];
                }
            }
        }];
    }else{
        NSArray* searchResultArray = [dataDictionary objectForKey:@"data"];
        NSLog(@"dataDictionary = %@",dataDictionary);
        NSLog(@"searchResult = %@",searchResultArray);
        [[BusSearchManager sharedManager]GETArrivedTimeWithURL:[[searchResultArray objectAtIndex:showCnt]objectForKey:@"url"] completionHandler:^(NSArray* array2,NSError * error){
            if(error){
                NSLog(@"%@",error.localizedDescription);
                errorLabel.text = error.localizedDescription;
                errorLabel.hidden = false;
                [indicator stopAnimating];
                indicator.hidden = true;

                noConnectionView.hidden = true;
                leftButton.hidden = true;
                rightButton.hidden = true;
                leftButton.enabled = false;
                rightButton.enabled = false;
                timeLabel.hidden = true;

                return;
            }
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
                    if([[[searchResultArray objectAtIndex:showCnt]objectForKey:@"map"] isEqualToString:@""]){
                        noConnectionView.mapButton.hidden = true;
                    }else{
                        noConnectionView.mapButton.hidden = false;
                    }
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
    if([BusSearchManager sharedManager].viaBusStop){
        if(showCnt > (int)[[[dataDictionary objectForKey:@"data"]objectForKey:@"first"] count]-1){
            showCnt = MIN(showCnt, (int)[[[dataDictionary objectForKey:@"data"]objectForKey:@"first"] count]-1);
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
        if(showCnt > (int)[[dataDictionary objectForKey:@"data"] count]-1){
            showCnt = MIN(showCnt, (int)[[dataDictionary objectForKey:@"data"] count]-1);
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
