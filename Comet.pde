// class that models and draws the comet
class Comet extends GameObject{
  float averageParticlesPerSecond = 50.0;

  Comet(float x, float y, float impactAngle, float velocity) {
    super(x, y, cometRadius, cometDensity);
    vX = -cos(impactAngle) * velocity; // calculated initial velocity vector
    vY = -sin(impactAngle) * velocity;
  }

  // move the comet, deltaTime = time passed since last update, in s
  void move(float deltaTime) {
    // handle movement in parent object
    super.move(deltaTime);

    // handle collision with ground
    if (y < radius) {
      y = radius;
      vX = 0;
      vY = 0;
    }

    // some nice particles
    float numberOfParticles = deltaTime * averageParticlesPerSecond;
    float actualNumber = floor(numberOfParticles) 
      + (random(1.0) < numberOfParticles - floor(numberOfParticles) ? 1 : 0);
    for(int i = 0; i < actualNumber; i++) {
      new Particle(
        x + (random(1.0) - 0.5) * 1.2 * radius, 
        y + (random(1.0) - 0.5) * 1.2 * radius, 
        random(1.0) * 8 + 1, // lifetime in s
        random(1.0) * radius * 2 // size of particles
        );
    }
  }
  
  void draw() {
    // draw circle
    fill(255);
    ellipse(x, y, radius*2, radius*2);
    
    // calculate power loss
    float v = mag(vX, vY);
    float loss = cw * airDensity(y) * flowArea * pow(v, 3) / 2;
    loss /= 1E12; // convert to terawatt

    pushMatrix();
    resetMatrix();

    fill(255);
    textAlign(RIGHT, TOP);
    textSize(16);
    text("Power loss: " + nf(loss, 2, 2) + " TW", width - 16, 32);

    popMatrix();
    
    // // draw impact arc (simplified: line)
    // float distanceTillImpact = vX/vY * -y; // helper variable
    // stroke(255);
    // strokeWeight(200);
    // line(x, y, x + distanceTillImpact, 0);
    
    // draw velocity vector
    stroke(255);
    strokeWeight(400);
    line(x, y, x + vX, y + vY);
  }
}
