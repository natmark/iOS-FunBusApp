//
//  ShowPassingTimeViewController.m
//  FunApp
//
//  Created by Atsuya Sato on 2016/01/29.
//  Copyright © 2016年 Atsuya Sato. All rights reserved.
//

#import "ShowPassingTimeViewController.h"

@interface ShowPassingTimeViewController ()

@end

@implementation ShowPassingTimeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([PassingTimeTableViewCell class]) bundle:nil] forCellReuseIdentifier:@"PassingTimeTableViewCell"];

    arrayList = [NSArray array];

    // Do any additional setup after loading the view from its nib.
    if((RouteType)[[self.data objectForKey:@"type"]intValue] == RouteTypeComplex){
        NSString* firstURL = [[self.data objectForKey:@"data"]objectForKey:@"url1"];
        NSString* secondURL = [[self.data objectForKey:@"data"]objectForKey:@"url2"];
        
        __block NSMutableArray* dataArray = [NSMutableArray array];
        
        [[BusSearchManager sharedManager]GETArrivedTimeWithURL:firstURL completionHandler:^(NSArray* array,NSError *error){
            if(error){
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"乗車マップ" message:@"エラーが発生したため、前画面に戻ります" preferredStyle:UIAlertControllerStyleAlert];
                // addActionした順に左から右にボタンが配置されます
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }]];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            int getOnIndex = 0;
            int viaIndex1 = 0;
            BOOL getOnFlg = NO;
            BOOL viaFlg = NO;
            
            for(int i = 0;i < [array count];i++){
                NSDictionary* dict = [array objectAtIndex:i];
                if([[dict objectForKey:@"name"] isEqualToString:[[BusSearchManager sharedManager].GetOnBusStop objectForKey:@"name"]] && !getOnFlg
                   ){
                    //ここから
                    getOnIndex = i;
                    NSLog(@"%@",[dict objectForKey:@"name"]);
                    getOnFlg=YES;
                }
                if([[dict objectForKey:@"name"] isEqualToString:[[BusSearchManager sharedManager].viaBusStop objectForKey:@"name"]] && !viaFlg
                   ){
                    NSLog(@"%@",[dict objectForKey:@"name"]);
                    //ここまで
                    viaIndex1 = i;
                    viaFlg = YES;
                }
            }
            NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(getOnIndex, viaIndex1 - getOnIndex + 1)];
            
            
            NSMutableArray* data = [[array objectsAtIndexes:indexes] mutableCopy];
            int i = 0;
            while(i < [data count] - 1){
                NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"↓",@"option",nil];
                [data insertObject:dictionary atIndex:i+1];
                i+=2;
            }
            
            dataArray = [[dataArray arrayByAddingObjectsFromArray:data]mutableCopy];
            NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"=====乗り継ぎ=====",@"option",nil];
            [dataArray addObject:dictionary];

            [[BusSearchManager sharedManager]GETArrivedTimeWithURL:secondURL completionHandler:^(NSArray* array2,NSError *error2){
                if(error2){
                    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"乗車マップ" message:@"エラーが発生したため、前画面に戻ります" preferredStyle:UIAlertControllerStyleAlert];
                    // addActionした順に左から右にボタンが配置されます
                    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }]];
                    [self presentViewController:alertController animated:YES completion:nil];
                }
                
                int viaIndex2 = 0;
                int getOffIndex = 0;
                
                for(int i = 0;i < [array2 count];i++){
                    NSDictionary* dict2 = [array2 objectAtIndex:i];
                    if([[dict2 objectForKey:@"name"] isEqualToString:[[BusSearchManager sharedManager].viaBusStop objectForKey:@"name"]]
                       ){
                        //ここから
                        viaIndex2 = i;
                    }
                    if([[dict2 objectForKey:@"name"] isEqualToString:[[BusSearchManager sharedManager].GetOffBusStop objectForKey:@"name"]]
                       ){
                        //ここまで
                        getOffIndex = i;
                    }
                }
                NSIndexSet *indexes2 = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(viaIndex2, getOffIndex - viaIndex2 + 1)];
                
                
                NSMutableArray* data2 = [[array2 objectsAtIndexes:indexes2] mutableCopy];
                int i = 0;
                while(i < [data2 count] - 1){
                    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"↓",@"option",nil];
                    [data2 insertObject:dictionary atIndex:i+1];
                    i+=2;
                }
                dataArray = [[dataArray arrayByAddingObjectsFromArray:data2]mutableCopy];
                 arrayList = [[NSArray alloc]initWithArray:dataArray];
                 [self.tableView reloadData];
            }];
        }];
    }else{
        NSString* URL = [[self.data objectForKey:@"data"]objectForKey:@"url"];
        [[BusSearchManager sharedManager]GETArrivedTimeWithURL:URL completionHandler:^(NSArray* array,NSError *error){
            if(error){
                UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"乗車マップ" message:@"エラーが発生したため、前画面に戻ります" preferredStyle:UIAlertControllerStyleAlert];
                // addActionした順に左から右にボタンが配置されます
                [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self dismissViewControllerAnimated:YES completion:nil];
                }]];
                [self presentViewController:alertController animated:YES completion:nil];
            }
            int getOnIndex = 0;
            int getOffIndex = 0;
            
            for(int i = 0;i < [array count];i++){
                NSDictionary* dict = [array objectAtIndex:i];
                if([[dict objectForKey:@"name"] isEqualToString:[[BusSearchManager sharedManager].GetOnBusStop objectForKey:@"name"]]
                   ){
                    //ここから
                    getOnIndex = i;
                    NSLog(@"%@",[dict objectForKey:@"name"]);
                }
                if([[dict objectForKey:@"name"] isEqualToString:[[BusSearchManager sharedManager].GetOffBusStop objectForKey:@"name"]]
                   ){
                    NSLog(@"%@",[dict objectForKey:@"name"]);
                    //ここまで
                    getOffIndex = i;
                }
            }
            
            NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(getOnIndex, getOffIndex - getOnIndex + 1)];
            
            NSArray *data = [array objectsAtIndexes:indexes];
            
            NSMutableArray* dataArray = [data mutableCopy];
            int i = 0;
            while(i < [dataArray count] - 1){
                NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"↓",@"option",nil];
                [dataArray insertObject:dictionary atIndex:i+1];
                i+=2;
            }
            //[mar insertObject:@"hoge" atIndex:3];

            arrayList = [[NSArray alloc]initWithArray:dataArray];
            [self.tableView reloadData];
            
        }];
    }
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30.0;
}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [UILabel new];
    label.font = [UIFont systemFontOfSize:13.0];
    label.backgroundColor = [UIColor colorWithRed:184/255.0 green:29/255.0 blue:31/255.0 alpha:1.0];
    label.textColor = [UIColor whiteColor];
    label.text = [NSString stringWithFormat:@"表示されている通過時間には遅延時間を含めています"];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[arrayList objectAtIndex:indexPath.row]objectForKey:@"option"]){
        return 30.0;
    }
    return 52.0;
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PassingTimeTableViewCell"];
    
    
    if (!cell) {
        // 再利用できない場合は新規で作成
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"PassingTimeTableViewCell"];
    }
    PassingTimeTableViewCell* customCell = (PassingTimeTableViewCell*)cell;
    if([[arrayList objectAtIndex:indexPath.row]objectForKey:@"option"]){
        customCell.nameLabel.text = [[arrayList objectAtIndex:indexPath.row]objectForKey:@"option"];
        customCell.nameLabel.textColor = [UIColor colorWithRed:184/255.0 green:29/255.0 blue:31/255.0 alpha:1.0];
        customCell.nameLabel.font = [UIFont systemFontOfSize:22.0];
        customCell.nameLabel.textAlignment = NSTextAlignmentCenter;
        customCell.timeLabel.text = @"";
    }else{
        customCell.nameLabel.text = [[arrayList objectAtIndex:indexPath.row]objectForKey:@"name"];
        customCell.nameLabel.textColor = [UIColor blackColor];
        customCell.nameLabel.font = [UIFont systemFontOfSize:14.0];
        customCell.nameLabel.textAlignment = NSTextAlignmentLeft;
        customCell.timeLabel.text = [[arrayList objectAtIndex:indexPath.row]objectForKey:@"time"];
    }
    
    return cell;
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
