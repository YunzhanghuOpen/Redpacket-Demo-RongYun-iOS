//
//  RedpacketMessageCell.h
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-25.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>
#import "RedpacketMessage.h"

@interface RedpacketMessageCell : RCMessageCell
@property(strong, nonatomic) UILabel *textLabel;
@property(nonatomic, strong) UIImageView *bubbleBackgroundView;

/*
 根据消息内容获取显示的尺寸
 
 @param message 消息内容
 
 @return 显示的View尺寸
 */
+ (CGSize)getBubbleBackgroundViewSize:(RedpacketMessage *)message;
@end
