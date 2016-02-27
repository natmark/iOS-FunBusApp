//
//  SettingViewController.m
//  FunApp
//
//  Created by Atsuya Sato on 2016/01/23.
//  Copyright © 2016年 Atsuya Sato. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    arrayList = [NSArray arrayWithObjects:@"My路線の設定",@"クラッシュレポート・お問い合わせ",@"乗り継ぎ間隔の設定",nil];
    InputGetOnBusStopViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"InputGetOnBusStopViewController"];

    InquiryViewController *controller2 = [self.storyboard instantiateViewControllerWithIdentifier:@"InquiryViewController"];
    
    InputGetOnBusStopViewController *controller3 = [self.storyboard instantiateViewControllerWithIdentifier:@"InputGetOnBusStopViewController"];
    
    transitionList = [NSArray arrayWithObjects:controller,controller2,controller3, nil];
    
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}
// Cell が選択された時
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.navigationController pushViewController:[transitionList objectAtIndex:indexPath.row] animated:YES];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingCell"];
    
    if (!cell) {
        // 再利用できない場合は新規で作成
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"SettingCell"];
    }
    
    cell.textLabel.text = [arrayList objectAtIndex:indexPath.row];
    
    return cell;
}
-(void)viewDidLayoutSubviews{
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
