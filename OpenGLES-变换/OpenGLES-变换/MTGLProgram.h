
#ifndef MTGLProgram_h
#define MTGLProgram_h

#ifdef __cplusplus
extern "C" {
#endif

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <stdio.h>

#define MTGLlog(format,...)           printf(format,__VA_ARGS__)

/**
 创建着色器程序

 @param vertex Vertex Shader
 @param fragment Fragment Shader
 @return 着色器程序 ID
 */
GLuint CreateGLProgram(const char *vertex, const char *fragment);

/**
 创建着色器程序

 @param vertexPath Vertex Shader Path
 @param fragment Fragment Shader Path
 @return 着色器程序 ID
 */
GLuint CreateGLProgramFromFile(const char *vertexPath, const char *fragment);

/**
 使用着色器程序

 @param program 着色程序 ID
 */
void UseProgram(GLuint program);

/**
 创建 VBO 对象

 @param target GL_ARRAY_BUFFER, GL_ELEMENT_ARRAY_BUFFER
 @param usage GL_STATIC_DRAW, GL_DYNAMIC_DRAW, GL_STREAM_DRAW
 @param dataSize data length
 @param data data ptr
 @return VBO ID
 */
GLuint CreateVBO(GLenum target, GLenum usage, GLsizeiptr dataSize, const GLvoid*data);

/**
 获取文件的内容

 @param buffer buffer to receive file data
 @param len buffer alloc size
 @param filePath file path
 @return the size of file content
 */
long GetFileContent(char *buffer, long len, const char *filePath);
    
#ifdef __cplusplus
}
#endif

#endif /* MTGLProgram_h */
