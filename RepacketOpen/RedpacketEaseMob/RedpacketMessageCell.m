//
//  RedpacketMessageCell.m
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-25.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import "RedpacketMessageCell.h"
#import "RedpacketMessage.h"
#import "RedpacketView.h"
#import "RedPacketLuckView.h"
#import "RPRedpacketUnionHandle.h"

#define Redpacket_Message_Font_Size 14
#define Redpacket_SubMessage_Font_Size 12
#define Redpacket_Background_Extra_Height 25
#define Redpacket_SubMessage_Text NSLocalizedString(@"查看红包", @"查看红包")
#define Redpacket_Label_Padding 2

@interface RedpacketMessageCell ()
@property (nonatomic, strong) RedpacketView *redpacketView;
@property (nonatomic, strong) RedPacketLuckView *repacketLuckView;
@end

@implementation RedpacketMessageCell


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    // 设置背景
    self.bubbleBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.messageContentView addSubview:self.bubbleBackgroundView];
    
    self.bubbleBackgroundView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap =
    [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
    [self.bubbleBackgroundView addGestureRecognizer:tap];

    [self.statusContentView removeFromSuperview];
    self.statusContentView = nil;
    
    [self.messageHasReadStatusView removeFromSuperview];
    self.messageHasReadStatusView = nil;

    [self.messageSendSuccessStatusView removeFromSuperview];
    self.messageSendSuccessStatusView = nil;
}

- (void)setDataModel:(RCMessageModel *)model {
    [super setDataModel:model];
    RedpacketMessage *redpacketMessage = (RedpacketMessage *)self.model.content;
    AnalysisRedpacketModel *messageModel = redpacketMessage.analyModel;
    if (messageModel.redpacketType == RPRedpacketTypeAmount) {
        [_redpacketView removeFromSuperview];
        _redpacketView = nil;
        [self.bubbleBackgroundView addSubview:self.repacketLuckView];
        [_repacketLuckView configWithRedpacketMessageModel:messageModel];
    } else {
        [_repacketLuckView removeFromSuperview];
        _repacketLuckView = nil;
        [self.bubbleBackgroundView addSubview:self.redpacketView];
        [_redpacketView configWithRedpacketMessageModel:messageModel];
    }
    [self setAutoLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.statusContentView.hidden = YES;
    self.messageHasReadStatusView.hidden = YES;
    self.messageSendSuccessStatusView.hidden = YES;
}

- (void)setAutoLayout {
    RedpacketMessage *redpacketMessage = (RedpacketMessage *)self.model.content;
    NSString *messageString = redpacketMessage.redpacket.greeting;
    self.greetingLabel.text = messageString;
    
    NSString *orgString = redpacketMessage.analyModel.redpacketOrgName;
    self.orgLabel.text = orgString;
    
    CGSize bubbleBackgroundViewSize = [[self class] getBubbleSize];
    CGRect messageContentViewRect = self.messageContentView.frame;
    
    // 设置红包文字
    if (MessageDirection_RECEIVE == self.messageDirection) {
        messageContentViewRect.size.width = bubbleBackgroundViewSize.width;
        self.messageContentView.frame = messageContentViewRect;
        self.bubbleBackgroundView.frame = CGRectMake(-8, 0, bubbleBackgroundViewSize.width, bubbleBackgroundViewSize.height);
    } else {
        messageContentViewRect.size.width = bubbleBackgroundViewSize.width;
        messageContentViewRect.origin.x = self.baseContentView.bounds.size.width - (messageContentViewRect.size.width + 12 + [RCIM sharedRCIM].globalMessagePortraitSize.width + 10);
        self.messageContentView.frame = messageContentViewRect;
        self.bubbleBackgroundView.frame = CGRectMake(-8, 0, bubbleBackgroundViewSize.width, bubbleBackgroundViewSize.height);
    }
    
    self.statusContentView.hidden = YES;
    self.messageHasReadStatusView.hidden = YES;
    self.messageSendSuccessStatusView.hidden = YES;
}

- (void)tap:(UITapGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.delegate didTapMessageCell:self.model];
    }
}

+ (CGSize)getBubbleSize {
    CGSize bubbleSize = CGSizeMake(198, 94);
    return bubbleSize;
}

+ (CGSize)getBubbleBackgroundViewSize:(RedpacketMessage *)message {
    AnalysisRedpacketModel *messageModel = message.analyModel;
    if (messageModel.redpacketType == MessageCellTypeRedpaket) {
        return CGSizeMake(116.0f,  [RedPacketLuckView heightForRedpacketMessageCell] + 20);
    }else {
        return CGSizeMake(218.0f,  [RedpacketView redpacketViewHeight] + 20);
    }
}

- (RedpacketView *)redpacketView
{
    if (!_redpacketView) {
        _redpacketView = [[RedpacketView alloc]init];
    }
    return _redpacketView;
}
- (RedPacketLuckView *)repacketLuckView
{
    if (!_repacketLuckView) {
        _repacketLuckView = [[RedPacketLuckView alloc]init];
    }
    return _repacketLuckView;
}

@end
