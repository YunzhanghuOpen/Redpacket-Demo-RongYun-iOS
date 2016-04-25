//
//  RedpacketMessage.m
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-25.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import "RedpacketMessage.h"

static NSString *const RedpacketDictKey = @"redpacket";
static NSString *const UserDictKey = @"user";

@interface RedpacketMessage ()
@property (nonatomic, readwrite, strong) RedpacketMessageModel *redpacket;
@end

@implementation RedpacketMessage

+ (instancetype)messageWithRedpacket:(RedpacketMessageModel *)redpacket
{
    RedpacketMessage *message = [[[self class] alloc] init];
    message.redpacket = redpacket;
    return message;
}

// 消息只存储，不计入未读消息
+ (RCMessagePersistent)persistentFlag {
    return (MessagePersistent_ISPERSISTED);
}

- (NSData *)encode
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:2];
    NSData *data = nil;
    
    // 先保证是一个正确的红包消息
    if(self.redpacket) {
        NSDictionary *modelDic = [self.redpacket redpacketMessageModelToDic];
        dic[RedpacketDictKey] = modelDic;
        
        if (self.senderUserInfo) {
            NSMutableDictionary *userInfoDic = [[NSMutableDictionary alloc] init];
            if (self.senderUserInfo.name) {
                [userInfoDic setObject:self.senderUserInfo.name forKeyedSubscript:@"name"];
            }
            if (self.senderUserInfo.portraitUri) {
                [userInfoDic setObject:self.senderUserInfo.portraitUri forKeyedSubscript:@"icon"];
            }
            if (self.senderUserInfo.userId) {
                [userInfoDic setObject:self.senderUserInfo.userId forKeyedSubscript:@"id"];
            }
            dic[UserDictKey] = userInfoDic;
        }
        
        if ([NSJSONSerialization isValidJSONObject:dic]) {
            NSError *error = nil;
            data = [NSJSONSerialization dataWithJSONObject:dic
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
        }
        else {
            NSLog(@"红包字典结构有问题，不支持 JSON 转换(%@)", dic);
        }
    }
    
    return data;
}

- (void)decodeWithData:(NSData *)data
{
    NSError *error = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data
                                                        options:0
                                                          error:&error];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        NSDictionary *redpacketDic = dic[RedpacketDictKey];
        if ([RedpacketMessageModel isRedpacketRelatedMessage:redpacketDic]) {
            RedpacketMessageModel *redpacket = [RedpacketMessageModel redpacketMessageModelWithDic:redpacketDic];
            self.redpacket = redpacket;
        }
        else {
            NSLog(@"获取的不是红包相关的数据");
        }
        
        NSDictionary *userDic = dic[UserDictKey];
        [self decodeUserInfo:userDic];
    }
    else {
        NSLog(@"获取的 JSON 不是字典内容");
    }
}

- (NSString *)conversationDigest
{
    return NSLocalizedString(@"您收到一个", @"红包消息");
}

+ (NSString *)getObjectName
{
    return YZHRedpacketMessageTypeIdentifier;
}

@end
