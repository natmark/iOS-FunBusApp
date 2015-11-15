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
    self.layer.cornerRadius = frame.size.width * 0.1;
    self.layer.borderColor = [[UIColor colorWithRed:184/255.0 green:29/255.0 blue:31/255.0 alpha:1.0]CGColor];
    self.layer.borderWidth = 2.0;
    
    self.departureLabel = [UILabel new];
    self.departureLabel.frame = CGRectMake(20, 0, frame.size.width, 40);
    self.departureLabel.textColor = [UIColor blackColor];
    self.departureLabel.font = [UIFont systemFontOfSize:12];
    
    [self addSubview:self.departureLabel];
    
    self.destinationLabel = [UILabel new];
    self.destinationLabel.frame = CGRectMake(20, 40, frame.size.width, 40);
    self.destinationLabel.textColor = [UIColor blackColor];
    self.destinationLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:self.destinationLabel];
    
    self.detailLabel = [UILabel new];
    self.detailLabel.frame = CGRectMake(20, 80, frame.size.width, 40);
    self.detailLabel.textColor = [UIColor blackColor];
    self.detailLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:self.detailLabel];
    
    self.arrivalLabel = [UILabel new];
    self.arrivalLabel.frame = CGRectMake(20, 120, frame.size.width, 40);
    self.arrivalLabel.textColor = [UIColor blackColor];
    self.arrivalLabel.font = [UIFont systemFontOfSize:12];
    [self addSubview:self.arrivalLabel];

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
