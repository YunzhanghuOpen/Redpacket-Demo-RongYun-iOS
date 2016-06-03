//
//  RedpacketConfig.h
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-25.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHRedpacketBridgeProtocol.h"

@interface RedpacketConfig : NSObject <YZHRedpacketBridgeDataSource>

// 由于不清楚的原因，有时候进入界面只有邮箱，没有用户名称，所以需要方法强制使用用户名
@property (nonatomic, copy, readwrite) NSString *currentUserName;
+ (instancetype)sharedConfig;
+ (void)config;
+ (void)reconfig;
+ (void)logout;
@end
