attribute vec3 aVertexPosition;
attribute vec2 aTextureCoord;
attribute mat3 aPrecomputeLT;

uniform mat4 uModelMatrix;
uniform mat4 uViewMatrix;
uniform mat4 uProjectionMatrix;
uniform sampler2D uSampler;

varying highp vec2 vTextureCoord;
varying highp mat3 vPrecomputeLT;

void main(void){
    gl_Position = uProjectionMatrix * uViewMatrix * uModelMatrix * vec4(aVertexPosition, 1.0);
    vTextureCoord = aTextureCoord;
    vPrecomputeLT = aPrecomputeLT;
}