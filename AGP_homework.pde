/**
 * @author Nils Gawlik
 * @date 2017-11-22
 * @matrikelnummer 553449
 */

 import java.util.HashSet;


// -- physical utility constants --
final float km = 1000; // kilometer, in m
final float h = 3600; // hour, in s
final float kmH = 1 / 3.6; // kilometers per hour, in m/s

// -- other constants --
// world constants
final float gravityY = -9.81; // in m/s
final float cw = 0.45; // "Strömungsbeiwert" for a sphere
final float e = (float) Math.E; // 2.71828; // Euler's number
float airDensity(float height) {
  return 1.3 * pow(e, -9.81 * 1.3 * height / 100000); // formula for calculating the air density
}

// origin of world on screen
final float xOrigin = 500; // in px
final float yOrigin = 650; // in px

final float baseWorldHeight = 200 * km; // in m, height of the displayed world
final float markerHeight = 30 * km; // in m, height of horizontal marker line
final float baseTimeScale = 5; // in s/s, time scale

// comet
final float initialImpactAngle = radians(170); // initial comet impact angle relative to x axis, in radians
final float initialImpactAngleVariance = radians(1);
final float initialVelocity = 16000 * kmH; // initial comet velocity, in m/s
final float initialVelocityVariance = 1600 * kmH;
final float cometRadius = 20;
final float cometDensity = 0.9 * 9167  + 0.1 * 4000; // in g/cm^3, 90% ice, 10% rock

// rocket
// calculate launch speed to reach the markerHeight (subtracting the rocket's height of 100 meters at 100x scale)
final float rocketLaunchSpeedMin = sqrt(2 * -gravityY * (markerHeight - 100*100));
final float rocketLaunchSpeed = rocketLaunchSpeedMin * 2; // actual speed is 2 times that
final float rocketRadius = 100;

// minimum distance for rocket and comet to count as collision
// final float rocketCometCollisionDistance = 120; // in m, realistic value
final float rocketCometCollisionDistance = 120*50; // in m, value that's good for gameplay

/** utility functions **/
float sign(float x) {
  if (x > 0) return 1;
  if (x < 0) return -1;
  return 0;
}

/** classes **/

// class that draws the floor and other environmental things
class Floor {
  float thickness; // thickness of the floor
  float markerHeight; // height of the marking line -> height at which the comet should be shot
  
  Floor(float thickness, float markerHeight) {
    this.thickness = thickness;
    this.markerHeight = markerHeight;
  }
  
  void draw() {
    // draw ground
    fill(0);
    noStroke();
    rect(worldBorderLeft, -thickness, worldWidth, thickness);
   
    // draw marker line
    fill(0);
    stroke(0xffffffff);
    strokeWeight(100);
    line(worldBorderLeft, markerHeight, worldWidth, markerHeight);
  }
}

// button responsible for start and reset
class StartButton extends Button {
  StartButton() {
    super(
      120, 70, // x, y
      new PImage[] {buttonGreenUp, buttonGreenDown, buttonRedUp, buttonRedDown}, // images
      new String[] {"Start", "Reset"}, // labels
      -12, 8 // offset of text when normal and pressed
      );
  }

  void performAction(int currentState) {
    // do certain things based on state
    switch (state) {
      case 0: // start
        timeScale = baseTimeScale;
        start();
      break;
      case 1: // reset
        teardownDynamic();
        setupDynamic();
      break;
    }
  }

  // start the game
  void start() {
    // rocketSlider.setLocked(true);
  }
}

// button responsible for launching the rocket
class LaunchButton extends Button {
  LaunchButton() {
    super(
      320, 70, // x, y
      new PImage[] {buttonGreenUp, buttonGreenDown}, // images
      new String[] {"Launch"}, // label
      -12, 8 // offset of text when normal and pressed
      );
  }

  void performAction(int currentState) {
    // independent of state (only one state exists)
    // check if simulation is running and rocket not already launched
    if (timeScale > 0 && !rocket.isLaunched) {
      rocket.launch();
    }
  }
}

/** global vairables **/

// images
PImage backgroundImage;
PImage buttonGreenUp;
PImage buttonGreenDown;
PImage buttonRedUp;
PImage buttonRedDown;
PImage particle;
PImage sliderBack;
PImage sliderFront;

// world
float worldWidth; // width of world, in m
float worldHeight; // height of world, in m
float worldScale; // scale of world, in px/m
float timeScale; // time scale, in s/s
float worldBorderLeft; // distance from origin to left border, in m
float worldBorderRight; // distance from origin to right border, in m


// Set that contains all currently existing game objects
HashSet<GameObject> allObjects = new HashSet<GameObject>();
ArrayList<GameObject> newGameObjects = new ArrayList<GameObject>();

// special objects to be rememberd
Comet comet;
Floor floor;
Rocket rocket;

// UI objects
Button buttonStart;
Button buttonLaunch;
Slider rocketSlider;


/** top level control functions **/

void setup() {
  // display
  size(1000, 800);
  frameRate(60);
  
  // dimensions
  float screenRatio = (float)(width) / (float)height;
   
  worldHeight = baseWorldHeight;
  worldWidth = worldHeight * screenRatio;

  worldScale = (float) width / worldWidth;
  timeScale = 0; // no prograssion at start, activated by start button

  worldBorderLeft = -xOrigin / worldScale;
  worldBorderRight = -xOrigin / worldScale + worldWidth;
  
  // load images
  buttonGreenUp = loadImage("b_green_up.png");
  buttonGreenDown = loadImage("b_green_down.png");
  buttonRedUp = loadImage("b_red_up.png");
  buttonRedDown = loadImage("b_red_down.png");
  particle = loadImage("particle.png");
  sliderBack = loadImage("sliderBack.png");
  sliderFront = loadImage("sliderFront.png");
  
  // generate image for background
  color c1 = #FAD723;
  color c2= #4D221F;
  backgroundImage = createImage(width, height, RGB);
  backgroundImage.loadPixels();

  for (int i = 0; i < backgroundImage.pixels.length; i++) {
    float amount = (float) i / backgroundImage.pixels.length;
    backgroundImage.pixels[i] = lerpColor(c1, c2, amount); // TODO use realistic colors to represent the athmosphere (and scale correctly)
  }
  backgroundImage.updatePixels();
  
  // initialize objects
  setupDynamic();
  floor = new Floor(yOrigin / worldScale, markerHeight);

  buttonStart = new StartButton();
  buttonLaunch = new LaunchButton();
  rocketSlider = new Slider(width/2, height - 100, sliderBack, sliderFront, 20.0, " °");

  // Run some tests
  println("Air density at 0: " + airDensity(0));
  println("Air density at markerHeight: " + airDensity(markerHeight));
  println("Air density at baseWorldHeight: " + airDensity(baseWorldHeight));
}

// set up dynamic objects
void setupDynamic() {
  // calculate randomized velocity and angle
  float impactAngle = initialImpactAngle + random(-1, 1) * initialImpactAngleVariance;
  float velocity = initialVelocity + random(-1, 1) * initialVelocityVariance;
  
  comet = new Comet(-120*km, markerHeight * 1.75, impactAngle, velocity);
  rocket = new Rocket(0*km, 0*km, PI/2.0);
}

// tear down dynamic objects (for reset)
void teardownDynamic() {
  comet.die();
  rocket.die();
  // remove all Particles
  for (GameObject obj : allObjects) {
    if (obj instanceof Particle) {
      obj.die();
    }
  }
  // also new instances
  for (GameObject obj : newGameObjects) {
    if (obj instanceof Particle) {
      obj.die();
    }
  }
  // stop time again
  timeScale = 0;
  // reset UI
  rocketSlider.setLocked(false);
}

// called every frame before drawing
void update() {
  float deltaTime = timeScale * 1.0 / frameRate;

  // add any new objects
  allObjects.addAll(newGameObjects);
  newGameObjects.clear();

  // list of objects tha have to be removed
  ArrayList<GameObject> toBeRemovedObjects = new ArrayList<GameObject>();
  // go through all game objects
  for(GameObject obj : allObjects) {
    // simulate physics etc.
    obj.move(deltaTime);
    // collect dead objects
    if (obj.markedAsDead) {
      toBeRemovedObjects.add(obj);
    }
  }
  // remove the dead objects
  allObjects.removeAll(toBeRemovedObjects);

  // update UI
  rocketSlider.update();
}

// passes on mouse events to UI
void mouseReleased() {
  buttonStart.mouseReleased();
  buttonLaunch.mouseReleased();
  rocketSlider.mouseReleased();
}

// passes on mouse events to UI
void mousePressed() {
  buttonStart.mousePressed();
  buttonLaunch.mousePressed();
  rocketSlider.mousePressed();
}
 
void draw() {
  update();

  background(backgroundImage);
  
  // add a transform from world space to screen space
  translate(0, height); // offset because of upcoming scale
  scale(worldScale, -worldScale); // scale and flip in y direction
  translate(xOrigin / worldScale, (height - yOrigin) / worldScale);  // move origin to correct position

  floor.draw(); 
  
  // draw all game objects
  for(GameObject obj : allObjects) {
    obj.draw();
  }
  
  // UI
  resetMatrix(); // reset back to screen space for UI
  
  // draw general info
  fill(255);
  textAlign(RIGHT, TOP);
  textSize(16);
  text("time scale: " + nf(timeScale, 2, 2), width - 16, 16);

  buttonStart.draw();
  buttonLaunch.draw();
  rocketSlider.draw();
}