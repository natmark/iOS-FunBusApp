//
//  SelectViaModalViewController.h
//  FunApp
//
//  Created by Atsuya Sato on 2016/04/06.
//  Copyright © 2016年 Atsuya Sato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouteSearchManager.h"
#import "MyRouteViewController.h"
@interface SelectViaModalViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate>{
    UILabel *errorLabel;
    UIActivityIndicatorView* indicator;
    NSArray* arrayList;

}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, assign) NSDictionary *getOnBusStop;
@property (nonatomic, assign) NSDictionary *getOffBusStop;

@end
