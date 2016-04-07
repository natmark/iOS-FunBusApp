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
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    UINib *nib = [UINib nibWithNibName:@"MyRouteTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"MyRouteTableViewCell"];
    isLoaded = YES;
    NSTimer* timer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(update:) userInfo:nil repeats:YES];
    [timer fire];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayList count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}
-(void)update:(NSTimer*)timer{
    [self viewWillAppear:YES];
}
/**
 テーブルに表示するセルを返します。（必須）
 
 @return UITableViewCell : テーブルセル
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 再利用できるセルがあれば再利用する
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyRouteTableViewCell"];
    
    if (!cell) {
        // 再利用できない場合は新規で作成
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"MyRouteTableViewCell"];
    }
    MyRouteTableViewCell* customCell = (MyRouteTableViewCell*)cell;
    
    
    NSDictionary* dict = [arrayList objectAtIndex:indexPath.row];
    
    customCell.routeLabel.text = [NSString stringWithFormat:@"%@→%@",dict[@"getOn"][@"name"],dict[@"getOff"][@"name"]];
    customCell.departureLabel.text = [dict[@"dict"][@"data"]objectAtIndex:0][@"time"];
    customCell.destinationLabel.text = [NSString stringWithFormat:@"%@ 行",[dict[@"dict"][@"data"]objectAtIndex:0][@"destination"]];
    customCell.detailLabel.text = [NSString stringWithFormat:@"%@",([[dict[@"dict"][@"data"]objectAtIndex:0][@"detail"]isEqualToString:@"*****"])?@"":[dict[@"dict"][@"data"]objectAtIndex:0][@"detail"]];
    
    return customCell;
}
-(void)viewWillDisappear:(BOOL)animated{
    
}
-(void)viewWillAppear:(BOOL)animated{
    if(!isLoaded) return;
    
    arrayList = [NSMutableArray new];
    isLoaded = NO;
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.io.github.natmark.FunApp"];
    NSDictionary* dict = [defaults objectForKey:@"MyRoute"];

    if(dict){
        //データ有り
        self.myRouteButton.hidden = YES;
        self.myRouteLabel.hidden = YES;
        if([[dict objectForKey:@"type"]intValue] == RouteTypeSimple){
            //乗り継ぎ無し
            [[RouteSearchManager sharedManager]getRouteWithGetOn:[[dict objectForKey:@"data"]objectForKey:@"getOn"] getOff:[[dict objectForKey:@"data"]objectForKey:@"getOff"] completionHandler:^(NSDictionary* data,NSError* error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(!error){
                    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:data,@"dict",[[dict objectForKey:@"data"]objectForKey:@"getOn"],@"getOn",[[dict objectForKey:@"data"]objectForKey:@"getOff"],@"getOff", nil];
                    [arrayList addObject:dictionary];
                    [[RouteSearchManager sharedManager]getRouteWithGetOn:[[dict objectForKey:@"data"]objectForKey:@"getOff"] getOff:[[dict objectForKey:@"data"]objectForKey:@"getOn"] completionHandler:^(NSDictionary* data,NSError* error){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(!error){
                            NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:data,@"dict",[[dict objectForKey:@"data"]objectForKey:@"getOff"],@"getOn",[[dict objectForKey:@"data"]objectForKey:@"getOn"],@"getOff", nil];
                            [arrayList addObject:dictionary];
                            [self.tableView reloadData];
                            isLoaded = YES;
                            }else{
                                isLoaded = YES;
                            }
                        });
                    }];
                    }else{
                        isLoaded = YES;
                    }
                });
            }];
        }else{
            //乗り継ぎ有り
            [[RouteSearchManager sharedManager]getRouteWithGetOn:[[dict objectForKey:@"data"]objectForKey:@"getOn"] getOff:[[dict objectForKey:@"data"]objectForKey:@"via"] completionHandler:^(NSDictionary* data,NSError* error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(!error){
                    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:data,@"dict",[[dict objectForKey:@"data"]objectForKey:@"getOn"],@"getOn",[[dict objectForKey:@"data"]objectForKey:@"via"],@"getOff", nil];
                    [arrayList addObject:dictionary];
                    [[RouteSearchManager sharedManager]getRouteWithGetOn:[[dict objectForKey:@"data"]objectForKey:@"via"] getOff:[[dict objectForKey:@"data"]objectForKey:@"getOff"] completionHandler:^(NSDictionary* data,NSError* error){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            if(!error){

                            NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:data,@"dict",[[dict objectForKey:@"data"]objectForKey:@"via"],@"getOn",[[dict objectForKey:@"data"]objectForKey:@"getOff"],@"getOff", nil];
                            [arrayList addObject:dictionary];
                            [[RouteSearchManager sharedManager]getRouteWithGetOn:[[dict objectForKey:@"data"]objectForKey:@"getOff"] getOff:[[dict objectForKey:@"data"]objectForKey:@"via"] completionHandler:^(NSDictionary* data,NSError* error){
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if(!error){

                                    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:data,@"dict",[[dict objectForKey:@"data"]objectForKey:@"getOff"],@"getOn",[[dict objectForKey:@"data"]objectForKey:@"via"],@"getOff", nil];
                                    [arrayList addObject:dictionary];
                                    [[RouteSearchManager sharedManager]getRouteWithGetOn:[[dict objectForKey:@"data"]objectForKey:@"via"] getOff:[[dict objectForKey:@"data"]objectForKey:@"getOn"] completionHandler:^(NSDictionary* data,NSError* error){
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            if(!error){
                                            NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:data,@"dict",[[dict objectForKey:@"data"]objectForKey:@"via"],@"getOn",[[dict objectForKey:@"data"]objectForKey:@"getOn"],@"getOff", nil];
                                            [arrayList addObject:dictionary];
                                            isLoaded = YES;
                                            [self.tableView reloadData];
                                            }else{
                                                isLoaded = YES;
                                            }
                                        });
                                    }];
                                    }else{
                                        isLoaded = YES;
                                    }
                                });
                            }];
                            }else{
                                isLoaded = YES;
                            }
                        });
                    }];
                    }else{
                        isLoaded = YES;
                    }
                });
            }];
        }
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
