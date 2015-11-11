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
    // Do any additional setup after loading the view, typically from a nib.
    //読み込むファイルパスを指定
    NSString* path = [[NSBundle mainBundle] pathForResource:@"bus_id" ofType:@"plist"];
    NSArray* array = [NSArray arrayWithContentsOfFile:path];
    NSLog(@"%@",array);
    NSLog(@"%@",[[array objectAtIndex:0]objectForKey:@"name"]);

    // string という名前の NSString 型の文字列から、"," が最初に現れる場所を取得します。
    //NSRange found = [string rangeOfString:@","];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
