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
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
-(void)viewWillAppear:(BOOL)animated{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    arrayList = [[[defaults objectForKey:@"Favorite"] reverseObjectEnumerator]allObjects];
    
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
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        // NSArrayの保存
        NSMutableArray* array = [NSMutableArray array];
        array = [[defaults objectForKey:@"History"]mutableCopy];
        if(!array){
            array = [NSMutableArray array];
        }
        
        NSDictionary* data = [[NSDictionary alloc]initWithObjectsAndKeys:[BusSearchManager sharedManager].GetOffBusStop,@"getOff",[BusSearchManager sharedManager].GetOnBusStop,@"getOn",nil];
        
        NSDictionary* dict = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:RouteTypeSimple],@"type",data,@"data",nil];
        
        [array addObject:dict];
        if([array count] > 100){
            [array removeObject:[array firstObject]];
        }
        [defaults setObject:array forKey:@"History"];

    }else{
        [BusSearchManager sharedManager].viaBusStop = [[[arrayList objectAtIndex:indexPath.row]objectForKey:@"data"]objectForKey:@"via"];
        [BusSearchManager sharedManager].GetOffBusStop = [[[arrayList objectAtIndex:indexPath.row]objectForKey:@"data"]objectForKey:@"getOff"];
        [BusSearchManager sharedManager].GetOnBusStop = [[[arrayList objectAtIndex:indexPath.row]objectForKey:@"data"]objectForKey:@"getOn"];
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        // NSArrayの保存
        NSMutableArray* array = [NSMutableArray array];
        array = [[defaults objectForKey:@"History"]mutableCopy];
        if(!array){
            array = [NSMutableArray array];
        }
        NSDictionary* data = [[NSDictionary alloc]initWithObjectsAndKeys:[BusSearchManager sharedManager].GetOffBusStop,@"getOff",[BusSearchManager sharedManager].GetOnBusStop,@"getOn",[BusSearchManager sharedManager].viaBusStop,@"via",nil];
        
        NSDictionary* dict = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:RouteTypeComplex],@"type",data,@"data",nil];
        
        [array addObject:dict];
        if([array count] > 100){
            [array removeObject:[array firstObject]];
        }
        [defaults setObject:array forKey:@"History"];

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
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //削除
    return  UITableViewCellEditingStyleDelete;
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    if(fromIndexPath.section == toIndexPath.section) { // 移動元と移動先は同じセクションです。
        if(arrayList && toIndexPath.row < [arrayList count]) {
            id item = [arrayList objectAtIndex:fromIndexPath.row]; // 移動対象を保持します。
            NSMutableArray* arr = [arrayList mutableCopy];
            [arr removeObject:item]; // 配列から一度消します。
            [arr insertObject:item atIndex:toIndexPath.row]; // 保持しておいた対象を挿入します。
            arrayList = [[NSArray alloc]initWithArray:arr];
            NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:[[arrayList reverseObjectEnumerator]allObjects] forKey:@"Favorite"];
            
        }
    }
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
    [defaults setObject:[[arrayList reverseObjectEnumerator]allObjects] forKey:@"Favorite"];
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
