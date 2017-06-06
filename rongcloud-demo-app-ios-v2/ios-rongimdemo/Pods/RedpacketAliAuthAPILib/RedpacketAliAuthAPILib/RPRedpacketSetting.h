//
//  RPRedpacketGlobalSetting.h
//  RedpacketRequestDataLib
//
//  Created by Mr.Yang on 16/7/26.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


typedef void(^RedpacketSuccessBlock)(NSError *error);

@interface RPRedpacketSetting : NSObject


+ (RPRedpacketSetting *)shareInstance;

/**
 *  刷新配置数据，如果距离上次请求不足5分钟，则立即回调。
 *
 *  @param success 成功之后的回调
 */
+ (void)asyncRequestRedpacketSettings:(RedpacketSuccessBlock)success;

/**
 *  立即刷新配置数据
 *
 *  @param success 成功后的回调
 */
+ (void)asyncRequestRedpacketsettingsIfNeed:(RedpacketSuccessBlock)success;


/**
 *  红包SDK客户名称
 */
@property (nonatomic, copy)     NSString *redpacketOrgName;

/**
 *  单个红包最大金额
 */
@property (nonatomic, assign)   CGFloat singlePayLimit;

/**
 *  单个红包最小金额
 */
@property (nonatomic, assign)   CGFloat redpacketMinMoney;

/**
 *  支付宝单笔最大上限
 */
@property (nonatomic, assign)   CGFloat alipayMaxMoney;

/**
 *  支付宝单日最大上限
 */
@property (nonatomic, assign)   CGFloat alipayDayMoney;

/**
 *  红包最大个数
 */
@property (nonatomic, assign)   NSInteger maxRedpacketCount;

/**
 *  红包背景图
 */
@property (nonatomic, copy)     NSString *redpacketBackImageURL;

/**
 *  红包祝福语
 */
@property (nonatomic, strong)   NSArray *redpacketGreetings;

/**
 *  小额度随机红包金额祝福语
 */
@property (nonatomic, copy)     NSArray *constGreetings;

/**
 *  红包保险服务协议用语
 */
@property (nonatomic, copy)     NSString *insuranceDes;

/**
 *  是否显示开发票功能
 */
@property (nonatomic, assign)   BOOL isShowInvoiceFunction;


@end
