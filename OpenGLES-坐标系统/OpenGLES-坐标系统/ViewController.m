//
//  ViewController.m
//  OpenGLES-坐标系统
//
//  Created by ShengQiang' Liu on 2017/11/4.
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
    
    MTEAGLView *glView = [[MTEAGLView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:glView];
    
    [glView setupGL];
    [glView render];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
