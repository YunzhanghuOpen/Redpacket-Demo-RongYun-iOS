//
//  RedpacketMessage.m
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-25.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import "RedpacketMessage.h"
#import <RongIMKit/RongIMKit.h>

static NSString *const RedpacketDictKey = @"redpacket";
static NSString *const UserDictKey = @"user";

@interface RedpacketMessage ()
@property (nonatomic, readwrite, copy) RedpacketMessageModel *redpacket;
@end

@implementation RedpacketMessage

+ (instancetype)messageWithRedpacket:(RedpacketMessageModel *)redpacket
{
    RedpacketMessage *message = [[[self class] alloc] init];
    message.redpacket = redpacket;
    message.redpacketUserInfo = [RCIMClient sharedRCIMClient].currentUserInfo;
    return message;
}

// 消息只存储，不计入未读消息
+ (RCMessagePersistent)persistentFlag {
    return (MessagePersistent_ISPERSISTED | MessagePersistent_ISCOUNTED);
}

- (NSData *)encode
{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:2];
    NSData *data = nil;
    
    // 先保证是一个正确的红包消息
    if(self.redpacket) {
        NSDictionary *modelDic = [self.redpacket redpacketMessageModelToDic];
        dic[RedpacketDictKey] = modelDic;
        
        if (self.redpacketUserInfo) {
            NSMutableDictionary *userInfoDic = [[NSMutableDictionary alloc] init];
            if (self.redpacketUserInfo.name) {
                [userInfoDic setObject:self.redpacketUserInfo.name forKeyedSubscript:@"name"];
            }
            if (self.redpacketUserInfo.portraitUri) {
                [userInfoDic setObject:self.redpacketUserInfo.portraitUri forKeyedSubscript:@"icon"];
            }
            if (self.redpacketUserInfo.userId) {
                [userInfoDic setObject:self.redpacketUserInfo.userId forKeyedSubscript:@"id"];
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
        
        NSDictionary *userInfoDic = dic[UserDictKey];
        if (userInfoDic) {
            self.redpacketUserInfo = [[RCUserInfo alloc] initWithUserId:userInfoDic[@"id"]
                                                                   name:userInfoDic[@"name"]
                                                               portrait:userInfoDic[@"icon"]];
        }
        
    }
    else {
        NSLog(@"获取的 JSON 不是字典内容");
    }
}

- (NSString *)conversationDigest
{
    NSString *s = @"[云红包]";
    
    if (RedpacketMessageTypeRedpacket == self.redpacket.messageType) {
        s = [NSString stringWithFormat:@"[云红包]%@", self.redpacket.redpacket.redpacketGreeting];
    }
    else if(RedpacketMessageTypeTedpacketTakenMessage == self.redpacket.messageType) {
        if([self.redpacket.currentUser.userId isEqualToString:self.redpacketUserInfo.userId]) {
            // 显示我抢了别人的红包的提示
            s =[NSString stringWithFormat:@"%@%@%@", // 你领取了 XXX 的红包
                NSLocalizedString(@"你领取了", @"领取红包消息"),
                self.redpacketUserInfo.name,
                NSLocalizedString(@"的红包", @"领取红包消息结尾")
                ];
        }
        else { // 收到了别人抢了我的红包的消息提示
            s = [NSString stringWithFormat:@"%@%@", // XXX 领取了你的红包
                 self.redpacketUserInfo.name,
                 NSLocalizedString(@"领取了你的红包", @"领取红包消息")];
        }
    }
    return s;
}

+ (NSString *)getObjectName
{
    return YZHRedpacketMessageTypeIdentifier;
}

@end
