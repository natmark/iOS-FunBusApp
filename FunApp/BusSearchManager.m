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
    }
    return sharedData_;
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
