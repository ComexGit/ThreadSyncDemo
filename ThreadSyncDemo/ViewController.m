//
//  ViewController.m
//  ThreadSyncDemo
//
//  Created by UncleDrew on 2018/9/16.
//  Copyright © 2018年 UncleDrew. All rights reserved.
//

#import "ViewController.h"
#import "TSLockMgr.h"


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    int buttonCount = 5;
    for (int i = 0; i < buttonCount; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(0, 0, 200, 50);
        button.center = CGPointMake(self.view.frame.size.width / 2, i * 60 + 160);
        button.tag = pow(10, i + 3);
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [button setTitle:[NSString stringWithFormat:@"run (%d)",(int)button.tag] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(tap:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
    
    UIButton *logButton = [UIButton buttonWithType:UIButtonTypeCustom];
    logButton.frame = CGRectMake(15, [[UIScreen mainScreen] bounds].size.height - 100, 100, 50);
    [logButton setTitle:@"All Costs" forState:UIControlStateNormal];
    [logButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [logButton addTarget:self action:@selector(log:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:logButton];
    
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    clearButton.frame = CGRectMake([[UIScreen mainScreen] bounds].size.width-115, [[UIScreen mainScreen] bounds].size.height - 100, 100, 50);
    [clearButton setTitle:@"Clear " forState:UIControlStateNormal];
    [clearButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [clearButton addTarget:self action:@selector(clear:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:clearButton];
}

- (void)tap:(UIButton *)sender {
    NSLog(@"");
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [TSLockMgr test:(int)sender.tag];
    });
}

- (IBAction)clear:(id)sender {
    for (NSUInteger i = 0; i < LockTypeCount; i++) {
        TimeCosts[i] = 0;
    }
    TimeCount = 0;
    printf("---- clear ----\n\n");
}

- (IBAction)log:(id)sender {
    [TSLockMgr printTimeConst:TimeCosts];
    printf("---- fin (sum:%d) ----\n\n",TimeCount);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
