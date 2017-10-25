/**
 * @author Nils Gawlik
 * @date 2017-10-25
 * @matrikelnummer 553449
 */
 

// -- physical utility constants --
final float km = 1000; // kilometer, in m
final float h = 3600; // hour, in s
final float kmH = 1 / 3.6; // kilometers per hour, in m/s

// -- other constants --

// origin of world on screen
final float xOrigin = 500; // in px
final float yOrigin = 700; // in px

final float baseWorldHeight = 200 * km; // in m, height of the displayed world
final float markerHeight = 30 * km; // in m, height of horizontal marker line
final float baseTimeScale = 1.0; // in s/s, time scale

// comet
final float initialImpactAngle = radians(170); // initial comet impact angle relative to x axis, in radians
final float initialVelocity = 32000 * kmH; // initial comet velocity, in m/s

// class that models and draws the comet
class Comet {
   float x;
   float y;
   float radius = 20*100; // 20 m, 100x scale
   // verlocity in m/s:
   float vX;
   float vY;
   
   Comet(float x, float y, float impactAngle, float velocity) {
     this.x = x;
     this.y = y;
     vX = -cos(impactAngle) * velocity; // calculated initial velocity vector
     vY = -sin(impactAngle) * velocity;
   }

   // move the comet, deltaTime = time passed since last update, in s
   void move(float deltaTime) {
     // update position
     x += vX * deltaTime;
     y += vY * deltaTime;

     // handle collision with ground
     if (y < radius) {
       y = radius;
       vX = 0;
       vY = 0;
     }
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
  float thickness; // thickness of the floor
  float markerHeight; // height of the marking line (height at which the comet should be shot)
  
  Floor(float thickness, float markerHeight) {
    this.thickness = thickness;
    this.markerHeight = markerHeight;
  }
  
  void draw() {
   // draw ground
   fill(128);
   strokeWeight(0);
   rect(worldBorderLeft, -thickness, worldWidth, thickness);
   
   // draw marker line
   fill(255);
   strokeWeight(100);
   line(worldBorderLeft, markerHeight, worldWidth, markerHeight);
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

  void move(float deltaTime) {
    // do nothing for now
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
}

// images
PImage backgroundImage;
PImage knobImage;
PImage buttonUpImage;
PImage grooveImage;

// world
float worldWidth; // width of world, in m
float worldHeight; // height of world, in m
float worldScale; // scale of world, in px/m
float timeScale; // time scale, in s/s
float worldBorderLeft; // distance from origin to left border, in m
float worldBorderRight; // distance from origin to right border, in m

Comet comet;
Floor floor;
Rocket rocket;

void setup() {
  // display
  size(1000, 800);
  frameRate(60);
  
  // dimensions
  float screenRatio = (float)(width) / (float)height;
   
  worldHeight = baseWorldHeight;
  worldWidth = worldHeight * screenRatio;

  worldScale = (float) width / worldWidth;
  timeScale = baseTimeScale;

  worldBorderLeft = -xOrigin / worldScale;
  worldBorderRight = -xOrigin / worldScale + worldWidth;
  
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
  comet = new Comet(-120*km, 40*km, initialImpactAngle, initialVelocity);
  rocket = new Rocket(0*km, 0*km);
  floor = new Floor(yOrigin / worldScale, markerHeight);
}

// called every frame before drawing
void update() {
  float deltaTime = timeScale * 1.0 / frameRate;
  comet.move(deltaTime);
  rocket.move(deltaTime);
}
 
void draw() {
  update();

  background(backgroundImage);
  
  // add a transform from world space to screen space
  translate(0, height); // offset because of upcoming scale
  scale(worldScale, -worldScale); // scale and flip in y direction
  translate(xOrigin / worldScale, (height - yOrigin) / worldScale);  // move origin to correct position

  comet.draw();
  floor.draw(); 
  rocket.draw();
  
  // UI
  resetMatrix(); // reset back to screen space for UI
  
  float centerLineHeight = height - buttonUpImage.height/2 - 16; // imaginary line to align the other ui elements to
  image(buttonUpImage, 16, centerLineHeight - buttonUpImage.height/2);
  image(grooveImage, buttonUpImage.width + 16 + 16, centerLineHeight - grooveImage.height/2);
  image(knobImage, buttonUpImage.width + 16 + 16 + grooveImage.width/2 - knobImage.width/2, centerLineHeight - knobImage.height/2);
}