//
//  InputGetOffBusStopViewController.m
//  FunApp
//
//  Created by Atsuya Sato on 2015/11/11.
//  Copyright © 2015年 Atsuya Sato. All rights reserved.
//

#import "InputGetOffBusStopViewController.h"

@interface InputGetOffBusStopViewController ()

@end

@implementation InputGetOffBusStopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.textField.delegate = self;
    self.webView.delegate = self;
    
    self.webView.hidden = true;
    self.busStopLabel.hidden = true;
    self.label1.hidden = true;
    self.searchButton.hidden = true;
    
    //インジケーター
    /*==========================*/
    indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.frame = CGRectMake(0, 0, 100, 100);
    indicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    indicator.backgroundColor = [UIColor colorWithRed:184/255.0 green:29/255.0 blue:31/255.0 alpha:1.0];
    indicator.layer.cornerRadius = indicator.frame.size.width * 0.1;
    indicator.hidden = true;
    [self.view addSubview:indicator];
    /*==========================*/

}
- (IBAction)pressedSearchButton:(id)sender {
    if([BusSearchManager sharedManager].GetOnBusStop && [BusSearchManager sharedManager].GetOffBusStop){
        //経由バス停を消してしまう
        [BusSearchManager sharedManager].viaBusStop = nil;
        [indicator startAnimating];
        indicator.hidden = false;
        [[BusSearchManager sharedManager]isExistRouteWithGetOn:[[[BusSearchManager sharedManager].GetOnBusStop objectForKey:@"code"]intValue] getOff:[[[BusSearchManager sharedManager].GetOffBusStop objectForKey:@"code"]intValue] completionHandler:^(BOOL flg,NSError *error){
            
            if(error){
                [indicator stopAnimating];
                indicator.hidden = true;
                
                SearchRouteViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchRouteViewController"];
                [self.navigationController pushViewController:viewController animated:YES];
            }else{
                if(flg){
                    [indicator stopAnimating];
                    indicator.hidden = true;
                    
                    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
                    // NSArrayの保存
                    NSMutableArray* array = [NSMutableArray array];
                    array = [[defaults objectForKey:@"History"]mutableCopy];
                    if(!array){
                        array = [NSMutableArray array];
                    }

                    NSDictionary* data = [[NSDictionary alloc]initWithObjectsAndKeys:[BusSearchManager sharedManager].GetOffBusStop,@"getOff",[BusSearchManager sharedManager].GetOnBusStop,@"getOn",nil];

                    NSDictionary* dict = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:RouteTypeSimple],@"type",data,@"data",nil];

                    [array addObject:dict];
                    if([array count] > 100){
                        [array removeObject:[array firstObject]];
                    }
                    [defaults setObject:array forKey:@"History"];
                    
                    
                    SearchRouteViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchRouteViewController"];
                    [self.navigationController pushViewController:viewController animated:YES];
                }else{
                    [[RouteSearchManager sharedManager]getViaListWithGetOn:[BusSearchManager sharedManager].GetOnBusStop getOff:[BusSearchManager sharedManager].GetOffBusStop completionHandler:^(NSArray *arrayList,NSError *error){
                        [indicator stopAnimating];
                        indicator.hidden = true;
                        
                        if(error){
                            SearchRouteViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchRouteViewController"];
                            [self.navigationController pushViewController:viewController animated:YES];
                        }else{
                            if([arrayList count] == 0){
                                NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
                                // NSArrayの保存
                                NSMutableArray* array = [NSMutableArray array];
                                array = [[defaults objectForKey:@"History"]mutableCopy];
                                if(!array){
                                    array = [NSMutableArray array];
                                }
                                NSDictionary* data = [[NSDictionary alloc]initWithObjectsAndKeys:[BusSearchManager sharedManager].GetOffBusStop,@"getOff",[BusSearchManager sharedManager].GetOnBusStop,@"getOn",nil];
                                
                                NSDictionary* dict = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:RouteTypeSimple],@"type",data,@"data",nil];
                                
                                [array addObject:dict];
                                if([array count] > 100){
                                    [array removeObject:[array firstObject]];
                                }
                                [defaults setObject:array forKey:@"History"];
                                
                                
                                SearchRouteViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchRouteViewController"];
                                [self.navigationController pushViewController:viewController animated:YES];
                                
                            }else{
                                SelectViaViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectViaViewController"];
                                [self.navigationController pushViewController:viewController animated:YES];
                            }
                        }
                    }];
                }
            }
        }];
    }else{
        //データ取得に失敗
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
// UITextFieldのキーボード上の「Return」ボタンが押された時に呼ばれる処理
- (BOOL)textFieldShouldReturn:(UITextField *)sender {
    // キーボードを閉じる
    [sender resignFirstResponder];
    
    searchArray = [[BusSearchManager sharedManager]busSearch:sender.text];
    self.busStopLabel.hidden = true;
    
    if([searchArray count] != 0){
        [indicator startAnimating];
        indicator.hidden = false;

        //上記JSが動いているUIWebViewのdelegateを指定します。
        for (id subView in self.webView.subviews) {
            if ([[subView class] isSubclassOfClass:[UIScrollView class]]) {
                ((UIScrollView *)subView).scrollEnabled = NO;   // スクロール禁止
                ((UIScrollView *)subView).bounces = NO; // バウンス禁止
            }
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        NSString *html = @"<script>function selectNavi(){var num;num = document.navi.contents.selectedIndex;var str = 'api-funapp://' + String(num);location.href = str;return false;}</script><form name='navi'><select name='contents' onchange='selectNavi()'>";
        
        for(NSDictionary* dict in searchArray){
            html = [NSString stringWithFormat:@"%@<option>%@</option>",html,[dict objectForKey:@"name"]];
        }
        self.busStopLabel.text = [[searchArray objectAtIndex:0]objectForKey:@"name"];
        [BusSearchManager sharedManager].GetOffBusStop = [searchArray objectAtIndex:0];

        html = [NSString stringWithFormat:@"%@</select></form>",html];
        
        //ロード待ちが必要
        [self.webView loadHTMLString:html baseURL:[[NSBundle mainBundle] resourceURL]];
        
    }else{
        self.webView.hidden = true;
        self.busStopLabel.text = @"検索結果がありません。";
        self.busStopLabel.hidden = false;
        self.label1.hidden = true;
        self.searchButton.hidden = true;
    }
    return TRUE;
}
#pragma mark webViewが読み込み終わったとき
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [indicator stopAnimating];
    indicator.hidden = true;

    self.webView.hidden = false;
    self.busStopLabel.hidden = false;
    self.label1.hidden = false;
    self.searchButton.hidden = false;
}
#pragma mark webViewが読み込み始めたとき
-(void)webViewDidStartLoad:(UIWebView *)webView{
    self.webView.hidden = true;
    self.busStopLabel.hidden = true;
    self.label1.hidden = true;
    self.searchButton.hidden = true;
}
#pragma mark - UIWebViewDelegate
// JavaScriptやリンクなどでサーバーへのリクエストが発生した際に呼び出されるメソッド。
- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    // もしNative連携用のURLスキームの場合には、処理する。
    NSString *urlStr = request.URL.absoluteString;
    if ([urlStr hasPrefix:@"api-funapp://"]) {
        
        // %エスケープされた内容を、デコードする。
        urlStr = [urlStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        // 不要な部分を削除する。
        urlStr = [urlStr stringByReplacingOccurrencesOfString:@"api-funapp://" withString:@""];
        // メソッドをコールします。
        [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"selectChange:"])
                   withObject:urlStr];
        
        // カスタムスキームの場合には、リクエストを中止します。
        return NO;
    }
    
    // 上記以外は、リクエストが外部へ放出することを許可します。
    return YES;
}


#pragma mark - Actions
// JavaScriptから指定されて呼び出されるメソッド。
-(void)selectChange:(NSString *)tag {
    self.busStopLabel.text = [[searchArray objectAtIndex:[tag integerValue]]objectForKey:@"name"];
    [BusSearchManager sharedManager].GetOffBusStop = [searchArray objectAtIndex:[tag integerValue]];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end