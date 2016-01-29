//
//  ShowPassingTimeViewController.h
//  FunApp
//
//  Created by Atsuya Sato on 2016/01/29.
//  Copyright © 2016年 Atsuya Sato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SearchRouteViewController.h"
#import "PassingTimeTableViewCell.h"
@interface ShowPassingTimeViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    NSArray* arrayList;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property(nonatomic,assign)NSDictionary* data;
@end
