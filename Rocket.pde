// class that models and draws a rocket
class Rocket extends GameObject {
  float h = 100*100; // rocket height (100x scale)
  float w = 20*100; // rocket width (100x scale)
  float cap = 20*100; // height of cap (100x scale)
  float rotation; // rocket's rotation in radians, 0 is rocket pointing right
  boolean isLaunched;
  boolean hasCollided;
  
  Rocket(float x, float y, float rotation) {
    super(x, y, rocketRadius, rocketDensity);
    isLaunched = false;
    hasCollided = false;
    this.rotation = rotation;
    hasFriction = false;
  }

  void launch() {
    if (isLaunched) {
      return;
    }

    isLaunched = true;
    vX = getCurrentLaunchVX();
    vY = getCurrentLaunchVY();
  }

  float getCurrentLaunchVX() {
    return cos(rotation) * rocketLaunchSpeed;
  }

  float getCurrentLaunchVY() {
    return sin(rotation) * rocketLaunchSpeed;
  }

  void move(float deltaTime) {
    // handle movement in parent object
    super.move(deltaTime);

    // handle collision with ground
    if (y < h/2) {
      y = h/2;
      vX = 0;
      vY = 0;
    }

    // handle collision with comet
    if (dist(x, y, comet.x, comet.y) < rocketCometCollisionDistance && !hasCollided) {
      hasCollided = true;
      // spawn some particles
      for(int i = 0; i < 20; i++) {
        float dir = random(0, 2*PI);
        float len = random(radius + comet.radius) * 0.5;
        
        Particle p = new Particle(
          x + cos(dir) * len, 
          y + sin(dir) * len, 
          random(1.0) * 12 + 1, // lifetime in s
          random(1.0) * (radius + comet.radius) * 0.4 // size of particles
          );

        p.vX = cos(dir) * len/10;
        p.vY = sin(dir) * len/10;
      }

      // Set to same position for visual reasons
      comet.x = this.x = (comet.x + this.x) / 2;
      comet.y = this.y = (comet.y + this.y) / 2;

      // Continue as unelastic impact
      float newVX = (comet.vX * comet.mass + this.vX * this.mass) / (comet.mass + this.mass);
      float newVY = (comet.vY * comet.mass + this.vY * this.mass) / (comet.mass + this.mass);
      this.vX = comet.vX = newVX;
      this.vY = comet.vY = newVY;

      // console message
      println("The comet was hit!");

      // // destroy objects
      // rocket.die();
      // comet.die();
    }

    // handle rotation
    if (!isLaunched) {
      rotation = radians(rocketSlider.value) + PI/2; // set proper rotation
    } else {
      rotation = atan2(vY, vX);
    }
  }

  void draw() {
    pushMatrix();

    translate(x, y); // translation to simplify calculations below
    rotate(rotation); // apply rotation
    rotate(-PI/2); // counteract the fact that the following lines assume an upright rocket
    // calculate and draw the rocket parts
    noStroke();
    fill(0);
    rect(-w/2, -h/2, w, h - cap);
    fill(0);
    triangle(-w/2, -h/2 + h - cap, w/2, -h/2 + h - cap, 0, h/2);
    
    popMatrix();
  }
}
