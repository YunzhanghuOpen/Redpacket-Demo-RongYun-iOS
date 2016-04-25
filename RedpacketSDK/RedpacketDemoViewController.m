//
//  RedpacketDemoViewController.m
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-22.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import "RedpacketDemoViewController.h"
#import <RongIMKit/RongIMKit.h>

#pragma mark - 红包相关头文件
#import "RedpacketViewControl.h"
#import "YZHRedpacketBridge.h"
#import "RedpacketMessage.h"
#import "RedpacketMessageCell.h"
#pragma mark -

// 用于获取
#import "RCDRCIMDataSource.h"

#pragma mark - 红包相关的宏定义
#define REDPACKET_BUNDLE(name) @"RedpacketCellResource.bundle/" name
#define REDPACKET_TAG 2016
#pragma mark -

@interface RedpacketDemoViewController () <RCMessageCellDelegate>

@property (nonatomic, strong, readwrite) RedpacketViewControl *redpacketControl;

@end

@implementation RedpacketDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
#pragma mark - 设置红包功能
    
    [self registerClass:[RedpacketMessageCell class] forCellWithReuseIdentifier:YZHRedpacketMessageTypeIdentifier];
    
    // 设置红包插件界面
    UIImage *icon = [UIImage imageNamed:REDPACKET_BUNDLE(@"redpacket_redpacket")];
    assert(icon);
    [self.pluginBoardView insertItemWithImage:icon
                                        title:NSLocalizedString(@"红包", @"红包")
                                      atIndex:0
                                          tag:REDPACKET_TAG];
    // 设置红包功能相关的参数
    self.redpacketControl = [[RedpacketViewControl alloc] init];
    self.redpacketControl.conversationController = self;
    
    // 设置红包用户信息
    RedpacketUserInfo *user = [[RedpacketUserInfo alloc] init];
    user.userId = [RCIM sharedRCIM].currentUserInfo.userId;
    
    // 目前 nickname 和 avatar 两个参数未被 SDK 使用，需要使用 YZHRedpacketBridgeProtocol 的方法
    user.userNickname = [RCIM sharedRCIM].currentUserInfo.name;
    user.userAvatar = [RCIM sharedRCIM].currentUserInfo.portraitUri;
    
    self.redpacketControl.converstationInfo = user;
    
    __weak typeof(self) SELF = self;
    [self.redpacketControl setRedpacketGrabBlock:^(RedpacketMessageModel *redpacket) {
        // 用户发出的红包收到被抢的通知
        [SELF onRedpacketTakenMessage:redpacket];
    } andRedpacketBlock:^(RedpacketMessageModel *redpacket) {
        // 用户发红包的通知
        [SELF sendRedpacketMessage:redpacket];
    }];
    
    [[YZHRedpacketBridge sharedBridge] reRequestRedpacketUserToken];
    
#pragma mark -
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - 融云消息与红包插件消息转换与处理
// 发送融云红包消息
- (void)sendRedpacketMessage:(RedpacketMessageModel *)redpacket
{
    RedpacketMessage *message = [RedpacketMessage messageWithRedpacket:redpacket];
    [self sendMessage:message pushContent:nil];
}

// 红包被抢消息处理
- (void)onRedpacketTakenMessage:(RedpacketMessageModel *)redpacket
{
    
}

- (CGSize)rcConversationCollectionView:(UICollectionView *)collectionView
                                layout:(UICollectionViewLayout *)collectionViewLayout
                sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCMessageModel *model = [self.conversationDataRepository objectAtIndex:indexPath.row];
    RCMessageContent *messageContent = model.content;
    if ([messageContent isMemberOfClass:[RedpacketMessage class]]) {
        return CGSizeMake(collectionView.frame.size.width, [RedpacketMessageCell getBubbleBackgroundViewSize:(RedpacketMessage *)messageContent].height + 40);
    } else {
        return [super rcConversationCollectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
    }
}

- (RCMessageBaseCell *)rcConversationCollectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RCMessageModel *model =
    [self.conversationDataRepository objectAtIndex:indexPath.row];
    
    if (!self.displayUserNameInCell) {
        if (model.messageDirection == MessageDirection_RECEIVE) {
            model.isDisplayNickname = NO;
        }
    }
    RCMessageContent *messageContent = model.content;
    if ([messageContent isMemberOfClass:[RedpacketMessage class]]) {
        RedpacketMessageCell *cell = [collectionView
                                    dequeueReusableCellWithReuseIdentifier:YZHRedpacketMessageTypeIdentifier
                                    forIndexPath:indexPath];
        [cell setDataModel:model];
        [cell setDelegate:self];
        return cell;
    } else {
        return [super rcConversationCollectionView:collectionView cellForItemAtIndexPath:indexPath];
    }
}

#pragma mark - 融云插件点击事件

- (void)pluginBoardView:(RCPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag
{
    switch (tag) {
        // 云账户增加红包插件点击回调
        case REDPACKET_TAG: {
            if (ConversationType_PRIVATE == self.conversationType) {
                [self.redpacketControl presentRedPacketViewController];
            }
            else if(ConversationType_DISCUSSION == self.conversationType) {

                // 需要在界面显示群员数量，需要先取得相应的数值
                [[RCIMClient sharedRCIMClient] getDiscussion:self.targetId
                                                     success:^(RCDiscussion *discussion) {
                                                         // 显示多人红包界面
                                                         [self.redpacketControl presentRedPacketMoreViewControllerWithCount:(int)discussion.memberIdList.count];
                                                     } error:^(RCErrorCode status) {
                                                         
                                                     }];
            }
        }
        default:
            [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
            break;
    }
}
@end
