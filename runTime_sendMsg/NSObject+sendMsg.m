//
//  NSObject+sendMsg.m
//  runTime_sendMsg
//
//  Created by Mr.GCY on 2017/9/4.
//  Copyright © 2017年 Mr.GCY. All rights reserved.
//

#import "NSObject+sendMsg.h"
#import <objc/message.h>
#import "Dog.h"
void class_swizzleMethod(Class cls,SEL originSel,SEL newSel){
    Method orgMethod = class_getInstanceMethod(cls, originSel);
    Method newMethod = class_getInstanceMethod(cls, newSel);
    //检测需要要换的方法 有没有实现方法
    BOOL didAddMethod = class_addMethod(cls, originSel, method_getImplementation(newMethod), method_getTypeEncoding(newMethod));
    if (didAddMethod) {
        //替换方法
        class_replaceMethod(cls, newSel, method_getImplementation(orgMethod), method_copyReturnType(orgMethod));
    }else{
        method_exchangeImplementations(orgMethod, newMethod);
    }
}
@implementation NSObject (sendMsg)
//交换类方法
-(void)swizzleClassMethod:(SEL)originSel andNewMethod:(SEL)newSel{
    class_swizzleMethod(object_getClass(self), originSel, newSel);
}
//交换对象方法
-(void)swizzleInstanceMethod:(SEL)originSel andNewMethod:(SEL)newSel{
    class_swizzleMethod([self class], originSel, newSel);
}
+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self swizzleClassMethod:@selector(resolveInstanceMethod:) andNewMethod:@selector(cy_resolveInstanceMethod:)];
        [self swizzleClassMethod:@selector(resolveClassMethod:) andNewMethod:@selector(cy_resolveClassMethod:)];
        [self swizzleInstanceMethod:@selector(forwardingTargetForSelector:) andNewMethod:@selector(cy_forwardingTargetForSelector:)];
        [self swizzleInstanceMethod:@selector(methodSignatureForSelector:) andNewMethod:@selector(cy_methodSignatureForSelector:)];
        [self swizzleInstanceMethod:@selector(forwardInvocation:) andNewMethod:@selector(cy_forwardInvocation:)];
    });
}
#pragma mark- 动态方法解析
// 没有返回值,1个参数
// void,(id,SEL) 对象方法实现
void cy_run(id self, SEL _cmd, NSNumber *meter,NSNumber *meter1) {
    NSLog(@"跑了%@米%@", meter,meter1);
}
// 任何方法默认都有两个隐式参数,self,_cmd（当前方法的方法编号）
// 什么时候调用:只要一个对象调用了一个未实现的方法就会调用这个方法,进行处理
// 作用:动态添加方法,处理未实现
//实例方法实现
+ (BOOL)cy_resolveInstanceMethod:(SEL)sel
{
    if (sel == NSSelectorFromString(@"run:")) {
        // 动态添加run方法
        // class: 给哪个类添加方法
        // SEL: 添加哪个方法，即添加方法的方法编号
        // IMP: 方法实现 => 函数 => 函数入口 => 函数名（添加方法的函数实现（函数地址））
        // type: 方法类型，(返回值+参数类型) v:void @:对象->self :表示SEL->_cmd
        class_addMethod(self, sel, (IMP)cy_run, "v@:@");
        return YES;
    }
    return [[self class] cy_resolveInstanceMethod:sel];
}
//类方法实现
+(void)cy_doWork:(NSString *)str{
    NSLog(@"我正在做作业-- %@",str);
}
//类方法实现
+(BOOL)cy_resolveClassMethod:(SEL)sel{
    if (sel == NSSelectorFromString(@"doWork:")) {
        class_addMethod(object_getClass(self), sel, class_getMethodImplementation(object_getClass(self),@selector(cy_doWork:)), "v@:");
        return YES;
    }
    BOOL isSuccess = [class_getSuperclass(self) cy_resolveClassMethod:sel];
    return isSuccess;
}
#pragma mark- 重定向
//当动态方法解析不作处理返回NO时 在消息转发机制执行前，Runtime系统会再给我们一次偷梁换柱的机会，即通过重载- (id)forwardingTargetForSelector:(SEL)aSelector方法替换消息的接受者为其他对象：
-(id)cy_forwardingTargetForSelector:(SEL)aSelector{
    NSLog(@"------------重定向-------------");
    if (aSelector == NSSelectorFromString(@"dogBite") || aSelector == NSSelectorFromString(@"dogRun")) {
        return [Dog new];
    }
    return [self cy_forwardingTargetForSelector:aSelector];
}
#pragma mark- 转发     消息转发机制
//所以我们在重写forwardInvocation:的同时也要重写methodSignatureForSelector:方法，否则会抛异常
//methodSignatureForSelector用来生成方法签名，这个签名就是给forwardInvocation中的参数NSInvocation调用的。
//unrecognized selector sent to instance，原来就是因为methodSignatureForSelector这个方法中，由于没有找到fly对应的实现方法，所以返回了一个空的方法签名，最终导致程序报错崩溃。
- (NSMethodSignature *)cy_methodSignatureForSelector:(SEL)aSelector{
    NSLog(@"------------methodSignatureForSelector-------------");
    if (aSelector == NSSelectorFromString(@"dogEatDung:")) {
        //手动写方法类型签名
        return [NSMethodSignature signatureWithObjCTypes:"v@:@"];
    }
    return [self cy_methodSignatureForSelector:aSelector];
}
//当动态方法解析不作处理返回NO时，消息转发机制会被触发。在这时forwardInvocation:方法会被执行
- (void)cy_forwardInvocation:(NSInvocation *)anInvocation{
    NSLog(@"------------forwardInvocation-------------");
    Dog * dog = [Dog new];
    if ([dog respondsToSelector:[anInvocation selector]]) {
        [anInvocation invokeWithTarget:dog];
    }
}
@end
