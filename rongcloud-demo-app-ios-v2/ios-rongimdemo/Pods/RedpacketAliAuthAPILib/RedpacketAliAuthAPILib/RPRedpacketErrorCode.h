//
//  RPRedpacketErrorCode.h
//  Description
//
//  Created by Mr.Yang on 2017/4/21.
//  Copyright © 2017年 Mr.Yang. All rights reserved.
//

#ifndef RPRedpacketErrorCode_h
#define RPRedpacketErrorCode_h

typedef NS_ENUM(NSInteger, RedpacketErrorCode){
    
    RedpacketTokenIllegal      = -1,    /*Token 不合法*/
    RedpacketTokenExprie       = -2,    /*Token 已过期*/
    RedpacketFetchTokenFailed  = -3,    /*Token查询错误*/
    RedpacketSuccessful        = 0,     /*操作成功*/
    RedpacketSignExpried       = 4,     /*签名过期*/
    RedpacketHBOcciOvermuch    = 9,     /*接口调用频率太高，请稍候重试*/
    
    RedpacketOtherError        = 100,   /*其它错误操作导致失败*/
    RedpacketChangeDevice,              /*设备号无效*/
    RedpacketParamInsuf        = 1000,  /*请求参数不足或者格式不正确*/
    
    RedpacketEaseMobTokenError = 20304, /*环信Token错误*/
    RedpacketYTXTokenError     = 20308, /*容联云Token错误*/
    
    RedpacketIDIllegal         = 3001,  /*红包ID不合法*/
    RedpacketMsgTooLong,                /*留言过长*/
    RedpacketCountIllegal,              /*红包数量不合法*/
    RedpacketAvgLess001,                /*人均小于0.01元*/
    RedpacketCountTooLarge,             /*您发的红包个数太多*/
    RedpacketAvgAmountTooLarge,         /*人均金额过大*/
    
    RedpacketExpried           = 3011,  /*红包已过期*/
    RedpacketReceiverError,             /*此红包不属于您*/
    RedpacketCompleted,                 /*拆红包但是红包已经被抢完*/
    RedpacketGetReceivedBefore,         /*此红包自己已领取过，多设备登录遇到的问题*/
    RedpacketQuotaDay,                  /*当日发红包限额提示*/
    
    RedpacketUnAliAuthed       = 60201  /*支付宝支付版本，支付宝未授权*/
    
};


#endif /* RPRedpacketErrorCode_h */
