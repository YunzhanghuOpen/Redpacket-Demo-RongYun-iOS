//
//  RedpacketChangeMoneySegue.m
//  RCloudMessage
//
//  Created by YANG HONGBO on 2016-4-26.
//  Copyright © 2016年 云帐户. All rights reserved.
//

#import "RedpacketChangeMoneySegue.h"

#pragma mark - 红包相关头文件
#import "RedpacketViewControl.h"
#pragma mark -

@interface RedpacketChangeMoneySegue ()
#pragma mark - 红包相关属性
@end

@implementation RedpacketChangeMoneySegue

- (void)perform
{
    [RedpacketViewControl presentChangePocketViewControllerFromeController:self.sourceViewController];
}

@end
