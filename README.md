# RunLoop
RunLoop学习测试demo
Runloop基本作用：

1.保持程序的持续运行（没有Runloop的话，程序启动完就退出，有runloop App可以启动起来，并保持持续运行状态）
2.处理APP中的各种事件（比如触摸事件，定期器事件，Selector事件）
3.节省CPU 资源，提升程序性能：该做事时就做事，该休息是休息，并不会一直处于就绪状态

Runloop对象
iOS中有2套API来访问和使用Runloop
1.Foundation
2 .NSRunloop

Core Foundation
CFRunloopRef

NSRunloop和CFRunLoopRef都代表着Runloop对象
NSRunloop是基于CFRunLoopRef的一层OC包装，所以要了解Runloop内部结构，需要多研究CFRunLoopRef层面的API（Core Foundation层面）

每个线程都有一个对应的Runloop，是一一对应的，关系是：Key（线程）- value（Runloop）
主线程对应的Runloop是默认开启的，子线程对应的Runloop默认是不开启的，需要手动开启

每个Runloop有很多个模式（Mode），系统默认注册了5个mode
1.kCFRunloopDefaultMode（oc中的NSDefaultRunnloop）：App的默认Mode，通常主线程是在这个Mode下运行
2.UITrackingRunloopMode：界面跟踪Mode，用于ScrollView追踪触摸滑动，保证界面滑动时不受其他Mode影响
3.UIInitializationRunLoopMode：在刚启动App时进入的第一个Mode，启动完成后就不再使用
4.GSEventReceiveRunLoopMode:接受系统事件的内部Mode，通常用不到
5.kCFRunLoopCommonModes:这是一个占位用的Mode，不是一种真正的Mode。兼容两种mode，可以在两种模式间自动切换



同一时刻只能有一种mode 
所以当App启动的时候会用一种Runloop，然后启动之后这种Runloop就不存在了，就变化了NSDefaultRunloop（经常情况下用到的默认的Runloop）当我们滑动Scrollview的时候又会有新的Runloop代替上面的defaultRunloop，所以说当我们给Runloop切换模式mode的时候，首先得让一个mode结束之后再去开启另外一种mode

为什么Runloop要其中一个mode全部退出之后才能加载另外一种mode？
因为一个Runloop有好多类资源，这样做可以分隔开不同组的Source/Timer/Observer，让其互不影响：
1.Source-事件源：处理一些事件时会生成Source，输入源
source0：基于用户的事件（比如手指触摸屏幕，会打包成一个source0事件）
source1：基于内核(Port)的事件（系统事件，自发调用）  

2.observer-监听（CFRunLoopObserverRef）：观察者，可以监听Runloop时各种状态
比如有手指点击屏幕了，那么就要告诉监听observer去唤醒Runloop，当没有手指等事件时，observer告诉Runloop可以休眠了
可监听的时间点有以下几个：
/* Run Loop Observer Activities */
typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
kCFRunLoopEntry = (1UL << 0),                           //即将进入loop（1）
kCFRunLoopBeforeTimers = (1UL << 1),              //即将处理Timer（2）
kCFRunLoopBeforeSources = (1UL << 2),           //即将处理Source（4）
kCFRunLoopBeforeWaiting = (1UL << 5),             //即将进入休眠（32）
kCFRunLoopAfterWaiting = (1UL << 6),                //刚从休眠中唤醒（64）
kCFRunLoopExit = (1UL << 7),                              //即将退出Loop（128）
kCFRunLoopAllActivities = 0x0FFFFFFFU
};

3.timer-定时器
比如倒计时5秒，当第5秒 那一刻到的时候唤醒runloop，是timer负责的

