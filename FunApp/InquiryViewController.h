//
//  InquiryViewController.h
//  FunApp
//
//  Created by Atsuya Sato on 2016/01/30.
//  Copyright © 2016年 Atsuya Sato. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InquiryViewController : UIViewController<UITextViewDelegate,UIWebViewDelegate>{
    NSString* itemStr;
    NSArray* searchArray;
}
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UITextView *textView;

@end
