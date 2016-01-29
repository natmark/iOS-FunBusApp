//
//  FavoriteViewController.m
//  FunApp
//
//  Created by Atsuya Sato on 2016/01/23.
//  Copyright © 2016年 Atsuya Sato. All rights reserved.
//

#import "FavoriteViewController.h"

@interface FavoriteViewController ()

@end

@implementation FavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}
-(void)viewWillAppear:(BOOL)animated{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    arrayList = [defaults objectForKey:@"Favorite"];
    
    [self.tableView reloadData];
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}
// Cell が選択された時
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath{
    NSLog(@"%d",(int)indexPath.row);
    
    if([[[arrayList objectAtIndex:indexPath.row]objectForKey:@"type"]intValue] == RouteTypeSimple){
        [BusSearchManager sharedManager].GetOffBusStop = [[[arrayList objectAtIndex:indexPath.row]objectForKey:@"data"]objectForKey:@"getOff"];
        [BusSearchManager sharedManager].GetOnBusStop = [[[arrayList objectAtIndex:indexPath.row]objectForKey:@"data"]objectForKey:@"getOn"];
        [BusSearchManager sharedManager].viaBusStop = nil;

    }else{
        [BusSearchManager sharedManager].viaBusStop = [[[arrayList objectAtIndex:indexPath.row]objectForKey:@"data"]objectForKey:@"via"];
        [BusSearchManager sharedManager].GetOffBusStop = [[[arrayList objectAtIndex:indexPath.row]objectForKey:@"data"]objectForKey:@"getOff"];
        [BusSearchManager sharedManager].GetOnBusStop = [[[arrayList objectAtIndex:indexPath.row]objectForKey:@"data"]objectForKey:@"getOn"];
    }
    
    SearchRouteViewController *viewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchRouteViewController"];
    [self.navigationController pushViewController:viewController animated:YES];
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arrayList count];
}
/**
 テーブルに表示するセルを返します。（必須）
 
 @return UITableViewCell : テーブルセル
 */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // 再利用できるセルがあれば再利用する
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FavoriteCell"];
    
    if (!cell) {
        // 再利用できない場合は新規で作成
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"FavoriteCell"];
    }
    if((RouteType)[[[arrayList objectAtIndex:indexPath.row]objectForKey:@"type"]intValue] == RouteTypeSimple){
        cell.textLabel.text = [NSString stringWithFormat:@"%@ → %@",[[[[arrayList objectAtIndex:indexPath.row]objectForKey:@"data"]objectForKey:@"getOn"]objectForKey:@"name"],[[[[arrayList objectAtIndex:indexPath.row]objectForKey:@"data"]objectForKey:@"getOff"]objectForKey:@"name"]];
        cell.detailTextLabel.text = @"";
    }else{
        cell.textLabel.text = [NSString stringWithFormat:@"%@ → %@",[[[[arrayList objectAtIndex:indexPath.row]objectForKey:@"data"]objectForKey:@"getOn"]objectForKey:@"name"],[[[[arrayList objectAtIndex:indexPath.row]objectForKey:@"data"]objectForKey:@"getOff"]objectForKey:@"name"]];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@経由",[[[[arrayList objectAtIndex:indexPath.row]objectForKey:@"data"]objectForKey:@"via"]objectForKey:@"name"]];
    }
    return cell;
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
