//
//  BusSearchManager.m
//  FunApp
//
//  Created by Atsuya Sato on 2015/11/12.
//  Copyright © 2015年 Atsuya Sato. All rights reserved.
//

#import "BusSearchManager.h"

@implementation BusSearchManager

static BusSearchManager *sharedData_ = nil;
+ (BusSearchManager *)sharedManager{
    if (!sharedData_) {
        sharedData_ = [BusSearchManager new];
        [sharedData_ readPlist];
    }
    return sharedData_;
}
//Plist読み込み
-(void)readPlist{
    busInfo = [NSArray new];
    //読み込むファイルパスを指定
    NSString* path = [[NSBundle mainBundle] pathForResource:@"bus_id" ofType:@"plist"];
    busInfo = [NSArray arrayWithContentsOfFile:path];
}
-(NSArray*)busSearch:(NSString *)str{
    NSMutableArray* getArray = [NSMutableArray new];
    
    for(NSDictionary* dict in busInfo){
        NSRange found = [[dict objectForKey:@"name"] rangeOfString:str];
        if((int)found.location != -1){
            [getArray addObject:dict];
        }
    }
    return getArray;
}
#pragma mark 直通路線が存在するかどうかBOOLの関数
-(void)isExistRouteWithGetOn:(int)on getOff:(int)off completionHandler:(void (^)(BOOL flg))handler{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.hakobus.jp/result.php?in=%d&out=%d",on,off]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                              NSURLResponse *response,
                                                              NSError *error){
        NSString* str = [[NSString alloc] initWithData:data encoding:NSShiftJISStringEncoding];
        NSRange range = [str rangeOfString:@"指定された区間の直通便はありません。"];
        BOOL flg = true;
        if (range.location != NSNotFound) {
            flg = false;
        }
        handler(flg);
    }] resume];
}
#pragma mark 営業時間が終了しているかどうかの関数
-(void)isOutOfServiceWithGetOn:(int)on getOff:(int)off completionHandler:(void (^)(BOOL flg))handler{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.hakobus.jp/result.php?in=%d&out=%d",on,off]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                              NSURLResponse *response,
                                                              NSError *error){
        NSString* str = [[NSString alloc] initWithData:data encoding:NSShiftJISStringEncoding];
        NSRange range = [str rangeOfString:@"本日の運行は終了しました。"];
        BOOL flg = false;
        if (range.location != NSNotFound) {
            flg = true;
        }
        handler(flg);
    }] resume];

}
#pragma mark ルート検索結果を取得
-(void)GETRouteSearchResultWithGetOn:(int)on GetOff:(int)off completionHandler:(void (^)(NSString *data))handler{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.hakobus.jp/result.php?in=%d&out=%d",on,off]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                              NSURLResponse *response,
                                                              NSError *error){
        NSString* str = [[NSString alloc] initWithData:data encoding:NSShiftJISStringEncoding];
        NSLog(@"%@",str);
        handler(str);
    }] resume];
    
}
#pragma mark TODO-LIST
//TODO:直通路線が存在するかどうかBOOLの関数
//TODO:経由候補を調べ、候補一覧を返す関数
//TODO:バス検索関数
//TODO:経由でのバス検索関数
- (id)init
{
    self = [super init];
    if (self) {
        //Initialization
    }
    return self;
}

@end
