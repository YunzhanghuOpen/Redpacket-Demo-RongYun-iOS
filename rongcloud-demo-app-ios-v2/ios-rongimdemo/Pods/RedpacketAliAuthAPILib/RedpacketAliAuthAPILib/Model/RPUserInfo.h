//
//  RPUserInfo.h
//  Description
//
//  Created by Mr.Yang on 2017/4/21.
//  Copyright © 2017年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

//  用户信息
@interface RPUserInfo : NSObject

//  用户ID 或者群ID
@property (nonatomic, copy) NSString *userID;
//  如果用户名超长，则此用户名是截断后的用户名
@property (nonatomic, copy) NSString *userName;
//  用户头像
@property (nonatomic, copy) NSString *avatar;

// 生成用户信息Model
+ (RPUserInfo *)userInfoWithUserID:(NSString *)userID
                          UserName:(NSString *)userName
                         andAvatar:(NSString *)avatar;

@end

