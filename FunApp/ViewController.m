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
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    arrayList = [NSMutableArray new];

}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayList count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 120;
}
-(void)update:(NSTimer*)timer{
    arrayList = [NSMutableArray new];
    NSUserDefaults * defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.io.github.natmark.FunApp"];
    NSDictionary* dict = [defaults objectForKey:@"MyRoute"];
    isLoading = YES;
    if(dict){
        //データ有り
        self.myRouteButton.hidden = YES;
        self.myRouteLabel.hidden = YES;
        if([[dict objectForKey:@"type"]intValue] == RouteTypeSimple){
            __block int load_counter = -1;
            NSMutableArray* order_array = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],nil];
            
            //乗り継ぎ無し
            [[RouteSearchManager sharedManager]getRouteWithGetOn:[[dict objectForKey:@"data"]objectForKey:@"getOn"] getOff:[[dict objectForKey:@"data"]objectForKey:@"getOff"] completionHandler:^(NSDictionary* data,NSError* error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    load_counter++;
                    [order_array replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:load_counter]];
                    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:data?data:[NSNull null],@"dict",error?error:[NSNull null],@"error",[[dict objectForKey:@"data"]objectForKey:@"getOn"],@"getOn",[[dict objectForKey:@"data"]objectForKey:@"getOff"],@"getOff", nil];
                    [arrayList addObject:dictionary];
                    if(load_counter == 1){
                        for(int i = 0; i < [order_array count]-1;i++){
                            int order = [[order_array objectAtIndex:i]intValue];
                            [arrayList exchangeObjectAtIndex:i withObjectAtIndex:order];
                        }
                    }
                    if(isLoading){
                        [self.tableView reloadData];
                    }
                });
            }];
            [[RouteSearchManager sharedManager]getRouteWithGetOn:[[dict objectForKey:@"data"]objectForKey:@"getOff"] getOff:[[dict objectForKey:@"data"]objectForKey:@"getOn"] completionHandler:^(NSDictionary* data,NSError* error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    load_counter++;
                    [order_array replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:load_counter]];
                    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:data?data:[NSNull null],@"dict",error?error:[NSNull null],@"error",[[dict objectForKey:@"data"]objectForKey:@"getOff"],@"getOn",[[dict objectForKey:@"data"]objectForKey:@"getOn"],@"getOff", nil];
                    [arrayList addObject:dictionary];
                    if(load_counter == 1){
                        for(int i = 0; i < [order_array count]-1;i++){
                            int order = [[order_array objectAtIndex:i]intValue];
                            [arrayList exchangeObjectAtIndex:i withObjectAtIndex:order];
                        }
                    }
                    if(isLoading){
                        [self.tableView reloadData];
                    }
                });
            }];
        }else{
            __block int load_counter = -1;
            NSMutableArray* order_array = [[NSMutableArray alloc]initWithObjects:[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],[NSNumber numberWithInt:0],nil];
            
            //乗り継ぎ有り
            [[RouteSearchManager sharedManager]getRouteWithGetOn:[[dict objectForKey:@"data"]objectForKey:@"getOn"] getOff:[[dict objectForKey:@"data"]objectForKey:@"via"] completionHandler:^(NSDictionary* data,NSError* error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    load_counter++;
                    [order_array replaceObjectAtIndex:0 withObject:[NSNumber numberWithInt:load_counter]];
                    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:data?data:[NSNull null],@"dict",error?error:[NSNull null],@"error",[[dict objectForKey:@"data"]objectForKey:@"getOn"],@"getOn",[[dict objectForKey:@"data"]objectForKey:@"via"],@"getOff", nil  ];
                        [arrayList addObject:dictionary];
                    if(load_counter == 3){
                        for(int i = 0; i < [order_array count]-1;i++){
                            int order = [[order_array objectAtIndex:i]intValue];
                            [arrayList exchangeObjectAtIndex:i withObjectAtIndex:order];
                        }
                    }
                    if(isLoading){
                        [self.tableView reloadData];
                    }
                });
            }];
            [[RouteSearchManager sharedManager]getRouteWithGetOn:[[dict objectForKey:@"data"]objectForKey:@"via"] getOff:[[dict objectForKey:@"data"]objectForKey:@"getOff"] completionHandler:^(NSDictionary* data,NSError* error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    load_counter++;
                    [order_array replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:load_counter]];
                    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:data?data:[NSNull null],@"dict",error?error:[NSNull null],@"error",[[dict objectForKey:@"data"]objectForKey:@"via"],@"getOn",[[dict objectForKey:@"data"]objectForKey:@"getOff"],@"getOff", nil];
                    [arrayList addObject:dictionary];
                    if(load_counter == 3){
                        for(int i = 0; i < [order_array count]-1;i++){
                            int order = [[order_array objectAtIndex:i]intValue];
                            [arrayList exchangeObjectAtIndex:i withObjectAtIndex:order];
                        }
                    }
                    if(isLoading){
                        [self.tableView reloadData];
                    }
                });
            }];
            [[RouteSearchManager sharedManager]getRouteWithGetOn:[[dict objectForKey:@"data"]objectForKey:@"getOff"] getOff:[[dict objectForKey:@"data"]objectForKey:@"via"] completionHandler:^(NSDictionary* data,NSError* error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    load_counter++;
                    [order_array replaceObjectAtIndex:2 withObject:[NSNumber numberWithInt:load_counter]];
                    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:data?data:[NSNull null],@"dict",error?error:[NSNull null],@"error",[[dict objectForKey:@"data"]objectForKey:@"getOff"],@"getOn",[[dict objectForKey:@"data"]objectForKey:@"via"],@"getOff", nil];
                    [arrayList addObject:dictionary];
                    if(load_counter == 3){
                        for(int i = 0; i < [order_array count]-1;i++){
                            int order = [[order_array objectAtIndex:i]intValue];
                            [arrayList exchangeObjectAtIndex:i withObjectAtIndex:order];
                        }
                    }
                    if(isLoading){
                        [self.tableView reloadData];
                    }
                });
            }];
            [[RouteSearchManager sharedManager]getRouteWithGetOn:[[dict objectForKey:@"data"]objectForKey:@"via"] getOff:[[dict objectForKey:@"data"]objectForKey:@"getOn"] completionHandler:^(NSDictionary* data,NSError* error){
                dispatch_async(dispatch_get_main_queue(), ^{
                    load_counter++;
                    [order_array replaceObjectAtIndex:3 withObject:[NSNumber numberWithInt:load_counter]];
                    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:data?data:[NSNull null],@"dict",error?error:[NSNull null],@"error",[[dict objectForKey:@"data"]objectForKey:@"via"],@"getOn",[[dict objectForKey:@"data"]objectForKey:@"getOn"],@"getOff", nil];
                    [arrayList addObject:dictionary];
                    if(load_counter == 3){
                        for(int i = 0; i < [order_array count]-1;i++){
                            int order = [[order_array objectAtIndex:i]intValue];
                            [arrayList exchangeObjectAtIndex:i withObjectAtIndex:order];
                        }
                    }
                    if(isLoading){
                        [self.tableView reloadData];
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
    //NSLog(@"%@",error.localizedDescription);
    MyRouteTableViewCell* customCell = (MyRouteTableViewCell*)cell;
    
    customCell.routeLabel.text = @"";
    customCell.departureLabel.text = @"";
    customCell.destinationLabel.text = @"";
    customCell.detailLabel.text = @"";

    
    NSDictionary* dict = [arrayList objectAtIndex:indexPath.row];
    
    NSError* error = dict[@"error"];

    customCell.departureLabel.font = [UIFont systemFontOfSize:30];
    
    NSLog(@"%@",dict[@"getOn"]);
    
    if(![error isEqual:[NSNull null]]){
        customCell.routeLabel.text = [NSString stringWithFormat:@"%@→%@",dict[@"getOn"][@"name"],dict[@"getOff"][@"name"]];
        customCell.departureLabel.font = [UIFont systemFontOfSize:14];
        customCell.departureLabel.text = error.localizedDescription;
    }else if([dict[@"dict"][@"data"]count] == 0){
        customCell.routeLabel.text = [NSString stringWithFormat:@"%@→%@",dict[@"getOn"][@"name"],dict[@"getOff"][@"name"]];
        customCell.departureLabel.font = [UIFont systemFontOfSize:14];
        customCell.departureLabel.text = @"上記路線の本日の運行は終了しました。";
    }else{
        customCell.routeLabel.text = [NSString stringWithFormat:@"%@→%@",dict[@"getOn"][@"name"],dict[@"getOff"][@"name"]];
        customCell.departureLabel.text = [dict[@"dict"][@"data"]objectAtIndex:0][@"time"];
        customCell.destinationLabel.text = [NSString stringWithFormat:@"%@ 行",[dict[@"dict"][@"data"]objectAtIndex:0][@"destination"]];
        customCell.detailLabel.text = [NSString stringWithFormat:@"%@",([[dict[@"dict"][@"data"]objectAtIndex:0][@"detail"]isEqualToString:@"*****"])?@"":[dict[@"dict"][@"data"]objectAtIndex:0][@"detail"]];
    }
    
    return customCell;
}
-(void)viewWillDisappear:(BOOL)animated{
    isLoading = NO;
    [updateTimer invalidate];
    arrayList = [NSMutableArray new];
}
-(void)viewWillAppear:(BOOL)animated{
    arrayList = [NSMutableArray new];
    updateTimer = [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(update:) userInfo:nil repeats:YES];
    [updateTimer fire];
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
