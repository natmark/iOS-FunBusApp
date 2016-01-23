//
//  HistoryViewController.h
//  FunApp
//
//  Created by Atsuya Sato on 2016/01/23.
//  Copyright © 2016年 Atsuya Sato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouteSearchManager.h"
#import "SearchRouteViewController.h"
@interface HistoryViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    NSArray* arrayList;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
