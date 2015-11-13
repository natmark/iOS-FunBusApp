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
#pragma mark 直通路線が存在するかどうかの関数
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
#pragma mark 営業時間外かどうかを返す関数
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
#pragma mark ルート検索の結果を返す関数
-(void)GETRouteSearchResultWithGetOn:(int)on GetOff:(int)off completionHandler:(void (^)(NSArray* array))handler{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.hakobus.jp/result.php?in=%d&out=%d",on,off]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                              NSURLResponse *response,
                                                              NSError *error){
        NSString* str = [[NSString alloc] initWithData:data encoding:NSShiftJISStringEncoding];
        NSMutableArray* resultArray = [NSMutableArray new];
        
        NSArray* timeArray = [self HTMLParserWithString:str pattern:@"(<td width=\"50\"><div align=\"center\">(.*?)</div></td>\n<td width=\"140\">)"];
        
        NSArray* destinationArray = [self HTMLParserWithString:str pattern:@"(<td width=\"120\"><div align=center>(.*?)</div></td>)"];
        
        NSArray* urlArray = [self HTMLParserWithString:str pattern:@"(<td width=\"50\"><div align=\"center\"><a href=\"(.*?)\"><img src=\"img/icon_keiro01.gif\" width=\"38\" height=\"16\" border=\"0\"></a></div></td>)"];
        
        for (int i = 0; i < [timeArray count]; i++) {
            NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [timeArray objectAtIndex:i],@"time",
                                  [destinationArray objectAtIndex:i],@"destination",
                                  [urlArray objectAtIndex:i],@"URL",nil];
            [resultArray addObject:dict];
        }
        handler(resultArray);
    }] resume];
}
#pragma mark 各地点の到着時間を返す関数
-(void)GETArrivedTimeWithURL:(NSString*)url completionHandler:(void (^)(NSArray *array))handler{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://%@",url]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                              NSURLResponse *response,
                                                              NSError *error){
        NSString* str = [[NSString alloc] initWithData:data encoding:NSShiftJISStringEncoding];
        
        NSMutableArray* resultArray = [NSMutableArray new];
        
        NSArray* nameArray = [self HTMLParserWithString:str pattern:@"(&nbsp;(.*?)&nbsp;)"];
        NSArray* timeArray = [self HTMLParserWithString:str pattern:@"(&nbsp;　（(.*?)）<!-- 1 -->)"];
        
        for(int i = 0;i < [timeArray count];i++){
            NSLog(@"%@ %@",[nameArray objectAtIndex:i],[timeArray objectAtIndex:i]);
            NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[nameArray objectAtIndex:i],@"name",
                                  [timeArray objectAtIndex:i],@"time",nil];
            [resultArray addObject:dict];
        }
        handler(resultArray);
    }] resume];
}
-(NSArray*)HTMLParserWithString:(NSString*)str pattern:(NSString*)ptn{
    NSMutableArray* array = [NSMutableArray new];
    NSError* error = nil;
    //#タグの検索
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:ptn options:0 error:&error];
    if (error == nil) {
        NSArray *arr = [regexp matchesInString:str options:0 range:NSMakeRange(0, str.length)];
        for (NSTextCheckingResult *match in arr) {
            NSRange range = [match rangeAtIndex:2];
            NSString *str1=[str substringWithRange:range];
            [array addObject:str1];
        }
    }
    return array;
}
- (id)init
{
    self = [super init];
    if (self) {
        //Initialization
    }
    return self;
}

@end
