//
//  noConnectionView.m
//  FunApp
//
//  Created by Atsuya Sato on 2015/11/14.
//  Copyright © 2015年 Atsuya Sato. All rights reserved.
//

#import "NoConnectionView.h"

@implementation NoConnectionView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.layer.borderColor = [[UIColor colorWithRed:184/255.0 green:29/255.0 blue:31/255.0 alpha:1.0]CGColor];
    self.layer.borderWidth = 2.0;
    
    UIView* colorview = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, 30)];
    colorview.backgroundColor = [UIColor colorWithRed:184/255.0 green:29/255.0 blue:31/255.0 alpha:1.0];
    [self addSubview:colorview];
    
    self.destinationLabel = [UILabel new];
    self.destinationLabel.frame = CGRectMake(20,0, frame.size.width-40, 30);
    self.destinationLabel.textColor = [UIColor whiteColor];
    self.destinationLabel.font = [UIFont systemFontOfSize:20];
    [colorview addSubview:self.destinationLabel];
    
    self.departureLabel = [UILabel new];
    self.departureLabel.frame = CGRectMake(20,30,100,50);
    self.departureLabel.textColor = [UIColor colorWithRed:184/255.0 green:29/255.0 blue:31/255.0 alpha:1.0];
    self.departureLabel.textAlignment = NSTextAlignmentCenter;
    self.departureLabel.font = [UIFont systemFontOfSize:35];
    [self addSubview:self.departureLabel];

    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(120, 30, 40, 50)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"→";
    label.font = [UIFont systemFontOfSize:35];
    label.textColor = [UIColor blackColor];
    [self addSubview:label];
    
    self.arrivalLabel = [UILabel new];
    self.arrivalLabel.frame = CGRectMake(160,30,100,50);
    self.arrivalLabel.textAlignment = NSTextAlignmentCenter;
    self.arrivalLabel.textColor = [UIColor colorWithRed:184/255.0 green:29/255.0 blue:31/255.0 alpha:1.0];
    self.arrivalLabel.font = [UIFont systemFontOfSize:35];
    [self addSubview:self.arrivalLabel];

    
    self.detailLabel = [UILabel new];
    self.detailLabel.frame = CGRectMake(20, 90, frame.size.width, 20);
    self.detailLabel.textColor = [UIColor blackColor];
    self.detailLabel.font = [UIFont systemFontOfSize:18];
    [self addSubview:self.detailLabel];
    

    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
