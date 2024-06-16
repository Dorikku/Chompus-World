import ddf.minim.*;
import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.analysis.*;
import ddf.minim.effects.*;
import ddf.minim.AudioSample;

Minim minim;
AudioSample soundEffect;

int agentsCount = 300;  // number of agents
int enemyCount = 10;
int hearDistance = 70;   // screem distance
Antbot[] ants = new Antbot[agentsCount];
Antbot[] ants_med = new Antbot[enemyCount];
Antbot[] ants_lar = new Antbot[agentsCount];


int initialRoomCount = 10;
int roomCount = 50;
ArrayList<Room> rooms;
ArrayList<Room> frontier;
import processing.sound.*;

boolean showAnt=true;   // show/hide agents. Controlled by mouse click
float circleX, circleY;  // Position of the circle

// player movement
boolean[] keys = new boolean[128];
int score = 0;

// Game state
int state;
final int START = 0;
final int PLAYING = 1;
final int GAME_OVER = 2;

// Buttons
int buttonX = 600; // X-coordinate of the button
int buttonY = 600; // Y-coordinate of the button
int buttonWidth = 80; // Width of the button
int buttonHeight = 40; // Height of the button
color buttonColor; // Color of the button

// Hunger bar
int startTime;
int totalTime = 15000; // 15 seconds in milliseconds
float initialLength = 200; // initial length of the line in pixels
float lineLength = initialLength; // current length of the line
int last_score = 0;

boolean isKeyPressed = false;



void setup(){
   size(1280, 720);
   minim = new Minim(this);
   soundEffect = minim.loadSample("eat.wav");

   state = PLAYING;
   ellipseMode(CENTER);   
   
   
   textSize(50); // Initial text size
   rooms = new ArrayList<Room>();
   frontier = new ArrayList<Room>();
   generateDungeon();
   
   PVector playerSpawnPosition = findValidSpawnPosition();
   circleX = playerSpawnPosition.x;  // Initial position of the circle
   circleY = playerSpawnPosition.y; // Initial position of the circle
   
   for (int i = 0; i < agentsCount; i++) {
      PVector antSpawnPosition;
      boolean isValidPosition;
      do {
        antSpawnPosition = new PVector(random(50, width - 50), random(50, height - 50));
        isValidPosition = !isCollidingWithAnyRoom(antSpawnPosition, 10) && !isCollidingWithEnemies(antSpawnPosition, 10);
      } while (!isValidPosition);
      ants[i] = new Antbot(antSpawnPosition.x, antSpawnPosition.y, random(TAU), (random(0, 10) > 5));
    }
   
  for (int i = 0; i < enemyCount; i++) {
    PVector enemySpawnPosition;
    boolean isValidPosition;
    do {
      enemySpawnPosition = new PVector(random(50, width - 50), random(50, height - 50));
      isValidPosition = !isCollidingWithAnyRoom(enemySpawnPosition, 10);
    } while (!isValidPosition);
    ants_med[i] = new Antbot(enemySpawnPosition.x, enemySpawnPosition.y, random(TAU), true);
  }
  
    startTime = millis(); // store the start time

   
}

// Helper function to check collision with enemy ants
boolean isCollidingWithEnemies(PVector position, float radius) {
  for (Antbot enemy : ants_med) {
    if (enemy != null && dist(enemy.X, enemy.Y, position.x, position.y) < radius * 2) {
      return true;
    }
  }
  return false;
}

void draw(){
  background(#231837);  
  //noStroke();
  
  switch(state) {
    case START:
      displayStartScreen();
      break;
    case PLAYING:
      runGame();
      break;
    case GAME_OVER:
      displayGameOverScreen();
      break;
  }
  
}


void displayStartScreen() {
  

}

void runGame() {

  drawDungeon();
  
  int elapsedTime = millis() - startTime;
  int remainingTime = totalTime - elapsedTime;
  float currentLength = map(remainingTime, 0, totalTime, 0, lineLength);
  currentLength = max(currentLength, 0);
  strokeWeight(40);
  // Draw the line
  stroke(255,0, 0); // black color for the line
  line(0, 0, currentLength, 0);
  
  // Stop the animation after 15 seconds
  if (elapsedTime >= totalTime) {
    state = GAME_OVER;
  }

  
  score = calculateScore();
  
  int currentTime = millis();

  startTime += ((score - last_score) * 1000);
  
  // Ensure the start time adjustment doesn't exceed the 15-second limit
  if (startTime - currentTime > totalTime) {
    startTime = currentTime + totalTime;
  }

  last_score = score;
  
  String label = "Score: " + score;
  
  // Display the label at the top-left corner
  fill(255);
  text(label, width-250, 50);
  
  for (int i=0; i<(enemyCount); i++){
     ants_med[i].step(false);
  }
  
  if(showAnt){                  
    for (int i=0; i<(enemyCount); i++){ // отрисовка букашек, если нужно
       ants_med[i].drawAgent(3);
    }
  }
  

  fill(#FBCC69); 
  move();
  
  if(isTouchingColor(int(circleX), int(circleY), color(213, 81, 90)) && startTime > 5000)
  {
    state = GAME_OVER;
  }
  
  ellipse(circleX, circleY, 60, 60);
  
  
  for (int i=0; i<(agentsCount); i++){
     ants[i].step(true);
     //ants_med[i].step(false);
  }
  
  if(showAnt){                  
    for (int i=0; i<(agentsCount); i++){ // отрисовка букашек, если нужно
       if (ants[i].dead == false)
       {
          ants[i].drawAgent(1);
          //ants = removeElement(ants, i);
          
       }
       //ants[i].drawAgent(1);

       //ants_med[i].drawAgent(3);
    }
  }
  
  
}

void displayGameOverScreen() {
  String label = "GAME OVER";
  
  // Display the label at the top-left corner
  fill(255);
  text(label, (width/2) - label.length()* 10, height/2);
  
  label = "Score: (" + score + ")";
  
  // Display the label at the top-left corner
  fill(255);
  text(label, (width/2) - (label.length()* 8), (height/2) + 50);
  
  // Draw the button
  fill(buttonColor);
  rect(buttonX, buttonY, buttonWidth, buttonHeight);
  
  // Check if the mouse is over the button
  if (mouseX >= buttonX && mouseX <= buttonX + buttonWidth &&
      mouseY >= buttonY && mouseY <= buttonY + buttonHeight) {
    // Change the button color when the mouse is over it
    buttonColor = color(150);
  } else {
    buttonColor = color(200);
  }
}

void mousePressed() {
  //showAnt = !showAnt;
  // Check if the mouse is pressed over the button
  if (mouseX >= buttonX && mouseX <= buttonX + buttonWidth &&
      mouseY >= buttonY && mouseY <= buttonY + buttonHeight) {
    // Perform an action when the button is clicked
    //println("Button clicked!");
    setup();
    // You can add your own functionality here
  }
  isKeyPressed = true;
}

// Mouse event handling function
//void mouseMoved() {
//  // Update the position of the circle to the mouse position
//  circleX = mouseX;
//  circleY = mouseY;
//}

int calculateScore() {
  int temp_score = 0;
   for (int i=0; i<(agentsCount); i++){ // отрисовка букашек, если нужно
       if (ants[i].dead == true)
       {
          temp_score+=1;
       }
  }
  return temp_score;
}

void move() {
  float moveSpeed = 2;
  
  if (keys['a'] && !isTouchingColor(int(circleX - moveSpeed), int(circleY), color(23, 104, 138)))
    circleX-= moveSpeed;
  if (keys['d'] && !isTouchingColor(int(circleX + moveSpeed), int(circleY), color(23, 104, 138)))
    circleX+=moveSpeed;
  if (keys['w'] && !isTouchingColor(int(circleX), int(circleY - moveSpeed), color(23, 104, 138)))
   circleY-=moveSpeed;
  if (keys['s'] && !isTouchingColor(int(circleX), int(circleY + moveSpeed), color(23, 104, 138)))
    circleY+=moveSpeed;
}


void keyPressed() {
  keys[key] = true;
  //isKeyPressed = true;
}

void keyReleased() {
  keys[key] = false;
}

// Function to check if the ellipse is touching a specific color
boolean isTouchingColor(int checkX, int checkY, color targetColor) {
  loadPixels();
  int ellipseRadius = 10; // Since the ellipse diameter is 20

  // Check the perimeter of the ellipse
  for (int angle = 0; angle < 360; angle += 10) {
    int checkPixelX = checkX + int(ellipseRadius * cos(radians(angle)));
    int checkPixelY = checkY + int(ellipseRadius * sin(radians(angle)));

    // Ensure we are within the bounds of the window
    if (checkPixelX >= 0 && checkPixelX < width && checkPixelY >= 0 && checkPixelY < height) {
      color pixelColor = get(checkPixelX, checkPixelY);
      if (pixelColor == targetColor) {
        return true;
      }
    }
  }
  
  return false;
}




// ===================== MAP AUTOMATA ================
void generateDungeon() {
  rooms.clear();
  frontier.clear();

  // Generate initial seed rooms
  for (int i = 0; i < initialRoomCount; i++) {
    int x = int(random(width));
    int y = int(random(height));
    if (!isPositionOccupied(new PVector(x, y))) {
      Room initialRoom = new Room(x, y, 50, 50); // Start with default size
      rooms.add(initialRoom);
      frontier.add(initialRoom);
    }
  }

  // Expand rooms from the initial seeds
  while (rooms.size() < roomCount && !frontier.isEmpty()) {
    Room currentRoom = frontier.remove(0);
    applyShapeGrammarRules(currentRoom);
  }
}

void applyShapeGrammarRules(Room currentRoom) {
  if (rooms.size() >= roomCount)
    return;

  for (Position doorway : currentRoom.doorways) {
    PVector newRoomPosition = getRoomPosition(currentRoom, doorway);
    if (!isPositionOccupied(newRoomPosition)) {
      Room newRoom = new Room((int)newRoomPosition.x, (int)newRoomPosition.y, 50, 50);
      applyTransformation(newRoom);
      rooms.add(newRoom);
      frontier.add(newRoom); // Add new room to frontier
    }
  }
}

PVector getRoomPosition(Room room, Position position) {
  switch (position) {
    case TOP:
      return new PVector(room.x, room.y - room.height);
    case RIGHT:
      return new PVector(room.x + room.width, room.y);
    case BOTTOM:
      return new PVector(room.x, room.y + room.height);
    case LEFT:
      return new PVector(room.x - room.width, room.y);
  }
  return new PVector(room.x, room.y);
}

boolean isPositionOccupied(PVector position) {
  for (Room room : rooms) {
    if (dist(room.x, room.y, position.x, position.y) < max(room.width, room.height)) {
      return true;
    }
  }
  return false;
}

boolean isCollidingWithAnyRoom(PVector position, float radius) {
  for (Room room : rooms) {
    if (position.x + radius > room.x - room.width / 2 && position.x - radius < room.x + room.width / 2 &&
        position.y + radius > room.y - room.height / 2 && position.y - radius < room.y + room.height / 2) {
      return true;
    }
  }
  return false;
}

void drawDungeon() {
  for (Room room : rooms) {
    room.draw();
  }
}

void applyTransformation(Room room) {
  // Randomly increase or decrease the size of the room
  if (random(1) < 0.5) {
    room.width = int(random(30, 90));
    room.height = int(random(30, 90));
  }
}

PVector findValidSpawnPosition() {
  int maxAttempts = 100; // Maximum number of attempts to find a valid position
  for (int i = 0; i < maxAttempts; i++) {
    float x = random(width);
    float y = random(height);
    PVector spawnPosition = new PVector(x, y);
    if (!isCollidingWithAnyRoom(spawnPosition, 25)) {
      return spawnPosition;
    }
  }
  // If no valid spawn position is found after maxAttempts, return a default position
  return new PVector(width / 2, height / 2);
}

void checkAntCollision(Antbot ant) {
  float antRadius = 10; // Example radius, change as needed
  if (isCollidingWithAnyRoom(new PVector(ant.X, ant.Y), antRadius)) {
    // Handle collision, e.g., move the ant back or change direction
    ant.X -= cos(ant.angle) * 2;
    ant.Y -= sin(ant.angle) * 2;
    ant.angle += PI / 2; // Turn the ant
  }
}
