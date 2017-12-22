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
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import "MTGLProgram.h"

@interface MTEAGLView ()
{
    GLuint _frameBuffer, _colorRenderBuffer;
    GLuint _pointVBO, _colorVBO, _VAO, _EBO;
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
        
        // 初始化 OpenGLES 上下文为 3.0 版本，VAO 需要在 3.0 版本以上才能使用
        self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
        if (!self.context || ![EAGLContext setCurrentContext:self.context])
        {
            NSLog(@"Failed to initialize OpenGLES 2.0 context.");
        }

    }
    return self;
}

- (void)destoryBuffer
{
    glDeleteFramebuffers(1, &_frameBuffer);
    _frameBuffer = 0;
    glDeleteRenderbuffers(1, &_colorRenderBuffer);
    _colorRenderBuffer = 0;
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



- (void)render
{
    glClearColor(1.0, 1.0, 0.0, 1.0); // 黄色背景
    glClear(GL_COLOR_BUFFER_BIT);
    
    glViewport(0, 0, self.bounds.size.width, self.bounds.size.height);
    
    /**
     三角形绘制
     */
//    [self renderTriangleVertexData]; // 直接使用顶点数组绘制
//    [self renderTriangleVertexBufferData]; // VBO 方式绘制
//    [self renderTriangleVertexArrayBufferData]; // VAO 方式绘制
    
    /**
     正方形绘制
     */
    [self renderSquareVertexData];
//    [self renderSquareVertexDataUsingElement];
//    [self renderSquareVertexBufferData];
//    [self renderSquareVertexArrayBufferData];
//    [self renderSquareVertexElementBufferData];

    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

#pragma mark - 三角形绘制
/**
 直接由 CPU 向 GPU 传输数据
 */
- (void)renderTriangleVertexData
{
    // 三角形位置，通过顶点着色器的 positon 属性传入顶点值
    static GLfloat vertices[] =
    {
        -0.5f, -0.5f, 0.0f, // 左下角
        0.5f, -0.5f, 0.0f, // 右下角
        0.0f,  0.5f, 0.0f  // 顶角
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
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

/**
 VBO 的方式向 GPU 传输数据
 */
- (void)renderTriangleVertexBufferData
{
    // 三角形位置，通过顶点着色器的 positon 属性传入顶点值
    static GLfloat vertices[] =
    {
        -0.5f, -0.5f, 0.0f, // left
        0.5f, -0.5f, 0.0f, // right
        0.0f,  0.5f, 0.0f  // top
    };
    
    // 顶点位置缓冲区
    glGenBuffers(1, &_pointVBO);
    glBindBuffer(GL_ARRAY_BUFFER, _pointVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    GLint positionAttrib = glGetAttribLocation(_program, "position");
    glVertexAttribPointer(positionAttrib, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), (GLvoid *)0);
    glEnableVertexAttribArray(positionAttrib);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    // 三角形颜色，通过顶点着色器的 color 属性传入颜色值，再通过 varying 的修饰，把颜色值从 Vertex Shader 传递到 Fragment Shader
    static GLfloat colors[] =
    {
        0.0f, 0.0f, 0.0f, // 左下角 黑色
        1.0f, 1.0f, 1.0f, // 右下角 白色
        0.0f, 1.0f, 1.0f, // 顶角 青色
    };
    
    glGenBuffers(1, &_colorVBO);
    glBindBuffer(GL_ARRAY_BUFFER, _colorVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(colors), colors, GL_STATIC_DRAW);
    
    GLint colorAttrib = glGetAttribLocation(_program, "color");
    glVertexAttribPointer(colorAttrib, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), (GLvoid *)0);
    glEnableVertexAttribArray(colorAttrib);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glDrawArrays(GL_TRIANGLES, 0, 3);
}

/**
 VAO 的方式向 GPU 传输数据
 */
- (void)renderTriangleVertexArrayBufferData
{
    // 创建和绑定 VAO
    glGenVertexArrays(1, &_VAO);
    glBindVertexArray(_VAO);
    
    // 三角形位置，通过顶点着色器的 positon 属性传入顶点值
    static GLfloat vertices[] =
    {
        -0.5f, -0.5f, 0.0f, // left
        0.5f, -0.5f, 0.0f, // right
        0.0f,  0.5f, 0.0f  // top
    };
    
    // 顶点位置缓冲区
    glGenBuffers(1, &_pointVBO);
    glBindBuffer(GL_ARRAY_BUFFER, _pointVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    GLint positionAttrib = glGetAttribLocation(_program, "position");
    glVertexAttribPointer(positionAttrib, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), (GLvoid *)0);
    glEnableVertexAttribArray(positionAttrib);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    // 三角形颜色，通过顶点着色器的 color 属性传入颜色值，再通过 varying 的修饰，把颜色值从 Vertex Shader 传递到 Fragment Shader
    static GLfloat colors[] =
    {
        0.0f, 0.0f, 0.0f, // 左下角 黑色
        1.0f, 1.0f, 1.0f, // 右下角 白色
        0.0f, 1.0f, 1.0f, // 顶角 青色
    };
    
    glGenBuffers(1, &_colorVBO);
    glBindBuffer(GL_ARRAY_BUFFER, _colorVBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(colors), colors, GL_STATIC_DRAW);
    
    GLint colorAttrib = glGetAttribLocation(_program, "color");
    glVertexAttribPointer(colorAttrib, 3, GL_FLOAT, GL_FALSE, 3 * sizeof(GLfloat), (GLvoid *)0);
    glEnableVertexAttribArray(colorAttrib);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glDrawArrays(GL_TRIANGLES, 0, 3);

    glBindVertexArray(0); // 解绑 VAO
}

#pragma mark - 正方形绘制

/**
 直接使用顶点数组
 */
- (void)renderSquareVertexData
{
    const GLfloat vertices[] =
    {
        -0.5f, 0.5f, 0.0f,  // 左上角
        -0.5f, -0.5f, 0.0f, // 左下角
        0.5f, -0.5f, 0.0f, // 右下角
        0.5f, 0.5f, 0.0f, // 右上角
    };
    
    GLint positionAttribution = glGetAttribLocation(_program, "position");
    glVertexAttribPointer(positionAttribution, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(positionAttribution);
    
    const GLfloat colors[] =
    {
        0,0,1,1, // 左上，蓝色
        0,0,0,1, // 左下，黑色
        1,0,0,1, // 右下，红色
        0,1,0,1, // 右上，绿色
    };
    
    GLint colorAttribution = glGetAttribLocation(_program, "color");
    glVertexAttribPointer(colorAttribution, 4, GL_FLOAT, GL_FALSE, 0, colors);
    glEnableVertexAttribArray(colorAttribution);
    
    // 绘制两个三角形，复用两个顶点，因此只需要四个顶点坐标
    // V0-V1-V2, V0-V2-V3。GL_TRIANGLE_FAN
    glDrawArrays(GL_TRIANGLE_FAN, 0, 4);
}

/**
 用索引的方式来使用顶点数组
 */
- (void)renderSquareVertexDataUsingElement
{
    const GLfloat vertices[] =
    {
        -0.5f, -0.5f, 0.0f, // 左下角
        0.5f, -0.5f, 0.0f, // 右下角
        -0.5f, 0.5f, 0.0f,  // 左上角
        0.5f, 0.5f, 0.0f, // 右上角
    };
    
    GLint positionAttribution = glGetAttribLocation(_program, "position");
    glVertexAttribPointer(positionAttribution, 3, GL_FLOAT, GL_FALSE, 0, vertices);
    glEnableVertexAttribArray(positionAttribution);
    
    const GLfloat colors[] =
    {
        0,0,0,1, // 左下，黑色
        1,0,0,1, // 右下，红色
        0,0,1,1, // 左上，蓝色
        0,1,0,1, // 右上，绿色
    };
    
    GLint colorAttribution = glGetAttribLocation(_program, "color");
    glVertexAttribPointer(colorAttribution, 4, GL_FLOAT, GL_FALSE, 0, colors);
    glEnableVertexAttribArray(colorAttribution);
    

    const GLubyte indices[] =
    {
      0, 1, 2, // V0-V1-V2
      1, 2, 3, // V0-V2-V3
    };
    
    glDrawElements(GL_TRIANGLES, 6, GL_UNSIGNED_BYTE, indices);
}

/**
 VBO
 */
- (void)renderSquareVertexBufferData
{
    const GLfloat vertices[] =
    {
        // position          // color
        -0.5f, -0.5f, 0.0f,  0,0,0,1, // 左下，黑色
        0.5f, -0.5f, 0.0f,   1,0,0,1, // 右下，红色
        -0.5f, 0.5f, 0.0f,   0,0,1,1, // 左上，蓝色
        0.5f, 0.5f, 0.0f,    0,1,0,1, // 右上，绿色
    };
    
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);

    
    GLint positionAttribution = glGetAttribLocation(_program, "position");
    GLint colorAttribution = glGetAttribLocation(_program, "color");
    
    glVertexAttribPointer(positionAttribution, 3, GL_FLOAT, GL_FALSE, 7 * sizeof(GLfloat), 0);
    glEnableVertexAttribArray(positionAttribution);

    
    glVertexAttribPointer(colorAttribution, 4, GL_FLOAT, GL_FALSE, 7 * sizeof(GLfloat), (GLvoid *)(3  * sizeof(GLfloat)));
    glEnableVertexAttribArray(colorAttribution);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}

/**
 VAO
 */
- (void)renderSquareVertexArrayBufferData
{
    const GLfloat vertices[] =
    {
        // position          // color
        -0.5f, -0.5f, 0.0f,  0,0,0,1, // 左下，黑色
        0.5f, -0.5f, 0.0f,   1,0,0,1, // 右下，红色
        -0.5f, 0.5f, 0.0f,   0,0,1,1, // 左上，蓝色
        0.5f, 0.5f, 0.0f,    0,1,0,1, // 右上，绿色
    };
    
    GLuint VAO;
    glGenVertexArrays(1, &VAO);
    
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    // 复制顶点数组到缓冲区中使用
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    // 绑定 VAO
    glBindVertexArray(VAO);
    
    // 获取顶点着色器中的属性
    GLint positionAttribution = glGetAttribLocation(_program, "position");
    GLint colorAttribution = glGetAttribLocation(_program, "color");
    
    // 设置顶点属性配置
    glVertexAttribPointer(positionAttribution, 3, GL_FLOAT, GL_FALSE, 7 * sizeof(GLfloat), 0);
    glVertexAttribPointer(colorAttribution, 4, GL_FLOAT, GL_FALSE, 7 * sizeof(GLfloat), (GLvoid *)(3  * sizeof(GLfloat)));
    // 启用顶点属性
    glEnableVertexAttribArray(positionAttribution);
    glEnableVertexAttribArray(colorAttribution);
    
    // 解绑 VBO
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    // 绘制
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    // 解绑 VAO
    glBindVertexArray(0);
}

/**
 EBO 缓存方式
 */
- (void)renderSquareVertexElementBufferData
{
    // 顶点数组
    const GLfloat vertices[] =
    {
        // position          // color
        -0.5f, -0.5f, 0.0f,  0,0,0,1, // 左下，黑色
        0.5f, -0.5f, 0.0f,   1,0,0,1, // 右下，红色
        -0.5f, 0.5f, 0.0f,   0,0,1,1, // 左上，蓝色
        0.5f, 0.5f, 0.0f,    0,1,0,1, // 右上，绿色
    };
    
    // 索引数组
    const GLubyte indices[] =
    {
      0, 1, 2, // V0、V1、V2
      1, 2, 3 // V1、V2、V3
    };
    
    GLuint VBO;
    glGenBuffers(1, &VBO);
    glBindBuffer(GL_ARRAY_BUFFER, VBO);
    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    
    GLuint EBO;
    glGenBuffers(1, &EBO);
    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, EBO);
    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);
    
    GLint positionAttribution = glGetAttribLocation(_program, "position");
    GLint colorAttribution = glGetAttribLocation(_program, "color");
    
    glVertexAttribPointer(positionAttribution, 3, GL_FLOAT, GL_FALSE, 7 * sizeof(GLfloat), 0);
    glEnableVertexAttribArray(positionAttribution);

    
    glVertexAttribPointer(colorAttribution, 4, GL_FLOAT, GL_FALSE, 7 * sizeof(GLfloat), (GLvoid *)(3  * sizeof(GLfloat)));
    glEnableVertexAttribArray(colorAttribution);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glDrawElements(GL_TRIANGLE_STRIP, 6, GL_UNSIGNED_BYTE, 0);
}





@end
