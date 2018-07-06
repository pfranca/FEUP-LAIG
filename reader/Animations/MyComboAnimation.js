
class ComboAnimation{

  constructor(scene, id, animationRefs){
    this.scene = scene;
    this.id = id;
    this.animationRefs = animationRefs;
    this.animationMatrix = mat4.create();
    mat4.identity(this.animationMatrix);
    this.secTimes = new Array();
    this.totalTime = 0;
    let time = 0;

    for(let i = 0; i <this.animationRefs.length; i++){
      time = this.scene.animations[this.animationRefs[i]].getTotalTime();
      this.totalTime += time;
      this.secTimes.push(time);
    }

  }

getTotalTime(){
  return this.totalTime;
}

getTransformMatrix(node, time, section) {
    let combSecTime = time;

    for(let i = 0; i < node.combIte; i++)
      combSecTime -= this.secTimes[i];

    if (node.combIte < this.animationRefs.length){
      if(combSecTime >= this.secTimes[node.combIte]){
          node.currentSection = 0;
          node.combIte++;
      }
      else if (combSecTime >= this.scene.animations[this.animationRefs[node.combIte]].secTimes[node.currentSection])//Combos with Linear Animations
           node.currentSection++;
      else{
        mat4.identity(this.animationMatrix);
        this.animationMatrix =  this.scene.animations[this.animationRefs[node.combIte]].getTransformMatrix(node, combSecTime, node.currentSection);
      }
   }
  return this.animationMatrix;
  }

}
