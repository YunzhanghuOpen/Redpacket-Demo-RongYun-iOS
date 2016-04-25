//
//  RedpacketMessage.m
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-25.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "YZHRedpacketMessage.h"

@interface YZHRedpacketMessage ()
@property (nonatomic, readwrite, strong) RedpacketMessageModel *redpacket;
@end

@implementation YZHRedpacketMessage

+ (instancetype)messageWithRedpacket:(RedpacketMessageModel *)redpacket
{
    YZHRedpacketMessage *message = [[[self class] alloc] init];
    message.redpacket = redpacket;
    return message;
}

- (NSData *)encode
{
    NSDictionary *modelDic = [self.redpacket redpacketMessageModelToDic];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:modelDic
                                                   options:NSJSONWritingPrettyPrinted
                                                     error:&error];
    if (!data) {
        if (error) {
            NSLog(@"红包 Dictionary 转 JSON 失败 : %@", error);
        }
        else {
            NSLog(@"红包 Dictionary 转 JSON 输出为空");
        }
    }
    
    return data;
}

@end
