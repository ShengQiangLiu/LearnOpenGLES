//
//  ViewController.m
//  OpenGLES-顶点数据缓冲区
//
//  Created by ShengQiang' Liu on 2017/10/30.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "ViewController.h"
#import "MTEAGLView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    MTEAGLView *glView = [[MTEAGLView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:glView];
    
    [glView setupGL];
    [glView render];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
