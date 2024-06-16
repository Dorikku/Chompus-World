class Room {
  int x, y;
  int width, height;
  ArrayList<Position> doorways;

  Room(int x, int y, int width, int height) {
    this.x = x;
    this.y = y;
    this.width = width;
    this.height = height;
    this.doorways = new ArrayList<Position>();
    if (random(1) < 0.5) doorways.add(Position.TOP);
    if (random(1) < 0.5) doorways.add(Position.RIGHT);
    if (random(1) < 0.5) doorways.add(Position.BOTTOM);
    if (random(1) < 0.5) doorways.add(Position.LEFT);
  }

  void draw() {

    // Draw walls
    fill(#17688A); 
    //noStroke();
    rect(x - width / 2, y - height / 2, width, height); // Center the room

     //Draw doorways
    fill(#155570); // Doorway color (white)
    for (Position doorway : doorways) {
      switch (doorway) {
        case TOP:
          rect(x - 10, y - height / 2, 10, 10);
          break;
        case RIGHT:
          rect(x + width / 2 - 10, y - 10, 10, 20);
          break;
        case BOTTOM:
          rect(x - 10, y + height / 2 - 10, 20, 10);
          break;
        case LEFT:
          rect(x - width / 2, y - 10, 10, 20);
          break;
      }
    }
  }
}
