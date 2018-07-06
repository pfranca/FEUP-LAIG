
function MyInterface() {
    //call CGFinterface constructor
    CGFinterface.call(this);
}
;

MyInterface.prototype = Object.create(CGFinterface.prototype);
MyInterface.prototype.constructor = MyInterface;


MyInterface.prototype.init = function(application) {
    // call CGFinterface init
    CGFinterface.prototype.init.call(this, application);

    // init GUI. For more information on the methods, check:
    //  http://workshop.chromeexperiments.com/examples/gui

    this.gui = new dat.GUI();

    // add a group of controls (and open/expand by defult)

    this.f1 = this.gui.addFolder('Environment Setup');

  this.f1.add(this.scene,"freeCam").name("Free Camera");
  this.f1.add(this.scene,"lockCam").name("Lock Camera");

   this.f1.add(this.scene,"alt_skin").name("Change Clock");
  this.f1.add(this.scene,"changeBackground").name("Change BG");

  this.f2 = this.gui.addFolder('Camera Setup');
  this.f2.add(this.scene,"InitalP").name("Initial Position");
  this.f2.add(this.scene,"side1").name("Side 1");
  this.f2.add(this.scene,"side2").name("Side 2");
  this.f2.add(this.scene,"side3").name("Side 3");
  this.f2.add(this.scene,"TopV").name("Top View");

   this.f3 = this.gui.addFolder("Game Options");

  this.f3.add(this.scene,"start_film").name("Start Film");

  this.f3.add(this.scene,"undo").name("Undo");

  



    return true;
};

/**
 * Adds a folder containing the IDs of the lights passed as parameter.
 */
MyInterface.prototype.addLightsGroup = function (lights) {

  var group = this.gui.addFolder("Lights");
  group.open();

  // add two check boxes to the group. The identifiers must be members variables of the scene initialized in scene.init as boolean
  // e.g. this.option1=true; this.option2=false;

  for (var key in lights) {
    if (lights.hasOwnProperty(key)) {
        this.scene.lightValues[key] = lights[key][0];
        group.add(this.scene.lightValues, key);
    }
  }
};


MyInterface.prototype.addNodesDropdown = function(nodes) {
  this.shadersGroup = this.gui.addFolder("Shader Options");
  this.shadersGroup.open();
  this.shadersGroup.add(this.scene, "currentSelectable", nodes).name("Selectable Node");
};


MyInterface.prototype.addShadersDropdown = function(shaders) {
  this.shadersGroup.add(this.scene, "currentShader", shaders).name("Special Shader");
};

