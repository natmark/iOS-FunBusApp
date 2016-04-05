//
//  SettingConnectionIntervalViewController.m
//  FunApp
//
//  Created by Atsuya Sato on 2016/04/05.
//  Copyright © 2016年 Atsuya Sato. All rights reserved.
//

#import "SettingConnectionIntervalViewController.h"

@interface SettingConnectionIntervalViewController ()

@end

@implementation SettingConnectionIntervalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // DatePickerの設定
    UIPickerView* pickerView = [[UIPickerView alloc]init];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults objectForKey:@"ConnectionInterval"]) [defaults setObject:@"0" forKey:@"ConnectionInterval"];
    
    self.textField.text = [defaults objectForKey:@"ConnectionInterval"];


    self.textField.inputView = pickerView;
    // Delegationの設定
    self.textField.delegate = self;
    
    // DoneボタンとそのViewの作成
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    keyboardDoneButtonView.barStyle  = UIBarStyleBlack;
    keyboardDoneButtonView.translucent = YES;
    keyboardDoneButtonView.tintColor = nil;
    [keyboardDoneButtonView sizeToFit];
    
    // 完了ボタンとSpacerの配置
    UIBarButtonItem* doneButton = [[UIBarButtonItem alloc] initWithTitle:@"完了" style:UIBarButtonItemStyleDone target:self action:@selector(pickerDoneClicked)];
    UIBarButtonItem *spacer1 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:spacer, spacer1, doneButton, nil]];
    
    // Viewの配置
    self.textField.inputAccessoryView = keyboardDoneButtonView;
}
-(void)viewWillAppear:(BOOL)animated{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    self.textField.text = [defaults objectForKey:@"ConnectionInterval"];
}
-(NSInteger)numberOfComponentsInPickerView:
(UIPickerView*)pickerView{
    return 1;
}
-(NSInteger)pickerView:
(UIPickerView*)pickerView numberOfRowsInComponent:
(NSInteger)component{
    return 60;
}
-(NSString*)pickerView:
(UIPickerView*)pickerView
           titleForRow:(NSInteger)row
          forComponent:(NSInteger)component{
    return [NSString stringWithFormat:@"%ld",row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.textField.text = [NSString stringWithFormat:@"%ld", row];
}
#pragma mark pickerViewの完了ボタンが押された場合
-(void)pickerDoneClicked {
    [self.textField resignFirstResponder];
}
- (IBAction)doneSetting:(id)sender {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    // NSArrayの保存
    [defaults setObject:self.textField.text forKey:@"ConnectionInterval"];
    
    // 生成と同時に各種設定も完了させる例
    UIAlertView *alert =
    [[UIAlertView alloc]
     initWithTitle:@"乗換時間"
     message:@"設定を変更しました"
     delegate:nil
     cancelButtonTitle:nil
     otherButtonTitles:@"OK", nil
     ];
    [alert show];
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
