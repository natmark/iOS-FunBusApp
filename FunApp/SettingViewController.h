//
//  SettingViewController.h
//  FunApp
//
//  Created by Atsuya Sato on 2016/01/23.
//  Copyright © 2016年 Atsuya Sato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "InputGetOnBusStopViewController.h"
#import "InquiryViewController.h"
#import "MyRouteViewController.h"
@interface SettingViewController : UIViewController<UITableViewDelegate,UITableViewDataSource>{
    NSArray* arrayList;
    NSArray* transitionList;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@end
