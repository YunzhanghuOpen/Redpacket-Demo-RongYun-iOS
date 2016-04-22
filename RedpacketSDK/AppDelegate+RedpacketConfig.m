//
//  AppDelegate+RedpacketConfig.m
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-22.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import "AppDelegate+RedpacketConfig.h"
#import "YZHRedpacketBridge.h"
#import <RongIMKit/RongIMKit.h>
#import <objc/runtime.h>
#import "AFNetworking.h"

//	*此为演示地址* App需要修改为自己AppServer上的地址, 数据格式参考此地址给出的格式。
static NSString * const requestUrl = @"http://121.42.52.69:3001/api/sign?duid=";

static void *SignDictKey;
@implementation AppDelegate (RedpacketConfig)

- (NSDictionary *)signDict
{
    NSDictionary *signDict = objc_getAssociatedObject(self, SignDictKey);
    return signDict;
}

- (void)setSignDict:(NSDictionary *)signDict
{
    objc_setAssociatedObject(self, &SignDictKey, signDict, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)configWithSignDict:(NSDictionary *)dict
{
    NSString *partner = [dict valueForKey:@"partner"];
    NSString *appUserId = [dict valueForKey:@"user_id"];
    unsigned long timeStamp = [[dict valueForKey:@"timestamp"] unsignedLongValue];
    NSString *sign = [dict valueForKey:@"sign"];
    
    [[YZHRedpacketBridge sharedBridge] configWithSign:sign
                                              partner:partner
                                            appUserId:appUserId
                                            timeStamp:timeStamp];
}

- (void)configRedpacket
{
    if (!self.signDict) {
        NSString *userId = [RCIM sharedRCIM].currentUserInfo.userId;
        NSString *urlStr = [NSString stringWithFormat:@"%@%@",requestUrl, userId];
        NSURL *url = [NSURL URLWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        [[[AFHTTPRequestOperationManager manager] HTTPRequestOperationWithRequest:request
    success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            self.signDict = responseObject;
            [self configWithSignDict:responseObject];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"request redpacket sign failed:%@", error);
    }] start];
        
    }
    else {
        [self configWithSignDict:self.signDict];
    }
}

@end
