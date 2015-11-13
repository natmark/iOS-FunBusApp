//
//  BusSearchManager.h
//  FunApp
//
//  Created by Atsuya Sato on 2015/11/12.
//  Copyright © 2015年 Atsuya Sato. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusSearchManager : NSObject{
    NSArray* busInfo;
}

+(BusSearchManager*)sharedManager;
//TODO: バス停検索機構・ルート検索機構・plist読み込み機構等 集約予定
-(NSArray*)busSearch:(NSString*)str;
@property(nonatomic,assign)NSDictionary* GetOnBusStop;
@property(nonatomic,assign)NSDictionary* GetOffBusStop;

-(void)isExistRouteWithGetOn:(int)on getOff:(int)off completionHandler:(void (^)(BOOL flg))handler;
-(void)GETRouteSearchResultWithGetOn:(int)on GetOff:(int)off completionHandler:(void (^)(NSString *data))handler;
-(void)isOutOfServiceWithGetOn:(int)on getOff:(int)off completionHandler:(void (^)(BOOL flg))handler;

@end
