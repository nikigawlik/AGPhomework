/**
 * @author Nils Gawlik
 * @matrikelnummer 553449
 */

class Comet {
   float x;
   float y;
   float radius = 2000;
   
   Comet(float x, float y) {
     this.x = x;
     this.y = y;
   }
   
   void asdf() {
     fill(255);
     ellipse(x, y, radius, radius);
   }
}
 
// physical utility constants
final float km = 1000;

// images
PImage backgroundImage;

// world
float worldWidth;
float worldHeight;

Comet comet;


void setup() {
  // display
  size(1000, 800);
  frameRate(60);
  
  // dimensions
  float screenRatio = (float)(width) / (float)height;
   
  worldHeight = 55 * km;
  worldWidth = worldHeight * screenRatio;
  
  // load images
  backgroundImage = loadImage("background.jpg");
  
  // initialize objects
  comet = new Comet(4*km, 3*km);
}
 
void draw() {
  background(backgroundImage);
  
  // transform from world space to screen space
  scale((float) width / worldWidth, -(float) height / worldHeight);
  translate(0, -worldHeight);

  // floor
  rect(0*km, 0*km, 3*km, 4*km);

  comet.asdf();
}