function MyTriangle(scene, args) {
  CGFobject.call(this,scene);

  this.args=args;
  for(var i = 0; i < this.args.length; i++){
    this.args[i] = parseFloat(this.args[i]);
  }


  
  this.initBuffers(args);
};

MyTriangle.prototype = Object.create(CGFobject.prototype);
MyTriangle.prototype.constructor=MyTriangle;

/**
 * Initialithis.argses the MyTriangle buffers.
 *
 * @this {MyTriangle}
 */ 

 
MyTriangle.prototype.initBuffers = function () {

  
  this.a = Math.sqrt(Math.pow(this.args[0] - this.args[6], 2) + Math.pow(this.args[1] - this.args[7], 2) + Math.pow(this.args[2] - this.args[8], 2));
  this.b = Math.sqrt(Math.pow(this.args[3] - this.args[0], 2) + Math.pow(this.args[4] - this.args[1], 2) + Math.pow(this.args[5] - this.args[2], 2));
  this.c = Math.sqrt(Math.pow(this.args[6] - this.args[3], 2) + Math.pow(this.args[7] - this.args[4], 2) + Math.pow(this.args[8] - this.args[5], 2));
  
  this.cos_a = Math.cos((- Math.pow(this.a, 2) + Math.pow(this.b, 2) + Math.pow(this.c, 2))/(2 * this.b * this.c));
  this.cos_b = Math.cos((Math.pow(this.a, 2) - Math.pow(this.b, 2) + Math.pow(this.c, 2))/(2 * this.b * this.c));
  this.cos_c = Math.cos((Math.pow(this.a, 2) + Math.pow(this.b, 2) - Math.pow(this.c, 2))/(2 * this.b * this.c));
  this.sin_b = Math.sqrt(1 - Math.pow(this.cos_b, 2));

  this.vertices = [
            this.args[0], this.args[1], this.args[2],
            this.args[3], this.args[4], this.args[5],
            this.args[6], this.args[7], this.args[8],
      ];

  this.indices = [
            0, 1, 2
        ];

    this.normals = [
        0, 1, 0,
        0, 1, 0,
        0, 1, 0
      ];


  this.texCoords = [
      0, 0,
      0, 1,
      1, 1
    ];

  this.primitiveType=this.scene.gl.TRIANGLES;
  this.initGLBuffers();
};

/**
* Scales the texture bound on MyTriangle. Overrides the same function in MyGraphLeaf.
*
* @this {MyTriangle}
* @param {number} ampS Amplification factor on the S coordinate in the ST coordinate system.
* @param {number} ampT Amplification factor on the T coordinate in the ST coordinate system.
*/

MyTriangle.prototype.updateTexCoords = function(ampS, ampT){
  this.texCoords = [
      /*(this.c - this.a * this.cos_b)/ampS, (1 - this.a * this.sin_b)/ampT,
      0, 1,
      this.c/ampS, 1*/ 
      0, 1,
      this.c/ampS, 1,
      (this.c - this.a * this.cos_b)/ampS, (1 - this.a * this.sin_b)/(ampT)
    ];
  this.updateTexCoordsGLBuffers();
}
