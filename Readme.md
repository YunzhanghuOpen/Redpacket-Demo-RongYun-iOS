融云红包 SDK 接入文档
=================

使用融云 demo app
------------------

  红包 SDK 的 demo 直接嵌入进 融云 demo 2.0 中，对于原 demo 仅做了少量的修改。如果你的 app 采用 融云的 demo app 作为原型的话，这里的方法是简单快捷的。

  在融云 demo app 里做的修改添加了相关的 #pragma mark 标记，可以在 Xcode 快速跳转到相应的标记

1. clone demo:[ https://github.com/YunzhanghuOpen/iOS-SDK-for-RongYun](https://github.com/YunzhanghuOpen/iOS-SDK-for-RongYun)

  `git clone --recursive https://github.com/YunzhanghuOpen/iOS-SDK-for-RongYun`

  (这里使用了 git submodule 来管理 SDK demo 与 融云 demo app 的版本关系。原本[库](https://github.com/YunzhanghuOpen/rongcloud-demo-app-ios-v2)使用的是 master 分支，我们这里未作改动，而是新建了 RedpacketLib 分支。 submodule 会关联其中的某一个提交版本。)

2. 下载最新的红包 SDK 库文件 ( master 或者是 release )

  因为红包 SDK 在一直更新维护，所以为了不与 demo 产生依赖，所以采取了单独下载 zip 包的策略

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
    以执行红包 SDK 的信息注册
