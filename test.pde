/**
 * @author Nils Gawlik
 * @date 2017-10-11
 * @matrikelnummer 553449
 */
 

// physical utility constants
final float km = 1000;

// class that models and draws the comet
class Comet {
   float x;
   float y;
   float radius = 20*100; // 100x scale
   // verlocity in m/s:
   float vX = cos(radians(10)) * 20*km; // calculated from impact angle (10 degrees)
   float vY = -sin(radians(10)) * 20*km;
   
   
   Comet(float x, float y) {
     this.x = x;
     this.y = y;
   }
   
   void draw() {
     // draw circle
     fill(255);
     ellipse(x, y, radius*2, radius*2);
     // draw impact arc (simplified: line)
     float distanceTillImpact = vX/vY * -y; // helper variable
     stroke(255);
     strokeWeight(200);
     line(x, y, x + distanceTillImpact, 0);
     
     // draw velocity vector
     stroke(255);
     strokeWeight(400);
     line(x, y, x + vX, y + vY);
   }
}

// class that draws the floor and other environmental things
class Floor {
  float thickness = 30*km; // thickness of the floor
  float markerHeight = 30*km; // height of the marking line (height at which the comet should be shot)
  
  Floor() {
  }
  
  void draw() {
   // draw ground
   fill(128);
   strokeWeight(0);
   rect(0, -thickness, worldWidth, thickness);
   
   // draw marker line
   fill(255);
   strokeWeight(100);
   line(0, markerHeight, worldWidth, markerHeight);
  }
}

// class that models and draws a rocket
class Rocket {
  float x;
  float y;
  float h = 100*100; // rocket height (100x scale)
  float w = 20*100; // rocket width (100x scale)
  float cap = 20*100; // height of cap (100x scale)
  
  Rocket(float x, float y) {
    this.x = x;
    this.y = y + h/2; // offset
  }
  
  void draw() {
    pushMatrix();
    translate(x, y); // translation to simplify calculations below
    // calculate and draw the rocket parts
    strokeWeight(0);
    fill(192);
    rect(-w/2, -h/2, w, h - cap);
    fill(200, 50, 60);
    triangle(-w/2, -h/2 + h - cap, w/2, -h/2 + h - cap, 0, h/2);
    
    popMatrix();
  }

  void dafsdfa() {
    
  }
}

// images
PImage backgroundImage;
PImage knobImage;
PImage buttonUpImage;
PImage grooveImage;

// world
float worldWidth;
float worldHeight;

Comet comet;
Floor floor;
Rocket rocket;

void setup() {
  // display
  size(1000, 800);
  frameRate(60);
  
  // dimensions
  float screenRatio = (float)(width) / (float)height;
   
  worldHeight = 200 * km;
  worldWidth = worldHeight * screenRatio;
  
  // load images
  knobImage = loadImage("knob.png");
  buttonUpImage = loadImage("buttonUp.png");
  grooveImage = loadImage("groove.png");
  
  // generate image for background
  backgroundImage = createImage(width, height, RGB);
  backgroundImage.loadPixels();
  for (int i = 0; i < backgroundImage.pixels.length; i++) {
    backgroundImage.pixels[i] = color(0, 0, floor(i / backgroundImage.width) * 0.33); // TODO use realistic colors to represent the athmosphere (and scale correctly)
  }
  backgroundImage.updatePixels();
  
  // initialize objects
  comet = new Comet(5*km, 40*km);
  rocket = new Rocket(60*km, 0*km);
  floor = new Floor();
}
 
void draw() {
  background(backgroundImage);
  
  // add a transform from world space to screen space
  scale((float) width / worldWidth, -(float) height / worldHeight);
  translate(0, -worldHeight);
  translate(0, floor.thickness); // some extra for the floor

  comet.draw();
  floor.draw(); 
  rocket.draw();
  
  // UI
  resetMatrix(); // reset back to screen space for UI
  
  float centerLineHeight = height - buttonUpImage.height/2 - 16;
  image(buttonUpImage, 16, centerLineHeight - buttonUpImage.height/2);
  image(grooveImage, buttonUpImage.width + 16 + 16, centerLineHeight - grooveImage.height/2);
  image(knobImage, buttonUpImage.width + 16 + 16 + grooveImage.width/2 - knobImage.width/2, centerLineHeight - knobImage.height/2);
}