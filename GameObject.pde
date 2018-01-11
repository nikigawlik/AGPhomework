// Parent class for physics objects
class GameObject {
  float x;
  float y;
  // verlocity in m/s:
  float vX;
  float vY;
  public boolean markedAsDead = false;
  protected float radius;
  protected float density;
  protected float flowArea;  // "angeströmte Fläche", area that is affected by flow resistance
  protected float mass;
  protected boolean hasFriction;

  GameObject(float x, float y, float radius, float density) {
    this.x = x;
    this.y = y;
    this.radius = radius;
    this.density = density;
    vX = 0;
    vY = 0;

    this.flowArea = PI * sq(radius);
    this.mass = 4/3 * PI * pow(radius, 3) * density;
    this.hasFriction = true;

    // add to global game object list
    newGameObjects.add(this);
  }

  void die() {
    // mark as dead so it can be cleaned up later
    markedAsDead = true;
  }
  
  void move(float deltaTime) {
    // apply gravity
    vY += gravityY * deltaTime;

    // apply air friction/resistance
    float v = mag(vX, vY);
    float resistance = cw * airDensity(y) * flowArea * sq(v) / 2;

    if (v != 0 && hasFriction) {
      vX -= sign(vX) * deltaTime * (vX/v) * resistance / mass;
      vY -= sign(vY) * deltaTime * (vY/v) * resistance / mass;
    }

    // move object
    x += vX * deltaTime;
    y += vY * deltaTime;
  }

  void draw() {
    // do nothing
  }
}

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
    strokeWeight(0);
    rect(worldBorderLeft, -thickness, worldWidth, thickness);
   
    // draw marker line
    fill(0);
    strokeWeight(100);
    line(worldBorderLeft, markerHeight, worldWidth, markerHeight);
  }
}
