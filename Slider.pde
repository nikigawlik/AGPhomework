// a slider for user input of a value
class Slider {
  float x;
  float y;
  PImage backgroundImage;
  PImage knobImage;
  float knobX;
  boolean isDown;
  float value;
  float valueScaling;
  String postfix;
  boolean locked;
  
  Slider(float x, float y, PImage backgroundImage, PImage knobImage, float valueScaling, String postfix) {
    this.x = x; 
    this.y = y; 
    knobX = x;
    this.backgroundImage = backgroundImage; 
    this.knobImage = knobImage;
    value = 0.0;
    this.valueScaling = valueScaling;
    this.postfix = postfix;
    locked = false;
  }

  void setLocked(boolean locked) {
    this.locked = locked;
    if (locked == true) {
      isDown = false;
    }
  }
  
  void mousePressed() {
    if (checkBounds() && !locked) {
      isDown = true;
    }
  }

  void mouseReleased() {
    if (isDown) {
      isDown = false;
    }
  }

  void update() {
    if (isDown) {
      // set the knob on the slider and constrain it to not leave the slider dimensions
      float maxKnobOffset = backgroundImage.width / 2 - knobImage.width / 2;
      knobX = constrain(mouseX, x - maxKnobOffset, x + maxKnobOffset);
      // normalize the output value to [-1, 1]
      value = (knobX - x) / maxKnobOffset * valueScaling;
    }
  }

  boolean checkBounds() {
    return mouseX >= x - backgroundImage.width/2 && mouseX < x + backgroundImage.width/2
    && mouseY >= y - backgroundImage.height/2 && mouseY < y + backgroundImage.height/2;
  }

  void draw() {
    image(backgroundImage, x, y);
    image(knobImage, knobX, y);
    // draw value
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(33);
    text(nf(value, 1, 1) + postfix, x, y + backgroundImage.height / 2 + 18);
  }
}
