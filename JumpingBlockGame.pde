class Platform{
  float frontX, frontY, backX, backY;
  float plat_length;
  float speed;
  
  Platform(float startX, float startY, float platLength, float platSpeed){
    frontX = startX;
    frontY = startY;
    backX = startX + platLength;
    backY = startY;
    plat_length = platLength;
    speed = platSpeed;
  }
  
  void display(){
    fill(10, 240, 10);
    rectMode(CORNER);
    rect(frontX, frontY, plat_length, 30);
  }
  
  void move(float num){
    frontX -= speed + num;
    backX -= speed + num;
  }
  
  boolean passPlayer(float num){
    if (backX <= num){
      return true;
    }
    return false;
  }
  
  boolean underPlayer(float num){
    if (frontX <= num - 17.5){
      return true;
    }
    return false;
  }
  
  boolean notOnScreen(){
    if (backX <= 0){
      return true;
    }
    return false;
  }
}

class Box{
  float frontX, backX, Y;
  float speedY = 0;
  float jumpSpeed = 20;
  float size;
  boolean jumped = false;
  
  Box(float startX, float startY, float boxSize){
    frontX = startX;
    backX = startX + boxSize;
    Y = startY;
    size = boxSize;
  }
  
  void display(){
    fill(0);
    square(frontX, Y, size);
  }
  
  void move(){
    Y += speedY;
    if (Y + size > Ground){
      Y = Ground - size;
      speedY = 0;
      if(Y + size == Ground){
        jumped = false;
      }
    }
    else{
      speedY++;
    }
    if(Y + size >= Ground && mousePressed){
      speedY =- jumpSpeed;
      jumped = true;
    }
  }
  
  boolean dies(){
    if(Y + size == endGround){
      return true;
    }
    return false;
  }
}

ArrayList<Platform> gamePlats = new ArrayList<Platform>();
ArrayList<PImage> gamePics = new ArrayList<PImage>();
Box player = new Box(180, 250, 35);
int focusIndex = 0, landingCount = 0, foodPoints = 0, add = 0, addSize = 0, PicNum = 0, getTime;
float Ground, endGround = 600, nextGround, gameSpeed = 0;
long timer = System.currentTimeMillis();
boolean tracker = true, bgTracker = true;

Platform createPlat(float prevX, float prevY){
  if (landingCount % 5 == 0){
    add = landingCount * 10;
  }
  float newX = random(prevX + 99 + add, prevX + 149 + add);
  float newY = random(prevY - 30, prevY + 60);
  while (newY > 400 || newY < 200){
    newY = random(prevY - 50, prevY + 50);
  }
  float newLength = random(300, 499 + add);
  return new Platform(newX, newY, newLength, 4);
}

boolean landNextPlat(Platform plat, Box player){
  if ((plat.frontX <= player.backX)){
    return true;
  }
  return false;
}

void setupPic(){
  PImage img1 = loadImage("pic1.jpg");
  PImage img2 = loadImage("pic2.jpg");
  PImage img3 = loadImage("pic3.jpg");
  PImage img4 = loadImage("pic4.png");
  img1.resize(width, height);
  img2.resize(width, height);
  img3.resize(width, height);
  img4.resize(width, height);
  gamePics.add(img1);
  gamePics.add(img2);
  gamePics.add(img3);
  gamePics.add(img4);
}

void displayGameInfo(){
  textSize(25);
  fill(255);
  text("Time: " + (int(System.currentTimeMillis() - timer))/1000 + " seconds", 10, 25);
  text("Score: " + (landingCount + foodPoints), 10, 55);
}

void gameGenerator(){
  for (int i = gamePlats.size() - 1; i >= 0; i--){
    gamePlats.get(i).move(gameSpeed);
    gamePlats.get(i).display();
  }
}

void showGameOver(){
  textSize(100);
  textAlign(CENTER, CENTER);
  fill(0);
  text("Game Over", 500, 180);
  textSize(36);
  textAlign(CENTER, CENTER);
  fill(255);
  text("Score: " + (landingCount + foodPoints), 500, 350);
}

void setup(){
  size(1000, 500);
  smooth(2);
  setupPic();
  Platform startPlat = new Platform(150, 300, 800, 4);
  gamePlats.add(startPlat);
  for (int i = 0; i < 5; i++){
    gamePlats.add(createPlat(gamePlats.get(i).backX, gamePlats.get(i).backY));
  }
  Ground = gamePlats.get(0).frontY;
}

void draw(){
  background(gamePics.get(PicNum));
  if (((int(System.currentTimeMillis() - timer))/1000) % 20 == 0 && bgTracker){
    PicNum++;
    if (PicNum == 4){
      PicNum = 0;
    }
    getTime = (int(System.currentTimeMillis() - timer))/1000;
    gameSpeed += .2;
    println("Game speed increased: " + gameSpeed);
    bgTracker = false;
  }
  else if ((int(System.currentTimeMillis() - timer))/1000 == getTime + 1){
    bgTracker = true;
  }
  player.move();
  gameGenerator();
  Platform focusPlat = gamePlats.get(focusIndex);
  Platform nextPlat = gamePlats.get(focusIndex + 1);
  nextGround = nextPlat.frontY;
  if (focusPlat.passPlayer(player.frontX) && tracker){
    if (player.jumped && (player.Y + player.size > nextGround)){
      Ground = endGround;
    }
    else if (player.jumped && landNextPlat(nextPlat, player)){
      Ground = nextGround;
      tracker = false;
      landingCount++;
    }
    else{
      Ground = endGround;
    }
  }
  if (focusPlat.notOnScreen()){
    gamePlats.remove(0);
    tracker = true;
  }
  gamePlats.add(createPlat(gamePlats.get(gamePlats.size()-1).backX, gamePlats.get(gamePlats.size()-1).backY));
  player.display();
  displayGameInfo();
  if (player.dies()){
    noLoop();
    if (player.dies()){
      showGameOver();
    }
  }
}
