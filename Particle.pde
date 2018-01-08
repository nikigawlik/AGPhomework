// smoke particle for explosions and other effects
class Particle extends GameObject {
  PImage image;
  float lifetime;
  float initialLifetime;
  float w = 1*km; // why not
  float h = 1*km;

  Particle(float x, float y, float lifetime, float size) {
    super(x, y, 1, 999999);
    image = particle;
    this.lifetime = lifetime;
    initialLifetime = lifetime;
    this.w = size;
    this.h = size;
  }

  void move(float deltaTime) {
    if (lifetime < 0) {
      die();
    }
    lifetime -= deltaTime;

    super.move(deltaTime);
  }

  void draw() {
    imageMode(CENTER);
    float s = max(lifetime / initialLifetime, 0);
    image(image, x, y, w*s, h*s);
  }
}
