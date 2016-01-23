//
//  noConnectionView.h
//  FunApp
//
//  Created by Atsuya Sato on 2015/11/14.
//  Copyright © 2015年 Atsuya Sato. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoConnectionView : UIView
@property(nonatomic,strong)UILabel* departureLabel;
@property(nonatomic,strong)UILabel* destinationLabel;
@property(nonatomic,strong)UILabel* detailLabel;
@property(nonatomic,strong)UILabel* arrivalLabel;
@property(nonatomic,strong)UILabel* getOnLabel;
@property(nonatomic,strong)UILabel* getOffLabel;
@property(nonatomic,strong)UIButton* mapButton;
@property(nonatomic,strong)UIButton* twitter;
@property(nonatomic,strong)UIButton* timerList;
@property(nonatomic,strong)UIButton* bookmark;
@end
/*
label.text = [NSString stringWithFormat:@"出発時刻:%@",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"time"]];
label2.text = [NSString stringWithFormat:@"行き先:%@",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"destination"]];
label3.text = [NSString stringWithFormat:@"遅延情報:%@",[[searchResultArray objectAtIndex:showCnt]objectForKey:@"detail"]];
label4.text = [NSString stringWithFormat:@"到着時刻:%@",[dict objectForKey:@"time"]];
*/