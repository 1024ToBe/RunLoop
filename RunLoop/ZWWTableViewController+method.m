//
//  ZWWTableViewController+method.m
//  RunLoop
//
//  Created by mac on 2018/5/19.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWTableViewController+method.h"
#import "ZWWThread.h"
#import <objc/runtime.h>
@interface ZWWTableViewController()

@property (nonatomic, strong) ZWWThread *thread;

@end

@implementation ZWWTableViewController (method)

- (void)setThread:(NSThread *)thread{
    objc_setAssociatedObject(self, @selector(thread), thread, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSThread *)thread{
    return objc_getAssociatedObject(self, @selector(thread));
}

- (void)testUseRunloop{
    
    //默认局部的thread变量，用完就会dealloc，无法保留住thread长期运行，以实现开启一个新的线程 长期执行一个操作（比如微信中一个新的子线程负责一直监听对方输入）
    ZWWThread *thread = [[ZWWThread alloc]initWithTarget:self selector:@selector(runThread) object:nil];
    [thread start];
    
//    2018-05-19 11:15:55.251180+0800 RunLoop[14466:131960] <ZWWThread: 0x60c000268d80>{number = 3, name = (null)} start
//    2018-05-19 11:15:55.251381+0800 RunLoop[14466:131960] 线程dealloc
    
    //1、尝试用全局变量保留住thread
    self.thread = thread;
    //此时log打印显示thread不再dealloc，然后测试没有dealloc是否可正常使用
//   2018-05-19 11:22:00.631379+0800 RunLoop[15120:139230] <ZWWThread: 0x60800027e500>{number = 3, name = (null)} start
    
   
    
    
}

- (void)runThread{
    NSLog(@"%@ start",[NSThread currentThread]);
    
    //1、尝试用runloop保留住thread
    //子线程不同于mainthread，runloop是默认不开启的，需要手动开启
    //runloop 必须有timer，source等之一运行，否则runloop会自动退出
    [[NSRunLoop currentRunLoop]addPort:[NSPort port] forMode:NSDefaultRunLoopMode];  //这句话注释掉之后runloop是开启失败的
    [[NSRunLoop currentRunLoop]run];
    
    //如果runloop循环开启成功，end将不执行
     NSLog(@"%@ end",[NSThread currentThread]);
    
}

//测试在thread 设置成全局变量后没有dealloc，是否可以正常使用
- (void)testThreanCanUse{
    //这里会提示EXC_BAD_ACCESS:坏内存，证明thread不可正常使用
    [self performSelector:@selector(testThreadUse) onThread:self.thread withObject:nil waitUntilDone:YES];
}



- (void)testThreadUse{
    NSLog(@"线程：%@可以正常使用",[NSThread currentThread]);
}

@end
