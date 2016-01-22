//
//  RouteSearchManager.m
//  FunApp
//
//  Created by Atsuya Sato on 2016/01/22.
//  Copyright © 2016年 Atsuya Sato. All rights reserved.
//

#import "RouteSearchManager.h"

@implementation RouteSearchManager

+(void)getRouteWithGetOn:(NSDictionary*)getOn getOff:(NSDictionary*)getOff completionHandler:(void (^)(NSDictionary *dict,NSError *error))handler{
    [[BusSearchManager sharedManager]isSystemMeintenanceWithcompletionHandler:^(BOOL meintenanceFlg,NSError *error){
        if(error){
            NSError * err = [NSError errorWithDomain:RouteSearchManagerError code:RouteSearchManagerErrorCodeNetwork userInfo: [NSDictionary dictionaryWithObject:@"ネットワークエラー" forKey:NSLocalizedDescriptionKey]];
            handler(nil,err);
            return;
        }
        if(!meintenanceFlg){
            [[BusSearchManager sharedManager]isExistRouteWithGetOn:[[getOn objectForKey:@"code"]intValue] getOff:[[getOff objectForKey:@"code"]intValue] completionHandler:^(BOOL flg,NSError *error){
                if(error){
                    NSError * err = [NSError errorWithDomain:RouteSearchManagerError code:RouteSearchManagerErrorCodeNetwork userInfo: [NSDictionary dictionaryWithObject:@"ネットワークエラー" forKey:NSLocalizedDescriptionKey]];
                    handler(nil,err);
                    return;
                }
                if(flg){
                    NSLog(@">直通路線はあります。");
                    [[BusSearchManager sharedManager]isOutOfServiceWithGetOn:[[getOn objectForKey:@"code"]intValue] getOff:[[getOff objectForKey:@"code"]intValue] completionHandler:^(BOOL flg2,NSError *error){
                        if(error){
                            NSError * err = [NSError errorWithDomain:RouteSearchManagerError code:RouteSearchManagerErrorCodeNetwork userInfo: [NSDictionary dictionaryWithObject:@"ネットワークエラー" forKey:NSLocalizedDescriptionKey]];
                            handler(nil,err);
                            return;
                        }
                        
                        if(!flg2){
                            NSLog(@">バスあります");
                            [[BusSearchManager sharedManager]GETRouteSearchResultWithGetOn:[[getOn objectForKey:@"code"]intValue] GetOff:[[getOff objectForKey:@"code"]intValue] completionHandler:^(NSArray* array,NSError* error){
                                if(error){
                                    NSError * err = [NSError errorWithDomain:RouteSearchManagerError code:RouteSearchManagerErrorCodeNetwork userInfo: [NSDictionary dictionaryWithObject:@"ネットワークエラー" forKey:NSLocalizedDescriptionKey]];
                                    handler(nil,err);
                                    return;
                                }
                                NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:array,@"data",RouteTypeSimple,@"type",nil];
                                handler(dict,nil);
#warning 検索後の処理
                                //[self showSearchResult];
                            }];
                            
                        }else{
                            NSLog(@">営業時間終了");
                            NSError * err = [NSError errorWithDomain:RouteSearchManagerError code:RouteSearchManagerErrorCodeOutOfService userInfo: [NSDictionary dictionaryWithObject:@"上記路線の本日の運行は終了しました。" forKey:NSLocalizedDescriptionKey]];
                            handler(nil,err);
                            return;
                        }
                    }];
                }else{
                    NSLog(@">直通路線はありません。");
                NSMutableArray* connectionSearchResultArray = [NSMutableArray new];

                    /*乗り継ぎバス停を検索*/
                    /*乗り継ぎバス停は以下8つのみ*/
                    /*現状2回以上の乗り継ぎは対応しない方向で*/
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
                    NSMutableArray* candidateArray = [[NSMutableArray alloc]init];
                    
                    int id_list[8] = {3,144,454,357,7,361,450,150};
                    
                    for(int i = 0;i < 8;i++){
                        if([[getOn objectForKey:@"id"]intValue] != id_list[i] && [[getOff objectForKey:@"id"]intValue] != id_list[i]){
                            NSDictionary* dict = [[BusSearchManager sharedManager]getBusInfo:id_list[i]];
                            [candidateArray addObject:dict];
                        }
                    }
                    
                    
                    __block bool route_flg = false;
                    __block bool data_flg = false;
                    __block int counta = 0;
                    
                    for(int i = 0;i < [candidateArray count];i++){
                        NSDictionary* dict = [candidateArray objectAtIndex:i];
                        
                        [[BusSearchManager sharedManager]isExistRouteWithGetOn:[[getOn objectForKey:@"code"]intValue] getOff:[[dict objectForKey:@"code"]intValue] completionHandler:^(BOOL flg2,NSError *error){
                            if(error){
                                NSError * err = [NSError errorWithDomain:RouteSearchManagerError code:RouteSearchManagerErrorCodeNetwork userInfo: [NSDictionary dictionaryWithObject:@"ネットワークエラー" forKey:NSLocalizedDescriptionKey]];
                                handler(nil,err);
                                return;
                            }
                            if(flg2){
                                [[BusSearchManager sharedManager]isExistRouteWithGetOn:[[dict objectForKey:@"code"]intValue] getOff:[[getOff objectForKey:@"code"]intValue] completionHandler:^(BOOL flg3,NSError *error){
                                    if(error){
                                        NSError * err = [NSError errorWithDomain:RouteSearchManagerError code:RouteSearchManagerErrorCodeNetwork userInfo: [NSDictionary dictionaryWithObject:@"ネットワークエラー" forKey:NSLocalizedDescriptionKey]];
                                        handler(nil,err);
                                        return;
                                    }
                                    if(flg3){
                                        NSLog(@">経由路線発見");
                                        [[BusSearchManager sharedManager]isOutOfServiceWithGetOn:[[getOn objectForKey:@"code"]intValue] getOff:[[dict objectForKey:@"code"]intValue] completionHandler:^(BOOL flg4,NSError *error){
                                            if(error){
                                                NSError * err = [NSError errorWithDomain:RouteSearchManagerError code:RouteSearchManagerErrorCodeNetwork userInfo: [NSDictionary dictionaryWithObject:@"ネットワークエラー" forKey:NSLocalizedDescriptionKey]];
                                                handler(nil,err);
                                                return;
                                            }
                                            if(!flg4){
                                                NSLog(@">乗車->乗り継ぎ バス営業中");
                                                [[BusSearchManager sharedManager]GETRouteSearchResultWithGetOn:[[getOn objectForKey:@"code"]intValue] GetOff:[[dict objectForKey:@"code"]intValue] completionHandler:^(NSArray* array,NSError *error){
                                                    if(error){
                                                        NSError * err = [NSError errorWithDomain:RouteSearchManagerError code:RouteSearchManagerErrorCodeNetwork userInfo: [NSDictionary dictionaryWithObject:@"ネットワークエラー" forKey:NSLocalizedDescriptionKey]];
                                                        handler(nil,err);
                                                        return;
                                                    }
                                                    [[BusSearchManager sharedManager]isOutOfServiceWithGetOn:[[dict objectForKey:@"code"]intValue] getOff:[[getOff objectForKey:@"code"]intValue] completionHandler:^(BOOL flg5,NSError *error){
                                                        if(error){
                                                            NSError * err = [NSError errorWithDomain:RouteSearchManagerError code:RouteSearchManagerErrorCodeNetwork userInfo: [NSDictionary dictionaryWithObject:@"ネットワークエラー" forKey:NSLocalizedDescriptionKey]];
                                                            handler(nil,err);
                                                            return;
                                                        }
                                                        if(!flg5){
                                                            NSLog(@">乗り継ぎ->降車 バス営業中");
                                                            [[BusSearchManager sharedManager]GETRouteSearchResultWithGetOn:[[dict objectForKey:@"code"]intValue] GetOff:[[getOff objectForKey:@"code"]intValue] completionHandler:^(NSArray* array3,NSError *error){
                                                                if(error){
                                                                    NSError * err = [NSError errorWithDomain:RouteSearchManagerError code:RouteSearchManagerErrorCodeNetwork userInfo: [NSDictionary dictionaryWithObject:@"ネットワークエラー" forKey:NSLocalizedDescriptionKey]];
                                                                    handler(nil,err);
                                                                    return;
                                                                }
                                                                [[BusSearchManager sharedManager]GETArrivedTimeWithURL:[[array3 objectAtIndex:0]objectForKey:@"url"] completionHandler:^(NSArray* array2,NSError *error){
                                                                    if(error){
                                                                        NSError * err = [NSError errorWithDomain:RouteSearchManagerError code:RouteSearchManagerErrorCodeNetwork userInfo: [NSDictionary dictionaryWithObject:@"ネットワークエラー" forKey:NSLocalizedDescriptionKey]];
                                                                        handler(nil,err);
                                                                        return;
                                                                    }
                                                                    
                                                                    NSDictionary* data = [[NSDictionary alloc]initWithObjectsAndKeys:array,@"first",
                                                                                          array3,@"second",dict,@"via",nil];
                                                                    [connectionSearchResultArray addObject:data];
                                                                    counta++;
                                                                    data_flg = true;
                                                                    if (counta == [candidateArray count] && data_flg == true) {
                                                                        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:connectionSearchResultArray,@"data",RouteTypeComplex,@"type",nil];
                                                                        handler(dict,nil);
#warning 検索後の処理
                                                                        //[self searchEarlyest];
                                                                    }else if(counta == [candidateArray count] && route_flg == true){
                                                                        NSError * err = [NSError errorWithDomain:RouteSearchManagerError code:RouteSearchManagerErrorCodeOutOfService userInfo: [NSDictionary dictionaryWithObject:@"上記路線の本日の運行は終了しました。" forKey:NSLocalizedDescriptionKey]];
                                                                        handler(nil,err);
                                                                        return;
                                                                    }else if(counta == [candidateArray count] && route_flg == false){
                                                                        NSError * err = [NSError errorWithDomain:RouteSearchManagerError code:RouteSearchManagerErrorCodeNoRoute userInfo: [NSDictionary dictionaryWithObject:@"上記路線間のルートが見つかりませんでした。" forKey:NSLocalizedDescriptionKey]];
                                                                        handler(nil,err);
                                                                        return;
                                                                    }
                                                                    
                                                                }];
                                                            }];
                                                        }else{
                                                            NSLog(@">営業時間終了");
                                                            counta++;
                                                            route_flg = true;
                                                            if (counta == [candidateArray count] && data_flg == true) {
                                                                NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:connectionSearchResultArray,@"data",RouteTypeComplex,@"type",nil];
                                                                handler(dict,nil);
#warning 検索後の処理
                                                                //[self searchEarlyest];
                                                            }else if(counta == [candidateArray count] && route_flg == true){
                                                                NSError * err = [NSError errorWithDomain:RouteSearchManagerError code:RouteSearchManagerErrorCodeOutOfService userInfo: [NSDictionary dictionaryWithObject:@"上記路線の本日の運行は終了しました。" forKey:NSLocalizedDescriptionKey]];
                                                                handler(nil,err);
                                                                return;
                                                            }else if(counta == [candidateArray count] && route_flg == false){
                                                                NSError * err = [NSError errorWithDomain:RouteSearchManagerError code:RouteSearchManagerErrorCodeNoRoute userInfo: [NSDictionary dictionaryWithObject:@"上記路線間のルートが見つかりませんでした。" forKey:NSLocalizedDescriptionKey]];
                                                                handler(nil,err);
                                                                return;
                                                            }
                                                        }
                                                    }];
                                                }];
                                            }else{
                                                NSLog(@">営業時間終了");
                                                counta++;
                                                route_flg = true;
                                                if (counta == [candidateArray count] && data_flg == true) {
                                                    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:connectionSearchResultArray,@"data",RouteTypeComplex,@"type",nil];
                                                    handler(dict,nil);
#warning 検索後の処理
                                                    //[self searchEarlyest];
                                                }else if(counta == [candidateArray count] && route_flg == true){
                                                    NSError * err = [NSError errorWithDomain:RouteSearchManagerError code:RouteSearchManagerErrorCodeOutOfService userInfo: [NSDictionary dictionaryWithObject:@"上記路線の本日の運行は終了しました。" forKey:NSLocalizedDescriptionKey]];
                                                    handler(nil,err);
                                                    return;
                                                }else if(counta == [candidateArray count] && route_flg == false){
                                                    NSError * err = [NSError errorWithDomain:RouteSearchManagerError code:RouteSearchManagerErrorCodeNoRoute userInfo: [NSDictionary dictionaryWithObject:@"上記路線間のルートが見つかりませんでした。" forKey:NSLocalizedDescriptionKey]];
                                                    handler(nil,err);
                                                    return;
                                                }
                                            }
                                        }];
                                    }else{
                                        NSLog(@">直通路線なし");
                                        counta++;
                                        NSLog(@"counta:%d",counta);
                                        
                                        if (counta == [candidateArray count] && data_flg == true) {
                                            NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:connectionSearchResultArray,@"data",RouteTypeComplex,@"type",nil];
                                            handler(dict,nil);
#warning 検索後の処理
                                            //[self searchEarlyest];
                                        }else if(counta == [candidateArray count] && route_flg == true){
                                            NSError * err = [NSError errorWithDomain:RouteSearchManagerError code:RouteSearchManagerErrorCodeOutOfService userInfo: [NSDictionary dictionaryWithObject:@"上記路線の本日の運行は終了しました。" forKey:NSLocalizedDescriptionKey]];
                                            handler(nil,err);
                                            return;
                                        }else if(counta == [candidateArray count] && route_flg == false){
                                            NSError * err = [NSError errorWithDomain:RouteSearchManagerError code:RouteSearchManagerErrorCodeNoRoute userInfo: [NSDictionary dictionaryWithObject:@"上記路線間のルートが見つかりませんでした。" forKey:NSLocalizedDescriptionKey]];
                                            handler(nil,err);
                                            return;
                                        }
                                    }
                                }];
                            }else{
                                NSLog(@">直通路線なし");
                                counta++;
                                if (counta == [candidateArray count] && data_flg == true) {
                                    NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:connectionSearchResultArray,@"data",RouteTypeComplex,@"type",nil];
                                    handler(dict,nil);
#warning 検索後の処理
                                    //[self searchEarlyest];
                                }else if(counta == [candidateArray count] && route_flg == true){
                                    NSError * err = [NSError errorWithDomain:RouteSearchManagerError code:RouteSearchManagerErrorCodeOutOfService userInfo: [NSDictionary dictionaryWithObject:@"上記路線の本日の運行は終了しました。" forKey:NSLocalizedDescriptionKey]];
                                    handler(nil,err);
                                    return;
                                }else if(counta == [candidateArray count] && route_flg == false){
                                    NSError * err = [NSError errorWithDomain:RouteSearchManagerError code:RouteSearchManagerErrorCodeNoRoute userInfo: [NSDictionary dictionaryWithObject:@"上記路線間のルートが見つかりませんでした。" forKey:NSLocalizedDescriptionKey]];
                                    handler(nil,err);
                                    return;
                                }
                            }
                        }];
                    }
                }
            }];
        }else{
            NSLog(@">システムメンテナンス中");
            NSError * err = [NSError errorWithDomain:RouteSearchManagerError code:RouteSearchManagerErrorCodeSystemMaintenance userInfo: [NSDictionary dictionaryWithObject:@"システムメンテナンス中です。" forKey:NSLocalizedDescriptionKey]];
            handler(nil,err);
            return;
        }
    }];
}

@end
