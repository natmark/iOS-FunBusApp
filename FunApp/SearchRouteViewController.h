//
//  SearchRouteViewController.h
//  FunApp
//
//  Created by Atsuya Sato on 2015/11/12.
//  Copyright © 2015年 Atsuya Sato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusSearchManager.h"
#import "NoConnectionView.h"
@interface SearchRouteViewController : UIViewController{
    UILabel *errorLabel;
    UIActivityIndicatorView* indicator;
    NSArray *searchResultArray;
    int showCnt;
    NoConnectionView* noConnectionView;
    UIButton* leftButton;
    UIButton* rightButton;
}
@property (strong, nonatomic) IBOutlet UILabel *getOnLabel;
@property (strong, nonatomic) IBOutlet UILabel *getOffLabel;
@end
