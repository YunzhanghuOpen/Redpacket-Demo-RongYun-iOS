//
//  RPAdvertInfo.h
//  Description
//
//  Created by Mr.Yang on 2017/4/21.
//  Copyright © 2017年 Mr.Yang. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, RedpacketAdvertisementActionType) {
    RedpacketAdvertisementReceive = 0 , //领取红包事件
    RedpacketAdvertisementAction      , //点击进入广告页
    RedpacketAdvertisementShare       , //点击分享
};

//  营销红包相关的信息
@interface RPAdvertInfo : NSObject

//  标题
@property (nonatomic, copy) NSString *title;
//  名称
@property (nonatomic, copy) NSString *name;
//  颜色
@property (nonatomic, copy) NSString *colorString;
//  背景图
@property (nonatomic, copy) NSString *landingPage;
//  banner图的URL
@property (nonatomic, copy) NSString *bannerURLString;
//  logoURL
@property (nonatomic, copy) NSString *logoURLString;
//  分享的文案
@property (nonatomic, copy) NSString *shareURLString;
//  分享的信息
@property (nonatomic, copy) NSString *shareMessage;
//  时间戳
@property (nonatomic, copy) NSString *timeString;
//  返回红包动作类型
@property (nonatomic, assign) RedpacketAdvertisementActionType AdvertisementActionType;

+ (RPAdvertInfo *)advertInfoWithRedpacketDic:(NSDictionary *)dict;

@end
