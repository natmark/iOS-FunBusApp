//
//  SelectViaModalViewController.h
//  FunApp
//
//  Created by Atsuya Sato on 2016/04/06.
//  Copyright © 2016年 Atsuya Sato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouteSearchManager.h"

@interface SelectViaModalViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>{
    UILabel *errorLabel;
    UIActivityIndicatorView* indicator;
    NSArray* arrayList;

}
@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end
