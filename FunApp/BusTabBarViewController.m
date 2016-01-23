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
}
-(void)tabBarController:(UITabBarController*)tabBarController didSelectViewController:(UIViewController*)viewController{
}
-(BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    if(self.selectedIndex == 1){
        if((UINavigationController*)viewController == [self.viewControllers objectAtIndex:1]){
            UINavigationController* navigation = (UINavigationController*)viewController;
            [navigation popToRootViewControllerAnimated:YES];
        }
    }
    return YES;
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
