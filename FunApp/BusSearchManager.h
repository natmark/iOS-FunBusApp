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

#pragma mark 直通路線が存在するかどうかの関数
-(void)isExistRouteWithGetOn:(int)on getOff:(int)off completionHandler:(void (^)(BOOL flg))handler;
#pragma mark ルート検索の結果を返す関数
-(void)GETRouteSearchResultWithGetOn:(int)on GetOff:(int)off completionHandler:(void (^)(NSArray *array))handler;
#pragma mark 営業時間外かどうかを返す関数
-(void)isOutOfServiceWithGetOn:(int)on getOff:(int)off completionHandler:(void (^)(BOOL flg))handler;
#pragma mark 各地点の到着時間を返す関数
-(void)GETArrivedTimeWithURL:(NSString*)url completionHandler:(void (^)(NSArray *array))handler;
#pragma mark システムメンテナンスかどうかの関数
-(void)isSystemMeintenanceWithcompletionHandler:(void (^)(BOOL flg))handler;
@end
