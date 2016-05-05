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
#import "RedpacketTakenMessage.h"
#import "RedpacketTakenMessageTipCell.h"
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
    
    // 注册消息显示 Cell
    [self registerClass:[RedpacketMessageCell class] forCellWithReuseIdentifier:YZHRedpacketMessageTypeIdentifier];
    [self registerClass:[RedpacketTakenMessageTipCell class] forCellWithReuseIdentifier:YZHRedpacketTakenMessageTypeIdentifier];
    [self registerClass:[RCTextMessageCell class] forCellWithReuseIdentifier:@"Message"];
    
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
    
    RedpacketUserInfo *user = [[RedpacketUserInfo alloc] init];
    user.userId = self.targetId;
    // 虽然现在 userName 不被 viewController 保存，但是如果不设置 userNickname，会
    // 导致新消息显示的时候显示 (null) 数据
    user.userNickname = self.userName;
    
    if (ConversationType_PRIVATE == self.conversationType) {
        // 异步获取更多用户消息, 这是 Demo app 的 DataSource 逻辑
        [[RCDRCIMDataSource shareInstance] getUserInfoWithUserId:self.targetId
                                                      completion:^(RCUserInfo *userInfo) {
                                                          // 设置红包接收用户信息
                                                          
                                                          user.userNickname = userInfo.name;
                                                          user.userAvatar = userInfo.portraitUri;
                                                          
                                                          // 更新用户信息
                                                          self.redpacketControl.converstationInfo = user;
                                                      }];
    }
    else if (ConversationType_DISCUSSION == self.conversationType) {
        // 设置群发红包
        user.isGroup = YES;
    }
    
    self.redpacketControl.converstationInfo = user;
    
    __weak typeof(self) SELF = self;
    // 设置红包 SDK 功能回调
    [self.redpacketControl setRedpacketGrabBlock:^(RedpacketMessageModel *redpacket) {
        // 用户发出的红包收到被抢的通知
        [SELF onRedpacketTakenMessage:redpacket];
    } andRedpacketBlock:^(RedpacketMessageModel *redpacket) {
        // 用户发红包的通知
        [SELF sendRedpacketMessage:redpacket];
    }];
    
    // 通知 红包 SDK 刷新 Token
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
    RedpacketTakenMessage *message = [RedpacketTakenMessage messageWithRedpacket:redpacket];
    [self sendMessage:message pushContent:nil];
}

- (CGSize)rcConversationCollectionView:(UICollectionView *)collectionView
                                layout:(UICollectionViewLayout *)collectionViewLayout
                sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCMessageModel *model = [self.conversationDataRepository objectAtIndex:indexPath.row];
    RCMessageContent *messageContent = model.content;
    if ([messageContent isKindOfClass:[RedpacketMessage class]]) {
        RedpacketMessageModel *redpacket = ((RedpacketMessage *)messageContent).redpacket;
        if(RedpacketMessageTypeRedpacket == redpacket.messageType) {
            return CGSizeMake(collectionView.frame.size.width, [RedpacketMessageCell getBubbleBackgroundViewSize:(RedpacketMessage *)messageContent].height + REDPACKET_MESSAGE_TOP_BOTTOM_PADDING);
        }
        else if(RedpacketMessageTypeTedpacketTakenMessage == redpacket.messageType){
            return CGSizeMake(collectionView.frame.size.width,
                              [RedpacketTakenMessageTipCell sizeForModel:model].height + REDPACKET_TAKEN_MESSAGE_TOP_BOTTOM_PADDING);
        }
        
    }
    
    return [super rcConversationCollectionView:collectionView layout:collectionViewLayout sizeForItemAtIndexPath:indexPath];
}

- (RCMessage *)willAppendAndDisplayMessage:(RCMessage *)message
{
    RCMessageContent *messageContent = message.content;
    if ([messageContent isKindOfClass:[RedpacketMessage class]]) {
        RedpacketMessageModel *redpacket = ((RedpacketMessage *)messageContent).redpacket;
        if(RedpacketMessageTypeTedpacketTakenMessage == redpacket.messageType){
                // 发红包的人可以显示所有被抢红包的消息
                // 抢红包的人显示自己的消息
            if (![redpacket.currentUser.userId isEqualToString:redpacket.redpacketSender.userId]
                && ![redpacket.currentUser.userId isEqualToString:redpacket.redpacketReceiver.userId]) {
                return nil;
            }
        }
    }
    return message;
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
    if ([messageContent isKindOfClass:[RedpacketMessage class]]) {
        RedpacketMessage *redpacketMessage = (RedpacketMessage *)messageContent;
        RedpacketMessageModel *redpacket = redpacketMessage.redpacket;
        if(RedpacketMessageTypeRedpacket == redpacket.messageType) {
            RedpacketMessageCell *cell = [collectionView
                                          dequeueReusableCellWithReuseIdentifier:YZHRedpacketMessageTypeIdentifier
                                          forIndexPath:indexPath];
            [cell setDataModel:model];
            [cell setDelegate:self];
            return cell;
        }
        else if(RedpacketMessageTypeTedpacketTakenMessage == redpacket.messageType){
            RedpacketTakenMessageTipCell *cell = [collectionView
                                      dequeueReusableCellWithReuseIdentifier:YZHRedpacketTakenMessageTypeIdentifier
                                      forIndexPath:indexPath];
            NSString *tip = nil;
            if([redpacket.currentUser.userId isEqualToString:redpacket.redpacketReceiver.userId]) {
                // 显示我抢了别人的红包的提示
                tip =[NSString stringWithFormat:@"%@%@%@", // 你领取了 XXX 的红包
                      NSLocalizedString(@"你领取了", @"领取红包消息"),
                      redpacket.redpacketSender.userNickname,
                      NSLocalizedString(@"的红包", @"领取红包消息结尾")
                      ];
            }
            else { // 收到了别人抢了我的红包的消息提示
                if (ConversationType_PRIVATE == self.conversationType) {
                    tip =[NSString stringWithFormat:@"%@%@", // XXX 领取了你的红包
                          // 当前红包 SDK 不返回用户的昵称，需要 app 自己获取
//                          redpacket.redpacketReceiver.userNickname,
                          self.userName,
                          NSLocalizedString(@"领取了你的红包", @"领取红包消息")];
                }
                else {
                    tip =[NSString stringWithFormat:@"%@%@", // XXX 领取了你的红包
                          // 当前红包 SDK 不返回用户的昵称，需要 app 自己获取
                          redpacketMessage.senderUsername,
                          NSLocalizedString(@"领取了你的红包", @"领取红包消息")];
                    
                    [[RCDRCIMDataSource shareInstance] getUserInfoWithUserId:redpacket.redpacketReceiver.userId
                                                                     inGroup:self.targetId
                                                                  completion:^(RCUserInfo *userInfo) {
                                                                      if (userInfo) {
                                                                          NSString *tip = nil;
                                                                          tip = [NSString stringWithFormat:@"%@%@", // XXX 领取了你的红包
                                                                                // 当前红包 SDK 不返回用户的昵称，需要 app 自己获取
                                                                                 userInfo.name,
                                                                                NSLocalizedString(@"领取了你的红包", @"领取红包消息")];
                                                                          
                                                                          RedpacketTakenMessageTipCell *cell = (RedpacketTakenMessageTipCell *)[collectionView cellForItemAtIndexPath:indexPath];
                                                                          if (cell) {
                                                                              cell.tipMessageLabel.text = tip;
                                                                              [cell setDataModel:model];
                                                                              [cell setNeedsLayout];
                                                                          }
                                                                      }
                                                                  }];
                }
            }
            cell.tipMessageLabel.text = tip;
            [cell setDataModel:model];
            [cell setNeedsLayout];
            return cell;
        }
        else {
            return [super rcConversationCollectionView:collectionView cellForItemAtIndexPath:indexPath];
        }
    } else {
        return [super rcConversationCollectionView:collectionView cellForItemAtIndexPath:indexPath];
    }
}

- (void)willDisplayMessageCell:(RCMessageBaseCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[RedpacketMessageCell class]]) {
        RedpacketMessageCell *c = (RedpacketMessageCell *)cell;
        c.statusContentView.hidden = YES;
    }
    [super willDisplayMessageCell:cell atIndexPath:indexPath];
}

#pragma mark - 红包插件点击事件
- (void)didTapMessageCell:(RCMessageModel *)model
{
    if ([model.content isKindOfClass:[RedpacketMessage class]]) {
        if(RedpacketMessageTypeRedpacket == ((RedpacketMessage *)model.content).redpacket.messageType) {
            if ([self.chatSessionInputBarControl.inputTextView isFirstResponder]) {
                [self.chatSessionInputBarControl.inputTextView resignFirstResponder];
            }
            [self.redpacketControl redpacketCellTouchedWithMessageModel:((RedpacketMessage *)model.content).redpacket];
        }
    }
    else {
        [super didTapMessageCell:model];
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
