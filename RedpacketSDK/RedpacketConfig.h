//
//  RedpacketConfig.h
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-25.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YZHRedpacketBridgeProtocol.h"

@interface RedpacketConfig : NSObject <YZHRedpacketBridgeDataSource>

+ (void)configRedpacket;

@end
