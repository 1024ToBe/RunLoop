//
//  ZWWUseRunloopViewController.m
//  RunLoop
//
//  Created by mac on 2018/8/30.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWUseRunloopViewController.h"
#import "ZWWThread.h"
#import <objc/runtime.h>

@interface ZWWUseRunloopViewController ()

@property (nonatomic, assign) BOOL  isCancelled;
@property (nonatomic, strong) ZWWThread *thread;

@end

@implementation ZWWUseRunloopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)createThread:(id)sender {
    //默认局部的thread变量，用完就会dealloc，无法保留住thread长期运行，以实现开启一个新的线程 长期执行一个操作（比如微信中一个新的子线程负责一直监听对方输入）
    ZWWThread *thread = [[ZWWThread alloc]initWithTarget:self selector:@selector(runThread) object:nil];
    [thread start];
    
    
    //情况一：打印结果：
    //    2018-08-30 16:08:50.033670+0800 RunLoop[47680:442529] <ZWWThread: 0x60000026ff00>{number = 3, name = (null)} start
    //    2018-08-30 16:08:50.033965+0800 RunLoop[47680:442529] <ZWWThread: 0x60000026ff00>{number = 3, name = (null)} end
    //    2018-08-30 16:08:50.034864+0800 RunLoop[47680:442529] 线程dealloc
    //可见局部的thread执行完就自动dealloc销毁了
}

- (IBAction)globalAction:(id)sender {
    ZWWThread *thread = [[ZWWThread alloc]initWithTarget:self selector:@selector(runThread) object:nil];
    [thread start];
    self.thread = thread;
    
    //情况二：尝试用全局变量保留住thread，打印结果
    //   2018-08-30 16:10:24.101440+0800 RunLoop[47861:444355] <ZWWThread: 0x6000002632c0>{number = 3, name = (null)} start
    //   2018-08-30 16:10:24.101966+0800 RunLoop[47861:444355] <ZWWThread: 0x6000002632c0>{number = 3, name = (null)} end
    //可见：此时log打印显示thread不再dealloc，然后通过testThreadCanUse测试没有dealloc的线程是否可正常使用
}

//测试在thread 设置成全局变量后没有dealloc，是否可以正常使用
- (IBAction)testGlobalThreadCanUse:(id)sender {
    //这里会提示EXC_BAD_ACCESS:坏内存，证明thread不可正常使用
    [self performSelector:@selector(testThreadUse) onThread:self.thread withObject:nil waitUntilDone:YES];
}

- (IBAction)runloopToKeepThread:(id)sender {
    ZWWThread *thread = [[ZWWThread alloc]initWithTarget:self selector:@selector(runLoopThread) object:nil];
    [thread start];
}

- (void)testThreadUse{
    NSLog(@"线程：%@可以正常使用",[NSThread currentThread]);
}

- (void)runThread{
    NSLog(@"%@ start",[NSThread currentThread]);
}

- (void)runLoopThread{
    NSLog(@"%@ start",[NSThread currentThread]);
    
//    尝试用runloop保留住thread
//    子线程不同于mainthread，runloop是默认不开启的，需要手动开启，但仅仅开启并不能让线程常驻--必须得有timer，source等在运行
//    runloop 必须有timer，source()等之一运行，否则runloop会自动退出===重点：如何开启常驻线程
    
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(runThread) userInfo:nil repeats:YES];
//    [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop]addPort:[NSPort port] forMode:NSDefaultRunLoopMode];  //这句话注释掉之后runloop是开启失败的,NSPort可以看做是source的一种
    [[NSRunLoop currentRunLoop]run];
    
    //如果runloop循环开启成功，end将不执行，代表这个子线程常驻成功
    NSLog(@"%@ end",[NSThread currentThread]);
}

//使用场景1
//维护线程的生命周期，让线程不自动退出，isCancelled为Yes时退出。
- (IBAction)cancelAction:(id)sender {
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn  = [switchButton isOn];
    if (isButtonOn) {
        self.isCancelled = YES;
    } else {
        self.isCancelled = NO;
    }
    
    ZWWThread *thread = [[ZWWThread alloc]initWithTarget:self selector:@selector(runLoopThread1) object:nil];
    [thread start];
}

- (void)runLoopThread1{
    NSLog(@"%@ start",[NSThread currentThread]);
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    while (!self.isCancelled) {
        @autoreleasepool {
            [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:3]];
        }
    }
    
    NSLog(@"%@ end",[NSThread currentThread]);
}


//使用场景2
//创建常驻线程，执行一些会一直存在的任务。该线程的生命周期跟App相同
- (IBAction)useRunloop2:(id)sender {
    
    ZWWThread *thread = [[ZWWThread alloc]initWithTarget:self selector:@selector(runLoopThread2) object:nil];
    [thread start];
}


- (void)runLoopThread2{
    NSLog(@"%@ start",[NSThread currentThread]);
    @autoreleasepool {
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
     NSLog(@"%@ end",[NSThread currentThread]);
}

//使用场景3
//在一定时间内监听某种事件，或执行某种任务的线程
//如下代码，在15秒内，每隔5s执行onTimerFired:。这种场景一般会出现在，如我需要在应用启动之后，在一定时间内持续更新某项数据。
- (IBAction)useRunloop3:(id)sender {
    
    ZWWThread *thread = [[ZWWThread alloc]initWithTarget:self selector:@selector(runLoopThread3) object:nil];
    [thread start];
}

- (void)runLoopThread3{
    NSLog(@"%@ start",[NSThread currentThread]);
    @autoreleasepool {
        NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
        NSTimer * udpateTimer = [NSTimer timerWithTimeInterval:5
                                                        target:self
                                                      selector:@selector(onTimerFired:)
                                                      userInfo:nil
                                                       repeats:YES];
        [runLoop addTimer:udpateTimer forMode:NSRunLoopCommonModes];
        [runLoop runUntilDate:[NSDate dateWithTimeIntervalSinceNow:3*5]];
     }
    NSLog(@"%@ end",[NSThread currentThread]);
}

- (void)onTimerFired:(NSTimer *)timer{
     NSLog(@"%@ start",[NSThread currentThread]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
