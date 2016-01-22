//
//  BusTabBarViewController.m
//  FunApp
//
//  Created by Atsuya Sato on 2016/01/23.
//  Copyright © 2016年 Atsuya Sato. All rights reserved.
//

#import "BusTabBarViewController.h"

@interface BusTabBarViewController ()

@end

@implementation BusTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    // Do any additional setup after loading the view.
    self.navigationItem.title = [self.viewControllers objectAtIndex:0].navigationItem.title;
}
-(void)tabBarController:(UITabBarController*)tabBarController didSelectViewController:(UIViewController*)viewController{
    self.navigationItem.title = viewController.navigationItem.title;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
