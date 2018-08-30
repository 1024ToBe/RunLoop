//
//  main.m
//  RunLoop
//
//  Created by mac on 2018/5/18.
//  Copyright © 2018年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
//        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        
        // 情况1
        //#【验证 Runloop 的开启】
        //#【验证结果】：只会打印开始，并不会打印结束,程序也并没有运行后直接退出。
        //#【Runloop 的退出条件】。
        //App退出；线程关闭；设置最大时间到期；
        
//       说明在UIApplicationMain函数内部开启了一个和主线程相关的RunLoop (保证主线程不会被销毁)，导致 UIApplicationMain 不会返回，一直在运行中，也就保证了程序的持续运行。
        ZWWLog(@"开始");
        int number = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        ZWWLog(@"结束");
        return number;
        
        // 情况2：下面这种情况就会打印开始，结束。然后程序启动后立马退出
//        ZWWLog(@"开始");
//        ZWWLog(@"结束");
//        return number;
        return 0;
        
    }
}
