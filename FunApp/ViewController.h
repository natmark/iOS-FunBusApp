//
//  ViewController.h
//  FunApp
//
//  Created by Atsuya Sato on 2015/06/27.
//  Copyright (c) 2015年 Atsuya Sato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouteSearchManager.h"
#import "SettingViewController.h"
#import "MyRouteTableViewCell.h"
@interface ViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    UIView* contentView;
    NSMutableArray* arrayList;
    NSTimer* updateTimer;
    BOOL isLoading;
}
@property (strong, nonatomic) IBOutlet UILabel *myRouteLabel;
@property (strong, nonatomic) IBOutlet UIButton *myRouteButton;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end

