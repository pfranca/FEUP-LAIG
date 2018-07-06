var DEGREE_TO_RAD = Math.PI / 180;

/**
 * XMLscene class, representing the scene that is to be rendered.
 * @constructor
 */
function XMLscene(interfac) {
    CGFscene.call(this);

    this.interfac = interfac;

    this.lightValues = {};
    this.currentSelectable = "None";
    this.currentShader = "Blue and Stretch";
    this.lastTime = 0;
    this.shaders = new Array();
    this.shadersRefs = new Array();
    let currentDate = new Date();
    this.initialTime = currentDate.getTime();


}
XMLscene.prototype = Object.create(CGFscene.prototype);
XMLscene.prototype.constructor = XMLscene;

/**
 * Initializes the scene, setting some WebGL defaults, initializing the camera and the axis.
 */
XMLscene.prototype.init = function(application) {

    newGame(this.getGame.bind(this));
    CGFscene.prototype.init.call(this, application);

    //shaders

    this.shaders["Blue and Stretch"] = new CGFshader(this.gl, "shaders/shader.vert", "shaders/shader.frag");
    this.shadersRefs.push("Blue and Stretch");
    this.shaders["Blue and Stretch"].setUniformsValues({Red: 0.0, Green: 0.0, Blue: 1.0});

    this.shaders["Pink and Stretch"] = new CGFshader(this.gl, "shaders/shader.vert", "shaders/shader.frag");
    this.shadersRefs.push("Pink and Stretch");
    this.shaders["Pink and Stretch"].setUniformsValues({Red: 1.0, Green: 0.15, Blue: 0.6});
    this.updateScalingFactor();

    //Shaders
    this.myShader = new CGFshader(this.gl, dir_shaders+"myshader.vert", dir_shaders+"myshader.frag");
    this.myShader.setUniformsValues({normScale: 0.05});
    this.myShader.setUniformsValues({uSampler2: 1});

    this.textShader=new CGFshader(this.gl, dir_shaders+"font.vert", dir_shaders+"font.frag");
    this.textShader.setUniformsValues({'dims': [10, 6]});

    this.defaultApp = new CGFappearance(this);
    this.defaultApp.setAmbient(0.9, 0.9, 0.9, 1);
    this.defaultApp.setDiffuse(0.7, 0.7, 0.7, 1);
    this.defaultApp.setSpecular(0.0, 0.0, 0.0, 1);  
    this.defaultApp.setShininess(120);


    //inicia as cameras
    this.initCameras();

    this.enableTextures(true);

    this.gl.clearDepth(100.0);
    this.gl.enable(this.gl.DEPTH_TEST);
    this.gl.enable(this.gl.CULL_FACE);
    this.gl.depthFunc(this.gl.LEQUAL);

    this.axis = new CGFaxis(this);

    //skins
    this.skin=1;

        //film
    this.film_playing = false;
    this.film_delay = 2;
    this.counter = 0;

    this.currTex = null;
    this.currMat = null;

    this.primitives = [];
    this.animations = [];
    this.setUpdatePeriod(16);
    //Picking
    this.setPickEnabled(true);
    this.pickedPiece = null;
    this.pickedPosition = null;

}

/**
 * Initializes the scene lights with the values read from the LSX file.
 */
XMLscene.prototype.initLights = function() {
    var i = 0;
    // Lights index.

    // Reads the lights from the scene graph.
    for (var key in this.graph.lights) {
        if (i >= 8)
            break;              // Only eight lights allowed by WebGL.

        if (this.graph.lights.hasOwnProperty(key)) {
            var light = this.graph.lights[key];

            this.lights[i].setPosition(light[1][0], light[1][1], light[1][2], light[1][3]);
            this.lights[i].setAmbient(light[2][0], light[2][1], light[2][2], light[2][3]);
            this.lights[i].setDiffuse(light[3][0], light[3][1], light[3][2], light[3][3]);
            this.lights[i].setSpecular(light[4][0], light[4][1], light[4][2], light[4][3]);

            this.lights[i].setVisible(true);
            if (light[0])
                this.lights[i].enable();
            else
                this.lights[i].disable();

            this.lights[i].update();

            i++;
        }
    }

}

/**
 * Initializes the scene cameras.
 */
XMLscene.prototype.initCameras = function() {
    this.camera = new CGFcamera(0.4,0.1,500,vec3.fromValues(15, 15, 15),vec3.fromValues(0, 0, 0));
}

/* Handler called when the graph is finally loaded.
 * As loading is asynchronous, this may be called already after the application has started the run loop
 */
XMLscene.prototype.onGraphLoaded = function()
{
    this.camera.near = this.graph.near;
    this.camera.far = this.graph.far;
    this.axis = new CGFaxis(this,this.graph.referenceLength);

    this.setGlobalAmbientLight(this.graph.ambientIllumination[0], this.graph.ambientIllumination[1],
    this.graph.ambientIllumination[2], this.graph.ambientIllumination[3]);

    this.gl.clearColor(this.graph.background[0], this.graph.background[1], this.graph.background[2], this.graph.background[3]);
    this.initCameras();
    this.initLights();
    this.initMaterials();

    // Adds lights group.
    this.interfac.addLightsGroup(this.graph.lights);
    this.interfac.addNodesDropdown(this.graph.selectableNodes);
    this.interfac.addShadersDropdown(this.shadersRefs);
    //newGame(this.getGame.bind(this));
    this.createElements();
    this.createPieces();
   
}

XMLscene.prototype.getGame = function(data){
    this.game=JSON.parse(data.target.response);

    this.board = this.game[0];
    this.player = this.game[2];    
    console.log('GAME');
    console.log(this.game);
 }

 XMLscene.prototype.getMoves = function(data){
    this.moves=JSON.parse(data.target.response);
    for(var i = 0; i< this.moves.length;i++){
        this.moves[i][0] += 1;
        this.moves[i][1] += 1;
    }
    getPrologRequest('clearMoves','Ok');

    console.log('Possible Moves:');
    console.log(this.moves);
 }



XMLscene.prototype.createElements = function() 
 {
    //GAMEBOARD   
    this.timer = new Timer(this.graph.scene,this.matWOODBRIGHT,this.fontWHITE);
    this.scoreboard = new Scoreboard(this.graph.scene,this.matWOODBRIGHT,this.fontWHITE);
    this.boardTable = new Board(this.graph.scene, this.graph.materials['defaultMaterial'], this.graph.materials['defaultMaterial'], this.graph.textures['board1'], this.graph.textures['board2']);
     console.log("Board Created");
    }

XMLscene.prototype.createPieces = function()
{
    //Pieces

    this.pieces = new Pieces(this.graph.scene,[this.board,this.graph.materials['blackPiece'],this.graph.materials['whitePiece']]);
    console.log('Pieces Created');

}



/**
 * Displays the scene.
 */
XMLscene.prototype.display = function() {
    // ---- BEGIN Background, camera and axis setup

    //Picking
    this.logPicking();
    this.clearPickRegistration();

    // Clear image and depth buffer everytime we update the scene
    this.gl.viewport(0, 0, this.gl.canvas.width, this.gl.canvas.height);
    this.gl.clear(this.gl.COLOR_BUFFER_BIT | this.gl.DEPTH_BUFFER_BIT);

    // Initialize Model-View matrix as identity (no transformation
    this.updateProjectionMatrix();
    this.loadIdentity();

    // Apply transformations corresponding to the camera position relative to the origin
    this.applyViewMatrix();

    this.pushMatrix();

    if (this.graph.loadedOk)
    {
        // Applies initial transformations.
        this.multMatrix(this.graph.initialTransforms);

		// Draw axis
		this.axis.display();


        var i = 0;
        for (var key in this.lightValues) {
            if (this.lightValues.hasOwnProperty(key)) {
                if (this.lightValues[key]) {
                    this.lights[i].setVisible(true);
                    this.lights[i].enable();
                }
                else {
                    this.lights[i].setVisible(false);
                    this.lights[i].disable();
                }
                this.lights[i].update();
                i++;
            }
        }
        
        
         //this.rotate(180*DEGREE_TO_RAD ,0,1,0);


        this.graph.scene.pushMatrix();

        this.graph.scene.pushMatrix();
        this.translate(16,5,8);
        this.scoreboard.display();
        this.graph.scene.popMatrix();


        this.graph.scene.pushMatrix();
        this.translate(0,5,8);
        this.rotate(180*DEGREE_TO_RAD ,0,1,0);
        this.timer.display();
        this.graph.scene.popMatrix();
        
      
        this.boardTable.display();
        this.pieces.display();
       
        this.graph.scene.popMatrix();

       let newDate = new Date();
       currTime = newDate.getTime();
       if(this.initialTime == null) {
           this.initialTime = currTime;
       }
       dT = (currTime - this.initialTime)/1000;
       this.updateScalingFactor(dT);
        // Displays the scene.
        this.graph.displayScene();
     


    }
	else
	{
		// Draw axis
		this.axis.display();
	}


    this.popMatrix();

    // ---- END Background, camera and axis setup

}

/*  Update para as animaçoes!
XMLscene.prototype.update = function(currTime){
 for(var node in this.graph.nodes) {
    this.graph.nodes[node].updateAnimationMatrix(currTime - this.lastTime);
  }
 this.lastTime = currTime;
}
*/

XMLscene.prototype.updateScalingFactor = function(date)
{
    this.shaders[this.currentShader].setUniformsValues({timeFactor: date});
};


// Picking
XMLscene.prototype.logPicking = function() {

   

    if(this.pickMode == false){
        if(this.pickResults != null && this.pickResults.length > 0){
            for(var i = 0; i < this.pickResults.length; i++){
                var obj = this.pickResults[i][0];
                var cor =this.pieces.piecesCol[obj.positionX][obj.positionY];
                if(obj){
                           
                           
                    var pid = this.pickResults[i][1];
                   // console.log("picked object:  " + obj + " ------ pick id: " + pid);

                    
                    if(obj instanceof MyBishop ){

                        console.log("Bispo "+'x:'+(obj.positionY +1) + ' y:'+(obj.positionX+1));
                        if(this.player == 'whitePlayer' && cor == true){
                            console.log(this.player);
                           getCellsToMoveTo(this.board,this.player,(obj.positionX),(obj.positionY),this.getMoves.bind(this));
                        }
                        if(this.player == 'blackPlayer' && cor == false){
                            getCellsToMoveTo(this.board,this.player,(obj.positionX),(obj.positionY),this.getMoves.bind(this));
                        }

                         this.pickedPiece = obj;


                    }
                    if(obj instanceof MyQueen ){

                        console.log("Rainha "+'x:'+(obj.positionY +1) + ' y:'+(obj.positionX+1));
                        if(this.player == 'whitePlayer' && cor == true){
                            console.log(this.player);
                           getCellsToMoveTo(this.board,this.player,(obj.positionX),(obj.positionY),this.getMoves.bind(this));
                        }
                        if(this.player == 'blackPlayer' && cor == false){
                            getCellsToMoveTo(this.board,this.player,(obj.positionX),(obj.positionY),this.getMoves.bind(this));
                        }
                        this.pickedPiece = obj;
                    }
                    if(obj instanceof MyTower ){

                        console.log("Torre "+'x:'+(obj.positionY +1) + ' y:'+(obj.positionX+1));
                        if(this.player == 'whitePlayer' && cor == true){
                            console.log(this.player);
                           getCellsToMoveTo(this.board,this.player,(obj.positionX),(obj.positionY),this.getMoves.bind(this));
                        }
                        if(this.player == 'blackPlayer' && cor == false){
                            getCellsToMoveTo(this.board,this.player,(obj.positionX),(obj.positionY),this.getMoves.bind(this));
                        }
                        this.pickedPiece = obj;
                    }
                    if(obj instanceof MyHorse ){

                        console.log("Cavalo "+'x:'+(obj.positionY +1) + ' y:'+(obj.positionX+1));
                        console.log(this.player);
                        if(this.player == 'whitePlayer' && cor == true){
                            console.log(this.player);
                            getCellsToMoveTo(this.board,this.player,(obj.positionX),(obj.positionY),this.getMoves.bind(this));
                        }
                        if(this.player == 'blackPlayer' && cor == false){
                            getCellsToMoveTo(this.board,this.player,(obj.positionX),(obj.positionY),this.getMoves.bind(this));
                        }
                        this.pickedPiece = obj;
                    }

                    if(obj instanceof Board ){
                        console.log("BOARD");
                        this.pickedPiece = obj;
                    }
                    if(obj instanceof MyQuad ){
                        console.log("MYQUAD");
                        //this.pickedPiece = obj;
                    }

                   
                }  
            }
            this.pickResults.splice(0, this.pickResults.length);
        }
    }
}




//Cameras


XMLscene.prototype.initCameras = function () {
    
    this.camera = new CGFcamera(0.4, 0.01, 500, vec3.fromValues(25, 20, 25), vec3.fromValues(0, 0, 0));
    this.cameraDestination = [25,10,0];
    this.cameraTransition = false;
    this.camTransTime = 1000;
};

//Cameras


XMLscene.prototype.InitalP = function() {

    if(!this.cameraTransition) {
        this.cameraOrigin=[this.camera.position[0], this.camera.position[1], this.camera.position[2]];
        this.cameraDestination = [25,20,25];
        if(!arraysEqual(this.cameraDestination, this.cameraOrigin)) this.calcTransition();
    }
};


XMLscene.prototype.TopV = function() {

    if(!this.cameraTransition) {
        this.cameraOrigin=[this.camera.position[0], this.camera.position[1], this.camera.position[2]];
        this.cameraDestination = [25,35,0];
        if(!arraysEqual(this.cameraDestination, this.cameraOrigin)) this.calcTransition();
    }
};

XMLscene.prototype.side1 = function() {

    if(!this.cameraTransition) {
        this.cameraOrigin=[this.camera.position[0], this.camera.position[1], this.camera.position[2]];
        this.cameraDestination = [25,10,10];
        if(!arraysEqual(this.cameraDestination, this.cameraOrigin)) this.calcTransition();
    }
};

XMLscene.prototype.side3 = function() {

    if(!this.cameraTransition) {
        this.cameraOrigin=[this.camera.position[0], this.camera.position[1], this.camera.position[2]];
        this.cameraDestination = [-3,15,29];
        if(!arraysEqual(this.cameraDestination, this.cameraOrigin)) this.calcTransition();
    }
};

XMLscene.prototype.cameraScore = function() {

    if(!this.cameraTransition) {
        this.cameraOrigin=[this.camera.position[0], this.camera.position[1], this.camera.position[2]];
        this.cameraDestination = [0,10,20];
        if(!arraysEqual(this.cameraDestination, this.cameraOrigin)) this.calcTransition();
    }
};

XMLscene.prototype.side2 = function() {

    if(!this.cameraTransition) {
        this.cameraOrigin=[this.camera.position[0], this.camera.position[1], this.camera.position[2]];
        this.cameraDestination = [1,15,-25];
        if(!arraysEqual(this.cameraDestination, this.cameraOrigin)) this.calcTransition();
    }
};


XMLscene.prototype.freeCam = function() {
    this.interfac.setActiveCamera(this.camera);
};

XMLscene.prototype.lockCam = function(){
    this.interfac.setActiveCamera(null);
};



XMLscene.prototype.update = function (currTime) {

    if(!this.timer.timeBeg) this.timer.timeBeg = currTime;
    this.timer.updateTime(currTime);

    
    if(this.cameraTransition) {
        if(!this.camTransBeg) this.camTransBeg = currTime;  //BEGINNING
        else
        {
            var time_since_start = currTime - this.camTransBeg;
            if(time_since_start>=this.camTransTime) { //END
                this.camera.setPosition(this.cameraDestination);
                this.camTransBeg=null;
                this.cameraTransition=false;
            }
            else {
                var time_perc = time_since_start / this.camTransTime;
                var new_pos = [this.cameraOrigin[0]+(this.transitionVec[0]*time_perc),
                this.cameraOrigin[1]+(this.transitionVec[1]*time_perc),
                this.cameraOrigin[2]+(this.transitionVec[2]*time_perc)];
                this.camera.setPosition(new_pos);
            }
        }
    }
    if(this.pieceTransition) {
        if(!this.pieceTransBeg) this.pieceTransBeg = currTime;  //BEGINNING
        else
        {
            var time_since_start = currTime-this.pieceTransBeg;
            if(time_since_start >= this.pieceTransTime) { //END
                this.pickedPiece.height = this.pieceFinalHeight;
                this.pieceTransBeg = null;
                this.pieceTransition = false;
            }
            else {
                var time_perc = time_since_start/this.pieceTransTime;
                this.pickedPiece.height = this.pieceFinalHeight*time_perc;
            }
        }
    }
};

//Change skins and background

XMLscene.prototype.alt_skin = function () {
    if(this.skin==1)
    {
        this.skin=2;
        //this.boardTable.setMatWOOD(this.matWOODDARK);

        
        this.scoreboard.setMatWOOD(this.matWOODDARK);
        this.scoreboard.setFont(this.fontRED);

        this.timer.setMatWOOD(this.matWOODDARK);
        this.timer.setFont(this.fontRED);
        

        this.matWOOD=this.matWOODDARK;
    }
    else
    {
        this.skin=1;
       // this.boardTable.setMatWOOD(this.matWOODBRIGHT);

        this.scoreboard.setMatWOOD(this.matWOODBRIGHT);    
        this.scoreboard.setFont(this.fontWHITE);
        

        this.timer.setMatWOOD(this.matWOODBRIGHT);
        this.timer.setFont(this.fontWHITE);

        this.matWOOD=this.matWOODBRIGHT;
    }
};

XMLscene.prototype.changeBackground = function(){
    if (this.bg == 1){
    this.bg=2;
    this.graph.nodes['walls'].textureID='brickwall';
    this.graph.nodes['table'].textureID='woodchair';
    this.graph.nodes['chair'].textureID='woodchair';
    this.graph.nodes['chair2'].textureID='woodchair';
    this.graph.nodes['chao'].textureID='piece2';
    this.graph.nodes['window2'].textureID='windowview';
    }
    else {
    this.bg=1;
    this.graph.nodes['walls'].textureID='wall';
     this.graph.nodes['table'].textureID='woodchair';
     this.graph.nodes['chair'].textureID='brickwall';
    this.graph.nodes['chair2'].textureID='brickwall';
    this.graph.nodes['chao'].textureID='floor';
    this.graph.nodes['window2'].textureID='mar';
    }
}

//Film
XMLscene.prototype.start_film = function() {

  };

//Undo
XMLscene.prototype.undo = function() {
    
};

//Utils

function arraysEqual(a, b) {
  if (a === b) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;

  for (var i = 0; i < a.length; ++i) {
    if (a[i] !== b[i]) return false;
  }
  return true;
};

XMLscene.prototype.calcTransition = function() {
    this.transitionVec = [this.cameraDestination[0]-this.cameraOrigin[0],
            this.cameraDestination[1]-this.cameraOrigin[1],
            this.cameraDestination[2]-this.cameraOrigin[2]];

    this.cameraTransition = true;
};

//Materials and textures
XMLscene.prototype.initMaterials = function () {

    this.defaultApp = new CGFappearance(this);
    this.defaultApp.setAmbient(0.9, 0.9, 0.9, 1);
    this.defaultApp.setDiffuse(0.7, 0.7, 0.7, 1);
    this.defaultApp.setSpecular(0.0, 0.0, 0.0, 1);  
    this.defaultApp.setShininess(120);

    this.matSILVER = new CGFappearance(this);
    this.matSILVER.setAmbient(0.2, 0.2, 0.2, 1.0);
    this.matSILVER.setDiffuse(0.2, 0.2, 0.2, 1.0);
    this.matSILVER.setSpecular(0.8, 0.8, 0.8, 1.0);
    this.matSILVER.setShininess(10.0);

    this.matGOLD = new CGFappearance(this);
    this.matGOLD.setAmbient(0.5, 0.42, 0.05, 1.0);
    this.matGOLD.setDiffuse(0.5, 0.42, 0.05, 1.0);
    this.matGOLD.setSpecular(0.8, 0.2, 0.2, 1.0);
    this.matGOLD.setShininess(2.0);

    this.matBLACK = new CGFappearance(this);
    this.matBLACK.setAmbient(0.07, 0.07, 0.07, 1.0);
    this.matBLACK.setDiffuse(0.07, 0.07, 0.07, 1.0);
    this.matBLACK.setSpecular(0.02, 0.02, 0.02, 1.0);
    this.matBLACK.setShininess(2.0);

    this.matWHITE = new CGFappearance(this);
    this.matWHITE.setAmbient(0.99, 0.99, 0.99, 1.0);
    this.matWHITE.setDiffuse(0.99, 0.99, 0.99, 1.0);
    this.matWHITE.setSpecular(0.2, 0.2, 0.2, 1.0);
    this.matWHITE.setShininess(2.0);

    this.matWOODBRIGHT = new CGFappearance(this);
    this.matWOODBRIGHT.setAmbient(0.5, 0.5, 0.5, 1.0);
    this.matWOODBRIGHT.setDiffuse(0.5, 0.5, 0.5, 1.0);
    this.matWOODBRIGHT.setSpecular(0.2, 0.2, 0.2, 1.0);
    this.matWOODBRIGHT.setShininess(2.0);
    this.matWOODBRIGHT.setTexture(new CGFtexture(this, dir_resources+"wood.jpg"));

    this.matWOOD=this.matWOODBRIGHT;

    this.matWOODDARK = new CGFappearance(this);
    this.matWOODDARK.setAmbient(0.16, 0.04, 0.02, 1);
    this.matWOODDARK.setDiffuse(0.16, 0.04, 0.02, 1);
    this.matWOODDARK.setSpecular(0.1, 0.02, 0.02, 1);
    this.matWOODDARK.setShininess(2.0);
    this.matWOODDARK.setTexture(new CGFtexture(this, dir_resources+"wood.jpg"));

    // FONT TEXTURES

    this.fontRED = new CGFtexture(this, dir_resources+"red-led-font.jpg");
    this.fontYELLOW = new CGFtexture(this, dir_resources+"yellow-led-font.jpg");
    this.fontWHITE = new CGFtexture(this, dir_resources+"white-led-font.jpg");
};

