//
//  ViewController.m
//  贝塞尔曲线
//
//  Created by ainolee on 15/9/16.
//  Copyright (c) 2015年 com.kls66.www. All rights reserved.
//

#import "ViewController.h"
#import "ProgressView.h"

#define kScreem_Width   [[UIScreen mainScreen] bounds].size.width

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSArray *desArr=@[@"准备购买",@"已经付款",@"已经收货",@"完成评价",@"最多五个"];
    
    ProgressView *progressview=[[ProgressView alloc]initWithFrame:CGRectMake(0, 100, kScreem_Width, 80) andDescriptionArr:desArr andStatus:4];
    [self.view addSubview:progressview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
