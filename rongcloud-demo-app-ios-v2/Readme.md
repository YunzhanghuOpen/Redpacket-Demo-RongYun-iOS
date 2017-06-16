# 融云 iOS红包SDK集成
## 集成概述
* 红包SDK分为两个版本，即**钱包版红包SDK**与**支付宝版红包SDK**。
* 使用钱包版红包SDK的用户，可以使用银行卡支付或支付宝支付等第三方支付来发红包；收到的红包金额会进入到钱包余额，并支持提现到绑定的银行卡。
* 使用支付宝版红包SDK的用户，发红包仅支持支付宝支付；收到的红包金额即时入账至绑定的支付宝账号。
* 请选择希望接入的版本并下载对应的SDK进行集成，钱包版红包SDK与支付宝版红包SDK集成方式相同。
* 需要注意的是如果已经集成了钱包版红包SDK，暂不支持切换到支付宝版红包SDK（两个版本不支持互通）。
* [集成演示Demo](https://github.com/YunzhanghuOpen/Redpacket-Demo-RongYun-iOS)，开发者可以通过此Demo了解iOS红包SDK的集成，集成方式仅供参考。

## 集成红包

### 红包开源模块介绍

* `RedpacketAliPay` 
* 为**支付宝版SDK**处理支付宝授权和支付宝支付回调

* `RedpacketJDPay` 
* 为**钱包版SDK**处理支付宝支付回调

* `RedpacketMessageCell` 
* 红包SDK内的红包卡片样式

*  `RedpacketCellResource.bundle` 
*  红包开源部分的资源文件

* `RedpacketDemoViewController` 
* 包含发红包收红包功能
* 单聊红包包含**小额随机红包**和**普通红包**
* 群红包包含**定向红包**，**普通红包**和**拼手气红包**

* `RedpacketConfig` 红包SDK初始化文件       
*  实现红包SDK注册
*  实现当前用户获取

### SDK初始化配置
文件名称：AppDelegate+Redpacket.h
说明：配置SDK相关数据源， 设置支付宝回调。

在AppDelegate中完成初始化
导入头文件
`#import "RedpacketConfig.h"`
`#import "RedpacketMessage.h"`
`#import "RedpacketTakenMessage.h"`
`#import "RedpacketTakenOutgoingMessage.h"`


```

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

...

//红包集成
[[RCIM sharedRCIM] registerMessageType:[RCDTestMessage class]];
[[RCIM sharedRCIM] registerMessageType:[RedpacketMessage class]];
[[RCIM sharedRCIM] registerMessageType:[RedpacketTakenMessage class]];
[[RCIM sharedRCIM] registerMessageType:[RedpacketTakenOutgoingMessage class]];
...

}

```

### 收发红包
文件名称：RedpacketDemoViewController.m

#### 添加红包按钮和红包按钮回调事件


```
- (void)viewDidLoad {
    [super viewDidLoad];
    if (ConversationType_PRIVATE == self.conversationType
    || ConversationType_DISCUSSION == self.conversationType
    || ConversationType_GROUP == self.conversationType ) {
    // 设置红包插件界面
    UIImage *icon = [UIImage imageNamed:REDPACKET_BUNDLE(@"redpacket_redpacket")];
    assert(icon);
    [self.pluginBoardView insertItemWithImage:icon title:NSLocalizedString(@"红包", @"红包") tag:REDPACKET_TAG];
                                                        }
...
...
}


- (void)pluginBoardView:(RCPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag {
...
...
}

```

#### 发送红包消息

* 红包消息

```
- (void)sendRedpacketMessage:(RedpacketMessageModel *)redpacket
{
    RedpacketMessage *message = [RedpacketMessage messageWithRedpacket:redpacket];
    NSString *push = [NSString stringWithFormat:@"%@发了一个红包", redpacket.currentUser.userNickname];
    [self sendMessage:message pushContent:push];
}```

* 接收处理被抢的消息

```
- (void)onRedpacketTakenMessage:(RedpacketMessageModel *)redpacket
{
    RedpacketTakenMessage *message = [RedpacketTakenMessage messageWithRedpacket:redpacket];
    // 抢自己的红包不发消息，只自己显示抢红包消息
    if (![redpacket.currentUser.userId isEqualToString:redpacket.redpacketSender.userId]) {
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

```

#### 展示红包卡片样式

红包样式`RedpacketMessageCell`
红包被领取的样式`RedpacketTakenMessageTipCell`

```
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
...
...
...	
}
```

#### 收拆红包

```
- (void)didTapMessageCell:(RCMessageModel *)model {
...
...
...
}
```

### 显示零钱功能

文件位置：`#import "RedpacketChangeMoneySegue.h"`

说明： 显示红包零钱页面

```
+ (void)presentChangePocketViewControllerFromeController:(UIViewController *)viewController;

```


