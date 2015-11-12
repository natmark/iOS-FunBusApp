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
-(void)routeSearch{
    if(self.GetOnBusStop && self.GetOffBusStop){
        
    }else{
        NSLog(@"Error");
    }
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
