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
#import "RedpacketMessage.h"
#import "RedpacketMessageCell.h"
#import "RedpacketTakenMessage.h"
#import "RedpacketTakenOutgoingMessage.h"
#import "RedpacketTakenMessageTipCell.h"
#import "RedpacketConfig.h"
#import "RCDHttpTool.h"
#pragma mark -

// 用于获取
#import "RCDRCIMDataSource.h"

#pragma mark - 红包相关的宏定义
#define REDPACKET_BUNDLE(name) @"RedpacketCellResource.bundle/" name
#define REDPACKET_TAG 2016
#pragma mark -

@interface RedpacketDemoViewController () <RCMessageCellDelegate>

@property (nonatomic, strong, readwrite) RedpacketViewControl *redpacketControl;
@property (atomic, strong)NSMutableArray * usersArray;
@end

@implementation RedpacketDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
#pragma mark - 设置红包功能
    [RedpacketConfig sharedConfig];
    self.usersArray = [NSMutableArray array];
    // 注册消息显示 Cell
    [self registerClass:[RedpacketMessageCell class] forCellWithReuseIdentifier:YZHRedpacketMessageTypeIdentifier];
    [self registerClass:[RedpacketTakenMessageTipCell class] forCellWithReuseIdentifier:YZHRedpacketTakenMessageTypeIdentifier];
    [self registerClass:[RCTextMessageCell class] forCellWithReuseIdentifier:@"Message"];
    
    if (ConversationType_PRIVATE == self.conversationType
        || ConversationType_DISCUSSION == self.conversationType
        || ConversationType_GROUP == self.conversationType ) {
        // 设置红包插件界面
        UIImage *icon = [UIImage imageNamed:REDPACKET_BUNDLE(@"redpacket_redpacket")];
        assert(icon);
        [self.pluginBoardView insertItemWithImage:icon title:NSLocalizedString(@"红包", @"红包") tag:REDPACKET_TAG];
    }
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
- (void)sendRedpacketMessage:(RPRedpacketModel *)redpacket
{
    RedpacketMessage *message = [RedpacketMessage messageWithRedpacket:redpacket];
    NSString *push = [NSString stringWithFormat:@"%@发了一个红包", redpacket.sender.userName];
    [self sendMessage:message pushContent:push];
}

// 红包被抢消息处理
- (void)onRedpacketTakenMessage:(RPRedpacketModel *)redpacket
{
    RedpacketTakenMessage *message = [RedpacketTakenMessage messageWithRedpacket:redpacket];
    // 抢自己的红包不发消息，只自己显示抢红包消息
    if (![[RCIM sharedRCIM].currentUserInfo.userId isEqualToString:redpacket.sender.userID]) {
        if (ConversationType_PRIVATE == self.conversationType) {
            [self sendMessage:message pushContent:nil];
        }
        else {
            RCMessage *m = [[RCIMClient sharedRCIMClient] insertMessage:self.conversationType
                                                               targetId:self.targetId
                                                           senderUserId:self.conversation.senderUserId
                                                             sendStatus:SentStatus_SENT
                                                                content:message];
            [self appendAndDisplayMessage:m];
            
            // 按照 android 的需求修改发送红包的功能
            RedpacketTakenOutgoingMessage *m2 = [RedpacketTakenOutgoingMessage messageWithRedpacket:redpacket];
            [self sendMessage:m2 pushContent:nil];
        }
    }
    else {
        RCMessage *m = [[RCIMClient sharedRCIMClient] insertMessage:self.conversationType
                                                           targetId:self.targetId
                                                       senderUserId:self.conversation.senderUserId
                                                         sendStatus:SentStatus_SENT
                                                            content:message];
        [self appendAndDisplayMessage:m];
    }
}

- (CGSize)rcConversationCollectionView:(UICollectionView *)collectionView
                                layout:(UICollectionViewLayout *)collectionViewLayout
                sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    RCMessageModel *model = [self.conversationDataRepository objectAtIndex:indexPath.row];
    RCMessageContent *messageContent = model.content;
    if ([messageContent isKindOfClass:[RedpacketMessage class]]) {
        RedpacketMessage *redpacketMessage = (RedpacketMessage *)messageContent;
        AnalysisRedpacketModel *redpacket = redpacketMessage.analyModel;
        if(MessageCellTypeRedpaket == redpacket.type) {
            return CGSizeMake(collectionView.frame.size.width, [RedpacketMessageCell getBubbleBackgroundViewSize:(RedpacketMessage *)messageContent].height + 100);
        }
        else if(MessageCellTypeRedpaketTaken == redpacket.type){
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
        RedpacketMessage *redpacketMessage = (RedpacketMessage *)messageContent;
        AnalysisRedpacketModel *redpacket = redpacketMessage.analyModel;
        if(MessageCellTypeRedpaketTaken == redpacket.type){
                // 发红包的人可以显示所有被抢红包的消息
                // 抢红包的人显示自己的消息
            // 过滤掉空消息显示
            if (![messageContent isMemberOfClass:[RedpacketTakenMessage class]]
                && ![[RCIM sharedRCIM].currentUserInfo.userId isEqualToString:redpacket.sender.userID]
                && ![[RCIM sharedRCIM].currentUserInfo.userId isEqualToString:redpacket.receiver.userID]) {
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
        AnalysisRedpacketModel *redpacket = redpacketMessage.analyModel;
        if(MessageCellTypeRedpaket == redpacket.type) {
            RedpacketMessageCell *cell = [collectionView
                                          dequeueReusableCellWithReuseIdentifier:YZHRedpacketMessageTypeIdentifier
                                          forIndexPath:indexPath];
            [cell setDataModel:model];
            [cell setDelegate:self];
            return cell;
        }
        else if(MessageCellTypeRedpaketTaken == redpacket.type) {
            RedpacketTakenMessageTipCell *cell = [collectionView
                                      dequeueReusableCellWithReuseIdentifier:YZHRedpacketTakenMessageTypeIdentifier
                                      forIndexPath:indexPath];
            // 目前红包 SDK 不传递有效的 redpacketReceiver
            cell.tipMessageLabel.text = [redpacketMessage conversationDigest];
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
        if(MessageCellTypeRedpaket == ((RedpacketMessage *)model.content).analyModel.type) {
            NSLog(@"%@",((RedpacketMessage *)model.content).redpacket.sender.userID);
            if ([self.chatSessionInputBarControl.inputTextView isFirstResponder]) {
                [self.chatSessionInputBarControl.inputTextView resignFirstResponder];
            }
            __weak typeof(self) weakSelf = self;
            RPRedpacketModel *rPmodel = ((RedpacketMessage *)model.content).redpacket;
            [RedpacketViewControl redpacketTouchedWithMessageModel:rPmodel
                                                fromViewController:self
                                                redpacketGrabBlock:^(RPRedpacketModel *messageModel) {
                                                    /** 抢到红包后，发送红包被抢的消息*/
                                                    if (messageModel.redpacketType != RPRedpacketTypeAmount) {
                                                        [weakSelf sendRedpacketMessage:messageModel];
                                                    }
                                                    
                                                } advertisementAction:^(id args) {
                                                    
                                                    [weakSelf advertisementAction:args];
                                                }];

        }
    }
    else {
        [super didTapMessageCell:model];
    }
}

- (void)advertisementAction:(id)args
{
#ifdef AliAuthPay
    /** 营销红包事件处理*/
    RPAdvertInfo *adInfo  =args;
    switch (adInfo.AdvertisementActionType) {
        case RedpacketAdvertisementReceive:
            /** 用户点击了领取红包按钮*/
            break;
            
        case RedpacketAdvertisementAction: {
            /** 用户点击了去看看按钮，进入到商户定义的网页 */
            UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:adInfo.shareURLString]];
            [webView loadRequest:request];
            
            UIViewController *webVc = [[UIViewController alloc] init];
            [webVc.view addSubview:webView];
            [(UINavigationController *)self.presentedViewController pushViewController:webVc animated:YES];
            
        }
            break;
            
        case RedpacketAdvertisementShare: {
            /** 点击了分享按钮，开发者可以根据需求自定义，动作。*/
            [[[UIAlertView alloc]initWithTitle:nil
                                       message:@"点击「分享」按钮，红包SDK将该红包素材内配置的分享链接传递给商户APP，由商户APP自行定义分享渠道完成分享动作。"
                                      delegate:nil
                             cancelButtonTitle:@"我知道了"
                             otherButtonTitles:nil] show];
        }
            break;
            
        default:
            break;
    }
#else
    NSDictionary *dict =args;
    NSInteger actionType = [args[@"actionType"] integerValue];
    switch (actionType) {
        case 0:
            // 点击了领取红包
            break;
        case 1: {
            // 点击了去看看按钮，此处为演示
            UIViewController     *VC = [[UIViewController alloc]init];
            UIWebView *webView = [[UIWebView alloc]initWithFrame:self.view.bounds];
            [VC.view addSubview:webView];
            NSString *url = args[@"LandingPage"];
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
            [webView loadRequest:request];
            [(UINavigationController *)self.presentedViewController pushViewController:VC animated:YES];
        }
            break;
        case 2: {
            // 点击了分享按钮，开发者可以根据需求自定义，动作。
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:@"点击「分享」按钮，红包SDK将该红包素材内配置的分享链接传递给商户APP，由商户APP自行定义分享渠道完成分享动作。" delegate:nil cancelButtonTitle:@"我知道了" otherButtonTitles:nil];
            [alert show];
        }
            break;
        default:
            break;
    }
    
#endif
}


#pragma mark - 融云插件点击事件

- (void)pluginBoardView:(RCPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag
{
    __weak typeof(self) weakSelf = self;
    RPRedpacketControllerType  redpacketVCType = 0;
    RPUserInfo *userInfo = [RPUserInfo new];
    userInfo.userID = weakSelf.targetId;
    switch (tag) {
            // 云账户增加红包插件点击回调
        case REDPACKET_TAG: {
            if (ConversationType_PRIVATE == self.conversationType) {
                /** 小额随机红包*/
                redpacketVCType = RPRedpacketControllerTypeRand;
                [RedpacketViewControl presentRedpacketViewController:redpacketVCType
                                                     fromeController:weakSelf
                                                    groupMemberCount:0 withRedpacketReceiver:userInfo
                                                     andSuccessBlock:^(RPRedpacketModel *model) {
                                                         [weakSelf sendRedpacketMessage:model];
                                                     } withFetchGroupMemberListBlock:nil];
            }
            else if(ConversationType_GROUP == self.conversationType) {
                /** 群红包*/
                redpacketVCType = RPRedpacketControllerTypeGroup;
                // 需要在界面显示群员数量，需要先取得相应的数值
                [RedpacketViewControl presentRedpacketViewController:redpacketVCType
                                                     fromeController:weakSelf
                                                    groupMemberCount:self.usersArray.count
                                               withRedpacketReceiver:userInfo andSuccessBlock:^(RPRedpacketModel *model) {
                                                   [weakSelf sendRedpacketMessage:model];
                                               } withFetchGroupMemberListBlock:^(RedpacketMemberListFetchBlock fetchFinishBlock) {
                                                   [RCDHTTPTOOL getGroupByID:self.targetId
                                                           successCompletion:^(RCGroup *group)
                                                    {
                                                        [[RCDHttpTool shareInstance] getGroupMembersByGroupID:group.groupId successCompletion:^(NSArray *members) {
                                                            [weakSelf.usersArray removeAllObjects];
                                                            for (NSDictionary *userDict in members) {
                                                                RPUserInfo *userInfo = [RPUserInfo new];
                                                                userInfo.userID = userDict[@"id"];
                                                                userInfo.userName = userDict[@"username"];
                                                                userInfo.avatar = userDict[@"portrait"];
                                                                [weakSelf.usersArray addObject:userInfo];
                                                            }
                                                            fetchFinishBlock(weakSelf.usersArray);
                                                        }];
                                                    }];
                                               }];

                                                         
            }
           
        }
        default:
            [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
            break;
    }

}

@end
