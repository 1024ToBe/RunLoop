//
//  ZWWTimerViewController.m
//  RunLoop
//
//  Created by mac on 2018/5/18.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWTimerViewController.h"

@interface ZWWTimerViewController ()

@property (nonatomic, strong)dispatch_source_t timer2;
@property (nonatomic, strong)NSTimer    *timer0;
@property (nonatomic, assign)NSInteger  count;
@end

@implementation ZWWTimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self createNSTimer];
}

- (void)createNSTimer{
    _count = 0;
    //方法1：系统自动将timer添加到当前的Runloop中
    //1.创建Timer 2.自动添加到当前Runloop中
    //   _timer0 = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handle) userInfo:nil repeats:YES];
    
    
    //方法2：需要手动将timer添加到指定mode的Runloop中
    //创建Timer
//    _timer0 = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(handle) userInfo:nil repeats:YES];
    //2.将Timer手动添加到当前Runloop中(默认mode)
    //mode 为NSDefaultRunLoopMode导致的问题：当TextView滑动时，会停止计时，滑动结束后继续计时。
//    [[NSRunLoop currentRunLoop]addTimer:_timer0 forMode:NSDefaultRunLoopMode];
    
    //mode 为UITrackingRunLoopMode导致的问题：当TextView滑动时才会是UITrackingRunLoopMode，所以TextView开始滑动，timer开始计时，TextView停止滑动，timer就停止计时
//    [[NSRunLoop currentRunLoop]addTimer:_timer0 forMode:UITrackingRunLoopMode];
    
    //NSRunLoopCommonModes:随时切换两种模式、等价于在NSDefaultRunLoopMode，UITrackingRunLoopMode两种模式下都添加了timer
//    [[NSRunLoop currentRunLoop]addTimer:_timer0 forMode:NSRunLoopCommonModes];
    
    //方法3：方法1，2默认放到主线程中，若主线程处理source0 等事件导致主线程阻塞会导致timer计时不准确，也可以重新创建一个子线程
    //GCD 方法创建Timer：与Runloop无关，不会导致Runloop模式切换时，计时出现问题
    __block int count = 0;
    self.timer2 = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    dispatch_source_set_timer(self.timer2, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 2 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.timer2, ^{
        NSLog(@"--run--");
        if (count == 5) {//取消计时
            dispatch_source_cancel(self.timer2);
            self.timer2 = nil;
        }
        count ++;
    });
    //开启定时器
    dispatch_resume(self.timer2);
    
}

- (void)handle{
    NSLog(@"--run--");
    if (_count==5) {
        [_timer0 invalidate];
        _timer0 = nil;
    }
    _count++;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
