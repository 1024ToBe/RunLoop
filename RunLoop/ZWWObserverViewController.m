//
//  ZWWObserverViewController.m
//  RunLoop
//
//  Created by mac on 2018/5/19.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWObserverViewController.h"

@interface ZWWObserverViewController ()

@end

@implementation ZWWObserverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self testObserver];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    //当手动点击屏幕时可以从下面log信息栏查看调用栈，可以看到响应里有source0，证明用户交互触发生成的是 source0
    //在该方法打印断点，lldb输入 thread backtrace或者输入bt就可以查看以下完整的堆栈信息
//    (lldb) thread backtrace
//    * thread #1, queue = 'com.apple.main-thread', stop reason = breakpoint 1.1
//    * frame #0: 0x00000001028ae100 RunLoop`-[ZWWObserverViewController touchesBegan:withEvent:](self=0x00007fe69ec0ea00, _cmd="touchesBegan:withEvent:", touches=1 element, event=0x000060c000114640) at ZWWObserverViewController.m:30
//    frame #1: 0x00000001041c87c7 UIKit`forwardTouchMethod + 340
//    frame #2: 0x00000001041c8662 UIKit`-[UIResponder touchesBegan:withEvent:] + 49
//    frame #3: 0x0000000104010e7a UIKit`-[UIWindow _sendTouchesForEvent:] + 2052
//    frame #4: 0x0000000104012821 UIKit`-[UIWindow sendEvent:] + 4086
//    frame #5: 0x0000000103fb6370 UIKit`-[UIApplication sendEvent:] + 352
//    frame #6: 0x00000001048f757f UIKit`__dispatchPreprocessedEventFromEventQueue + 2796
//    frame #7: 0x00000001048fa194 UIKit`__handleEventQueueInternal + 5949
//    frame #8: 0x0000000103ac0bb1 CoreFoundation`__CFRUNLOOP_IS_CALLING_OUT_TO_A_SOURCE0_PERFORM_FUNCTION__ + 17
//    frame #9: 0x0000000103aa54af CoreFoundation`__CFRunLoopDoSources0 + 271                       /**********这里显示是source0事件************/
//    frame #10: 0x0000000103aa4a6f CoreFoundation`__CFRunLoopRun + 1263
//    frame #11: 0x0000000103aa430b CoreFoundation`CFRunLoopRunSpecific + 635
//    frame #12: 0x00000001085cca73 GraphicsServices`GSEventRunModal + 62
//    frame #13: 0x0000000103f9b0b7 UIKit`UIApplicationMain + 159
//    frame #14: 0x00000001028ae00f RunLoop`main(argc=1, argv=0x00007ffeed3510e0) at main.m:14
//    frame #15: 0x0000000107577955 libdyld.dylib`start + 1

}

- (void)testObserver{
    
    //监听对象
    //kCFRunLoopAllActivities:监听所有事件活动
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        NSLog(@"监听到Runloop发生改变==%zd",activity);
    });
    
//    typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
//        kCFRunLoopEntry = (1UL << 0),               //1:进入Runloop
//        kCFRunLoopBeforeTimers = (1UL << 1),        //2:进入timer监听：查看有没有timer发生
//        kCFRunLoopBeforeSources = (1UL << 2),       //4：source监听：查看有没有source发生
//        kCFRunLoopBeforeWaiting = (1UL << 5),       //32：休眠状态
//        kCFRunLoopAfterWaiting = (1UL << 6),        //64：唤醒状态
//        kCFRunLoopExit = (1UL << 7),                //128：退出Runloop
//        kCFRunLoopAllActivities = 0x0FFFFFFFU       //所有事件
//    };

    
    //把监听添加到Runloop里
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    
    //c语言使用完成记得释放
    CFRelease(observer);
    
    //进入App会先打印1，然后循环打印2，4检查是或否有timer，source事件
    //点击屏幕会打印64唤醒（点击后肯定先打印64.从32休眠状态转为64唤醒状态），会自动休眠32（基本最后没有任何操作时会打印32，自动处于休眠状态）
}


@end
