//
//  ShowMapViewController.h
//  FunApp
//
//  Created by Atsuya Sato on 2016/01/29.
//  Copyright © 2016年 Atsuya Sato. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BusSearchManager.h"
@interface ShowMapViewController : UIViewController
@property(nonatomic,assign)NSString* boarding;
@property(nonatomic,assign)NSString* mapURL;
@property (strong, nonatomic) IBOutlet UINavigationItem *titleView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) IBOutlet UIImageView *mapView;
@end
