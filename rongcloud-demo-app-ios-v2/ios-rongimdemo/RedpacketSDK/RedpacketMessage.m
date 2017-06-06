//
//  RedpacketMessage.m
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-25.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import "RedpacketMessage.h"
#import <RongIMKit/RongIMKit.h>
#import "RPRedpacketUnionHandle.h"
#import "RPRedpacketConstValues.h"

static NSString *const RedpacketDictKey = @"redpacket";
static NSString *const UserDictKey = @"user";

@interface RedpacketMessage ()
@property (nonatomic, readwrite) RPRedpacketModel *redpacket;
@property (nonatomic, readwrite) AnalysisRedpacketModel *analyModel;
@end

@implementation RedpacketMessage

+ (instancetype)messageWithRedpacket:(RPRedpacketModel *)redpacket
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
        NSDictionary *modelDic;
        if (self.redpacket.receiveMoney.floatValue > 0.001) {
            modelDic = [RPRedpacketUnionHandle dictWithRedpacketModel:self.redpacket isACKMessage:YES];
        } else {
            modelDic = [RPRedpacketUnionHandle dictWithRedpacketModel:self.redpacket isACKMessage:NO];
        }
        
        [dic addEntriesFromDictionary:modelDic];
        
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
        self.analyModel = [AnalysisRedpacketModel analysisRedpacketWithDict:dic andIsSender:YES];
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
        NSDictionary *redpacketDic = dic;
        if ([AnalysisRedpacketModel messageCellTypeWithDict:redpacketDic] != MessageCellTypeUnknown) {
            RPUserInfo *sender = [RPUserInfo new];
            sender.userID = redpacketDic[RedpacketKeyRedpacketSenderId];
            sender.userName = self.senderUserInfo.name;
            sender.avatar = self.senderUserInfo.portraitUri;
            self.redpacket = [RPRedpacketUnionHandle modelWithChannelRedpacketDic:redpacketDic andSender:sender];
            self.analyModel = [AnalysisRedpacketModel analysisRedpacketWithDict:redpacketDic andIsSender:[sender.userID isEqualToString:[RCIM sharedRCIM].currentUserInfo.userId]];
        }
        else {
            NSLog(@"获取的不是红包相关的数据");
        }
    }
    else {
        NSLog(@"获取的 JSON 不是字典内容");
    }
}

- (NSString *)conversationDigest
{
    NSString *tip = @"[云红包]";
    
    if (self.analyModel.type == MessageCellTypeRedpaket) {
        tip = [NSString stringWithFormat:@"[%@]%@", self.analyModel.redpacketOrgName, self.analyModel.greeting];
    }
    else if(MessageCellTypeUnknown != self.analyModel.type) {
        if([[RCIM sharedRCIM].currentUserInfo.userId isEqualToString:self.analyModel.sender.userID]) {
            if ([[RCIM sharedRCIM].currentUserInfo.userId isEqualToString:self.analyModel.receiver.userID]) {
                tip = NSLocalizedString(@"你领取了自己的红包", @"你领取了自己的红包");
            }
            else {
                // 收到了别人抢了我的红包的消息提示
                tip =[NSString stringWithFormat:@"%@%@", // XXX 领取了你的红包
                      // 当前红包 SDK 不返回用户的昵称，需要 app 自己获取
                      self.analyModel.receiver.userID,
                      NSLocalizedString(@"领取了你的红包", @"领取红包消息")];
            }
        }
        else {
            // 显示我抢了别人的红包的提示
            tip =[NSString stringWithFormat:@"%@%@%@", // 你领取了 XXX 的红包
                  NSLocalizedString(@"你领取了", @"领取红包消息"),
                  self.analyModel.sender.userName,
                  NSLocalizedString(@"的红包", @"领取红包消息结尾")
                  ];
        }
    }
    return tip;
}

+ (NSString *)getObjectName
{
    return YZHRedpacketMessageTypeIdentifier;
}

@end
