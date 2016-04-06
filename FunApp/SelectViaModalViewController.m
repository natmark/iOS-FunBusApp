//
//  SelectViaModalViewController.m
//  FunApp
//
//  Created by Atsuya Sato on 2016/04/06.
//  Copyright © 2016年 Atsuya Sato. All rights reserved.
//

#import "SelectViaModalViewController.h"

@interface SelectViaModalViewController ()

@end

@implementation SelectViaModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    //エラー表示用
    /*==========================*/
    errorLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height / 2 - 30, self.view.frame.size.width, 60)];
    errorLabel.textColor = [UIColor colorWithRed:184/255.0 green:29/255.0 blue:31/255.0 alpha:1.0];
    errorLabel.font = [UIFont systemFontOfSize:22];
    errorLabel.hidden = true;
    errorLabel.numberOfLines = 0;
    errorLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:errorLabel];
    /*==========================*/
    //インジケーター
    /*==========================*/
    indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.frame = CGRectMake(0, 0, 100, 100);
    indicator.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    indicator.backgroundColor = [UIColor colorWithRed:184/255.0 green:29/255.0 blue:31/255.0 alpha:1.0];
    indicator.layer.cornerRadius = indicator.frame.size.width * 0.1;
    indicator.hidden = true;
    [self.view addSubview:indicator];
    /*==========================*/
    
    indicator.hidden = false;
    [indicator startAnimating];
    [[RouteSearchManager sharedManager]getViaListWithGetOn:self.getOnBusStop getOff:self.getOffBusStop completionHandler:^(NSArray *list,NSError *error){
        if(error){
            NSLog(@"%@",error.localizedDescription);
            errorLabel.text = error.localizedDescription;
            errorLabel.hidden = false;
            [indicator stopAnimating];
            indicator.hidden = true;
        }else{
            arrayList = list;
            [indicator stopAnimating];
            indicator.hidden = true;
            [self.tableView reloadData];
        }
    }];
}
-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath;
}
// Cell が選択された時
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath*) indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; // 選択状態の解除
    
    NSLog(@"%d",(int)indexPath.row);
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary* data = [[NSDictionary alloc]initWithObjectsAndKeys:self.getOffBusStop,@"getOff",self.getOnBusStop,@"getOn",[arrayList objectAtIndex:(int)indexPath.row],@"via",nil];
    NSDictionary* dict = [[NSDictionary alloc]initWithObjectsAndKeys:[NSNumber numberWithInt:RouteTypeComplex],@"type",data,@"data",nil];
    [defaults setObject:dict forKey:@"MyRoute"];
    
    //乗り換え無し
    UIAlertView *alert =
    [[UIAlertView alloc]
     initWithTitle:@"Myルート登録"
     message:@"設定を変更しました"
     delegate:self
     cancelButtonTitle:nil
     otherButtonTitles:@"OK", nil
     ];
    [alert show];
    
}
// アラートのボタンが押された時に呼ばれるデリゲート例文
-(void)alertView:(UIAlertView*)alertView
clickedButtonAtIndex:(NSInteger)buttonIndex {
    [self dismissViewControllerAnimated:YES completion:nil];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"viaCell"];
    
    if (!cell) {
        // 再利用できない場合は新規で作成
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:@"viaCell"];
    }
    
    cell.textLabel.text = [[arrayList objectAtIndex:indexPath.row]objectForKey:@"name"];
    
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
