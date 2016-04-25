//
//  RedpacketMessage.h
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-25.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

#import "RedpacketMessageModel.h"

#define YZHRedpacketMessageTypeIdentifier @"YZH:RedpacketMsg"

@interface YZHRedpacketMessage : RCMessageContent

@property (nonatomic, readonly, strong) RedpacketMessageModel *redpacket;

+ (instancetype)messageWithRedpacket:(RedpacketMessageModel *)redpacket;

@end
