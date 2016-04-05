//
//  MyRouteViewController.h
//  FunApp
//
//  Created by Atsuya Sato on 2016/02/27.
//  Copyright © 2016年 Atsuya Sato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouteSearchManager.h"
#import "BusSearchManager.h"
#import "SelectViaViewController.h"
@interface MyRouteViewController : UIViewController<UITextFieldDelegate,UIWebViewDelegate>{
    NSArray* getOnSearchArray;
    NSArray* getOffSearchArray;
    NSMutableArray* searchArrays;

    UIActivityIndicatorView* indicator;
    NSArray* textFieldArray;
    NSArray* webViewArray;
    NSArray* labelArray;
    
    NSDictionary* getOnBusStop;
    NSDictionary* getOffBusStop;
}
@property (strong, nonatomic) IBOutlet UITextField *getOnTextField;
@property (strong, nonatomic) IBOutlet UITextField *getOffTextField;
@property (strong, nonatomic) IBOutlet UIWebView *getOnWebView;
@property (strong, nonatomic) IBOutlet UIWebView *getOffWebView;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
@property (strong, nonatomic) IBOutlet UILabel *getOnLabel;
@property (strong, nonatomic) IBOutlet UILabel *getOffLabel;

@end
