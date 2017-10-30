
precision mediump float; // precision 精度修饰符，用于确定默认精度修饰符。(highp, mediump, lowp) -> (高、中、低) 精度
varying vec3 outColor;

void main()
{
    gl_FragColor = vec4(outColor, 1.0); // Fragment Shader 内置变量，用来保存 Fragment Shader 计算完成的片段颜色值，此颜色值将送入渲染管线的后继阶段进行处理。
}
