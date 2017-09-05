//
//  ViewController.m
//  runTime_sendMsg
//
//  Created by Mr.GCY on 2017/8/31.
//  Copyright © 2017年 Mr.GCY. All rights reserved.
//

#import "ViewController.h"
#import <objc/message.h>
#import "Person.h"
#import "Dog.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    /*
     Class class = [CustomObject class];//类对象
     Class metaClass = object_getClass(class);//类元对象
     Class metaOfMetaClass = object_getClass(metaClass);//NSObject类元对象
     Class rootMataClass = object_getClass(metaOfMetaClass);//NSObject类元对象的类元对象
     
     NSLog(@"CustomObject类对象是:%p",class);
     NSLog(@"CustomObject类元对象是:%p",metaClass);
     NSLog(@"metaClass类元对象:%p",metaOfMetaClass);
     NSLog(@"metaOfMetaClass的类元对象的是:%p",rootMataClass);
     NSLog(@"NSObject类元对象%p",object_getClass([NSObject class]));
     
     
     CustomObject类对象是:0x10248aed0
     CustomObject类元对象是:0x10248aea8
     metaClass类元对象:0x102ce5198
     metaOfMetaClass的类元对象的是:0x102ce5198
     NSObject类元对象0x102ce5198
     */
    
    //调用person的私有方法
    /**
     id:谁发送消息; SEL:发送什么消息;
     objc_msgSend(id self, SEL op, ...)
     
     // 用最底层写
     objc_getClass(const char *name) 获取当前类
     sel_registerName(const char *str) 注册个方法编号
     让Person这个类对象发送了一个alloc消息，返回一个分配好的内存对象给你;再发送一个消息初始化.
     */
    Person * p = objc_msgSend(objc_getClass("Person"),sel_registerName("alloc"));
    
    
    //1.直接调用对象.m中实现的方法
    objc_msgSend(p, sel_registerName("eat"));
    
    //2.对象方法调用  使用动态方法解析
    objc_msgSend(p, sel_registerName("run:"),@(100),@"nihao");
    
    //3.动态解析没有使用  采用重定向
    objc_msgSend(p, sel_registerName("dogBite"));
    
    //4.重定向没有使用 采用消息转发
    objc_msgSend(p, sel_registerName("dogEatDung:"),@"嘿嘿");

    //5.类方法调用  使用动态方法解析
    objc_msgSend([p class], sel_registerName("doWork:"),@"高晨阳");
    
    //6. 使用重定向
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wundeclared-selector"
    [self performSelector:@selector(dogRun) withObject:nil];
    #pragma clang diagnostic pop
}

-(id)forwardingTargetForSelector:(SEL)aSelector{
    if (aSelector == NSSelectorFromString(@"dogRun")) {
        return [Dog new];
    }
    return [super forwardingTargetForSelector:aSelector];
}
@end
