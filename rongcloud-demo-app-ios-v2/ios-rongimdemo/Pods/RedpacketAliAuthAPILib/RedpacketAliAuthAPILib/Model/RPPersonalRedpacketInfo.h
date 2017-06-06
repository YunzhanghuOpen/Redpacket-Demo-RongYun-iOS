//
//  RPRedpacketBriefInfo.h
//  Description
//
//  Created by Mr.Yang on 2017/4/21.
//  Copyright © 2017年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RPRedpacketModel.h"

@interface RPRedpacketBriefBaseInfo : NSObject

//  抢红包时间
@property (nonatomic, copy)  NSString *date;
//  App名称
@property (nonatomic, copy)  NSString *propuctName;
//  单个红包金额,或者收到的金额
@property (nonatomic, copy)  NSString *money;

@end

//  抢到的红包信息
@interface RPRedpacketBriefReceiveInfo : RPRedpacketBriefBaseInfo

//  红包类型
@property (nonatomic, assign)  RPRedpacketType type;
//  红包接收者或者发送者信息
@property (nonatomic, strong)  RPUserInfo *user;
//  是否是手气最佳
@property (nonatomic, assign)  BOOL isBest;

@end


//  发送的红包信息
@interface RPRedpacketBriefSendInfo : RPRedpacketBriefBaseInfo

//  红包类型
@property (nonatomic,   copy)  NSString *redpacketType;
//  红包总个数
@property (nonatomic, assign)  NSInteger totalCount;
//  已领取个数
@property (nonatomic, assign)  NSInteger receiveCount;

@end


//  个人收发红包记录
@interface RPPersonalRedpacketInfo : NSObject

//  共发收到的金额
@property (nonatomic,   copy)  NSString *totalReceiveMoney;
//  共收到的数量
@property (nonatomic, assign)  NSInteger totalReceiveCount;
//  手气最佳个数
@property (nonatomic, assign)  NSInteger bestReceiveCount;
//  共发出去的金额
@property (nonatomic,   copy)  NSString *totalSendMoney;
//  共发出去的个数
@property (nonatomic, assign)  NSInteger totalSendCount;

//  个人发送的红包
@property (nonatomic, strong)  NSArray <RPRedpacketBriefSendInfo *> *sendRedpackets;
//  个人收到的红包
@property (nonatomic, strong)  NSArray <RPRedpacketBriefReceiveInfo *> *receiveRedpackets;

@end

