//
//  Dog.m
//  runTime_sendMsg
//
//  Created by Mr.GCY on 2017/9/1.
//  Copyright © 2017年 Mr.GCY. All rights reserved.
//

#import "Dog.h"
#import <objc/message.h>
@implementation Dog

//--------------------------------------1.使用运行时进行实现
// 没有返回值,1个参数
// void,(id,SEL) 对象方法实现 默认有两个参数 id self, SEL _cmd
void cy_dogBite(id self, SEL _cmd) {
    NSLog(@"------------狗咬人----------");
}

//实例方法实现
+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    // [NSStringFromSelector(sel) isEqualToString:@"run"];
    if (sel == NSSelectorFromString(@"dogBite")) {
        // 动态添加run方法
        // class: 给哪个类添加方法
        // SEL: 添加哪个方法，即添加方法的方法编号
        // IMP: 方法实现 => 函数 => 函数入口 => 函数名（添加方法的函数实现（函数地址））
        // type: 方法类型，(返回值+参数类型) v:void @:对象->self :表示SEL->_cmd
        class_addMethod(self, sel, (IMP)cy_dogBite, "v");
        return YES;
    }
    return [super resolveInstanceMethod:sel];
}

//---------------------------------2.使用最简单的方法声明和实现进行处理
-(void)dogEatDung:(NSString *)name{
    NSLog(@"--------------%@---狗改不了吃屎------",name);
}


-(void)dogRun{
    NSLog(@"--------狗在疯狂的奔跑------");
}
@end
