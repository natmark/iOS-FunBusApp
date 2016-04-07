//
//  MyRouteTableViewCell.h
//  FunApp
//
//  Created by Atsuya Sato on 2016/04/06.
//  Copyright © 2016年 Atsuya Sato. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyRouteTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *destinationLabel;
@property (strong, nonatomic) IBOutlet UILabel *departureLabel;
@property (strong, nonatomic) IBOutlet UILabel *routeLabel;
@property (strong, nonatomic) IBOutlet UILabel *detailLabel;

@end
