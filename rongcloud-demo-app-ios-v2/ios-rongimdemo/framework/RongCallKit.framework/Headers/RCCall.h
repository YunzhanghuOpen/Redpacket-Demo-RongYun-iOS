//
//  RCCall.h
//  RongVoIPKit
//
//  Created by 岑裕 on 16/3/11.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RongIMLib/RongIMLib.h>
#import <RongCallLib/RongCallLib.h>

/*!
 群组成员列表提供者
 */
@protocol RCCallGroupMemberDataSource <NSObject>
@optional

/*!
 获取当前群组成员列表的回调
 
 @param groupId     群ID
 @param resultBlock 获取成功 [userIdList:群成员ID列表]
 */
- (void)getAllMembersOfGroup:(NSString *)groupId
                      result:(void (^)(NSArray *userIdList))resultBlock;
@end

/*!
 融云CallKit核心类
 */
@interface RCCall : NSObject

/*!
 当前的通话会话实体
 */
@property (nonatomic, strong, readonly) RCCallSession *currentCallSession;

/*!
 音频通话支持的最大通话人数
 */
@property (nonatomic, assign) int maxMultiAudioCallUserNumber;

/*!
 视频通话支持的最大通话人数
 */
@property (nonatomic, assign) int maxMultiVideoCallUserNumber;

/*!
 群组成员列表提供者
 */
@property (nonatomic, weak) id<RCCallGroupMemberDataSource> groupMemberDataSource;

/*!
 获取融云通话界面组件CallKit的核心类单例
 
 @return 融云通话界面组件CallKit的核心类单例
 
 @discussion 您可以通过此方法，获取CallKit的单例，访问对象中的属性和方法.
 */
+ (instancetype)sharedRCCall;

/*!
 当前会话类型是否支持音频通话
 
 @param conversationType 会话类型
 
 @return 是否支持音频通话
 */
- (BOOL)isAudioCallEnabled:(RCConversationType)conversationType;

/*!
 当前会话类型是否支持视频通话
 
 @param conversationType 会话类型
 
 @return 是否支持视频通话
 */
- (BOOL)isVideoCallEnabled:(RCConversationType)conversationType;

/*!
 发起单人通话
 
 @param targetId  对方的用户ID
 @param mediaType 使用的媒体类型
 */
- (void)startSingleCall:(NSString *)targetId
              mediaType:(RCCallMediaType)mediaType;

/*!
 发起多人通话
 
 @param conversationType 会话类型
 @param targetId         会话目标ID
 @param mediaType        使用的媒体类型
 
 @discussion 此方法会先弹出选择成员界面，选择完成后再会发起通话。目前支持的会话类型有讨论组和群组。
 
 @warning 如果您需要在群组中调用此接口发起多人会话，需要设置并实现groupMemberDataSource。
 */
- (void)startMultiCall:(RCConversationType)conversationType
              targetId:(NSString *)targetId
             mediaType:(RCCallMediaType)mediaType;

/*!
 发起多人通话
 
 @param conversationType 会话类型
 @param targetId         会话目标ID
 @param mediaType        使用的媒体类型
 @param userIdList       邀请的用户ID列表
 
 @discussion 此方法会直接发起通话。目前支持的会话类型有讨论组和群组。
 
 @warning 您需要设置并实现groupMemberDataSource才能加人。
 */
- (void)startMultiCallViewController:(RCConversationType)conversationType
                            targetId:(NSString *)targetId
                           mediaType:(RCCallMediaType)mediaType
                          userIdList:(NSArray *)userIdList;

#pragma mark - Utility
/*!
 弹出通话ViewController或选择成员ViewController
 
 @param viewController 通话ViewController或选择成员ViewController
 */
- (void)presentCallViewController:(UIViewController *)viewController;

/*!
 取消通话ViewController或选择成员ViewController
 
 @param viewController 通话ViewController或选择成员ViewController
 */
- (void)dismissCallViewController:(UIViewController *)viewController;

@end
