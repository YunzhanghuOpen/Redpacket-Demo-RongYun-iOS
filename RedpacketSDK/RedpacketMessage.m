//
//  RedpacketMessage.m
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-25.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import "RedpacketMessage.h"
#import <RongIMKit/RongIMKit.h>

// 按照 Android 的消息格式修改了消息结构
static NSString *const SenderUserNameKey = @"sendUserName";
static NSString *const SenderUserIdKey = @"sendUserID";
static NSString *const ReceiverUserNameKey = @"receiveUserName";
static NSString *const ReceiverUserIdKey = @"receiveUserID";
static NSString *const RedpacketMessageKey = @"message";
static NSString *const RedpacketIdKey = @"moneyID";

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
        // 原来使用的是 RedpacketMessagModel 的方法生成的 Dictionary ，但是后来 Android 那边需求
        // 按照 Android 的消息机制做了修改。
        dic[SenderUserIdKey] = self.redpacket.redpacketSender.userId;
        dic[SenderUserNameKey] = self.redpacket.redpacketSender.userNickname;
        
        if (RedpacketMessageTypeRedpacket == self.redpacket.messageType) {
            dic[RedpacketMessageKey] = self.redpacket.redpacket.redpacketGreeting;
            dic[RedpacketIdKey] = self.redpacket.redpacketId;
        }
        else // RedpacketMessageTypeTedpacketTakenMessage (原来的类型就是这个名字)
        {
            dic[ReceiverUserIdKey] = self.redpacket.redpacketReceiver.userId;
            dic[ReceiverUserNameKey] = self.redpacket.redpacketReceiver.userNickname;
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
        // 原来使用的是 RedpacketMessagModel 的方法生成的 Dictionary ，但是后来 Android 那边需求
        // 按照 Android 的消息机制做了修改。但是这里依然生成 RedpacketMessageModel，以保证原来的功
        // 能代码尽量保持不变
        RedpacketMessageModel *redpacket = [[RedpacketMessageModel alloc] init];
        
        NSString *senderUserId = dic[SenderUserIdKey];
        NSString *senderUserName = dic[SenderUserNameKey];
        RedpacketUserInfo *sender = [[RedpacketUserInfo alloc] init];
        sender.userNickname = senderUserName;
        sender.userId = senderUserId;
        redpacket.redpacketSender = sender;
        
        NSString *message = dic[RedpacketMessageKey];
        NSString *redpacketId = dic[RedpacketIdKey];
        
        if (redpacketId) { // 是红包消息
            redpacket.redpacketId = redpacketId;
            redpacket.redpacket.redpacketGreeting = message;
            redpacket.messageType = RedpacketMessageTypeRedpacket;
        }
        else
        {
            NSString *userId = dic[ReceiverUserIdKey];
            NSString *userName = dic[ReceiverUserNameKey];
            
            RedpacketUserInfo *receiver = [[RedpacketUserInfo alloc] init];
            receiver.userNickname = userName;
            receiver.userId = userId;
            redpacket.redpacketReceiver = receiver;
            redpacket.messageType = RedpacketMessageTypeTedpacketTakenMessage;
        }
        
        self.redpacket = redpacket;
        self.redpacketUserInfo = [[RCUserInfo alloc] initWithUserId:senderUserId
                                                               name:senderUserName
                                                           portrait:nil];
    }
    else {
        NSLog(@"获取的不是红包相关的数据");
    }
    
}

- (NSString *)conversationDigest
{
    NSString *tip = @"[云红包]";
    
    if (RedpacketMessageTypeRedpacket == self.redpacket.messageType) {
        tip = [NSString stringWithFormat:@"[云红包]%@", self.redpacket.redpacket.redpacketGreeting];
    }
    else if(RedpacketMessageTypeTedpacketTakenMessage == self.redpacket.messageType) {
        RedpacketMessageModel *redpacket = self.redpacket;
        if([redpacket.currentUser.userId isEqualToString:redpacket.redpacketSender.userId]) {
            if ([redpacket.currentUser.userId isEqualToString:redpacket.redpacketReceiver.userId]) {
                tip = NSLocalizedString(@"你领取了自己的红包", @"你领取了自己的红包");
            }
            else {
                // 收到了别人抢了我的红包的消息提示
                tip =[NSString stringWithFormat:@"%@%@", // XXX 领取了你的红包
                      // 当前红包 SDK 不返回用户的昵称，需要 app 自己获取
                      redpacket.redpacketReceiver.userNickname,
                      NSLocalizedString(@"领取了你的红包", @"领取红包消息")];
            }
        }
        else {
            // 显示我抢了别人的红包的提示
            tip =[NSString stringWithFormat:@"%@%@%@", // 你领取了 XXX 的红包
                  NSLocalizedString(@"你领取了", @"领取红包消息"),
                  redpacket.redpacketSender.userNickname,
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
