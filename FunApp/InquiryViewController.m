//
//  InquiryViewController.m
//  FunApp
//
//  Created by Atsuya Sato on 2016/01/30.
//  Copyright © 2016年 Atsuya Sato. All rights reserved.
//

#import "InquiryViewController.h"
#include <sys/types.h>
#include <sys/sysctl.h>

@interface InquiryViewController ()

@end

@implementation InquiryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.textView.layer.borderColor = [[UIColor grayColor]CGColor];
    self.textView.layer.borderWidth = 1.0;
    self.textView.delegate = self;
    self.textView.inputAccessoryView = [self getAccessoryView];
    
    self.webView.delegate = self;
    self.webView.hidden = true;
    
    NSString *subject = @"■お問い合わせ「はこバス」に関して(以下に本文を記入してください。操作方法等の返信を希望する場合、メールアドレスを追記してください。)";
    UIDevice *device = [UIDevice currentDevice];
    NSLog(@"HWModel: %@", device.model);
    
    NSString *body = @"＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝\n※以下の情報は変更しないで下さい。\n";
    
    body = [body stringByAppendingFormat:@"Device=%@\n",device.model];
    
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    
    body = [body stringByAppendingFormat:@"Platform=%@\n",platform];
    
    body = [body stringByAppendingFormat:@"SystemVer=%@\n",[[UIDevice currentDevice] systemVersion]];
    body = [body stringByAppendingFormat:@"AppVer=%@\n",[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey]];

    body = [body stringByAppendingString:@"＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝"];

    self.textView.text = [NSString stringWithFormat:@"%@\n\n\n\n\n\n%@",subject,body];
    
    searchArray = [NSArray arrayWithObjects:@"バグ報告:ホーム画面",@"バグ報告:バス停入力画面",@"バグ報告:経由選択画面",@"バグ報告:検索結果画面",@"バグ報告:地図表示画面",@"バグ報告:通過時間表示画面",@"バグ報告:ブックマーク画面",@"バグ報告:履歴画面",@"バグ報告:設定画面",@"バグ報告:その他",@"操作方法",@"その他",nil];
    
    if([searchArray count] != 0){
        itemStr = [searchArray firstObject];
        //上記JSが動いているUIWebViewのdelegateを指定します。
        for (id subView in self.webView.subviews) {
            if ([[subView class] isSubclassOfClass:[UIScrollView class]]) {
                ((UIScrollView *)subView).scrollEnabled = NO;   // スクロール禁止
                ((UIScrollView *)subView).bounces = NO; // バウンス禁止
            }
        }
        
        // Do any additional setup after loading the view, typically from a nib.
        NSString *html = @"<script>function selectNavi(){var num;num = document.navi.contents.selectedIndex;var str = 'api-funapp://' + String(num);location.href = str;return false;}</script><form name='navi'><div><select name='contents' onchange='selectNavi()'>";
        
        for(NSString* txt in searchArray){
            html = [NSString stringWithFormat:@"%@<option>%@</option>",html,txt];
        }
        
        html = [NSString stringWithFormat:@"%@</select></div></form>",html];
        NSLog(@"%@",html);
        
        //ロード待ちが必要
        [self.webView loadHTMLString:html baseURL:[[NSBundle mainBundle] resourceURL]];
        
    }

}
- (UIView *)getAccessoryView
{
    UIView *accessoryView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 280.0f, 40.0f)];
    accessoryView.backgroundColor = [UIColor whiteColor];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(250.0f, 5.0f, 65.0f, 34.0f);
    [button setTitle:@"閉じる" forState:UIControlStateNormal];
    
    // ボタンを押した時のイベント
    [button addTarget:self action:@selector(closeKeyboard:) forControlEvents:UIControlEventTouchUpInside];
    
    // View にボタン追加
    [accessoryView addSubview:button];
    
    return accessoryView;
}
-(void)closeKeyboard:(UIButton*)sender{
    [self.textView resignFirstResponder];
}
#pragma mark webViewが読み込み終わったとき
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    self.webView.hidden = false;
}
#pragma mark webViewが読み込み始めたとき
-(void)webViewDidStartLoad:(UIWebView *)webView{
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView{
    [textView resignFirstResponder];
    return YES;
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
    itemStr = [searchArray objectAtIndex:[tag integerValue]];
}
- (IBAction)pushSendButton:(id)sender {
    [self postJSONToSlack:[NSString stringWithFormat:@"お問い合わせ項目:「%@」\n%@\n",itemStr,self.textView.text]];
}
- (void)postJSONToSlack:(NSString*)sendText{
    
    // This is the URL to your Slack team and channel
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[NSURL URLWithString:@"https://hooks.slack.com/services/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"]];
    
    NSDictionary *requestData = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 sendText, @"text",
                                 @"#bug-report",@"channel",
                                 @"crash report",@"username",
                                 @":bug:",@"icon_emoji",
                                 nil];
    
    NSError *error;
    NSData *postData = [NSJSONSerialization dataWithJSONObject:requestData options:0 error:&error];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:postData];
    NSURLConnection *connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    
    if (connection) {
        NSLog(@"Connection Successful");
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"お問い合わせ" message:@"お問い合わせを送信しました。" preferredStyle:UIAlertControllerStyleAlert];
        // addActionした順に左から右にボタンが配置されます
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self.navigationController popViewControllerAnimated:YES];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        NSLog(@"Connection could not be made");
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"お問い合わせ" message:@"送信に失敗しました。" preferredStyle:UIAlertControllerStyleAlert];
        // addActionした順に左から右にボタンが配置されます
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
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
