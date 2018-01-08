// parent class for buttons to inherit, supports multiple states to switch between
abstract class Button {
  boolean isDown = false;

  int state = 0; // 0 = red, 1 = green
  int numberOfStates = 2;

  PImage[] images; // images for the states, alternating eween up and down position
  String[] texts;
  float downOffset; // offset when the button is down

  float textOffsetY; // normal offset

  float x;
  float y;

  Button(float x, float y, PImage[] images, String[] texts, float textOffsetY, float downOffset) {
    this.x = x;
    this.y = y;
    this.images = images;
    this.texts = texts;
    this.textOffsetY = textOffsetY;
    this.downOffset = downOffset;
  }

  void mousePressed() {
    if (checkBounds()) {
      isDown = true;
    }
  }

  void mouseReleased() {
    if (isDown) {
      isDown = false;
      performAction(state);
      increaseState();
    }
  }

  protected void performAction(int currentState) {
    // do nothing
  }

  private void increaseState() {
    // update state
    state = (state + 1) % texts.length; // increase state
  }

  void draw() {
    imageMode(CENTER);
    image(currentImage(), x, y);
    if (texts != null && state < texts.length) {
      fill(255);
      textAlign(CENTER, CENTER);
      textSize(33);
      text(texts[state], x, y + textOffsetY + (isDown? downOffset : 0));
    }
  }

  PImage currentImage() {
    return isDown? images[state * 2 + 1] : images[state * 2]; // pick odd images for down, even for up
  }

  boolean checkBounds() {
    return mouseX >= x - currentImage().width/2 && mouseX < x + currentImage().width/2
    && mouseY >= y - currentImage().height/2 && mouseY < y + currentImage().height/2;
  }
}
