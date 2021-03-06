//
//  RedpacketMessage.h
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-25.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import <RongIMLib/RongIMLib.h>

#import "RPRedpacketModel.h"
#import "RPRedpacketUnionHandle.h"

#define YZHRedpacketMessageTypeIdentifier @"YZH:RedPacketMsg"

// 云帐户红包消息类
@interface RedpacketMessage : RCMessageContent

@property (nonatomic, readonly) NSDictionary * _Nullable redpackDic;
@property (nonatomic, readonly)  RPRedpacketModel * __nonnull redpacket;
@property (nonatomic, readonly)  AnalysisRedpacketModel  * __nonnull analyModel;
// 红包消息未包含对方的用户昵称，所以需要消息体自己处理
@property (nonnull, readwrite, strong) RCUserInfo *redpacketUserInfo;

+ (instancetype _Nonnull)messageWithRedpacket:(RPRedpacketModel * _Nonnull) redpacket;

@end
