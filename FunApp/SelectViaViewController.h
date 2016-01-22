//
//  SelectViaViewController.h
//  FunApp
//
//  Created by Atsuya Sato on 2016/01/22.
//  Copyright © 2016年 Atsuya Sato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouteSearchManager.h"
#import "SearchRouteViewController.h"
@interface SelectViaViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    UILabel *errorLabel;
    UIActivityIndicatorView* indicator;
    NSArray* arrayList;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
