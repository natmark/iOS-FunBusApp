//
//  ConnectionView.m
//  FunApp
//
//  Created by Atsuya Sato on 2015/11/27.
//  Copyright © 2015年 Atsuya Sato. All rights reserved.
//

#import "ConnectionView.h"

@implementation ConnectionView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.layer.borderColor = [[UIColor colorWithRed:184/255.0 green:29/255.0 blue:31/255.0 alpha:1.0]CGColor];
    self.layer.borderWidth = 2.0;
    
#pragma mark 乗車->経由
    UIView* colorview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 30)];
    colorview.backgroundColor = [UIColor colorWithRed:184/255.0 green:29/255.0 blue:31/255.0 alpha:1.0];
    [self addSubview:colorview];
    
    self.destinationLabel1 = [UILabel new];
    self.destinationLabel1.frame = CGRectMake(20,0, frame.size.width-40, 30);
    self.destinationLabel1.textColor = [UIColor whiteColor];
    self.destinationLabel1.font = [UIFont systemFontOfSize:20];
    [colorview addSubview:self.destinationLabel1];
    
    self.getOnLabel1 = [UILabel new];
    self.getOnLabel1.frame = CGRectMake(20,30,100,20);
    self.getOnLabel1.textColor = [UIColor blackColor];
    self.getOnLabel1.textAlignment = NSTextAlignmentCenter;
    self.getOnLabel1.font = [UIFont systemFontOfSize:10];
    self.getOnLabel1.numberOfLines = 0;
    [self addSubview:self.getOnLabel1];
    
    self.getOffLabel1 = [UILabel new];
    self.getOffLabel1.frame = CGRectMake(160,30,100,20);
    self.getOffLabel1.textColor = [UIColor blackColor];
    self.getOffLabel1.textAlignment = NSTextAlignmentCenter;
    self.getOffLabel1.font = [UIFont systemFontOfSize:10];
    self.getOffLabel1.numberOfLines = 0;
    [self addSubview:self.getOffLabel1];
    
    self.departureLabel1 = [UILabel new];
    self.departureLabel1.frame = CGRectMake(20,40,100,50);
    self.departureLabel1.textColor = [UIColor colorWithRed:184/255.0 green:29/255.0 blue:31/255.0 alpha:1.0];
    self.departureLabel1.textAlignment = NSTextAlignmentCenter;
    self.departureLabel1.font = [UIFont systemFontOfSize:35];
    [self addSubview:self.departureLabel1];
    
    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(120, 40, 40, 50)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"→";
    label.font = [UIFont systemFontOfSize:35];
    label.textColor = [UIColor blackColor];
    [self addSubview:label];
    
    self.arrivalLabel1 = [UILabel new];
    self.arrivalLabel1.frame = CGRectMake(160,40,100,50);
    self.arrivalLabel1.textAlignment = NSTextAlignmentCenter;
    self.arrivalLabel1.textColor = [UIColor colorWithRed:184/255.0 green:29/255.0 blue:31/255.0 alpha:1.0];
    self.arrivalLabel1.font = [UIFont systemFontOfSize:35];
    [self addSubview:self.arrivalLabel1];
    
    
    self.detailLabel1 = [UILabel new];
    self.detailLabel1.frame = CGRectMake(20, 90, frame.size.width, 20);
    self.detailLabel1.textColor = [UIColor blackColor];
    self.detailLabel1.font = [UIFont systemFontOfSize:18];
    [self addSubview:self.detailLabel1];
#pragma mark 経由->降車
    UIView* colorview2 = [[UIView alloc]initWithFrame:CGRectMake(0, 120, frame.size.width, 30)];
    colorview2.backgroundColor = [UIColor colorWithRed:184/255.0 green:29/255.0 blue:31/255.0 alpha:1.0];
    [self addSubview:colorview2];
    
    self.destinationLabel2 = [UILabel new];
    self.destinationLabel2.frame = CGRectMake(20,120, frame.size.width-40, 30);
    self.destinationLabel2.textColor = [UIColor whiteColor];
    self.destinationLabel2.font = [UIFont systemFontOfSize:20];
    [colorview addSubview:self.destinationLabel2];
    
    self.getOnLabel2 = [UILabel new];
    self.getOnLabel2.frame = CGRectMake(20,150,100,20);
    self.getOnLabel2.textColor = [UIColor blackColor];
    self.getOnLabel2.textAlignment = NSTextAlignmentCenter;
    self.getOnLabel2.font = [UIFont systemFontOfSize:10];
    self.getOnLabel2.numberOfLines = 0;
    [self addSubview:self.getOnLabel2];
    
    self.getOffLabel2 = [UILabel new];
    self.getOffLabel2.frame = CGRectMake(160,150,100,20);
    self.getOffLabel2.textColor = [UIColor blackColor];
    self.getOffLabel2.textAlignment = NSTextAlignmentCenter;
    self.getOffLabel2.font = [UIFont systemFontOfSize:10];
    self.getOffLabel2.numberOfLines = 0;
    [self addSubview:self.getOffLabel2];
    
    self.departureLabel2 = [UILabel new];
    self.departureLabel2.frame = CGRectMake(20,160,100,50);
    self.departureLabel2.textColor = [UIColor colorWithRed:184/255.0 green:29/255.0 blue:31/255.0 alpha:1.0];
    self.departureLabel2.textAlignment = NSTextAlignmentCenter;
    self.departureLabel2.font = [UIFont systemFontOfSize:35];
    [self addSubview:self.departureLabel2];
    
    UILabel* label2 = [[UILabel alloc]initWithFrame:CGRectMake(120, 160, 40, 50)];
    label2.textAlignment = NSTextAlignmentCenter;
    label2.text = @"→";
    label2.font = [UIFont systemFontOfSize:35];
    label2.textColor = [UIColor blackColor];
    [self addSubview:label2];
    
    self.arrivalLabel2 = [UILabel new];
    self.arrivalLabel2.frame = CGRectMake(160,160,100,50);
    self.arrivalLabel2.textAlignment = NSTextAlignmentCenter;
    self.arrivalLabel2.textColor = [UIColor colorWithRed:184/255.0 green:29/255.0 blue:31/255.0 alpha:1.0];
    self.arrivalLabel2.font = [UIFont systemFontOfSize:35];
    [self addSubview:self.arrivalLabel2];
    
    
    self.detailLabel2 = [UILabel new];
    self.detailLabel2.frame = CGRectMake(20, 210, frame.size.width, 20);
    self.detailLabel2.textColor = [UIColor blackColor];
    self.detailLabel2.font = [UIFont systemFontOfSize:18];
    [self addSubview:self.detailLabel2];
    
    return self;
}

@end
