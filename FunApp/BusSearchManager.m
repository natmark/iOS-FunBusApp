//
//  BusSearchManager.m
//  FunApp
//
//  Created by Atsuya Sato on 2015/11/12.
//  Copyright © 2015年 Atsuya Sato. All rights reserved.
//

#import "BusSearchManager.h"
#define SYSTEM_MAINTENANCE_URL @"http://www.hakobus.jp/search01.php"
#define ROUTE_SEARCH_URL @"http://www.hakobus.jp/result.php"
#define GET_MAP_IMAGE_URL @"http://www.hakobus.jp/"

#define CONFIRM_ROUTE_CACHE 60*24//min
#define ROUTE_SEARCH_CACHE 1//min
#define GET_ARRIVED_TIME_CACHE 60*24//min
#define GET_MAP_IMAGE 60*24*7//min


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
#pragma mark バス検索関数
-(NSArray*)busSearch:(NSString *)str{
    NSMutableArray* getArray = [NSMutableArray new];
    int priority_counter = 0;
    for(NSDictionary* dict in busInfo){
        NSRange found = [[dict objectForKey:@"name"] rangeOfString:str];
        
        if((int)found.location != -1){
            if((int)found.location == 0){
                //前方一致を優先表示&plistの順番優先
                [getArray insertObject:dict atIndex:priority_counter];
                priority_counter++;
            }else if((int)found.location > 0){
                [getArray addObject:dict];
            }
        }
    }
    getArray = [self arraySort:getArray];
    return getArray;
}
#pragma mark バス検索配列のソート
-(NSMutableArray*)arraySort:(NSArray*)arr{
    /*
     ・函館駅前 id:3 code:3
     ・五稜郭 id:144 code:149
     ・湯倉神社前 id:454 code:465
     ・テーオーデパート前 id:357 code:363
     ・ガス会社前 id:7 code:7
     ・深堀町 id:361 code:367
     ・花園町 id:450 code:461
     ・亀田支所前 id:150 code:155
     */
    //乗り換えバス停を優先表示
    NSMutableArray* candidateArray = [arr mutableCopy];
    
    int id_list[8] = {3,144,454,357,7,361,450,150};
    
    for(int i = 0;i < 8;i++){
        NSDictionary* dict = [[BusSearchManager sharedManager]getBusInfo:id_list[i]];
        if([candidateArray containsObject:dict]){
            [candidateArray removeObject:dict];
            [candidateArray insertObject:dict atIndex:0];
        }
    }
    return candidateArray;
}

#pragma mark バス情報返信関数
-(NSDictionary*)getBusInfo:(int)bus_id{
    NSDictionary* returnDict = [NSDictionary new];
    
    for(NSDictionary* dict in busInfo){
        if([[dict objectForKey:@"id"]intValue] == bus_id){
            returnDict = dict;
        }
    }
    return returnDict;
}
#pragma mark システムメンテナンスかどうかの関数
-(void)isSystemMeintenanceWithcompletionHandler:(void (^)(BOOL flg,NSError *error))handler{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:SYSTEM_MAINTENANCE_URL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                              NSURLResponse *response,
                                                              NSError *error){
     
        NSString* str = [[NSString alloc] initWithData:data encoding:NSShiftJISStringEncoding];
        NSRange range = [str rangeOfString:@"只今、システムメンテナンス中のためバス接近情報はご利用できません。"];
        BOOL flg = false;
        if (range.location != NSNotFound) {
            flg = true;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(flg,error);
        });
    }] resume];

}

#pragma mark 直通路線が存在するかどうかの関数
-(void)isExistRouteWithGetOn:(int)on getOff:(int)off completionHandler:(void (^)(BOOL flg,NSError *error))handler{
    /*=======================*/
    //データ読み込み
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    NSDictionary* loadData = [ud objectForKey:[NSString stringWithFormat:@"%@?in=%d&out=%d",ROUTE_SEARCH_URL,on,off]];
    if(loadData){
        NSDate* saveDate = [loadData objectForKey:@"date"];
        NSDate* nowDate = [NSDate date];
        NSTimeInterval since;
        // dateBとdateAの時間の間隔を取得(dateB - dateAなイメージ)
        since = [nowDate timeIntervalSinceDate:saveDate];
        NSLog(@"%f分", since/60);
        if(since/60 < CONFIRM_ROUTE_CACHE){
            NSLog(@">>USE CACHE");
            NSData* loadSearchData = [loadData objectForKey:@"data"];
            NSString* str = [[NSString alloc] initWithData:loadSearchData encoding:NSShiftJISStringEncoding];
            NSRange range = [str rangeOfString:@"指定された区間の直通便はありません。"];
            BOOL flg = true;
            if (range.location != NSNotFound) {
                flg = false;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(flg,nil);
            });
            return;
        }
    }
    /*=======================*/

    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?in=%d&out=%d",ROUTE_SEARCH_URL,on,off]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];

    [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                              NSURLResponse *response,
                                                              NSError *error){
        /*=======================*/
        //データ保存
        NSDate* now = [NSDate date];
        NSDictionary* saveData = [NSDictionary dictionaryWithObjectsAndKeys:now,@"date",data,@"data",nil];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];  // 取得
        [userDefault setObject:saveData forKey:[response.URL absoluteString]];
        /*=======================*/
        
        NSString* str = [[NSString alloc] initWithData:data encoding:NSShiftJISStringEncoding];
        NSRange range = [str rangeOfString:@"指定された区間の直通便はありません。"];
        BOOL flg = true;
        if (range.location != NSNotFound) {
            flg = false;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(flg,error);
        });
    }] resume];
}
#pragma mark 営業時間外かどうかを返す関数
-(void)isOutOfServiceWithGetOn:(int)on getOff:(int)off completionHandler:(void (^)(BOOL flg,NSError *error))handler{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?in=%d&out=%d",ROUTE_SEARCH_URL,on,off]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];

    [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                              NSURLResponse *response,
                                                              NSError *error){
        NSString* str = [[NSString alloc] initWithData:data encoding:NSShiftJISStringEncoding];
        NSRange range = [str rangeOfString:@"本日の運行は終了しました。"];
        BOOL flg = false;
        if (range.location != NSNotFound) {
            flg = true;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(flg,nil);
        });
    }] resume];

}
#pragma mark ルート検索の結果を返す関数
-(void)GETRouteSearchResultWithGetOn:(int)on GetOff:(int)off completionHandler:(void (^)(NSArray* array,NSError *error))handler{
    /*=======================*/
    //データ読み込み
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    NSDictionary* loadData = [ud objectForKey:[NSString stringWithFormat:@"%@?in=%d&out=%d",ROUTE_SEARCH_URL,on,off]];
    if(loadData){
        NSDate* saveDate = [loadData objectForKey:@"date"];
        NSDate* nowDate = [NSDate date];
        NSTimeInterval since;
        // dateBとdateAの時間の間隔を取得(dateB - dateAなイメージ)
        since = [nowDate timeIntervalSinceDate:saveDate];
        NSLog(@"%f分", since/60);
        if(since/60 < ROUTE_SEARCH_CACHE){
            NSLog(@">>USE CACHE");
            NSData* loadSearchData = [loadData objectForKey:@"data"];
            NSString* str = [[NSString alloc] initWithData:loadSearchData encoding:NSShiftJISStringEncoding];
            NSMutableArray* resultArray = [NSMutableArray new];
            
            NSArray* timeArray = [self HTMLParserWithString:str pattern:@"(<td width=\"50\"><div align=\"center\">(.*?)</div></td>\n<td width=\"140\">)"];
            
            NSArray* destinationArray = [self HTMLParserWithString:str pattern:@"(<td width=\"120\"><div align=center>(.*?)</div></td>)"];
            
            NSArray* urlArray = [self HTMLParserWithString:str pattern:@"(<td width=\"50\"><div align=\"center\"><a href=\"(.*?)\"><img src=\"img/icon_keiro01.gif\" width=\"38\" height=\"16\" border=\"0\"></a></div></td>)"];
            
            NSArray* detailArray = [self HTMLParserWithString:str pattern:@"(<td width=\"160\">(.*?)</td>)"];
            
            NSArray* mapArray = [self HTMLParserWithString:str pattern:@"(<td width=\"100\"><div align=center><a href=(.*?)>.*?</a></div></td>)"];
    
            NSArray* boardingArray = [self HTMLParserWithString:str pattern:@"(<td width=\"100\"><div align=center><a href=.*?>(.*?)</a></div></td>)"];

            for (int i = 0; i < [timeArray count]; i++) {
                NSString* mapURL = @"";
                NSString* boardingPlace = @"";
                
                if([mapArray count] != 0){
                    mapURL = [mapArray objectAtIndex:i];
                    boardingPlace = [boardingArray objectAtIndex:i];
                }
                
                NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [timeArray objectAtIndex:i],@"time",
                                      [destinationArray objectAtIndex:i],@"destination",
                                      [urlArray objectAtIndex:i],@"url",
                                      mapURL,@"map",
                                      boardingPlace,@"boarding",
                                      [detailArray objectAtIndex:i],@"detail",nil];
                [resultArray addObject:dict];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(resultArray,nil);
            });

            return;
        }
    }
    /*=======================*/
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@?in=%d&out=%d",ROUTE_SEARCH_URL,on,off]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];

    [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                              NSURLResponse *response,
                                                              NSError *error){
        /*=======================*/
        //データ保存
        NSDate* now = [NSDate date];
        NSDictionary* saveData = [NSDictionary dictionaryWithObjectsAndKeys:now,@"date",data,@"data",nil];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];  // 取得
        [userDefault setObject:saveData forKey:[response.URL absoluteString]];
        /*=======================*/
        NSString* str = [[NSString alloc] initWithData:data encoding:NSShiftJISStringEncoding];
        NSMutableArray* resultArray = [NSMutableArray new];
        
        NSArray* timeArray = [self HTMLParserWithString:str pattern:@"(<td width=\"50\"><div align=\"center\">(.*?)</div></td>\n<td width=\"140\">)"];
        
        NSArray* destinationArray = [self HTMLParserWithString:str pattern:@"(<td width=\"120\"><div align=center>(.*?)</div></td>)"];
        
        NSArray* urlArray = [self HTMLParserWithString:str pattern:@"(<td width=\"50\"><div align=\"center\"><a href=\"(.*?)\"><img src=\"img/icon_keiro01.gif\" width=\"38\" height=\"16\" border=\"0\"></a></div></td>)"];
        
        NSArray* detailArray = [self HTMLParserWithString:str pattern:@"(<td width=\"160\">(.*?)</td>)"];

        NSArray* mapArray = [self HTMLParserWithString:str pattern:@"(<td width=\"100\"><div align=center><a href=(.*?)>.*?</a></div></td>)"];

        NSArray* boardingArray = [self HTMLParserWithString:str pattern:@"(<td width=\"100\"><div align=center><a href=.*?>(.*?)</a></div></td>)"];
        
        for (int i = 0; i < [timeArray count]; i++) {
            NSString* mapURL = @"";
            NSString* boardingPlace = @"";
            
            if([mapArray count] != 0){
                mapURL = [mapArray objectAtIndex:i];
                boardingPlace = [boardingArray objectAtIndex:i];
            }
            
            NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [timeArray objectAtIndex:i],@"time",
                                  [destinationArray objectAtIndex:i],@"destination",
                                  [urlArray objectAtIndex:i],@"url",
                                  mapURL,@"map",
                                  boardingPlace,@"boarding",
                                  [detailArray objectAtIndex:i],@"detail",nil];
            
            [resultArray addObject:dict];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(resultArray,error);
        });
    }] resume];
}
#pragma mark 各地点の到着時間を返す関数
-(void)GETArrivedTimeWithURL:(NSString*)url completionHandler:(void (^)(NSArray *array,NSError *error))handler{
    /*=======================*/
    //データ読み込み
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    NSDictionary* loadData = [ud objectForKey:[NSString stringWithFormat:@"http://www.hakobus.jp/%@",url]];
    if(loadData){
        NSDate* saveDate = [loadData objectForKey:@"date"];
        NSDate* nowDate = [NSDate date];
        NSTimeInterval since;
        // dateBとdateAの時間の間隔を取得(dateB - dateAなイメージ)
        since = [nowDate timeIntervalSinceDate:saveDate];
        NSLog(@"%f分", since/60);
        if(since/60 < GET_ARRIVED_TIME_CACHE){
            NSLog(@">>USE CACHE");
            NSData* loadSearchData = [loadData objectForKey:@"data"];
            NSString* str = [[NSString alloc] initWithData:loadSearchData encoding:NSShiftJISStringEncoding];
            
            NSMutableArray* resultArray = [NSMutableArray new];
            
            NSArray* nameArray = [self HTMLParserWithString:str pattern:@"(&nbsp;(.*?)&nbsp;)"];
            NSArray* timeArray = [self HTMLParserWithString:str pattern:@"(\\s（(.*?)）<!-- 1 -->)"];
            
            for(int i = 0;i < [timeArray count];i++){
                NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[nameArray objectAtIndex:i],@"name",
                                      [timeArray objectAtIndex:i],@"time",nil];
                [resultArray addObject:dict];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                handler(resultArray,nil);
            });

            return;
        }
    }
    /*=======================*/
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.hakobus.jp/%@",url]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];

    [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                              NSURLResponse *response,
                                                              NSError *error){
        /*=======================*/
        //データ保存
        NSDate* now = [NSDate date];
        NSDictionary* saveData = [NSDictionary dictionaryWithObjectsAndKeys:now,@"date",data,@"data",nil];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];  // 取得
        [userDefault setObject:saveData forKey:[response.URL absoluteString]];
        /*=======================*/
        NSString* str = [[NSString alloc] initWithData:data encoding:NSShiftJISStringEncoding];
        
        NSMutableArray* resultArray = [NSMutableArray new];
        
        NSArray* nameArray = [self HTMLParserWithString:str pattern:@"(&nbsp;(.*?)&nbsp;)"];
        NSArray* timeArray = [self HTMLParserWithString:str pattern:@"(\\s（(.*?)）<!-- 1 -->)"];
        
        for(int i = 0;i < [timeArray count];i++){
            NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[nameArray objectAtIndex:i],@"name",
                                  [timeArray objectAtIndex:i],@"time",nil];
            [resultArray addObject:dict];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            handler(resultArray,error);
        });

    }] resume];
}
#pragma mark HTMLパース用関数(private)
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
#pragma mark マップ画像取得関数
-(void)GETMapImageWithURL:(NSString*)url imageView:(UIImageView*)imageView completionHandler:(void (^)(NSError *error))handler{
    /*=======================*/
    //データ読み込み
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];  // 取得
    NSDictionary* loadData = [ud objectForKey:[NSString stringWithFormat:@"%@%@",GET_MAP_IMAGE_URL,url]];
    if(loadData){
        NSDate* saveDate = [loadData objectForKey:@"date"];
        NSDate* nowDate = [NSDate date];
        NSTimeInterval since;
        // dateBとdateAの時間の間隔を取得(dateB - dateAなイメージ)
        since = [nowDate timeIntervalSinceDate:saveDate];
        NSLog(@"%f分", since/60);
        if(since/60 < CONFIRM_ROUTE_CACHE){
            NSLog(@">>USE CACHE");
            NSData* data = [loadData objectForKey:@"data"];
            NSString* str = [[NSString alloc] initWithData:data encoding:NSShiftJISStringEncoding];
            NSString* urlString = [[self HTMLParserWithString:str pattern:@"(<p align=\"center\"><img src=\"(.*?)\" alt=\".*?\" width=\"396\" height=\"460\"></p>)"] firstObject];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",GET_MAP_IMAGE_URL,urlString]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
            
            NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
            
            [[session downloadTaskWithRequest:request completionHandler:^(NSURL *location,
                                                                          NSURLResponse *response,
                                                                          NSError *error){
                if(error){
                    handler(error);
                }
                UIImage *downloadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    imageView.image = downloadedImage;
                    handler(error);
                });
            }] resume];
            return;
        }
    }
    /*=======================*/
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",GET_MAP_IMAGE_URL,url]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                              NSURLResponse *response,
                                                              NSError *error){
        if(error){
            handler(error);
        }
        /*=======================*/
        //データ保存
        NSDate* now = [NSDate date];
        NSDictionary* saveData = [NSDictionary dictionaryWithObjectsAndKeys:now,@"date",data,@"data",nil];
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];  // 取得
        [userDefault setObject:saveData forKey:[response.URL absoluteString]];
        /*=======================*/
        
        NSString* str = [[NSString alloc] initWithData:data encoding:NSShiftJISStringEncoding];
        NSString* urlString = [[self HTMLParserWithString:str pattern:@"(<p align=\"center\"><img src=\"(.*?)\" alt=\".*?\" width=\"396\" height=\"460\"></p>)"] firstObject];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",GET_MAP_IMAGE_URL,urlString]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
        
        [[session downloadTaskWithRequest:request completionHandler:^(NSURL *location,
                                                                     NSURLResponse *response,
                                                                     NSError *error){
            if(error){
                handler(error);
            }
            UIImage *downloadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                imageView.image = downloadedImage;
                handler(error);
            });
        }] resume];
    }] resume];
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
