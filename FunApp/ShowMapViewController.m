//
//  ShowMapViewController.m
//  FunApp
//
//  Created by Atsuya Sato on 2016/01/29.
//  Copyright © 2016年 Atsuya Sato. All rights reserved.
//

#import "ShowMapViewController.h"

@interface ShowMapViewController ()

@end

@implementation ShowMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}
-(void)viewWillAppear:(BOOL)animated{
    self.indicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    self.indicator.hidden = NO;
    [self.indicator startAnimating];
    self.titleView.title = [NSString stringWithFormat:@"乗り場「%@」",self.boarding];
    [[BusSearchManager sharedManager]GETMapImageWithURL:self.mapURL imageView:self.mapView completionHandler:^(NSError* error){
        if(error){
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"乗車マップ" message:@"エラーが発生したため、前画面に戻ります" preferredStyle:UIAlertControllerStyleAlert];
            // addActionした順に左から右にボタンが配置されます
            [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }]];
            [self presentViewController:alertController animated:YES completion:nil];
        }
        self.indicator.hidden = YES;
        [self.indicator stopAnimating];
    }];
}
-(void)viewDidLayoutSubviews{
    self.indicator.layer.cornerRadius = self.indicator.frame.size.width * 0.1;
    [self.view addSubview:self.indicator];
}
- (IBAction)pushBackButton:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
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
