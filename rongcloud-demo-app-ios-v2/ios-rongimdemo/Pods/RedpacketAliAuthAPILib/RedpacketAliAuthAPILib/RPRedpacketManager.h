//
//  RPRedpacketManager.h
//  RedpacketRequestDataLib
//
//  Created by Mr.Yang on 2017/4/24.
//  Copyright © 2017年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RPRedpacketModel.h"
#import "RPPersonalRedpacketInfo.h"

/// 注意
/// 使用前，请先参考API文档


/// 返回操作是否成功， 如果error为空则成功，反之失败
typedef void (^RPProcessResultBlock)(NSError *error);

/// 返回结果只有一个字符串
typedef void (^RPProcessResultStringBlock)(NSError *error, NSString *string);

/// 返回生成红包、查询红包详情和抢红包时的红包数据
typedef void(^RPProcessResultObjectBlock)(NSError *error, RPRedpacketModel *model);

/// 返回我的红包收发记录
typedef NS_ENUM(NSInteger, RPPersonalRedpacketType) {
    
    RPPersonalRedpacketTypeSend,        /** 我发送的红包信息*/
    RPPersonalRedpacketTypeReceive      /** 我收到的红包信息*/
    
};

/// 查询收发红包详情后的回调
typedef void(^fetchFinishBlock)(NSError *error, RPPersonalRedpacketInfo *);


@interface RPRedpacketAliauth : NSObject

+ (RPUserInfo *)redpacketCurrentUser;

/// 获取支付宝授权时需要的签名, string为sign
+ (void)requestAliAuthSign:(RPProcessResultStringBlock)block;

/// 上传支付宝授权信息, 成功后触发block error为nil，失败后block返回error
+ (void)uploadAliAuthInfo:(NSString *)authCode
                   userID:(NSString *)userID
          andRequsetBlock:(RPProcessResultBlock)block;

///  查询支付宝绑定信息, 返回绑定的用户名
+ (void)fetchAliAuthBindInfo:(RPProcessResultStringBlock)block;

///  解绑支付宝
+ (void)unBindAliAuth:(RPProcessResultBlock)block;

@end


@interface RPRedpacketSender : NSObject

/// 生成红包ID
+ (void)generateRedpacketID:(RPProcessResultStringBlock)block;

/// 生成支付宝付款时所需要的订单信息， 返回的string为支付宝订单， 通过string去调用支付宝支付
+ (void)generateRedpacketPayOrder:(NSString *)sendMoney
                    generateBlock:(RPProcessResultStringBlock)block;

/// 发送红包
/// model的生成是通过【RPRedpacketModel】类里边生成红包model的方法
+ (void)sendRedpacket:(RPRedpacketModel *)model
         andSendBlock:(RPProcessResultObjectBlock)block;

@end


@interface RPRedpacketReceiver : NSObject

/// 查询红包状态
+ (void)fetchRedpacketStatus:(RPRedpacketModel *)model
               andFetchBlock:(RPProcessResultObjectBlock)block;

/**
 * 拆红包方法
 *
 * 成功状态：
 * 1. 抢到了红包，判断条件：receiveMoney不等于0。
 *
 * 错误状态：
 * 1. 此红包不属于您，错误码，3012
 * 2. 没抢到红包（红包已经领取完），错误码：3013
 * 3. 你已领取此红包，醋五马：3014
 * 4. 支付宝未授权，需要先调用`RPRedpacketAliauth`相关方法，进行支付宝授权，授权已上传成功后，方可继续调用抢红包方法。
 */
+ (void)grabRedpacket:(RPRedpacketModel *)model
         andGrabBlock:(RPProcessResultObjectBlock)block;

/**
 * 查询红包详情
 * 如果存在多页数据，则重复调用，成功后model.takenUsers会追加相应的数据。
 *
 * @param length  最少为10条
 */
+ (void)fetchRedpacketDetail:(RPRedpacketModel *)model
              userListLength:(NSInteger)length
               andFetchBlock:(RPProcessResultObjectBlock)block;

@end


@interface RPRedpacketStatistics : NSObject

/**
 * 收发红包信息查询，如果存在多页数据，则重复调用此接口即可获取其它页数据
 * personalInfo.sendRedpackets发出的红包信息
 * personalInfo.receiveRedpackets收到的红包信息
 * 判断是否是最后一页的依据为sendRedpackets||receiveRedpackets的值跟上次请求是否一致，如果一致则没有更多的数据了
 *
 * @param length 默认为10
 * @param personalInfo  首次传空，以后传入函数返回的personalInfo
 */
+ (void)fetchPersonalRedpacketInfos:(RPPersonalRedpacketType)type
                   fromPersonalInfo:(RPPersonalRedpacketInfo *)personalInfo
                             legnth:(NSInteger)length
                     andFinishBlock:(fetchFinishBlock)block;

@end


/// 红包相关事件统计
@interface RPRedpacketAnalysiser : NSObject

/// 广告红包被打开的事件
+ (void)redpacketAdverOpenEventWithRedpacketID:(NSString *)redpacketID;

/// 广告红包详情被查看的事件
+ (void)redpacketAdverViewDetailEventWithRedapcketID:(NSString *)redpacketID;

/// 根据事件和红包ID进行统计
+ (void)redpacketEvent:(NSString *)event andRedpacketID:(NSString *)redpacketID;

@end

