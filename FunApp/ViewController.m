//
//  ViewController.m
//  FunApp
//
//  Created by Atsuya Sato on 2015/06/27.
//  Copyright (c) 2015年 Atsuya Sato. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
-(void)viewWillAppear:(BOOL)animated{
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.io.github.natmark.FunApp"];
    NSDictionary* dict = [defaults objectForKey:@"MyRoute"];
    
    if(dict){
        //データ有り
        self.myRouteButton.hidden = YES;
        self.myRouteLabel.hidden = YES;
    }else{
        //データ無し
        self.myRouteButton.hidden = NO;
        self.myRouteLabel.hidden = NO;
    }
}
- (IBAction)gotoSetUpMyRoute:(id)sender {
    self.navigationController.tabBarController.selectedIndex = 4;
    UINavigationController* viewController = [self.navigationController.tabBarController.viewControllers objectAtIndex:4];
    
     MyRouteViewController *nextController = [self.storyboard instantiateViewControllerWithIdentifier:@"MyRouteViewController"];
    [viewController popToRootViewControllerAnimated:NO];
    [viewController pushViewController:nextController animated:YES];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
