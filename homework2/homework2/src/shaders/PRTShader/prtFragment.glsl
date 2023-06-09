#ifdef GL_ES
precision mediump float;
#endif

uniform mat3 uPrecomputeLR;
uniform mat3 uPrecomputeLG;
uniform mat3 uPrecomputeLB;
uniform sampler2D uSampler;

varying highp vec2 vTextureCoord;
varying highp mat3 vPrecomputeLT;

void main(void){
    vec3 color = texture2D(uSampler, vTextureCoord).rgb;
    //color = pow(color, vec3(2.2));

    vec3 result = 
        vec3(uPrecomputeLR[0][0],uPrecomputeLG[0][0],uPrecomputeLB[0][0]) * vPrecomputeLT[0][0] + 
        vec3(uPrecomputeLR[0][1],uPrecomputeLG[0][1],uPrecomputeLB[0][1]) * vPrecomputeLT[0][1] + 
        vec3(uPrecomputeLR[0][2],uPrecomputeLG[0][2],uPrecomputeLB[0][2]) * vPrecomputeLT[0][2] + 
        vec3(uPrecomputeLR[1][0],uPrecomputeLG[1][0],uPrecomputeLB[1][0]) * vPrecomputeLT[1][0] + 
        vec3(uPrecomputeLR[1][1],uPrecomputeLG[1][1],uPrecomputeLB[1][1]) * vPrecomputeLT[1][1] + 
        vec3(uPrecomputeLR[1][2],uPrecomputeLG[1][2],uPrecomputeLB[1][2]) * vPrecomputeLT[1][2] + 
        vec3(uPrecomputeLR[2][0],uPrecomputeLG[2][0],uPrecomputeLB[2][0]) * vPrecomputeLT[2][0] + 
        vec3(uPrecomputeLR[2][1],uPrecomputeLG[2][1],uPrecomputeLB[2][1]) * vPrecomputeLT[2][1] + 
        vec3(uPrecomputeLR[2][2],uPrecomputeLG[2][2],uPrecomputeLB[2][2]) * vPrecomputeLT[2][2];
        
    color = result * color;
    //color = pow(result * color, vec3(0.45));
    gl_FragColor = vec4(color,1.0);
}

