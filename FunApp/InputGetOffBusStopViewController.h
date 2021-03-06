//
//  InputGetOffBusStopViewController.h
//  FunApp
//
//  Created by Atsuya Sato on 2015/11/11.
//  Copyright © 2015年 Atsuya Sato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusSearchManager.h"
#import "SearchRouteViewController.h"
#import "SelectViaViewController.h"
@interface InputGetOffBusStopViewController : UIViewController<UITextFieldDelegate,UIWebViewDelegate>{
    NSArray* searchArray;
    UIActivityIndicatorView* indicator;
}

@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UILabel *busStopLabel;
@property (strong, nonatomic) IBOutlet UILabel *label1;
@property (strong, nonatomic) IBOutlet UIButton *searchButton;

@end
