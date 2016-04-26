融云红包 SDK 接入文档
=================

使用融云 demo app
------------------

  `红包 SDK` 的 demo 直接嵌入进 融云 demo 2.0 中，对于原 demo 仅做了少量的修改。如果你的 app 采用 融云的 demo app 作为原型的话，这里的方法是简单快捷的。

  在融云 demo app 里做的修改添加了相关的 `#pragma mark` 标记，可以在 Xcode 快速跳转到相应的标记

1. clone demo:[ https://github.com/YunzhanghuOpen/iOS-SDK-for-RongYun](https://github.com/YunzhanghuOpen/iOS-SDK-for-RongYun)

  `git clone --recursive https://github.com/YunzhanghuOpen/iOS-SDK-for-RongYun`

  (这里使用了 git submodule 来管理 SDK demo 与 融云 demo app 的版本关系。原本[库](https://github.com/YunzhanghuOpen/rongcloud-demo-app-ios-v2)使用的是 master 分支，我们这里未作改动，而是新建了 RedpacketLib 分支。 submodule 会关联其中的某一个提交版本。)

  如果已有代码，需要执行

  `git pull --rebase`

  来进行更新。

  如果没能更新 submodule， 则执行

  `git submodule update --recursive`

  来更新所有的 submodule

2. 下载最新的红包 SDK 库文件 ( master 或者是 release )

  因为`红包 SDK` 在一直更新维护，所以为了不与 demo 产生依赖，所以采取了单独下载 zip 包的策略

  [https://github.com/YunzhanghuOpen/iOSRedpacketLib](https://github.com/YunzhanghuOpen/iOSRedpacketLib)

  解压后将 RedpacketLib 复制至 iOS-SDK-for-RongYun 目录下。

3. 开启 rongcloud-demo-app-ios-v2/ios-rongimdemo/RCloudMessage.xcodeproj 工程文件

4. 设置红包信息

  在 `AppDelegate.m` 中的
  ```objc
  - (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
  ```

  最后添加了

    ```objc
    #pragma mark - 配置红包信息
    [RedpacketConfig configRedpacket];
    ```

  `RedpacketConfig` 类有两个作用。

    1) 它实现了 `YZHRedpacketBridgeDataSource` protocol，并在 Singleton 创建对象的时候设置了

      `[[YZHRedpacketBridge sharedBridge] setDataSource:config];`

      `YZHRedpacketBridgeDataSource` protocol 用以为红包 SDK 提供用户信息

    2) 它用于执行`YZHRedpacketBridge` 的

    ```objc
    - (void)configWithSign:(NSString *)sign
               partner:(NSString *)partner
             appUserId:(NSString *)appUserid
             timeStamp:(long)timeStamp;
    ```
    
    以执行`红包 SDK` 的信息注册

5. 在聊天对话中添加红包支持

  1) 添加类支持

  在 融云 demo app 中已经实现 `RCDChatViewController` ，为了尽量不改动原来的代码，我们重新定义 `RCDChatViewController` 的子类 `RedpacketDemoViewController`。

  在 `RCDChatListViewController` 中的

  ```objc
  -(void)onSelectedTableRow:(RCConversationModelType)conversationModelType
          conversationModel:(RCConversationModel *)model
                atIndexPath:(NSIndexPath *)indexPath
  ```

  找到

  ```objc
  if (conversationModelType == RC_CONVERSATION_MODEL_TYPE_NORMAL) {
 #pragma mark - 对于特定的界面使用红包功能
   RCDChatViewController *_conversationVC = [[RCDChatViewController alloc]init];
 #pragma mark -
  ...
  ```

  对应部分修改为

  ```objc
  RCDChatViewController *_conversationVC = [[RedpacketDemoViewController alloc] init];
  ```

  2) 添加红包功能

  查看 `RedpacketDemoViewController.m` 的 源代码注释了解红包功能的。

    添加的部分包括：

        (1) 注册消息显示 Cell
       (2) 设置红包插件界面
       (3) 设置红包功能相关的参数
       (4) 设置红包接收用户信息
       (5) 设置红包 SDK 功能回调

6. 显示零钱功能

  通过执行

```objc
  - [RedpacketViewControl presentChangeMoneyViewController]
```

  在 融云 SDK demo app 中使用 Storyboard 定义个人设置界面，这里为了执行显示功能，采用 Custom Segue 的方法，在 Demo 中的 `RedpacketChangeMoneySegue` 类实现
