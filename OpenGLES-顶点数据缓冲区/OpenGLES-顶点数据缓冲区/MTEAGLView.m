//
//  MTEAGLView.m
//  OpenGLES-三角形绘制
//
//  Created by ShengQiang' Liu on 2017/10/20.
//  Copyright © 2017年 apple. All rights reserved.
//

#import "MTEAGLView.h"
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "MTGLProgram.h"

@interface MTEAGLView ()
{
    GLuint _frameBuffer, _colorRenderBuffer;
    GLuint _program;
}

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) CAEAGLLayer *eaglLayer;

@end



@implementation MTEAGLView

// 必须重新该方法，用于支持 OpenGLES 绘制
+ (Class)layerClass
{
    return [CAEAGLLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    {
        // 配置 CAEAGLLayer
        self.eaglLayer = (CAEAGLLayer *)self.layer;
        self.eaglLayer.opaque = YES;
        self.eaglLayer.drawableProperties = @{
                                              kEAGLDrawablePropertyRetainedBacking:[NSNumber numberWithBool:NO],
                                              kEAGLDrawablePropertyColorFormat:kEAGLColorFormatRGBA8
                                              };
        
        // 初始化 OpenGLES 上下文为 2.0 版本
        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        if (!self.context || ![EAGLContext setCurrentContext:self.context])
        {
            NSLog(@"Failed to initialize OpenGLES 2.0 context.");
        }

    }
    return self;
}


- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    [self setupBuffers];
    [self loadShaders];
}

- (void)setupBuffers
{
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:self.eaglLayer];
//    glRenderbufferStorage(GL_RENDERBUFFER, GL_RGB, MTScreenWidth, MTScreenHeight);
    
    glGenFramebuffers(1, &_frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
}

- (void)loadShaders
{
    NSString *vertexPath = [[NSBundle mainBundle] pathForResource:@"vertex" ofType:@"vsh"];
    NSString *fragmentPath = [[NSBundle mainBundle] pathForResource:@"fragment" ofType:@"fsh"];
    _program = CreateGLProgramFromFile(vertexPath.UTF8String, fragmentPath.UTF8String);
    UseProgram(_program);
}

- (void)setupVertexData
{
    // 三角形位置，通过顶点着色器的 positon 属性传入顶点值
    static GLfloat vertices[] =
    {
        -0.5f, -0.5f, 0.0f, // left
        0.5f, -0.5f, 0.0f, // right
        0.0f,  0.5f, 0.0f  // top
    };
    
    GLint positionAttrib = glGetAttribLocation(_program, "position");
    glVertexAttribPointer(positionAttrib, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(positionAttrib);
    
    // 三角形颜色，通过顶点着色器的 color 属性传入颜色值，再通过 varying 的修饰，把颜色值从 Vertex Shader 传递到 Fragment Shader
    static GLfloat colors[] =
    {
        0.0f, 0.0f, 0.0f, // 左下角 黑色
        1.0f, 1.0f, 1.0f, // 右下角 白色
        0.0f, 1.0f, 1.0f, // 顶角 青色
    };
    GLint colorAttrib = glGetAttribLocation(_program, "color");
    glVertexAttribPointer(colorAttrib, 3, GL_FLOAT, GL_FALSE, 0, colors);
    glEnableVertexAttribArray(colorAttrib);
}

- (void)destoryBuffer
{
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
}

- (void)render
{
    glClearColor(0.0, 1.0, 1.0, 1.0); // 青色
    glClear(GL_COLOR_BUFFER_BIT);
    
    glViewport(0, 0, self.bounds.size.width, self.bounds.size.height);

    [self setupVertexData];
    

    glDrawArrays(GL_TRIANGLES, 0, 3);
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}




@end
