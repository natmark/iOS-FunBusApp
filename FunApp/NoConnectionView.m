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
    self.destinationLabel.frame = CGRectMake(20,0, frame.size.width-60, 30);
    self.destinationLabel.textColor = [UIColor whiteColor];
    self.destinationLabel.font = [UIFont systemFontOfSize:20];
    [colorview addSubview:self.destinationLabel];
    
    self.getOnLabel = [UILabel new];
    self.getOnLabel.frame = CGRectMake(20,30,100,20);
    self.getOnLabel.textColor = [UIColor blackColor];
    self.getOnLabel.textAlignment = NSTextAlignmentCenter;
    self.getOnLabel.font = [UIFont systemFontOfSize:10];
    self.getOnLabel.numberOfLines = 0;
    [self addSubview:self.getOnLabel];

    self.getOffLabel = [UILabel new];
    self.getOffLabel.frame = CGRectMake(160,30,100,20);
    self.getOffLabel.textColor = [UIColor blackColor];
    self.getOffLabel.textAlignment = NSTextAlignmentCenter;
    self.getOffLabel.font = [UIFont systemFontOfSize:10];
    self.getOffLabel.numberOfLines = 0;
    [self addSubview:self.getOffLabel];

    self.departureLabel = [UILabel new];
    self.departureLabel.frame = CGRectMake(20,40,100,50);
    self.departureLabel.textColor = [UIColor colorWithRed:184/255.0 green:29/255.0 blue:31/255.0 alpha:1.0];
    self.departureLabel.textAlignment = NSTextAlignmentCenter;
    self.departureLabel.font = [UIFont systemFontOfSize:35];
    [self addSubview:self.departureLabel];

    UILabel* label = [[UILabel alloc]initWithFrame:CGRectMake(120, 40, 40, 50)];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"→";
    label.font = [UIFont systemFontOfSize:35];
    label.textColor = [UIColor blackColor];
    [self addSubview:label];
    
    self.arrivalLabel = [UILabel new];
    self.arrivalLabel.frame = CGRectMake(160,40,100,50);
    self.arrivalLabel.textAlignment = NSTextAlignmentCenter;
    self.arrivalLabel.textColor = [UIColor colorWithRed:184/255.0 green:29/255.0 blue:31/255.0 alpha:1.0];
    self.arrivalLabel.font = [UIFont systemFontOfSize:35];
    [self addSubview:self.arrivalLabel];

    
    self.detailLabel = [UILabel new];
    self.detailLabel.frame = CGRectMake(20, 90, frame.size.width, 20);
    self.detailLabel.textColor = [UIColor blackColor];
    self.detailLabel.font = [UIFont systemFontOfSize:18];
    [self addSubview:self.detailLabel];
    

    self.mapButton = [UIButton new];
    self.mapButton.frame = CGRectMake(colorview.frame.size.width-28, 2, 26, 26);
    [self.mapButton setImage:[UIImage imageNamed:@"pin.png"] forState:UIControlStateNormal];
    [self.mapButton setImage:[UIImage imageNamed:@"pin.png"] forState:UIControlStateHighlighted];
    self.mapButton.backgroundColor = [UIColor whiteColor];
    self.mapButton.clipsToBounds = YES;
    self.mapButton.layer.cornerRadius = self.mapButton.frame.size.width / 4;
    [self addSubview:self.mapButton];
    
    self.twitter = [UIButton new];
    self.twitter.frame = CGRectMake(self.frame.size.width - 50,self.frame.size.height - 50, 40, 40);
    [self.twitter setImage:[UIImage imageNamed:@"twitter.png"] forState:UIControlStateNormal];
    self.twitter.backgroundColor = [UIColor whiteColor];
    self.twitter.clipsToBounds = YES;
    self.twitter.layer.cornerRadius = self.twitter.frame.size.width / 4;
    [self addSubview:self.twitter];
    
    self.timerList = [UIButton new];
    self.timerList.frame = CGRectMake(self.twitter.frame.origin.x - 50,self.frame.size.height - 50, 40, 40);
    [self.timerList setImage:[UIImage imageNamed:@"list.png"] forState:UIControlStateNormal];
    self.timerList.backgroundColor = [UIColor whiteColor];
    self.timerList.clipsToBounds = YES;
    self.timerList.layer.cornerRadius = self.timerList.frame.size.width / 4;
    [self addSubview:self.timerList];

    self.bookmark = [UIButton new];
    self.bookmark.frame = CGRectMake(self.timerList.frame.origin.x - 50,self.frame.size.height - 50, 40, 40);
    [self.bookmark setImage:[UIImage imageNamed:@"bookmark.png"] forState:UIControlStateNormal];
    self.bookmark.backgroundColor = [UIColor whiteColor];
    self.bookmark.clipsToBounds = YES;
    self.bookmark.layer.cornerRadius = self.bookmark.frame.size.width / 4;
    [self addSubview:self.bookmark];

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
