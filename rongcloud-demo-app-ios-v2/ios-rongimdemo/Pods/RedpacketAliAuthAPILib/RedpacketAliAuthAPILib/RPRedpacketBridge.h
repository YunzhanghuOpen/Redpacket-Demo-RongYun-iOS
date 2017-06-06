//
//  RedpacketUserAccount.h
//  ChatDemo-UI3.0
//
//  Created by Mr.Yang on 16/3/1.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

// Token注册的几种方式
@interface RPRedpacketRegisitModel : NSObject

//  签名方式
+ (RPRedpacketRegisitModel *)signModelWithAppUserId:(NSString *)appUserId       //  App的用户ID
                                       signString:(NSString *)sign              //  当前用户的签名 (App Server端获取)
                                          partner:(NSString *)partner           //  App ID （商户注册后可得到）
                                     andTimeStamp:(NSString *)timeStamp;        //  签名的时间戳 (App Server端获取)

//  环信的方式
+ (RPRedpacketRegisitModel *)easeModelWithAppKey:(NSString *)appkey             //  环信的注册商户Key
                                      appToken:(NSString *)appToken             //  环信IM的Token
                                  andAppUserId:(NSString *)appUserId;           //  环信IM的用户ID

//  容联云的方式
+ (RPRedpacketRegisitModel *)rongCloudModelWithAppId:(NSString *)appId          //  容联云的AppId
                                         appUserId:(NSString *)appUserId;       //  容联云的用户ID

@end


//  Token初始化参数回传， 如果初始化失败请传入nil
typedef void (^RPFetchRegisitParamBlock)(RPRedpacketRegisitModel *model);


@class RPUserInfo;
@protocol RPRedpacketBridgeDelegate <NSObject>

@required

// 获取当前登录用户的信息
- (RPUserInfo *)redpacketUserInfo;

//  使用红包服务时，如果红包Token不存在或者过期，则回调此方法，需要在RedpacketRegisitModel生成后，通过fetchBlock回传给红包SDK
//  如果错误error不为空，可能是一下情况
//  1. 如果是环信IM，则刷新环信ImToken
//  2.如果是签名方式， 则刷新签名
- (void)redpacketFetchRegisitParam:(RPFetchRegisitParamBlock)fetchBlock withError:(NSError *)error;

@end


@interface RPRedpacketBridge : NSObject

@property (nonatomic, weak) id <RPRedpacketBridgeDelegate> delegate;

// 是否是调试模式, 默认为NO
// 调试模式可以启动参数检查， 输出请求日志
@property (nonatomic, assign)   BOOL isDebug;


+ (RPRedpacketBridge *)sharedBridge;


@end
