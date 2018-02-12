// class that models and draws a rocket
class Rocket extends GameObject {
  float h = 100*100; // rocket height (100x scale)
  float w = 20*100; // rocket width (100x scale)
  float cap = 20*100; // height of cap (100x scale)
  float rotation; // rocket's rotation in radians, 0 is rocket pointing right
  boolean isLaunched;
  boolean hasCollided;

  float massEmpty;
  float massPropellant;
  float vGas;
  float massFlow;
  
  Rocket(float x, float y, float rotation) {
    super(x, y, rocketRadius, 0); // mass is calculated on launch
    isLaunched = false;
    hasCollided = false;
    this.rotation = rotation;
    hasFriction = false;

    vGas = rocketGasVelocity;
    massFlow = rocketMassFlow; 

    massEmpty = 0.0; // calculated on launch
    massPropellant = 0.0; // calculated on launch 
  }

  void launch() {
    if (isLaunched) {
      return;
    }

    isLaunched = true;
    // vX = getCurrentLaunchVX();
    // vY = getCurrentLaunchVY();

    // initialize masses
    massEmpty = calculateMinMass() * 1.2; // minimum mass + some extra
    massPropellant = massEmpty / rocketMassRatio;
    mass = massEmpty + massPropellant;
  }

  // Mass needed to get a velocity parallel to the ground after collision
  // (assuming collision at marker height)
  float calculateMinMass() {
    // float v_r = this.vY; // absolute velocity of Rocket (vertical)
    float v_r = getCurrentLaunchVY(); // absolute velocity of Rocket (vertical)
    float m_c = comet.mass; // mass of comet 
    float v_c = abs(comet.vY); // absolute velocity of Comet (vertical)
    float g = abs(gravityY); // G
    float h = markerHeight; // estimated collision height

    // Rechenweg (Energierhaltung):
    // E_Raketenstart - E_Höhe = E_Komet
    // .5 m_r v_r^2 - m_r g h = .5 m_c v_c^2
    // m_r (.5 v_r^2 - g h) = .5 m_c v_c^2
    // m_r = .5 m_c v_c^2 / (.5 v_r^2 - g h)

    // calculate mass of rocket
    float m_r = 0.5 * m_c * sq(v_c) / (0.5 * sq(v_r) - g * h);

    return m_r;
  }

  float getCurrentLaunchVX() {
    return cos(rotation) * rocketLaunchSpeed;
  }

  float getCurrentLaunchVY() {
    return sin(rotation) * rocketLaunchSpeed;
  }

  void move(float deltaTime) {
    // custom acceleration
    float ejectionAngle = rotation + PI; // opposite to where rocket is pointing
    // calculate the ejected mass, either by flow and time or just the remaining mass if none is left
    float ejectedMass = min(massFlow * deltaTime, massPropellant);
    // subtract ejected mass from current mass
    massPropellant -= ejectedMass;
    mass = massEmpty + massPropellant;

    if (mass != 0) {
      float deltaV = (ejectedMass * -vGas) / mass;
      vX += cos(ejectionAngle) * deltaV;
      vY += sin(ejectionAngle) * deltaV;
    }

    // handle rest of movement in parent object
    super.move(deltaTime);

    // spawn ejection particles
    float averageParticlesPerSecond = ejectedMass * 0.01;
    float numberOfParticles = deltaTime * averageParticlesPerSecond * (mag(vX, vY) / initialVelocity);
    float actualNumber = floor(numberOfParticles) 
      + (random(1.0) < numberOfParticles - floor(numberOfParticles) ? 1 : 0);
    float exhaustX = x + cos(rotation + PI) * h * 0.5;
    float exhaustY = y + sin(rotation + PI) * h * 0.5;
    for(int i = 0; i < actualNumber; i++) {
      new Particle(
        exhaustX + (random(1.0) - 0.5) * 1.2 * radius*10, 
        exhaustY + (random(1.0) - 0.5) * 1.2 * radius*10, 
        random(1.0) * 8 + 1, // lifetime in s
        random(1.0) * radius*10 * 2 // size of particles
        );
    }

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
