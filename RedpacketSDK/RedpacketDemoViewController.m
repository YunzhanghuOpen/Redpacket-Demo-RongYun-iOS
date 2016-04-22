//
//  RedpacketDemoViewController.m
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-22.
//  Copyright © 2016年 RongCloud. All rights reserved.
//

#import "RedpacketDemoViewController.h"


#pragma mark - 红包相关的宏定义
#define REDPACKET_BUNDLE(name) @"RedpacketCellResource.bundle/" name
#define REDPACKET_TAG 2016
#pragma mark -

@interface RedpacketDemoViewController ()

@end

@implementation RedpacketDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
#pragma mark - 云账户增加插件功能
    UIImage *icon = [UIImage imageNamed:REDPACKET_BUNDLE(@"redpacket_redpacket")];
    assert(icon);
    [self.pluginBoardView insertItemWithImage:icon
                                        title:NSLocalizedString(@"红包", @"红包")
                                      atIndex:0
                                          tag:REDPACKET_TAG];
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

- (void)pluginBoardView:(RCPluginBoardView *)pluginBoardView clickedItemWithTag:(NSInteger)tag
{
    switch (tag) {
#pragma mark - 云账户增加红包插件点击回调
        case REDPACKET_TAG: {
            // some code
        }
#pragma mark -
        default:
            [super pluginBoardView:pluginBoardView clickedItemWithTag:tag];
            break;
    }
}
@end
