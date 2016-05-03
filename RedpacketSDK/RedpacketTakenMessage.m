//
//  RedpacketTakenMessage.m
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-5-3.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RedpacketTakenMessage.h"

@implementation RedpacketTakenMessage

+ (RCMessagePersistent)persistentFlag {
    return (MessagePersistent_ISPERSISTED);
}

+ (NSString *)getObjectName
{
    return YZHRedpacketTakenMessageTypeIdentifier;
}

@end
