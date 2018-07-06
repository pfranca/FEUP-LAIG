/**
 * Creates an instance of MyRectangle
 * 
 * @constructor
 * @this {MyRectangle}
 * @param {CGFScene} scene Scene to place this object in.
 * @param {Array} args Array containing the information needed to draw a MyRectangle. 
 */
/**
 * Creates an instance of MyRectangle
 * 
 * @constructor
 * @this {MyRectangle}
 * @param {CGFScene} scene Scene to place this object in.
 * @param {Array} args Array containing the information needed to draw a MyRectangle. 
 */
function MyRectangle(scene, args) { //first 2 args: coordinates of top left vertex
	CGFobject.call(this,scene);		  //second 2 args: coordinates of bottom right vertex
	this.args = args;

    this.minS = 0;
    this.maxS = 1;
    this.minT = 0;
    this.maxT = 1;
	
	this.initBuffers(args);
};

MyRectangle.prototype = Object.create(CGFobject.prototype);
MyRectangle.prototype.constructor=MyRectangle;

 /**
 * Initializes the MyRectangle buffers.
 *
 * @this {MyRectangle}
 */
MyRectangle.prototype.initBuffers = function () {

	
	this.dx = this.args[2] - this.args[0];
	this.dy = this.args[1] - this.args[3];

	this.vertices = [
            this.args[0], this.args[3], 0, //1
            this.args[2], this.args[3], 0,  //2
            this.args[0], this.args[1], 0,  //3
            this.args[2], this.args[1], 0   //4
			];

	this.indices = [
            0, 1, 2, 
			3, 2, 1
        ];

    this.normals = [
			0, 0, 1,
			0, 0, 1,
			0, 0, 1,
			0, 0, 1
    	];

    this.texCoords = [
		this.args[0], this.args[3], //1
        this.args[2], this.args[3],  //2
        this.args[0], this.args[1],  //3
        this.args[2], this.args[1]
    ];
		
	this.primitiveType=this.scene.gl.TRIANGLES;
	this.initGLBuffers();
};

/**
* Scales the texture bound on MyRectangle. Overrides the same function in MyGraphLeaf.
*
* @this {MyRectangle}
* @param {number} ampS Amplification factor on the S coordinate in the ST coordinate system.
* @param {number} ampT Amplification factor on the T coordinate in the ST coordinate system.
*/
MyRectangle.prototype.updateTexCoords = function(ampS, ampT){
	this.texCoords = [    
		/*0, 0,
		this.dx/ampS, 0,
		0, this.dy/ampT,
		this.dx/ampS, this.dy/ampT*/
		this.dx/ampS, this.dy/ampT,
		0, this.dy/ampT,
		this.dx/ampS, 0,
		0, 0
    ];
	this.updateTexCoordsGLBuffers();
}


/*
	
	3____________________4
	I					I
	I					I
	I		 0, 0		I
	I					I
	I					I
	_____________________
	1					2





*/