/**
 * MyRectangle
 * @constructor
 */
function MyRect(scene, ltX, ltY, rbX, rbY) {
    CGFobject.call(this, scene);
    

    this.ltX = ltX;
    this.ltY = ltY;
    this.rbX = rbX;
    this.rbY = rbY;
    
    this.initBuffers();
}
;


MyRect.prototype = Object.create(CGFobject.prototype);
MyRect.prototype.constructor = MyRect;

MyRect.prototype.initBuffers = function() {
    this.vertices = [
    this.ltX, this.rbY, 0, 
    this.rbX, this.rbY, 0, 
    this.ltX, this.ltY, 0, 
    this.rbX, this.ltY, 0
    ];
    
    this.texCoords = [];
    
    this.indices = [
    0, 1, 2, 
    3, 2, 1
    ];
    
    this.primitiveType = this.scene.gl.TRIANGLES;
    
    this.normals = [
    0, 0, 1, 
    0, 0, 1, 
    0, 0, 1, 
    0, 0, 1
    ];
    
    this.initGLBuffers();
}
;

MyRect.prototype.updateTexCoords = function(s, t) {
    
    this.ampS = s;
    this.ampT = t;
    
    this.texCoords = [
    0, (this.ltY - this.rbY) / this.ampT, (this.rbX - this.ltX) / this.ampS, 
    (this.ltY - this.rbY) / this.ampT, 0, 0, 
    (this.rbX - this.ltX) / this.ampS, 0
    ];
    
    this.setTex = true;
    
    this.updateTexCoordsGLBuffers();
}
;
