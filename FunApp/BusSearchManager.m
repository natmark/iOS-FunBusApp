//
//  BusSearchManager.m
//  FunApp
//
//  Created by Atsuya Sato on 2015/11/12.
//  Copyright © 2015年 Atsuya Sato. All rights reserved.
//

#import "BusSearchManager.h"

@implementation BusSearchManager{
    void (^varGETRouteSearchResultCompletionHandler)(NSString* data);
}

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
-(void)routeSearch{
    NSLog(@"%@",self.GetOffBusStop);
    NSLog(@"%@",self.GetOnBusStop);
    
    if(self.GetOnBusStop && self.GetOffBusStop){
        [self GETRouteSearchResultWithGetOn:[[self.GetOnBusStop objectForKey:@"code"]intValue] GetOff:[[self.GetOffBusStop objectForKey:@"code"]intValue] completionHandler:^(NSString* data){
            NSLog(@"%@",data);
            
        }];
    }else{
        NSLog(@"Error");
    }
}
#pragma mark ルート検索結果を取得
-(void)GETRouteSearchResultWithGetOn:(int)on GetOff:(int)off completionHandler:(void (^)(NSString *data))handler{
    varGETRouteSearchResultCompletionHandler = handler;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://www.hakobus.jp/result.php?in=%d&out=%d",on,off]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData *data,
                                                              NSURLResponse *response,
                                                              NSError *error){
        NSString* str = [[NSString alloc] initWithData:data encoding:NSShiftJISStringEncoding];
        NSLog(@"%@",str);
        if(varGETRouteSearchResultCompletionHandler){
            varGETRouteSearchResultCompletionHandler(str);
        }
        
        /*
        //jsonデータの取得
        NSMutableDictionary* json = [[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error]mutableCopy];
        
        if(varGETRouteSearchResultCompletionHandler){
            varGETRouteSearchResultCompletionHandler(json);
        }
        */
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
