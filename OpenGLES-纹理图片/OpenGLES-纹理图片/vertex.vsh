
attribute vec3 position;
attribute vec2 textureCoordinate;

varying vec2 vTextureCoordinate;

void main()
{
    gl_Position = vec4(position, 1.0);
    vTextureCoordinate = textureCoordinate;
}
