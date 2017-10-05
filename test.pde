/**
 * @author Nils Gawlik
 * @matrikelnummer 553449
 */
 
// physical utility constants
final float km = 1000;

// images
PImage backgroundImage;

// world
float worldWidth;
float worldHeight;

class Comet {
   float x;
   float y;
   
   Comet(float x, float y) {
     this.x = x;
     this.y = y;
   }
   
   void draw() {
      circle(20);
   }
}

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
}
 
void draw() {
  background(backgroundImage);
  
  // transform from world space to screen space
  scale((float) width / worldWidth, -(float) height / worldHeight);
  translate(0, -worldHeight);

  // floor
  rect(0*km, 0*km, 3*km, 4*km);

}

/**
  Transforms an x coordinate from world space to screen space.
  @param x x coordinate in meters.
  @return x coordinate in pixels
 */
float worldToScreenX(float x) {
  return x / worldWidth * (float) width;
}

/**
  Transforms an y coordinate from world space to screen space.
  @param y y coordinate in meters.
  @return y coordinate in pixels
 */
float worldToScreenY(float y) {
  return y / worldHeight * (float) height;
}