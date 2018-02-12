// class that models and draws a rocket
class Rocket extends GameObject {
  float h = 100*100; // rocket height (100x scale)
  float w = 20*100; // rocket width (100x scale)
  float cap = 20*100; // height of cap (100x scale)
  float rotation; // rocket's rotation in radians, 0 is rocket pointing right
  boolean isLaunched;
  boolean hasCollided;
  float launchTimer;

  float massEmpty;
  float massPropellant;
  float vGas;
  float massFlow;
  float startMass;
  
  Rocket(float x, float y, float rotation) {
    super(x, y, rocketRadius, 0); // mass is calculated on launch
    isLaunched = false;
    hasCollided = false;
    this.rotation = rotation;
    hasFriction = false;

    vGas = rocketGasVelocity;
    massFlow = rocketMassFlow; 

    massEmpty = 2.7E8; // in kg, experimental value, extremely high but necessarry to divert comet
    massPropellant = massEmpty / rocketMassRatio;
    mass = massEmpty + massPropellant;
    startMass = mass;

    float cometFlightDuration = -comet.x / comet.vX;
    launchTimer = cometFlightDuration - calculateFlightDuration();
  }

  float calculateFlightDuration() {
    // calculate the launch time using fixed point iteration
    float time = 0.1;
    // itereate a maximum of 1 000 times
    for(int i = 0; i < 1E3; i++) {
      println(time);
      float lastTime = time;
      time = launchTimeIterationFormula(lastTime);
      if (abs(lastTime - time) < 0.001) {
        return -time;
      }
    }
    // this code should not be reached
    println("WARNING: Rocket launch calculations did not terminate.");
    return -time;
  }

  float launchTimeIterationFormula(float t) {
    float ht = markerHeight; //<>//
    float g = -gravityY;
    float mStart = startMass;
    float q = -massFlow;
    float vg = vGas;
    // println("ht: " + ht); 
    // println("g: " + g); 
    // println("mStart: " + mStart); 
    // println("q: " + q); 

    return (-ht - g * sq(t) * 0.5 - vg * (mStart / q - t) 
      * log(1.0 - (q * t)/mStart)) / vg;
  }

  void launch() {
    if (isLaunched) {
      return;
    }

    isLaunched = true;
    // vX = getCurrentLaunchVX();
    // vY = getCurrentLaunchVY();
  }

  void move(float deltaTime) {
    if (isLaunched) {
      // custom acceleration
      float ejectionAngle = rotation + PI; // opposite to where rocket is pointing
      // calculate the ejected mass, either by flow and time or just the remaining mass if none is left
      float ejectedMass = min(massFlow * deltaTime, massPropellant);
      // subtract ejected mass from current mass
      massPropellant -= ejectedMass;
      mass = massEmpty + massPropellant; // recalculate total mass

      if (mass != 0) {
        // caclulate the acceleration based on the ejected mass and the velocity of the gas
        // "nach Impulserhaltungssatz"
        float deltaV = (ejectedMass * -vGas) / mass;
        // ... and add it to the current speed
        vX += cos(ejectionAngle) * deltaV;
        vY += sin(ejectionAngle) * deltaV;
      }
      
      // spawn ejection particles
      float averageParticlesPerSecond = ejectedMass * 0.01;
      float numberOfParticles = deltaTime * averageParticlesPerSecond;
      float actualNumber = floor(numberOfParticles) 
        + (random(1.0) < numberOfParticles - floor(numberOfParticles) ? 1 : 0);
      float exhaustX = x + cos(rotation + PI) * h * 0.5;
      float exhaustY = y + sin(rotation + PI) * h * 0.5;
      for(int i = 0; i < actualNumber; i++) {
        new Particle(
          exhaustX + (random(1.0) - 0.5) * 1200, 
          exhaustY + (random(1.0) - 0.5) * 1200, 
          random(1.0) * 8 + 1, // lifetime in s
          random(1.0) * 2000 // size of particles
          );
      }
    }

    // handle rest of movement in parent object (gravity, updating position)
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

      // console message
      println("The comet was hit!");
      println("-> with mass: " + mass + " kg");
      println("-> with speed: (" + vX + " m/s, " + vY + " m/s)");

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

    // handle launch timer
    launchTimer -= deltaTime;
    if (launchTimer <= 0 && !isLaunched) {
      launch();
      println("LAUNCH");
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
