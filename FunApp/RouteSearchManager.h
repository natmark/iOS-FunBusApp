//
//  RouteSearchManager.h
//  FunApp
//
//  Created by Atsuya Sato on 2016/01/22.
//  Copyright © 2016年 Atsuya Sato. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BusSearchManager.h"

#define RouteSearchManagerError @"io.github.natmark.RouteSearchManagerError"
typedef enum
{
    RouteSearchManagerErrorCodeNetwork = 0,
    RouteSearchManagerErrorCodeSystemMaintenance,
    RouteSearchManagerErrorCodeNoRoute,
    RouteSearchManagerErrorCodeOutOfService
} RouteSearchManagerErrorCode;

typedef enum{
    RouteTypeSimple = 0,
    RouteTypeComplex
}RouteType;

@interface RouteSearchManager : NSObject

+(RouteSearchManager*)sharedManager;
-(void)getRouteWithGetOn:(NSDictionary*)getOn getOff:(NSDictionary*)getOff completionHandler:(void (^)(NSDictionary *dict,NSError *error))handler;
-(void)getRouteWithGetOn:(NSDictionary*)getOn getOff:(NSDictionary*)getOff via:(NSDictionary*)via completionHandler:(void (^)(NSDictionary *dict,NSError *error))handler;
-(void)getViaListWithGetOn:(NSDictionary*)getOn getOff:(NSDictionary*)getOff completionHandler:(void (^)(NSArray *list,NSError *error))handler;
@end
