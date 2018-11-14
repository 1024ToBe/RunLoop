//
//  ZWWTimerViewController.m
//  RunLoop
//
//  Created by mac on 2018/5/18.
//  Copyright © 2018年 mac. All rights reserved.
// test commitlint

#import "ZWWTimerViewController.h"

@interface ZWWTimerViewController ()

@property (nonatomic, assign)NSInteger  count;
@property (nonatomic, strong)NSTimer    *timer1;
@property (nonatomic, strong)NSTimer    *timer2;
@property (nonatomic, strong)dispatch_source_t timer3;

@end

@implementation ZWWTimerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
}

- (IBAction)createTimer1:(id)sender {
    _count = 0;
    //方法1：系统自动将timer添加到当前的Runloop中
    //1.创建Timer
    //2.自动添加到当前Runloop中,默认mode为kCFRunLoopDefaultMode
    //mode 为kCFRunLoopDefaultMode导致的问题：当TextView滑动时，会停止计时，滑动结束后继续计时。
   
    _timer1 = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(handle:) userInfo:_timer1 repeats:YES];
    
}
- (IBAction)createTimer0201:(id)sender {
    _count = 0;
    //方法2.1需要手动将timer添加到指定mode的Runloop中
    //1.创建Timer
    _timer2 = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(handle:) userInfo:_timer2 repeats:YES];
    //2.1将Timer手动添加到当前Runloop中(默认mode)
    //mode 为NSDefaultRunLoopMode导致的问题：当TextView滑动时，会停止计时，滑动结束后继续计时。
     //原因：当滑动Scrollview时。mode改变成为UITrackingRunLoopMode，而timer添加到了默认模式下 NSDefaultRunLoopMode
    [[NSRunLoop currentRunLoop]addTimer:_timer2 forMode:NSDefaultRunLoopMode];
}

- (IBAction)createTimer0202:(id)sender {
    _count = 0;
    //方法2.2：需要手动将timer添加到指定mode的Runloop中
    //1.创建Timer
    _timer2 = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(handle:) userInfo:_timer2 repeats:YES];
    //2. mode 为UITrackingRunLoopMode导致的问题：当TextView滑动时才会是UITrackingRunLoopMode，所以TextView开始滑动，timer开始计时，TextView停止滑动，timer就停止计时
    [[NSRunLoop currentRunLoop]addTimer:_timer2 forMode:UITrackingRunLoopMode];
}

- (IBAction)createTimer0203:(id)sender {
    _count = 0;
    //方法2.3：需要手动将timer添加到指定mode的Runloop中
    //1.创建Timer
    _timer2 = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(handle:
                                                                              ) userInfo:_timer2 repeats:YES];
    //2. NSRunLoopCommonModes:任意切换两种模式(不是NSDefaultRunLoopMode 和 UITrackingRunLoopMode两种方式并存)、等价于在NSDefaultRunLoopMode，UITrackingRunLoopMode两种模式下都添加了timer
    [[NSRunLoop currentRunLoop]addTimer:_timer2 forMode:NSRunLoopCommonModes];
    
}
- (IBAction)createTimerUseGCD:(id)sender {
    //方法3：方法1，2默认将timer放到主线程中，有可能造成计时不是很准确：Runloop处理完Timer事件处理source0，若主线程处理source0或source1等事件导致主线程阻塞时，timer不会及时走就会导致runloop中timer计时不准确。
    //解决方法1：可以重新创建一个子线程，将timer添加到子线程中。成本是：需要开辟一个新的线程
    //解决方法2：GCD 方法创建Timer。实际只要提到Runloop就会阻塞主线程，GCD 方法创建Timer与Runloop无关，不会导致Runloop模式切换时，计时出现问题
    //打印方法：直接打出dispatch，选择GCD Timer回车即可
    
        __block int count = 0;
    
        //生成定时器（要用全局变量timer）
        self.timer3 = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(0, 0));
    
        //设置时间间隔    1 * NSEC_PER_SEC：多少秒执行一次   2 * NSEC_PER_SEC：多少秒后执行
        dispatch_source_set_timer(self.timer3, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 2 * NSEC_PER_SEC);
    
        //设置触发事件
        dispatch_source_set_event_handler(self.timer3, ^{
            NSLog(@"--run--");
            if (count == 5) {//取消计时
                dispatch_source_cancel(self.timer3);
                self.timer3 = nil;
            }
            count ++;
        });
        //开启定时器
        dispatch_resume(self.timer3);
}

- (void)handle:(id)timer{
    _count++;
    NSLog(@"----run--- count==%ld,当前runloopMode==%@",_count,[[NSRunLoop currentRunLoop]currentMode]);
    if (_count==10) {
        
        [timer invalidate];
        timer = nil;

    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
