//
//  RPRedpacketUser.h
//  RedpacketRequestDataLib
//
//  Created by Mr.Yang on 16/7/28.
//  Copyright © 2016年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>


#define RPREDPACKET_TOKEN  [RPRedpacketUser currentUser].userToken

UIKIT_EXTERN NSString *const RedpacketUserTokenKey;


@class RPUserInfo;
@protocol RPRedpacketUserDataSource <NSObject>
@required

- (RPUserInfo *)redpacketUserInfo;

@end

//  当前红包用户
@interface RPRedpacketUser : NSObject

@property (nonatomic, weak) id <RPRedpacketUserDataSource>dataSource;

//  当前用户信息
@property (nonatomic,strong, readonly) RPUserInfo *currentUserInfo;

//  用户Token
@property (nonatomic, copy, readonly) NSString *userToken;

//  是否过期
@property (nonatomic, assign,readonly) BOOL isTokenExpired;


+ (RPRedpacketUser *)currentUser;

//  Private Method
- (void)clearTokenInfo;
//  Private Method
- (void)redpacketTokenRequestSuccess:(NSDictionary *)tokenDic;

@end
