

#include "MTGLProgram.h"
#include <stdlib.h>
#include <string.h>

long GetFileContent(char *buffer, long len, const char *filePath)
{
    FILE *file = fopen(filePath, "rb");
    if (file == NULL)
    {
        return -1;
    }
    
    fseek(file, 0, SEEK_END);
    long size = ftell(file);
    rewind(file);
    
    if (len < size)
    {
        MTGLlog("File is large than the size(%ld) you give\n", len);
        return -1;
    }
    
    fread(buffer, 1, size, file);
    buffer[size] = '\0';
    
    fclose(file);
    
    return size;
}

static GLuint CreateGLShader(const char *shaderString, GLenum shaderType)
{
    GLuint shader = glCreateShader(shaderType);
    glShaderSource(shader, 1, &shaderString, NULL);
    glCompileShader(shader);
    
    int complied = 0;
    glGetShaderiv(shader, GL_COMPILE_STATUS, &complied);
    if (!complied)
    {
        GLint infoLen = 0;
        glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 1)
        {
            char *infoLog = (char *)malloc(sizeof(char) * infoLen);
            if (infoLog)
            {
                glGetShaderInfoLog(shader, infoLen, NULL, infoLog);
                MTGLlog("Error comiling shader: %s\n", infoLog);
                free(infoLog);
            }
        }
        glDeleteShader(shader);
        return 0;
    }
    return shader;
}

/**
 着色器运行过程
 1、编译
 2、链接
 */
GLuint CreateGLProgram(const char *vertex, const char *fragment)
{
    GLuint program = glCreateProgram();
    
    GLuint vertexShader = CreateGLShader(vertex, GL_VERTEX_SHADER);
    GLuint fragmentShader = CreateGLShader(fragment, GL_FRAGMENT_SHADER);
    
    if (vertexShader == 0 || fragmentShader == 0)
    {
        return 0;
    }
    
    glAttachShader(program, vertexShader);
    glAttachShader(program, fragmentShader);
    
    glLinkProgram(program);
    GLint success;
    glGetProgramiv(program, GL_LINK_STATUS, &success);
    if (!success)
    {
        GLint infoLen;
        glGetProgramiv(program, GL_INFO_LOG_LENGTH, &infoLen);
        if (infoLen > 1)
        {
            GLchar *infoText = (GLchar *)malloc(sizeof(GLchar)*infoLen + 1);
            if (infoText)
            {
                memset(infoText, 0x00, sizeof(GLchar)*infoLen + 1);
                glGetProgramInfoLog(program, infoLen, NULL, infoText);
                MTGLlog("%s", infoText);
                free(infoText);
            }
        }
        glDeleteShader(vertexShader);
        glDeleteShader(fragmentShader);
        glDeleteProgram(program);
        return 0;
    }
    glDetachShader(program, vertexShader);
    glDetachShader(program, fragmentShader);
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    return program;
}

GLuint CreateGLProgramFromFile(const char *vertexPath, const char *fragmentPath)
{
    char vBuffer[2048] = {0};
    char fBuffer[2048] = {0};
    
    if (GetFileContent(vBuffer, sizeof(vBuffer), vertexPath) < 0)
    {
        return 0;
    }
    if (GetFileContent(fBuffer, sizeof(fBuffer), fragmentPath) < 0)
    {
        return 0;
    }
    return CreateGLProgram(vBuffer, fBuffer);
}

void UseProgram(GLuint program)
{
    glUseProgram(program);
}

GLuint CreateVBO(GLenum target, GLenum usage, GLsizeiptr dataSize, const GLvoid*data)
{
    GLuint vbo;
    glGenBuffers(1, &vbo);
    glBindBuffer(target, vbo);
    glBufferData(target, dataSize, data, usage);
    return vbo;
}


