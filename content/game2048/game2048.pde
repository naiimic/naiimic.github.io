class Player {
  long fitness;
  boolean dead = false;
  int score = 0;

  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  ArrayList<Tile> tiles = new ArrayList<Tile>();
  ArrayList<PVector> emptyPositions = new ArrayList<PVector>();
  PVector moveDirection = new PVector();
  boolean movingTheTiles =false;
  boolean tileMoved = false;

  float[][] startingPositions = new float[2][3];

  State start;


  //constructor

  Player() {
    fillEmptyPositions(); 

    //add 2 tiles

    addNewTile();
    addNewTile();

    startingPositions[0][0] = tiles.get(0).position.x;
    startingPositions[0][1] = tiles.get(0).position.y;
    startingPositions[0][2] = tiles.get(0).value;


    startingPositions[1][0] = tiles.get(1).position.x;
    startingPositions[1][1] = tiles.get(1).position.y;
    startingPositions[1][2] = tiles.get(1).value;
  }

  Player(boolean isReplay) {

    fillEmptyPositions();
  }


  void setTilesFromHistory() {

    tiles.add(new Tile(floor(startingPositions[0][0]), floor(startingPositions[0][1])));
    tiles.get(0).value = floor(startingPositions[0][2]);

    tiles.add(new Tile(floor(startingPositions[1][0]), floor(startingPositions[1][1])));
    tiles.get(1).value = floor(startingPositions[1][2]);


    for ( int i = 0; i< emptyPositions.size(); i ++) {
      if (compareVec(emptyPositions.get(i), tiles.get(0).position) || compareVec(emptyPositions.get(i), tiles.get(1).position)) {
        emptyPositions.remove(i);
        i--;
      }
    }
  }


  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  void show() {
    //show the ones which are going to die first so it looks like they slip under the other ones
    for (int i = 0; i< tiles.size(); i++) {
      if (tiles.get(i).deathOnImpact) {
        tiles.get(i).show();
      }
    }

    for (int i = 0; i< tiles.size(); i++) {
      if (!tiles.get(i).deathOnImpact) {
        tiles.get(i).show();
      }
    }
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  void move() {
    if (movingTheTiles) {
      for (int i = 0; i< tiles.size(); i++) {
        tiles.get(i).move(moveSpeed);
      }
      if (doneMoving()) {
        for (int i = 0; i< tiles.size(); i++) {//kill collided tiles
          if (tiles.get(i).deathOnImpact) {
            tiles.remove(i);
            i--;
          }
        }

        movingTheTiles =false;
        setEmptyPositions();
        addNewTileNotRandom();
      }
    }
  }

  boolean doneMoving() {

    for (int i = 0; i< tiles.size(); i++) {
      if (tiles.get(i).moving) {
        return false;
      }
    }

    return true;
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------
  void update() {
    move();
  }
  //-------------------------------------------------------------------------------------------------------------------------------------

  void fillEmptyPositions() {
    for (int i = 0; i< 4; i++) {
      for (int j =0; j< 4; j++) {
        emptyPositions.add(new PVector(i, j));
      }
    }
  }
  //---------------------------------

  void setEmptyPositions() {
    emptyPositions.clear();
    for (int i = 0; i< 4; i++) {
      for (int j =0; j< 4; j++) {
        if (getValue(i, j) ==0) {
          emptyPositions.add(new PVector(i, j));
        }
      }
    }
  }

  //----------------------------------------------------------------------------------------------------------------------------------------------------



  void moveTiles() {
    tileMoved = false;
    for (int i = 0; i< tiles.size(); i++) {
      tiles.get(i).alreadyIncreased = false;
    }
    ArrayList<PVector> sortingOrder = new ArrayList<PVector>();
    PVector sortingVec = new PVector();
    boolean vert = false;//is up or down
    if (moveDirection.x ==1) {//right
      sortingVec = new PVector(3, 0);
      vert = false;
    } else if (moveDirection.x ==-1) {//left
      sortingVec = new PVector(0, 0);
      vert = false;
    } else if (moveDirection.y ==1) {//down
      sortingVec = new PVector(0, 3);
      vert = true;
    } else if (moveDirection.y ==-1) {//right
      sortingVec = new PVector(0, 0);
      vert = true;
    }

    for (int i = 0; i< 4; i++) {
      for (int j = 0; j<4; j++) {
        PVector temp = new PVector(sortingVec.x, sortingVec.y);
        if (vert) {
          temp.x += j;
        } else {
          temp.y += j;
        }
        sortingOrder.add(temp);
      }
      sortingVec.sub(moveDirection);
    }

    for (int j = 0; j< sortingOrder.size(); j++) {
      for (int i = 0; i< tiles.size(); i++) {
        if (tiles.get(i).position.x == sortingOrder.get(j).x && tiles.get(i).position.y == sortingOrder.get(j).y) {
          PVector moveTo = new PVector(tiles.get(i).position.x + moveDirection.x, tiles.get(i).position.y + moveDirection.y);
          int valueOfMoveTo = getValue(floor(moveTo.x), floor(moveTo.y));
          while (valueOfMoveTo == 0) {
            //tiles.get(i).position = new PVector(moveTo.x, moveTo.y); 
            tiles.get(i).moveTo(moveTo);
            moveTo = new PVector(tiles.get(i).positionTo.x + moveDirection.x, tiles.get(i).positionTo.y + moveDirection.y);
            valueOfMoveTo = getValue(floor(moveTo.x), floor(moveTo.y));
            tileMoved = true;
          }

          if (valueOfMoveTo == tiles.get(i).value) {
            //merge tiles
            Tile temp = getTile(floor(moveTo.x), floor(moveTo.y));



            if (!temp.alreadyIncreased) {

              tiles.get(i).moveTo(moveTo);
              tiles.get(i).deathOnImpact = true;


              //tiles.remove(i);
              temp.alreadyIncreased = true;
              tiles.get(i).alreadyIncreased = true;
              temp.value *=2;
              score += temp.value;
              temp.setColour();
              tileMoved = true;
            }
          }
        }
      }
    }
    if (tileMoved) {
      movingTheTiles = true;
    }
  }


  //------------------------------------------------------------------------------------------------------------------------------------

  void addNewTile() {


    PVector temp = emptyPositions.remove(floor(random(emptyPositions.size())));
    tiles.add(new Tile(floor(temp.x), floor(temp.y)));
  }


  void addNewTileNotRandom() {
    int notRandomNumber = score;// %
    for (int i = 0; i< tiles.size(); i++) {
      notRandomNumber += floor(tiles.get(i).position.x);
      notRandomNumber += floor(tiles.get(i).position.y);
      notRandomNumber += i;
    }

    int notRandomNumber2 = notRandomNumber %  emptyPositions.size();
    PVector temp = emptyPositions.remove(notRandomNumber2);
    tiles.add(new Tile(floor(temp.x), floor(temp.y)));

    if (notRandomNumber % 10 < 9) {
      tiles.get(tiles.size() -1).value = 2;
    } else {
      tiles.get(tiles.size() -1).value = 4;
    }

    tiles.get(tiles.size() -1).setColour();
  }


  //--------------------------------------------------------------------------------------------------------------------------
  int getValue(int x, int y) {
    if (x > 3 || x <0 || y>3 || y<0) { 
      return -1;
    }
    for (int i = 0; i< tiles.size(); i++) {
      if (tiles.get(i).positionTo.x == x && tiles.get(i).positionTo.y ==y) {
        return tiles.get(i).value;
      }
    }
    return 0;//means that its free
  }


  //----------------------------------------------------------------------------------------------------------------------------------
  Tile getTile(int x, int y) {
    for (int i = 0; i< tiles.size(); i++) {
      if (tiles.get(i).positionTo.x == x && tiles.get(i).positionTo.y ==y) {
        return tiles.get(i);
      }
    }

    return null;
  }


  //-----------------------------------------------------------------------------------------------------------------------------------
  void setStartState() {
    start = new State();
    //clone tiles
    for (int i = 0; i< tiles.size(); i++) {
      start.tiles.add(tiles.get(i).clone());
    }
    start.score = score;
    start.setEmptyPositions();
  }

//-------------------------------------------------------------------------------------------------------------------------------------
//gets the best move by looking x number of moves into the future.
  void getMove() {
    setStartState();
    start.getChildrenValues(0);
    switch(start.bestChild) {
    case 0 :
      moveDirection = new PVector(1, 0);
      break;
    case 1 :
      moveDirection = new PVector(-1, 0);
      break;
    case 2 :
      moveDirection = new PVector(0, 1);
      break;
    case 3 :
      moveDirection = new PVector(0, -1);
      break;
      
      
    }
    
    if(start.children[start.bestChild].value <= 0){
     setup(); 
    }
  }
}

class State {
  State[] children = new State[4];
  float value = 0;
  int score = 0;

  ArrayList<Tile> tiles = new ArrayList<Tile>();
  ArrayList<PVector> emptyPositions = new ArrayList<PVector>();
  boolean differentFromParent = false;
  boolean dead =false;
  int bestChild =0;

  State() {
  }

  State clone() {
    State clone = new State();
    //clone tiles
    for (int i = 0; i< tiles.size(); i++) {
      clone.tiles.add(tiles.get(i).clone());
    }
    clone.score = score;
    clone.setEmptyPositions();
    return clone;
  }

  void fillEmptyPositions() {
    for (int i = 0; i< 4; i++) {
      for (int j =0; j< 4; j++) {
        emptyPositions.add(new PVector(i, j));
      }
    }
  }
  
  //---------------------------------//

  void setEmptyPositions() {
    emptyPositions.clear();
    for (int i = 0; i< 4; i++) {
      for (int j =0; j< 4; j++) {
        if (getValue(i, j) ==0) {
          emptyPositions.add(new PVector(i, j));
        }
      }
    }
  }


  void move(int x, int y) {
    PVector moveDirection = new PVector(x, y);
    differentFromParent = false;
    for (int i = 0; i< tiles.size(); i++) {
      tiles.get(i).alreadyIncreased = false;
    }
    ArrayList<PVector> sortingOrder = new ArrayList<PVector>();
    PVector sortingVec = new PVector();
    boolean vert = false;//is up or down
    if (x ==1) {//right
      sortingVec = new PVector(3, 0);
      vert = false;
    } else if (x ==-1) {//left
      sortingVec = new PVector(0, 0);
      vert = false;
    } else if (y ==1) {//down
      sortingVec = new PVector(0, 3);
      vert = true;
    } else if (y ==-1) {//right
      sortingVec = new PVector(0, 0);
      vert = true;
    }
    for (int i = 0; i< 4; i++) {
      for (int j = 0; j<4; j++) {
        PVector temp = new PVector(sortingVec.x, sortingVec.y);
        if (vert) {
          temp.x += j;
        } else {
          temp.y += j;
        }
        sortingOrder.add(temp);
      }
      sortingVec.sub(moveDirection);
    }

    for (int j = 0; j< sortingOrder.size(); j++) {
      for (int i = 0; i< tiles.size(); i++) {
        if (tiles.get(i).position.x == sortingOrder.get(j).x && tiles.get(i).position.y == sortingOrder.get(j).y) {
          PVector moveTo = new PVector(tiles.get(i).position.x + moveDirection.x, tiles.get(i).position.y + moveDirection.y);
          int valueOfMoveTo = getValue(floor(moveTo.x), floor(moveTo.y));
          while (valueOfMoveTo == 0) {
            //tiles.get(i).position = new PVector(moveTo.x, moveTo.y); 
            tiles.get(i).moveToNow(moveTo);
            moveTo = new PVector(tiles.get(i).position.x + moveDirection.x, tiles.get(i).position.y + moveDirection.y);
            valueOfMoveTo = getValue(floor(moveTo.x), floor(moveTo.y));
            differentFromParent = true;
          }

          if (valueOfMoveTo == tiles.get(i).value) {
            //merge tiles
            Tile temp = getTile(floor(moveTo.x), floor(moveTo.y));



            if (!temp.alreadyIncreased) {

              tiles.get(i).moveToNow(moveTo);
              tiles.get(i).deathOnImpact = true;


              //tiles.remove(i);
              temp.alreadyIncreased = true;
              tiles.get(i).alreadyIncreased = true;
              temp.value *=2;
              score += temp.value;
              temp.setColour();
              differentFromParent = true;
            }
          }
        }
      }
    }
    if (differentFromParent) {

      addNewTileNotRandom();
    } else {
      dead= true;
    }
  }

  // ------------------------------- //
  
  void addNewTile() {


    PVector temp = emptyPositions.remove(floor(random(emptyPositions.size())));
    tiles.add(new Tile(floor(temp.x), floor(temp.y)));
  }


  void addNewTileNotRandom() {

    setEmptyPositions();
    if (emptyPositions.size() ==0) {
      dead = true; 
      return;
    }
    int notRandomNumber = score;// %
    for (int i = 0; i< tiles.size(); i++) {
      notRandomNumber += floor(tiles.get(i).position.x);
      notRandomNumber += floor(tiles.get(i).position.y);
      notRandomNumber += i;
    }

    int notRandomNumber2 = notRandomNumber %  emptyPositions.size();
    PVector temp = emptyPositions.remove(notRandomNumber2);
    tiles.add(new Tile(floor(temp.x), floor(temp.y)));

    if (notRandomNumber % 10 < 9) {
      tiles.get(tiles.size() -1).value = 2;
    } else {
      tiles.get(tiles.size() -1).value = 4;
    }

    tiles.get(tiles.size() -1).setColour();
  }

  // ------------------------------- //

  int getValue(int x, int y) {
    if (x > 3 || x <0 || y>3 || y<0) { 
      return -1;
    }
    for (int i = 0; i< tiles.size(); i++) {
      if (tiles.get(i).position.x == x && tiles.get(i).position.y ==y) {
        return tiles.get(i).value;
      }
    }
    return 0;//means that its free
  }

  // ------------------------------- //
  
  Tile getTile(int x, int y) {
    for (int i = 0; i< tiles.size(); i++) {
      if (tiles.get(i).position.x == x && tiles.get(i).position.y ==y) {
        return tiles.get(i);
      }
    }
    return null;
  }
  
  // ------------------------------- //
  
  void setValue() {
    if (dead) {
      value =0;
      return;
    }
    value = 0;
    value += score;
    //value += random(1000);
    
    for (int i = 0; i< tiles.size(); i++) {
      for (int j = 0; j< tiles.size(); j++) {
        if (i != j && dist(tiles.get(i).position.x, tiles.get(i).position.y, tiles.get(j).position.x, tiles.get(j).position.y) <= 1) {
          //tiles whihc are adjacent are good
          if (tiles.get(i).value == tiles.get(j).value) {
            value += tiles.get(i).value/2;
          }

          //have adjacent things be close in value
          if (tiles.get(i).value == tiles.get(j).value/2) {
            value += tiles.get(i).value/4;
          } else  if (tiles.get(j).value == tiles.get(i).value/2) {
            value += tiles.get(j).value/4;
          }
        }
      }
    }
    //value empty spaces  
    value*= (1.0+(emptyPositions.size() * 0.05));
    int max = 0 ;
    int maxTile = 0;
    for (int i = 0; i< tiles.size(); i++) {
      if (tiles.get(i).value > max) {
        max = tiles.get(i).value;
        maxTile = i;
      }
    }

    if (tiles.get(maxTile).position.y ==0) {
      value *= 1.5;
      if (tiles.get(maxTile).position.x ==0) {
        value *=3;
        max = 0;
        int secondBest = 0;
        for (int i = 0; i< tiles.size(); i++) {
          if (i != maxTile && tiles.get(i).value > max) {
            max = tiles.get(i).value;
            secondBest = i;
          }
        }
        if (tiles.get(secondBest).position.y ==0 && tiles.get(secondBest).position.x ==1) {
          value *= 1.2;
          max = 0;
          int thirdBest = 0;
          for (int i = 0; i< tiles.size(); i++) {
            if (i != maxTile && i != secondBest && tiles.get(i).value > max) {
              max = tiles.get(i).value;
              thirdBest = i;
            }
          }
          if (tiles.get(thirdBest).position.y ==0 && tiles.get(thirdBest).position.x ==2) {
            value *= 1.2;
          }
        }
      }
    } 
  }


  // ------------------------------- //
  float getChildrenValues(int depth) {
    if (depth >= maxDepth) {
      setValue();
      return value;
    }

    for (int i = 0; i< 4; i++) {
      children[i] = clone();
    }

    children[0].move(1, 0);

    children[1].move(-1, 0);

    children[2].move(0, 1);

    children[3].move(0, -1);

    for (int i = 0; i< 4; i++) {
      if (!children[i].differentFromParent) {
        children[i].dead = true;
      }
    }



    float max = 0;
    int maxChild =0;
    for (int i = 0; i  < 4; i++) {
      if (!children[i].dead) {
        float temp = children[i].getChildrenValues(depth+1) ;

//        if (i == 2) {
//          temp *= 0.5;
//        }
//        if (depth ==0) {
//          println("Child " + i + "gets a value of " + temp);
//        }
        if (temp > max) {
          max =  temp;
          maxChild = i;
        }
      }
    }


    bestChild = maxChild;
    
    setValue();
    if(max < value){
     return value; 
    }
    return max;
  }
}

class Tile {
  int value;
  PVector position;
  PVector pixelPos;//top left
  boolean alreadyIncreased = false;
  boolean moving = false;

  color colour;
  PVector positionTo;
  PVector pixelPosTo;


  boolean deathOnImpact =false;

  Tile(int x, int y) {
    if (random(1)< 0.1) {
      value = 4;
    } else {
      value =2;
    }

    position = new PVector(x, y);
    positionTo = new PVector(x, y);

    pixelPos = new PVector(xoffset +x*100/2 + (x+1) *5/2, yoffset + y*100/2 + (y+1) *5/2);
    pixelPosTo = new PVector(xoffset + x*100/2 + (x+1) *5/2, yoffset + y*100/2 + (y+1) *5/2);

    setColour();
  }

  //---------------------------------//

  void show() {
    if (!deathOnImpact || moving) {
      fill(colour);
      noStroke();
      rect(pixelPos.x, pixelPos.y, 100/2, 100/2);
      if (value < 8) {
        fill(40);
      } else {
        fill(240);
      }
      textAlign(CENTER, CENTER);
      textSize(20);
      text(value, pixelPos.x+50/2, pixelPos.y+50/2);
    }
  }

  //---------------------------------//

  void moveTo(PVector to) {
    positionTo = new PVector(to.x, to.y);
    pixelPosTo = new PVector(xoffset +to.x*100/2 + (to.x+1) *5/2, yoffset +to.y*100/2 + (to.y+1) *5/2);
    moving = true;
  }
  void moveToNow(PVector to) {
    position = new PVector(to.x, to.y);
    pixelPos = new PVector(xoffset +to.x*100/2 + (to.x+1) *5/2, yoffset +to.y*100/2 + (to.y+1) *5/2);
  }

  //---------------------------------//
  
  void move(int speed) {
    if (moving) {
      if (!teleport && dist(pixelPos.x, pixelPos.y, pixelPosTo.x, pixelPosTo.y) > speed) {
        PVector MoveDirection = new PVector(positionTo.x - position.x, positionTo.y - position.y); 
        MoveDirection.normalize();
        MoveDirection.mult(speed);
        pixelPos.add(MoveDirection);
      } else {
        moving = false;
        pixelPos = new PVector(pixelPosTo.x, pixelPosTo.y);
        position = new PVector(positionTo.x, positionTo.y);
      }
    }
  }

  //---------------------------------//

  void setColour() {
    switch(value) {
    case 2:
      colour = color(238, 228, 218);
      break;
    case 4:
      colour = color(237, 224, 200);
      break;       
    case 8:
      colour = color(242, 177, 121);
      break;
    case 16:
      colour = color(2345, 149, 99);
      break;
    case 32:
      colour = color(246, 124, 95);
      break;
    case 64:
      colour = color(246, 94, 59);
      break;
    case 128:
      colour = color(237, 207, 114);
      break;
    case 256:
      colour = color(237,204,97);
      break;
    case 512:
      colour = color(237,200,80);
      break;
    case 1024:
      colour = color(237,197,63);
      break;
    case 2048:
      colour = color(237,197,1);
      break;
    case 4096:
      colour = color(94,218,146);
      break;
      
    }
  }

  Tile clone() {
    Tile clone = new Tile(floor(position.x), floor(position.y));
    clone.value = value;
    clone.setColour();

    return clone;
  }
}

Player p;
boolean released = true;
boolean teleport = false;

int maxDepth = 4;
//this means that there is some information specific to the game to input here

int pauseCounter = 100;
int nextConnectionNo = 1000;
int speed = 60;
int moveSpeed = 60;

int xoffset = 0;
int yoffset = 0;

void setup() {
  frameRate(20);
  size(213, 213);
  p = new Player();
}

void draw() {
  background(187,173,160);
  fill(205,193,180);
  for(int i = 0 ; i< 4 ;i++){
    for(int j =0; j< 4 ;j++){
      rect(i*100/2 + (i+1) *5/2, j*100/2 + (j+1) *5/2, 100/2, 100/2);  
    
    }
    
    
  }
  p.move();
  p.show();
  
  if(p.doneMoving()){
    p.getMove();
    p.moveTiles();
  }
}


void keyPressed() {
  if (released) {
    switch(key) {
    case CODED:
      switch(keyCode) {
      case UP:
        if (p.doneMoving()) {
          p.moveDirection = new PVector(0, -1);
          p.moveTiles();
        }
        break;
      case DOWN:
        if (p.doneMoving()) {
          p.moveDirection = new PVector(0, 1);
          p.moveTiles();
        }
        break;
      case LEFT:
        if (p.doneMoving()) {
          p.moveDirection = new PVector(-1, 0);
          p.moveTiles();
        }
        break;
      case RIGHT:
        if (p.doneMoving()) {
          p.moveDirection = new PVector(1, 0);
          p.moveTiles();
        }
        break;
      }
    }
    released = false;
  }
}

void keyReleased(){
 released = true; 
  
}

boolean compareVec(PVector p1, PVector p2) {
  if (p1.x == p2.x && p1.y == p2.y) {
    return true;
  }
  return false;
}
