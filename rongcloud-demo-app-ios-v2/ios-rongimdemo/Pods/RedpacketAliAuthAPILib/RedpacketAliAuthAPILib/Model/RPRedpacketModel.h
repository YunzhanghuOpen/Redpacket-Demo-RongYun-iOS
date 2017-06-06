//
//  RedpacketMessageModel.h
//  Description
//
//  Created by Mr.Yang on 2017/4/21.
//  Copyright © 2017年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RPUserInfo.h"
#import "RPAdvertInfo.h"


//  红包类型
typedef NS_ENUM(NSInteger, RPRedpacketType) {
    
    RPRedpacketTypeSingle = 2001,     /***  点对点红包*/
    RPRedpacketTypeAmount,            /***  小额随机红包*/
    
    RPRedpacketTypeGroupRand,         /***  拼手气红包*/
    RPRedpacketTypeGroupAvg,          /***  普通红包*/
    RPRedpacketTypeGoupMember,        /***  专属红包*/
    
    RPRedpacketTypeSystem,            /***  系统红包*/
    
    RPRedpacketTypeAdvertisement      /***  广告红包*/
    
};

//  红包与当前用户的关系
typedef NS_ENUM(NSInteger, RPRedpacketStatusType) {
    
    RPRedpacketStatusTypeOutDate = -1,        /***  红包已过期*/
    RPRedpacketStatusTypeCanGrab = 0,         /***  红包可以抢*/
    RPRedpacketStatusTypeGrabFinish = 1,      /***  红包被抢完*/
    
};

//  拆红包详情页面，拆过红包的用户信息
@interface RPBriefUserInfo : NSObject

//  领取人信息
@property (nonatomic, strong, readonly) RPUserInfo *userInfo;
//  领取日期
@property (nonatomic, copy,   readonly) NSString *takenDate;
//  领取金额
@property (nonatomic, copy,   readonly) NSString *takenMoney;
//  是否是手气最佳
@property (nonatomic, assign, readonly) BOOL isBest;

@end


//  红包相关的信息
@interface RPRedpacketModel : NSObject

//  红包发送信息
@property (nonatomic, copy,   readonly) NSString *redpacketID;
//  红包类型
@property (nonatomic, assign, readonly) RPRedpacketType redpacketType;
//  红包的字符串类型
@property (nonatomic, copy,   readonly) NSString *redpacketTypeStr;
//  红包状态
@property (nonatomic, assign, readonly) RPRedpacketStatusType statusType;
//  群红包，群ID
@property (nonatomic, copy,   readonly) NSString *groupID;
//  金额
@property (nonatomic, copy,   readonly) NSString *money;
//  红包数量
@property (nonatomic, assign, readonly) NSInteger count;
//  祝福语
@property (nonatomic, copy,   readonly) NSString *greeting;
//  当前用户收到的红包金额
@property (nonatomic, assign, readonly) NSString *receiveMoney;
//  当前用户是否是红包发送者
@property (nonatomic, assign, readonly) BOOL isSender;
//  红包接收者
@property (nonatomic, strong, readonly) RPUserInfo *receiver;
//  红包发送者
@property (nonatomic, strong, readonly) RPUserInfo *sender;
//  广告红包信息
@property (nonatomic, strong, readonly) RPAdvertInfo *adverInfo;
//  群红包领取人们
@property (nonatomic, strong, readonly) NSArray <RPBriefUserInfo *> *takenUsers;
//  被领取数量
@property (nonatomic, assign, readonly) NSInteger totalTakenCount;
//  领取金额
@property (nonatomic, copy,   readonly) NSString *totalTakenMoney;
//  领取所用时间
@property (nonatomic, copy,   readonly) NSString *takenCostTime;



// 生成单聊红包或者是小额随机红包的数据模型
+ (RPRedpacketModel *)generateSingleRedpacketInfo:(RPRedpacketType)type
                                         receiver:(RPUserInfo *)receiver
                                   redpacketMoney:(NSString *)money
                                      andGreeting:(NSString *)greeting;

// 生成群随机红包或者群平均红包的数据模型
+ (RPRedpacketModel *)generateGroupRedpacketInfo:(RPRedpacketType)type
                                         groupID:(NSString *)groupID
                                  redpacketMoney:(NSString *)money
                                           count:(NSInteger)count
                                     andGreeting:(NSString *)greeting;

// 生成群定向红包的数据模型
+ (RPRedpacketModel *)generateGroupRedpacketInfo:(RPRedpacketType)type
                                         groupID:(NSString *)groupID
                                        receiver:(RPUserInfo *)receiver
                                  redpacketMoney:(NSString *)money
                                           count:(NSInteger)count
                                     andGreeting:(NSString *)greeting;


// 查询红包详情时，用来生成红包Model
+ (RPRedpacketModel *)modelWithRedpacketID:(NSString *)redpacketID
                             redpacketType:(NSString *)redpacketType
                        andRedpacketSender:(RPUserInfo *)sender;

@end


