//
//  ZWWTableViewController.m
//  RunLoop
//
//  Created by mac on 2018/5/19.
//  Copyright © 2018年 mac. All rights reserved.
//

#import "ZWWTableViewController.h"
#import "ZWWTimerViewController.h"
#import "ZWWObserverViewController.h"
#import "ZWWTableViewController+method.h"
@interface ZWWTableViewController ()

@property (strong, nonatomic) NSArray *titleArr;
@property (strong, nonatomic) NSArray *vcArr;

@end

@implementation ZWWTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //系统总共有五个runloop，每个runloop有source0：处理用户交互事件，source1：系统响应事件，obsever:监听 timer：定时器事件；
    _titleArr = @[@"NSTimer创建",@"obsver",@"runLoop实践0",@"runLoop实践0-1"];
    _vcArr = @[@"ZWWTimerViewController",@"ZWWObserverViewController",@""];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"basicCell"];
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return _titleArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basicCell" forIndexPath:indexPath];
    cell.textLabel.text = _titleArr[indexPath.row];
   
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
        case 1:{
            Class className = NSClassFromString(_vcArr[indexPath.row]);
            UIViewController *vc = [[className alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
            break;
        }
        case 2:{//runloop实践0
            [self testUseRunloop];
            break;
        }
        case 3:{//runloop实践0-1
            [self testThreanCanUse];
            break;
        }
        default:
            break;
    }
    
   
}

//然后根据具体的业务场景去写逻辑就可以了,比如
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    //Tip:我们可以通过打印touch.view来看看具体点击的view是具体是什么名称,像点击UITableViewCell时响应的View则是UITableViewCellContentView.
    if ([NSStringFromClass([touch.view class])    isEqualToString:@"UITableViewCellContentView"]) {
        //返回为NO则屏蔽手势事件
        return NO;
    }
    return YES;
}

@end
