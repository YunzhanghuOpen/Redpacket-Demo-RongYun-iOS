//
//  RedpacketConfig.m
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-25.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import "RedpacketConfig.h"
#import <RongIMKit/RongIMKit.h>
#import <objc/runtime.h>
#import "AFNetworking.h"

#import "RPRedpacketBridge.h"
#import "AnalysisRedpacketModel.h"


//	*此为演示地址* App需要修改为自己AppServer上的地址, 数据格式参考此地址给出的格式。
static NSString *requestUrl = @"https://rpv2.yunzhanghu.com/api/sign?duid=";
static RedpacketConfig *__sharedConfig__ = nil;

@interface RedpacketConfig ()

@end

@implementation RedpacketConfig

+ (instancetype)sharedConfig
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        __sharedConfig__ = [[RedpacketConfig alloc] init];
        [RPRedpacketBridge sharedBridge].delegate = __sharedConfig__;
        [RPRedpacketBridge sharedBridge].isDebug = YES;//开发者调试的的时候，设置为YES，看得见日志。
        
    });
    
    
    return __sharedConfig__;
}

/* MARK:红包Token注册回调**/
- (void)redpacketFetchRegisitParam:(RPFetchRegisitParamBlock)fetchBlock withError:(NSError *)error
{
    if (self.redpacketUserInfo.userID.length) {
        // 获取应用自己的签名字段。实际应用中需要开发者自行提供相应在的签名计算服务
        
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",requestUrl, self.redpacketUserInfo.userID];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        [[[AFHTTPRequestOperationManager manager] HTTPRequestOperationWithRequest:request
                                                                          success:^(AFHTTPRequestOperation *operation, id responseObject) {
                                                                              if ([responseObject isKindOfClass:[NSDictionary class]]) {
                                                                                  NSDictionary *dict = (NSDictionary *)responseObject;
                                                                                  NSString *partner = [dict valueForKey:@"partner"];
                                                                                  NSString *appUserId = [dict valueForKey:@"user_id"];
                                                                                  NSString *timeStamp = [NSString stringWithFormat:@"%@",[dict valueForKey:@"timestamp"]] ;
                                                                                  NSString *sign = [dict valueForKey:@"sign"];
                                                                                  RPRedpacketRegisitModel *model = [RPRedpacketRegisitModel signModelWithAppUserId:appUserId
                                                                                                                                                    signString:sign
                                                                                                                                                       partner:partner
                                                                                                                                                  andTimeStamp:timeStamp];
                                                                                  fetchBlock(model);

                                                                              }
                                                                          } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                                              NSLog(@"request redpacket sign failed:%@", error);
                                                                              fetchBlock(nil);
                                                                          }] start];
    }else {
        fetchBlock(nil);
    }
}

- (RPUserInfo *)redpacketUserInfo
{
    RPUserInfo *user = [[RPUserInfo alloc] init];
    RCUserInfo *info = [[RCIM sharedRCIM] getUserInfoCache:[RCIM sharedRCIM].currentUserInfo.userId];
    user.userID = info.userId;
    user.userName = info.name;
    user.avatar = info.portraitUri;
    return user;
}

@end
