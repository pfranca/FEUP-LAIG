function Pieces(scene, args) {
    CGFobject.call(this, scene);

   this.pieces = new Array(8);
   this.piecesCol = new Array(8);

   for(var i = 0; i < 8; i++)
   {
    this.pieces[i] = new Array(8);
    this.piecesCol[i] = new Array(8);
   }

   this.piecesPos = args[0];
   this.pieceMaterial1 = args[1];
   this.pieceMaterial2 = args[2];


    this.initBuffers();
};

Pieces.prototype = Object.create(CGFobject.prototype);
Pieces.prototype.constructor = Board;

Pieces.prototype.initBuffers = function() {


  for(var i = 0; i < 8; i ++)
  {
    for(var j = 0; j < 8; j++)
    {
      switch(this.piecesPos[j][i]){
      case 'wq':
        //New Queen White
        this.pieces[j][i] = new MyQueen(this.scene,j,i);
        this.piecesCol[j][i] = true;
        break;
      case 'wt':
        this.pieces[j][i] = new MyTower(this.scene,j,i);
        this.piecesCol[j][i] = true;
        //New Tower White
        break;
      case'wh':
        this.pieces[j][i] = new MyHorse(this.scene,j,i);
        this.piecesCol[j][i] = true;
        //New Horse White
        break;
      case'wb':
        this.pieces[j][i] = new MyBishop(this.scene,j,i);
        this.piecesCol[j][i] = true;
        //New Bishop White
        break;
      case 'bq':
        this.pieces[j][i] = new MyQueen(this.scene,j,i);
        this.piecesCol[j][i] = false;
        //New Queen Black
        break;
      case 'bt':
        this.pieces[j][i] = new MyTower(this.scene,j,i);
        this.piecesCol[j][i] = false;
        //New Tower Black
        break;
      case'bh':
        this.pieces[j][i] = new MyHorse(this.scene,j,i);
        this.piecesCol[j][i] = false;
        //New Horse Black
        break;
      case'bb':
        this.pieces[j][i] = new MyBishop(this.scene,j,i);
        this.piecesCol[j][i] = false;
        //New Bisp Black
        break;


      }
    }
  }
  
    
};

Pieces.prototype.display = function() {
  
  for(var i = 0; i < 8; i++)
  {
    for(var j = 0; j < 8; j++)
    {
        this.scene.pushMatrix();
        
        this.scene.translate(0.5,0,0.5);
        this.scene.translate(i*5+2.5, 0, j*5+2.5) //+2.5 ; +2.5 para a outras peças
        this.scene.rotate(0, 1, 0, 0);
        this.scene.scale(1,1,1);


      if(!this.piecesCol[j][i])
      {
        this.pieceMaterial1.apply();
      }
      else
      {
        this.pieceMaterial2.apply();
      }

        var pid = (i+1)*10 + j+1;
        this.scene.registerForPick(pid, this.pieces[j][i]);
        this.pieces[j][i].display();
        this.scene.popMatrix();

    }
  }

  

  
}

