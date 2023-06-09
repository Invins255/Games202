function getRotationPrecomputeL(precompute_L, rotationMatrix){
	let rotMat = mat4Matrix2mathMatrix(rotationMatrix)
	let rotMatBand1 = computeSquareMatrix_3by3(rotMat);
	let rotMatBand2 = computeSquareMatrix_5by5(rotMat);

	let result = [];

	
	for(let i=0; i<3; i++){

		//band1旋转
		let rotSHBand1 = math.multiply(rotMatBand1, [precompute_L[i][1],precompute_L[i][2],precompute_L[i][3]]);	
		//band2旋转
		let rotSHBand2 = math.multiply(rotMatBand2, [precompute_L[i][4],precompute_L[i][5],precompute_L[i][6],precompute_L[i][7],precompute_L[i][8]]);
	/*	
		result.push([precompute_L[i][0], rotSHBand1[0], rotSHBand1[1],
					 rotSHBand1[2],	 rotSHBand2[0], rotSHBand2[1],
					 rotSHBand1[2],	 rotSHBand1[3], rotSHBand1[4]]);
	*/
	}
	

	return result;
}

function computeSquareMatrix_3by3(rotationMatrix){ // 计算方阵SA(-1) 3*3 
	
	// 1、pick ni - {ni}
	let n1 = [1, 0, 0, 0]; let n2 = [0, 0, 1, 0]; let n3 = [0, 1, 0, 0];

	// 2、{P(ni)} - A  A_inverse
	let Pn1 = SHEval(n1[0],n1[1],n1[2],3);
	let Pn2 = SHEval(n2[0],n2[1],n2[2],3);
	let Pn3 = SHEval(n3[0],n3[1],n3[2],3);
	let A = math.matrix([[Pn1[1],Pn2[1],Pn3[1]],
						 [Pn1[2],Pn2[2],Pn3[2]],
						 [Pn1[3],Pn2[3],Pn3[3]]]);
	let A_inv = math.inv(A);

	// 3、用 R 旋转 ni - {R(ni)}
	let rn1 = math.multiply(rotationMatrix,n1);
	let rn2 = math.multiply(rotationMatrix,n2);
	let rn3 = math.multiply(rotationMatrix,n3);

	// 4、R(ni) SH投影 - S
	let Prn1 = SHEval(rn1[0],rn1[1],rn1[2],3);
	let Prn2 = SHEval(rn2[0],rn2[1],rn2[2],3);
	let Prn3 = SHEval(rn3[0],rn3[1],rn3[2],3);
	let S = math.matrix([[Prn1[1],Prn2[1],Prn3[1]],
						 [Prn1[2],Prn2[2],Prn3[2]],
						 [Prn1[3],Prn2[3],Prn3[3]]]);
	// 5、S*A_inverse
	return math.transpose(math.multiply(S._data, A_inv._data));
}

function computeSquareMatrix_5by5(rotationMatrix){ // 计算方阵SA(-1) 5*5
	
	// 1、pick ni - {ni}
	let k = 1 / math.sqrt(2);
	let n1 = [1, 0, 0, 0]; let n2 = [0, 0, 1, 0]; let n3 = [k, k, 0, 0]; 
	let n4 = [k, 0, k, 0]; let n5 = [0, k, k, 0];

	// 2、{P(ni)} - A  A_inverse
	let Pn1 = SHEval(n1[0],n1[1],n1[2],5);
	let Pn2 = SHEval(n2[0],n2[1],n2[2],5);
	let Pn3 = SHEval(n3[0],n3[1],n3[2],5);
	let Pn4 = SHEval(n4[0],n4[1],n4[2],5);
	let Pn5 = SHEval(n5[0],n5[1],n5[2],5);
	let A = math.matrix([[Pn1[4],Pn2[4],Pn3[4],Pn4[4],Pn5[4]],
						 [Pn1[5],Pn2[5],Pn3[5],Pn4[5],Pn5[5]],
						 [Pn1[6],Pn2[6],Pn3[6],Pn4[6],Pn5[6]],
						 [Pn1[7],Pn2[7],Pn3[7],Pn4[7],Pn5[7]],
						 [Pn1[8],Pn2[8],Pn3[8],Pn4[8],Pn5[8]]
						]);
	let A_inv = math.inv(A);
	// 3、用 R 旋转 ni - {R(ni)}
	let rn1 = math.multiply(rotationMatrix,n1);
	let rn2 = math.multiply(rotationMatrix,n2);
	let rn3 = math.multiply(rotationMatrix,n3);
	let rn4 = math.multiply(rotationMatrix,n4);
	let rn5 = math.multiply(rotationMatrix,n5);

	// 4、R(ni) SH投影 - S
	let Prn1 = SHEval(rn1[0],rn1[1],rn1[2],5);
	let Prn2 = SHEval(rn2[0],rn2[1],rn2[2],5);
	let Prn3 = SHEval(rn3[0],rn3[1],rn3[2],5);
	let Prn4 = SHEval(rn4[0],rn4[1],rn4[2],5);	
	let Prn5 = SHEval(rn5[0],rn5[1],rn5[2],5);
	let S = math.matrix([[Prn1[4],Prn2[4],Prn3[4],Prn4[4],Prn5[4]],
						 [Prn1[5],Prn2[5],Prn3[5],Prn4[5],Prn5[5]],
						 [Prn1[6],Prn2[6],Prn3[6],Prn4[6],Prn5[6]],
						 [Prn1[7],Prn2[7],Prn3[7],Prn4[7],Prn5[7]],
						 [Prn1[8],Prn2[8],Prn3[8],Prn4[8],Prn5[8]]
						]);

	// 5、S*A_inverse
	return math.transpose(math.multiply(S._data, A_inv._data));

}

function mat4Matrix2mathMatrix(rotationMatrix){

	let mathMatrix = [];
	for(let i = 0; i < 4; i++){
		let r = [];
		for(let j = 0; j < 4; j++){
			r.push(rotationMatrix[i*4+j]);
		}
		mathMatrix.push(r);
	}
	return math.matrix(mathMatrix)

}

function getMat3ValueFromRGB(precomputeL){

    let colorMat3 = [];
    for(var i = 0; i<3; i++){
        colorMat3[i] = mat3.fromValues( precomputeL[0][i], precomputeL[1][i], precomputeL[2][i],
										precomputeL[3][i], precomputeL[4][i], precomputeL[5][i],
										precomputeL[6][i], precomputeL[7][i], precomputeL[8][i] ); 
	}
    return colorMat3;
}