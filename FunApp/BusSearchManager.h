//
//  BusSearchManager.h
//  FunApp
//
//  Created by Atsuya Sato on 2015/11/12.
//  Copyright © 2015年 Atsuya Sato. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BusSearchManager : NSObject<NSURLSessionDelegate>{
    NSArray* busInfo;
}

+(BusSearchManager*)sharedManager;
#pragma mark バス検索関数
-(NSArray*)busSearch:(NSString*)str;
#pragma mark バス情報返信関数
-(NSDictionary*)getBusInfo:(int)bus_id;

@property(nonatomic,assign)NSDictionary* GetOnBusStop;
@property(nonatomic,assign)NSDictionary* GetOffBusStop;

#pragma mark 直通路線が存在するかどうかの関数
-(void)isExistRouteWithGetOn:(int)on getOff:(int)off completionHandler:(void (^)(BOOL flg,NSError *error))handler;
#pragma mark ルート検索の結果を返す関数
-(void)GETRouteSearchResultWithGetOn:(int)on GetOff:(int)off completionHandler:(void (^)(NSArray *array,NSError *error))handler;
#pragma mark 営業時間外かどうかを返す関数
-(void)isOutOfServiceWithGetOn:(int)on getOff:(int)off completionHandler:(void (^)(BOOL flg,NSError *error))handler;
#pragma mark 各地点の到着時間を返す関数
-(void)GETArrivedTimeWithURL:(NSString*)url completionHandler:(void (^)(NSArray *array,NSError *error))handler;
#pragma mark システムメンテナンスかどうかの関数
-(void)isSystemMeintenanceWithcompletionHandler:(void (^)(BOOL flg,NSError *error))handler;
@end
