//
//  MyRouteViewController.m
//  FunApp
//
//  Created by Atsuya Sato on 2016/02/27.
//  Copyright © 2016年 Atsuya Sato. All rights reserved.
//

#import "MyRouteViewController.h"

@interface MyRouteViewController ()

@end

@implementation MyRouteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.getOnTextField.delegate = self;
    self.getOnTextField.tag = 0;
    self.getOffTextField.delegate = self;
    self.getOffTextField.tag = 1;

    self.getOnWebView.delegate = self;
    self.getOnWebView.tag = 0;
    self.getOffWebView.delegate = self;
    self.getOffWebView.tag = 1;

    textFieldArray = [NSArray arrayWithObjects:self.getOnTextField,self.getOffTextField,nil];
    webViewArray = [NSArray arrayWithObjects:self.getOnWebView,self.getOffWebView,nil];
    
    self.getOnWebView.hidden = YES;
    self.getOffWebView.hidden = YES;

    self.doneButton.hidden = YES;
    
    self.getOnLabel.text = @"";
    self.getOffLabel.text = @"";
    labelArray = [NSArray arrayWithObjects:self.getOnLabel,self.getOffLabel, nil];
    
    getOnSearchArray = [NSArray array];
    getOffSearchArray = [NSArray array];
    searchArrays = [NSMutableArray arrayWithObjects:getOnSearchArray,getOffSearchArray,nil];

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
-(void)viewWillAppear:(BOOL)animated{
    self.viaLabel.text = @"";
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.io.github.natmark.FunApp"];
    NSDictionary* dict = [defaults objectForKey:@"MyRoute"];
    
    if(dict){
        if([[dict objectForKey:@"type"]intValue] == RouteTypeComplex)self.viaLabel.text = [NSString stringWithFormat:@"経由:%@",[[[dict objectForKey:@"data"]objectForKey:@"via"]objectForKey:@"name"]];
        
        self.getOnLabel.text = [[[dict objectForKey:@"data"]objectForKey:@"getOn"]objectForKey:@"name"];
        self.getOnTextField.text = [[[dict objectForKey:@"data"]objectForKey:@"getOn"]objectForKey:@"name"];
        self.getOffLabel.text = [[[dict objectForKey:@"data"]objectForKey:@"getOff"]objectForKey:@"name"];
        self.getOffTextField.text = [[[dict objectForKey:@"data"]objectForKey:@"getOff"]objectForKey:@"name"];
        getOnBusStop = [[dict objectForKey:@"data"]objectForKey:@"getOn"];
        getOffBusStop = [[dict objectForKey:@"data"]objectForKey:@"getOff"];
    }
    if(getOnBusStop && getOffBusStop){
        if([getOnBusStop objectForKey:@"id"] != [getOffBusStop objectForKey:@"id"]){
            self.doneButton.hidden = NO;
        }
    }
}
// UITextFieldのキーボード上の「Return」ボタンが押された時に呼ばれる処理
- (BOOL)textFieldShouldReturn:(UITextField *)sender {
    // キーボードを閉じる
    [sender resignFirstResponder];
    UIWebView* webView = [webViewArray objectAtIndex:sender.tag];
    NSArray* searchArray = [searchArrays objectAtIndex:sender.tag];
    searchArray = [[BusSearchManager sharedManager]busSearch:sender.text];
    [searchArrays replaceObjectAtIndex:sender.tag withObject:searchArray];
    if([searchArray count] != 0){
        [indicator startAnimating];
        indicator.hidden = false;
        
        //上記JSが動いているUIWebViewのdelegateを指定します。
        for (id subView in webView.subviews) {
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
        UILabel* label = [labelArray objectAtIndex:sender.tag];
        label.text = [[searchArray objectAtIndex:0]objectForKey:@"name"];
        if(sender.tag == 0) getOnBusStop = [searchArray objectAtIndex:0];
        else getOffBusStop = [searchArray objectAtIndex:0];
        
        html = [NSString stringWithFormat:@"%@</select></form>",html];
        
        //ロード待ちが必要
        [webView loadHTMLString:html baseURL:[[NSBundle mainBundle] resourceURL]];
        
    }else{
        UILabel* label = [labelArray objectAtIndex:sender.tag];
        label.text = @"";
        webView.hidden = YES;
        self.doneButton.hidden = YES;
    }
    return YES;
}
#pragma mark webViewが読み込み終わったとき
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [indicator stopAnimating];
    indicator.hidden = YES;
    webView.hidden = NO;
    
    if(getOnBusStop && getOffBusStop){
        if([getOnBusStop objectForKey:@"id"] != [getOffBusStop objectForKey:@"id"]){
            self.doneButton.hidden = NO;
        }
    }
}
#pragma mark webViewが読み込み始めたとき
-(void)webViewDidStartLoad:(UIWebView *)webView{
    webView.hidden = YES;
    self.doneButton.hidden = YES;
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
        //[self performSelector:NSSelectorFromString([NSString stringWithFormat:@"selectChange:"])withObject:urlStr];
        [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"selectChange:withIndex:"]) withObject:urlStr withObject:aWebView];
        // カスタムスキームの場合には、リクエストを中止します。
        return NO;
    }
    
    // 上記以外は、リクエストが外部へ放出することを許可します。
    return YES;
}


#pragma mark - Actions
// JavaScriptから指定されて呼び出されるメソッド。
-(void)selectChange:(NSString *)tag withIndex:(UIWebView*)webView{
    NSArray* searchArray = [searchArrays objectAtIndex:webView.tag];
    if(webView.tag == 0) getOnBusStop = [searchArray objectAtIndex:[tag integerValue]];
    else getOffBusStop = [searchArray objectAtIndex:[tag integerValue]];
    
    UILabel* label = [labelArray objectAtIndex:webView.tag];
    label.text = [[searchArray objectAtIndex:[tag integerValue]]objectForKey:@"name"];
    if(getOnBusStop && getOffBusStop){
        if([getOnBusStop objectForKey:@"id"] != [getOffBusStop objectForKey:@"id"]){
            self.doneButton.hidden = NO;
        }
    }
}

- (IBAction)doneSetting:(id)sender {
    //経由バス停を消してしまう
    [indicator startAnimating];
    indicator.hidden = false;
    [[BusSearchManager sharedManager]isExistRouteWithGetOn:[[getOnBusStop objectForKey:@"code"]intValue] getOff:[[getOffBusStop objectForKey:@"code"]intValue] completionHandler:^(BOOL flg,NSError *error){
        
        if(error){
            [indicator stopAnimating];
            indicator.hidden = true;
            
            //エラー
            UIAlertView *alert =
            [[UIAlertView alloc]
             initWithTitle:@"エラー"
             message:[error domain]
             delegate:nil
             cancelButtonTitle:nil
             otherButtonTitles:@"OK", nil
             ];
            [alert show];

        }else{
            if(flg){
                [indicator stopAnimating];
                indicator.hidden = true;
                
                NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.io.github.natmark.FunApp"];
                NSDictionary* data = [[NSDictionary alloc]initWithObjectsAndKeys:getOffBusStop,@"getOff",getOnBusStop,@"getOn",nil];
                NSDictionary* dict = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:RouteTypeSimple],@"type",data,@"data",nil];
                [defaults setObject:dict forKey:@"MyRoute"];
                
                //乗り換え無し
                UIAlertView *alert =
                [[UIAlertView alloc]
                 initWithTitle:@"Myルート登録"
                 message:@"設定を変更しました"
                 delegate:nil
                 cancelButtonTitle:nil
                 otherButtonTitles:@"OK", nil
                 ];
                [alert show];

            }else{
                [[RouteSearchManager sharedManager]getViaListWithGetOn:getOnBusStop getOff:getOffBusStop completionHandler:^(NSArray *arrayList,NSError *error){
                    [indicator stopAnimating];
                    indicator.hidden = true;
                    
                    if(error){
                        //エラー
                        UIAlertView *alert =
                        [[UIAlertView alloc]
                         initWithTitle:@"エラー"
                         message:[error domain]
                         delegate:nil
                         cancelButtonTitle:nil
                         otherButtonTitles:@"OK", nil
                         ];
                        [alert show];

                    }else{
                        if([arrayList count] == 0){
                            //乗り継ぎ無し
                            //エラー
                            UIAlertView *alert =
                            [[UIAlertView alloc]
                             initWithTitle:@"エラー"
                             message:@"ルートが見つかりませんでした"
                             delegate:nil
                             cancelButtonTitle:nil
                             otherButtonTitles:@"OK", nil
                             ];
                            [alert show];

                        }else{
                            //乗り継ぎ検索
                            //SelectViaを開いてtypeComplexでMyRoute保存
                            //この画面上で経由を表示できるようにしておく必要がある。
                            SelectViaModalViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectViaModalViewController"];
                            viewController.getOffBusStop = getOffBusStop;
                            viewController.getOnBusStop = getOnBusStop;
                            
                            [self presentViewController:viewController animated:YES completion:nil];
                            
                            /*
                            NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
                            NSDictionary* data = [[NSDictionary alloc]initWithObjectsAndKeys:getOffBusStop,@"getOff",getOnBusStop,@"getOn",nil];
                            NSDictionary* dict = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:RouteTypeSimple],@"type",data,@"data",nil];
                            [defaults setObject:dict forKey:@"MyRoute"];
                            
                            SelectViaViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectViaViewController"];
                            [self.navigationController pushViewController:viewController animated:YES];
                         */
                        }
                    }
                }];
            }
        }
    }];
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
