//
//  ViewController.m
//  MultipleNetworkRequests
//
//  Created by Macmini on 2019/8/15.
//  Copyright © 2019 Macmini. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self wrongOperation];
//    [self correctOperation];
//    [self orderedOperation];
    // Do any additional setup after loading the view.
}




#pragma mark ========== 网路请求场景1-多个网络请求都完成后通知主线程(错误做法) ==========
- (void)wrongOperation {
    dispatch_group_t myGroup = dispatch_group_create();
    //网络请求1
    dispatch_group_async(myGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //模拟网络请求返回dispatch_after
        NSLog(@"请求1开始");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"请求1结束");
        });
    });
    //网络请求2
    dispatch_group_async(myGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //模拟网络请求返回dispatch_after
        NSLog(@"请求2开始");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"请求2结束");
        });
    });
    //网络请求3
    dispatch_group_async(myGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //模拟网络请求返回dispatch_after
        NSLog(@"请求3开始");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"请求3结束");
        });
    });
    //group通知
    dispatch_group_notify(myGroup, dispatch_get_main_queue(), ^{
        NSLog(@"全部请求结束");
    });
}

#pragma mark ========== 网路请求场景1-多个网络请求都完成后通知主线程 ==========
- (void)correctOperation {
    dispatch_group_t myGroup = dispatch_group_create();
    //enter leave配合使用使所有网络请求完成后通知主线程
    //网络请求1
    dispatch_group_enter(myGroup);
    dispatch_group_async(myGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //模拟网络请求返回dispatch_after
        NSLog(@"请求1开始");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"请求1结束");
            dispatch_group_leave(myGroup);
        });
    });
    //网络请求2
    dispatch_group_enter(myGroup);
    dispatch_group_async(myGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //模拟网络请求返回dispatch_after
        NSLog(@"请求2开始");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"请求2结束");
            dispatch_group_leave(myGroup);
        });
    });
    //网络请求3
    dispatch_group_enter(myGroup);
    dispatch_group_async(myGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //模拟网络请求返回dispatch_after
        NSLog(@"请求3开始");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"请求3结束");
            dispatch_group_leave(myGroup);
        });
    });
    //group通知
    dispatch_group_notify(myGroup, dispatch_get_main_queue(), ^{
        NSLog(@"全部请求结束");
    });
}

#pragma mark ========== 网路请求场景1-多个网络请求按顺序执行都完成后通知主线程 ==========
- (void)orderedOperation {
    dispatch_group_t myGroup = dispatch_group_create();
    //信号量机制控制网络请求按顺序执行
    //enter leave配合使用使所有网络请求完成后通知主线程
    dispatch_group_enter(myGroup);
    dispatch_group_async(myGroup, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //模拟网络请求返回dispatch_after
        dispatch_semaphore_t mySemaphore = dispatch_semaphore_create(0);
        NSLog(@"请求1开始");
        //网络请求1
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"请求1结束");
            //发送信号量
            dispatch_semaphore_signal(mySemaphore);
        });
        //模拟网络请求返回dispatch_after
        dispatch_semaphore_wait(mySemaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"请求2开始");
        //网络请求2
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"请求2结束");
            //发送信号量
            dispatch_semaphore_signal(mySemaphore);
        });
        //模拟网络请求返回dispatch_after
        dispatch_semaphore_wait(mySemaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"请求3开始");
        //网络请求3
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSLog(@"请求3结束");
            //发送信号量
            dispatch_semaphore_signal(mySemaphore);
            dispatch_group_leave(myGroup);
        });
    });
    //group通知
    dispatch_group_notify(myGroup, dispatch_get_main_queue(), ^{
        NSLog(@"全部请求结束");
    });
}
@end
