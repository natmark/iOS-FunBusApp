//
//  ConnectionView.h
//  FunApp
//
//  Created by Atsuya Sato on 2015/11/27.
//  Copyright © 2015年 Atsuya Sato. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConnectionView : UIView
//TODO:乗車->経由
@property(nonatomic,strong)UILabel* departureLabel1;
@property(nonatomic,strong)UILabel* destinationLabel1;
@property(nonatomic,strong)UILabel* detailLabel1;
@property(nonatomic,strong)UILabel* arrivalLabel1;
@property(nonatomic,strong)UILabel* getOnLabel1;
@property(nonatomic,strong)UILabel* getOffLabel1;
@property(nonatomic,strong)UIButton* mapButton1;

//TODO:経由->降車
@property(nonatomic,strong)UILabel* departureLabel2;
@property(nonatomic,strong)UILabel* destinationLabel2;
@property(nonatomic,strong)UILabel* detailLabel2;
@property(nonatomic,strong)UILabel* arrivalLabel2;
@property(nonatomic,strong)UILabel* getOnLabel2;
@property(nonatomic,strong)UILabel* getOffLabel2;
@property(nonatomic,strong)UIButton* mapButton2;

//その他
@property(nonatomic,strong)UIButton* twitter;
@property(nonatomic,strong)UIButton* timerList;
@property(nonatomic,strong)UIButton* bookmark;

@end
