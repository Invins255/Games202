class PRTMaterial extends Material {
    constructor(color, vertexShader, fragmentShader) {
        super({
            'uSampler':{type:'texture',value:color},
            'uPrecomputeLR':{type:'updatedInRealTime',value:null},
            'uPrecomputeLG':{type:'updatedInRealTime',value:null},
            'uPrecomputeLB':{type:'updatedInRealTime',value:null},
        }, ['aPrecomputeLT'], vertexShader, fragmentShader, null);
    }
}


async function buildPRTMaterial(color, vertexPath, fragmentPath) {

    let vertexShader = await getShaderString(vertexPath);
    let fragmentShader = await getShaderString(fragmentPath);

    return new PRTMaterial(color, vertexShader, fragmentShader);

}