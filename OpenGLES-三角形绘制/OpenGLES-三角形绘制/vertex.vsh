
attribute vec3 position; // attribute 修饰符描述只能用于 Vertex Shader，不能用于 Fragment Shader
attribute vec3 color;

varying vec3 outColor; // varying 修饰符描述用于从 Vertex Shader 传递到 Fragment Shader 的变量

void main()
{
    gl_Position = vec4(position, 1.0); // Vertex Shader 内建变量，表示变化后点的空间位置。顶点着色器从应用程序中获得原始的顶点位置数据，这些原始的顶点数据在顶点着色器中经过平移、旋转、缩放等数学变换后，生成新的顶点位置。新的顶点位置通过在顶点着色器中写入gl_Position传递到渲染管线的后继阶段继续处理。
    outColor = color;
}
