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
@interface SearchRouteViewController : UIViewController{
    UILabel *errorLabel;
    UIActivityIndicatorView* indicator;
    int showCnt;
    NoConnectionView* noConnectionView;
    ConnectionView* connectionView;
    UIButton* leftButton;
    UIButton* rightButton;
    UILabel* timeLabel;
    NSDictionary* dataDictionary;
}
@property (strong, nonatomic) IBOutlet UIButton *switchButton;
@property (strong, nonatomic) IBOutlet UILabel *getOnLabel;
@property (strong, nonatomic) IBOutlet UILabel *getOffLabel;
@end
