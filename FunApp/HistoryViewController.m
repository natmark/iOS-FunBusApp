//
//  HistoryViewController.m
//  FunApp
//
//  Created by Atsuya Sato on 2016/01/23.
//  Copyright © 2016年 Atsuya Sato. All rights reserved.
//

#import "HistoryViewController.h"

@interface HistoryViewController ()

@end

@implementation HistoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewWillAppear:(BOOL)animated{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    arrayList = [[[defaults objectForKey:@"History"] reverseObjectEnumerator]allObjects];

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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HistoryCell"];
    
    if (!cell) {
        // 再利用できない場合は新規で作成
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"HistoryCell"];
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
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //削除
    return  UITableViewCellEditingStyleDelete;
}
-(void)setEditing:(BOOL)editing animated:(BOOL)animated{
    [super setEditing:editing animated:animated];
    [self.tableView setEditing:editing animated:YES];
}
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {
    NSMutableArray* arr = [arrayList mutableCopy];
    [arr removeObjectAtIndex:indexPath.row];
    arrayList = arr;
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[[arrayList reverseObjectEnumerator]allObjects] forKey:@"History"];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
