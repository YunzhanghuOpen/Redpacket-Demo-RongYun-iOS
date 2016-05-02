//
//  RedpacketMessage.h
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-25.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

#import "RedpacketMessageModel.h"

#define YZHRedpacketMessageTypeIdentifier @"YZH:RedpacketMsg"
#define YZHRedpacketTakenMessageCellTypeIdentifier @"YZH:RedpacketTakenMsg"

// 云帐户红包消息类
@interface RedpacketMessage : RCMessageContent

@property (nonatomic, readonly, copy) RedpacketMessageModel *redpacket;

+ (instancetype)messageWithRedpacket:(RedpacketMessageModel *)redpacket;

@end
