//
//  SearchRouteViewController.h
//  FunApp
//
//  Created by Atsuya Sato on 2015/11/12.
//  Copyright © 2015年 Atsuya Sato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusSearchManager.h"
#import "RouteSearchManager.h"
#import "NoConnectionView.h"
#import "ConnectionView.h"
#import "ShowMapViewController.h"
#import "ShowPassingTimeViewController.h"
#import <Social/Social.h>

@interface SearchRouteViewController : UIViewController{
    UILabel *errorLabel;
    UIActivityIndicatorView* indicator;
    int showCnt;
    int CONNECTION_TIME;
    NoConnectionView* noConnectionView;
    ConnectionView* connectionView;
    UIButton* leftButton;
    UIButton* rightButton;
    UILabel* timeLabel;
    NSDictionary* dataDictionary;
    NSDictionary* mapURLNoConnection;
    NSDictionary* mapURLConnection1;
    NSDictionary* mapURLConnection2;

    NSString* noConnectionPassingURL;
    NSString* connection1PassingURL;
    NSString* connection2PassingURL;
}

@property (strong, nonatomic) IBOutlet UIButton *switchButton;
@property (strong, nonatomic) IBOutlet UILabel *getOnLabel;
@property (strong, nonatomic) IBOutlet UILabel *getOffLabel;
@end
