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

#include "Glm/glm.hpp"

@interface MTEAGLView ()
{
    GLuint _frameBuffer, _colorRenderBuffer;
    GLuint _pointVBO, _colorVBO, _EBO;
    GLuint _program;
    GLuint _texture, _texture2;
}

@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) CAEAGLLayer *eaglLayer;
@property (nonatomic, strong) UIImage *textureImage;
@property (nonatomic, strong) UIImage *textureImage2;

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

        self.textureImage = [UIImage imageNamed:@"Logo.png"];
        self.textureImage2 = [UIImage imageNamed:@"Timg.jpeg"];
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

    [self setupTextureWithImage:self.textureImage textures:_texture];
    [self setupTextureWithImage:self.textureImage2 textures:_texture2];
    [self renderSquareVertexElementBufferData];
    
    [self.context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)renderSquareVertexElementBufferData
{
    // 顶点数组
    const GLfloat vertices[] =
    {
        // position          // texture Coordinate
        -0.9f, -0.9f, 0.0f,  0,0, // 左下
        0.9f, -0.9f, 0.0f,   1,0, // 右下
        -0.9f, 0.9f, 0.0f,   0,1, // 左上
        0.9f, 0.9f, 0.0f,    1,1, // 右上
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
    GLint textureCoordinateAttribution = glGetAttribLocation(_program, "textureCoordinate");
    
    glVertexAttribPointer(positionAttribution, 3, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), 0);
    glEnableVertexAttribArray(positionAttribution);

    
    glVertexAttribPointer(textureCoordinateAttribution, 2, GL_FLOAT, GL_FALSE, 5 * sizeof(GLfloat), (GLvoid *)(3  * sizeof(GLfloat)));
    glEnableVertexAttribArray(textureCoordinateAttribution);
    
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    glDrawElements(GL_TRIANGLE_STRIP, 6, GL_UNSIGNED_BYTE, 0);
}

- (void)setupTextureWithImage:(UIImage *)image textures:(GLuint)texture;
{
    CGImageRef cgImageRef = image.CGImage;
    GLuint width = (GLuint)CGImageGetWidth(cgImageRef);
    GLuint height = (GLuint)CGImageGetHeight(cgImageRef);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    void *imageData = malloc(width * height * 4);
    CGContextRef context = CGBitmapContextCreate(imageData,
                                                 width,
                                                 height,
                                                 8,
                                                 width * 4,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
    CGColorSpaceRelease(colorSpace);
    CGContextClearRect(context, rect);
    CGContextDrawImage(context, rect, cgImageRef);
    
    // 生成纹理
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    
    // 环绕方式
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    // 线性过滤
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
//    glGenerateMipmap(GL_TEXTURE_2D);

    CGContextRelease(context);
    free(imageData);
    
    // 激活纹理
    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, texture);
    GLint imageUniform = glGetUniformLocation(_program, "textureImage");
    glUniform1i(imageUniform, 0);

}



@end
