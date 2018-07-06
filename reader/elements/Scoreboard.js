/**
 * Scoreboard
 * @constructor
 */
function Scoreboard(scene, matWOOD, fontText) {
 	CGFobject.call(this,scene);
	
 	this.scene=scene;
 	this.matWOOD=matWOOD;

	this.sideTB = new MyRect(scene,-3,0.5,3,-0.5);
	this.sideTB.updateTexCoords(1,1);
	this.sideLR = new MyRect(scene,-1.75,0.5,1.75,-0.5);
	this.sideLR.updateTexCoords(1,1);
	this.borderTB = new MyRect(scene,-3,0.5,3,-0.5);
	this.borderTB.updateTexCoords(1,1);
	this.borderLR = new MyRect(scene,-0.75,0.25,0.75,-0.25);
	this.borderLR.updateTexCoords(1,1);
	this.bottom = new MyRect(scene,-3,1.75,3,-1.75);
	this.bottom.updateTexCoords(1,1);

	this.rec = new MyRect(scene, -0.5, 1, 0.5, -1);
	this.rec.updateTexCoords(1,2);

	this.appearance = scene.defaultApp;
	this.fontText = fontText;

	this.counterW=0;
	this.counterB=0;
};

Scoreboard.prototype = Object.create(CGFobject.prototype);
Scoreboard.prototype.constructor = Scoreboard;

Scoreboard.prototype.display = function () {

	this.scene.pushMatrix();

		this.scene.rotate(90*DEGREE_TO_RAD,1,0,0);

 		//TEXT
 		this.appearance.setTexture(this.fontText);
 		this.displayScore();

 	this.scene.popMatrix();
};

Scoreboard.prototype.displayScore = function () {
	
	this.scene.pushMatrix();
		this.scene.setActiveShaderSimple(this.scene.textShader);
		this.appearance.apply();

		var decW = Math.floor(this.counterW/10);
		var uniW = this.counterW%10;

		var decB = Math.floor(this.counterB/10);
		var uniB = this.counterB%10;

		this.scene.rotate(90*DEGREE_TO_RAD,0,0,1);
		this.scene.translate(0,-0.2,0.25);


		this.scene.activeShader.setUniformsValues({'charCoords': [decB,5]});
		this.scene.pushMatrix();
			this.scene.translate(-4,16.35,0);
			this.scene.rotate(90*DEGREE_TO_RAD,1,0,0);
			this.rec.display();
		this.scene.popMatrix();

		this.scene.activeShader.setUniformsValues({'charCoords': [uniB,5]});
		this.scene.pushMatrix();
			this.scene.translate(-5,16.35,0);
			this.scene.rotate(90*DEGREE_TO_RAD,1,0,0);
			this.rec.display();
		this.scene.popMatrix();

		this.scene.activeShader.setUniformsValues({'charCoords': [1,4]});
		this.scene.pushMatrix();
			this.scene.translate(-3,16.35,0);
			this.scene.rotate(90*DEGREE_TO_RAD,1,0,0);
			this.rec.display();
		this.scene.popMatrix();

		this.scene.activeShader.setUniformsValues({'charCoords': [decW,5]});
		this.scene.pushMatrix();
			this.scene.translate(-1,16.35,0);
			this.scene.rotate(90*DEGREE_TO_RAD,1,0,0);
			this.rec.display();
		this.scene.popMatrix();

		this.scene.activeShader.setUniformsValues({'charCoords': [uniW,5]});
		this.scene.pushMatrix();
			this.scene.translate(-2,16.35,0);
			this.scene.rotate(90*DEGREE_TO_RAD,1,0,0);
			this.rec.display();
		this.scene.popMatrix();

		this.scene.setActiveShaderSimple(this.scene.defaultShader);
	this.scene.popMatrix();
};

Scoreboard.prototype.setMatWOOD = function (mat) {

	this.matWOOD = mat;
};

Scoreboard.prototype.setFont = function (font) {

	this.fontText = font;
	this.appearance.setTexture(font);
};

Scoreboard.prototype.setCounters = function (w,b) {

	this.counterW=w;
	this.counterB=b;
};