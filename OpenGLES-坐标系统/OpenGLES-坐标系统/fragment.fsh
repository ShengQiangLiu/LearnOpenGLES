
precision mediump float;
uniform sampler2D textureImage;
uniform sampler2D textureImage2;
varying vec2 vTextureCoordinate;

void main()
{
    gl_FragColor = mix(texture2D(textureImage, vTextureCoordinate), texture2D(textureImage2, vTextureCoordinate), 0.2);
}

