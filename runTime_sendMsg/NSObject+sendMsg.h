//
//  NSObject+sendMsg.h
//  runTime_sendMsg
//
//  Created by Mr.GCY on 2017/9/4.
//  Copyright © 2017年 Mr.GCY. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (sendMsg)
//交换类方法
-(void)swizzleClassMethod:(SEL)originSel andNewMethod:(SEL)newSel;
//交换对象方法
-(void)swizzleInstanceMethod:(SEL)originSel andNewMethod:(SEL)newSel;
@end
