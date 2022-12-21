//number of tiles
int tilesX = 10;
int tilesY = 10;

//size of each tile
int tileSize = 30;

Tile[][] tiles = new Tile[tilesX][tilesY];

//self explanatory
int numberOfBombs = 10;
int bombLimit = 25;
boolean gameOver = false;
AI ai;
//images used
PImage flag;
PImage cursor;
PImage hiddenSprite;
PImage bombSprite;
PImage unhiddenSprite;
PFont font;

//the number of bombs left
int bombsLeft = numberOfBombs;

//frame rate
int speed = 60;

//did the ai win or lose
boolean loser = false;
boolean winner = false;

//the amount of milliseconds it took to complete the game
int timer = 0;
boolean gameOverShow = true;

void setup() {
  frameRate(10);
  size(300, 300); 
  cursor = loadImage("content/minesweeper/cursor.png");
  flag = loadImage("content/minesweeper/flag.png");
  hiddenSprite  = loadImage("content/minesweeper/hidden.png");
  bombSprite = loadImage("content/minesweeper/bomb.png");
  unhiddenSprite = loadImage("content/minesweeper/unhidden.png");
  for (int i = 0; i< tilesX; i++) {
    for (int j = 0; j< tilesY; j++) {
      tiles[i][j] = new Tile(i*tileSize, j*tileSize);
    }
  }

  for (int i = 0; i< numberOfBombs; i++) {
    int x  = floor(random(tilesX));
    int y  = floor(random(tilesY));
    while (tiles[x][y].bomb) {//find a tile which isnt a bomb
      x  = floor(random(tilesX));
      y  = floor(random(tilesY));
    }
    tiles[x][y].bomb = true;
  }
  calculateNumbers();
  ai = new AI();
  font = loadFont("content/minesweeper/AgencyFB-Bold-15.vlw");
}


void draw() {

  if (!gameOver) {
    //background(0);
    for (int i = 0; i< tilesX; i++) {
      for (int j = 0; j< tilesY; j++) {
        if (tiles[i][j].changed) {//only show changed tiles for efficiency
          tiles[i][j].show();
          tiles[i][j].changed = false;
        }
      }
    }

    ai.move();
  } else {
    if (gameOverShow) {//if game over then show the bombs if you didnt win
      for (int i = 0; i< tilesX; i++) {
        for (int j = 0; j< tilesY; j++) {
          tiles[i][j].show();
        }
      }
      if (winner) {
        //println("Timer", millis() - timer);//print time
        //gameOverShow = false;

        // delay(1000);
        tiles = new Tile[tilesX][tilesY];
        gameOver = false;
        loser = false;
        winner = false;
        timer = millis();

        gameOverShow = true;

        bombsLeft = numberOfBombs;
        numberOfBombs = numberOfBombs + 1;
        // println(numberOfBombs);
        
        if(numberOfBombs <= bombLimit){

          //reset tiles
          for (int i = 0; i< tilesX; i++) {
            for (int j = 0; j< tilesY; j++) {
              tiles[i][j] = new Tile(i*tileSize, j*tileSize);
            }
          }
  
          //randomise bomb locations
          for (int i = 0; i< numberOfBombs; i++) {
            int x  = floor(random(tilesX));
            int y  = floor(random(tilesY));
            while (tiles[x][y].bomb) {//find a tile which isnt a bomb
              x  = floor(random(tilesX));
              y  = floor(random(tilesY));
            }
            tiles[x][y].bomb = true;
          }
  
          calculateNumbers();
          ai = new AI();
        } else {
          gameOverShow = false; 
          gameOver = true;
        }
      } else {
        //if we lost then show then pause for a bit then reset the game

        // delay(200);
        tiles = new Tile[tilesX][tilesY];
        gameOver = false;
        loser = false;
        winner = false;
        timer = millis();

        gameOverShow = true;

        bombsLeft = numberOfBombs;
        //reset tiles
        for (int i = 0; i< tilesX; i++) {
          for (int j = 0; j< tilesY; j++) {
            tiles[i][j] = new Tile(i*tileSize, j*tileSize);
          }
        }

        //randomise bomb locations
        for (int i = 0; i< numberOfBombs; i++) {
          int x  = floor(random(tilesX));
          int y  = floor(random(tilesY));
          while (tiles[x][y].bomb) {//find a tile which isnt a bomb
            x  = floor(random(tilesX));
            y  = floor(random(tilesY));
          }
          tiles[x][y].bomb = true;
        }

        calculateNumbers();
        ai = new AI();
      }
    }
  }
}
//---------------------------------------------------------------------------------------------------------------------------------------------
void keyPressed() {
  switch(key) {
  case '+':
    speed +=10;
    frameRate(speed);
    break;
  case '-':
    speed -=10;
    frameRate(speed);
  }
}
//---------------------------------------------------------------------------------------------------------------------------------------------

void mousePressed() {
  Tile temp = getTileNear(mouseX, mouseY);
  if (mouseButton == LEFT) {

    if (!temp.hidden || temp.flagged) {
      return;
    }
    if (temp.bomb) {
      gameOver=true;
      //println("DEAD");
      return;
    }
    temp.hidden = false;
    if (temp.bombsNear ==0) {
      clickedZero(floor(temp.pos.x/tileSize), floor(temp.pos.y/tileSize));
    }
  } else if (mouseButton == RIGHT) {
    if (!temp.hidden ) {
      return;
    }
    temp.flagged = !temp.flagged;
    if (temp.flagged) {
      bombsLeft --;
      if (bombsLeft ==0) {
        //println("winner");
        gameOver = true;
      }
    } else {
      bombsLeft++;
    }
  }
}

//---------------------------------------------------------------------------------------------------------------------------------------------
Tile getTileNear(float x, float y) {
  float min = 10000;
  int minIndexI = 0;
  int minIndexJ = 0;

  for (int i = 0; i< tilesX; i++) {
    for (int j = 0; j< tilesY; j++) {
      if (dist(x, y, tiles[i][j].pos.x +15, tiles[i][j].pos.y+15) < min) {
        min = dist(x, y, tiles[i][j].pos.x + 15, tiles[i][j].pos.y + 15);
        minIndexI = i;
        minIndexJ = j;
      }
    }
  }

  return tiles[minIndexI][minIndexJ];
}
//---------------------------------------------------------------------------------------------------------------------------------------------
void calculateNumbers() {
  for (int i = 0; i< tilesX; i++) {
    for (int j = 0; j< tilesY; j++) {
      int n = 0;


      if ( i > 0 && tiles[i-1][j].bomb) n++;
      if (i < tilesX-1 && tiles[i+1][j].bomb) n++;
      if (i > 0 && j > 0 &&  tiles[i-1][j-1].bomb) n++;
      if (i < tilesX-1 &&j > 0 &&  tiles[i+1][j-1].bomb) n++;
      if (i > 0 && j < tilesY-1 &&  tiles[i-1][j+1].bomb) n++;
      if (i < tilesX-1 &&j < tilesY-1 &&  tiles[i+1][j+1].bomb) n++;
      if (j < tilesY-1 && tiles[i][j+1].bomb) n++;
      if (j > 0 &&  tiles[i][j-1].bomb) n++;
      tiles[i][j].bombsNear = n;
    }
  }
}
//---------------------------------------------------------------------------------------------------------------------------------------------
//called when an empty square is clicked then we need to click all 0s near it
void clickedZero(int i, int j) {
  tiles[i][j].hidden = false;
  tiles[i][j].changed = true;

  //cheeky recursion
  if ( i > 0 && tiles[i-1][j].hidden && tiles[i-1][j].bombsNear ==0) clickedZero(i-1, j);
  if (i < tilesX-1 &&  tiles[i+1][j].hidden && tiles[i+1][j].bombsNear ==0) clickedZero(i+1, j);
  if (j < tilesY-1 &&  tiles[i][j+1].hidden && tiles[i][j+1].bombsNear ==0) clickedZero(i, j+1);
  if (j > 0 &&  tiles[i][j-1].hidden &&  tiles[i][j-1].bombsNear ==0) clickedZero(i, j-1);



  //click all non 0 tiles around it
  if ( i > 0 && tiles[i-1][j].hidden && tiles[i-1][j].bombsNear != 0) {
    tiles[i-1][j].hidden = false;
    tiles[i-1][j].changed = true;
  }
  if (i < tilesX-1 &&  tiles[i+1][j].hidden && tiles[i+1][j].bombsNear != 0) {
    tiles[i+1][j].hidden = false;
    tiles[i+1][j].changed = true;
  }
  if (i > 0 && j > 0 &&  tiles[i-1][j-1].hidden  && tiles[i-1][j-1].bombsNear != 0) {
    tiles[i-1][j-1].hidden = false;
    tiles[i-1][j-1].changed = true;
  }
  if (i < tilesX-1 &&j > 0 &&   tiles[i+1][j-1].hidden  && tiles[i+1][j-1].bombsNear != 0) {
    tiles[i+1][j-1].hidden = false;
    tiles[i+1][j-1].changed = true;
  }
  if (i > 0 && j < tilesY-1 &&   tiles[i-1][j+1].hidden && tiles[i-1][j+1].bombsNear != 0 ) {
    tiles[i-1][j+1].hidden = false;
    tiles[i-1][j+1].changed = true;
  }
  if (i < tilesX-1 &&j < tilesY-1 &&  tiles[i+1][j+1].hidden && tiles[i+1][j+1].bombsNear != 0) {
    tiles[i+1][j+1].hidden = false;
    tiles[i+1][j+1].changed = true;
  }
  if (j < tilesY-1 &&  tiles[i][j+1].hidden && tiles[i][j+1].bombsNear != 0 ) {
    tiles[i][j+1].hidden = false;
    tiles[i][j+1].changed = true;
  }
  if (j > 0 &&  tiles[i][j-1].hidden && tiles[i][j-1].bombsNear != 0) {
    tiles[i][j-1].hidden = false;
    tiles[i][j-1].changed = true;
  }
}
//---------------------------------------------------------------------------------------------------------------------------------------------

void setTileInfo() {
  for (int i = 0; i< tilesX; i++) {
    for (int j = 0; j< tilesY; j++) {


      //count the number of hidden tiles near current tile
      int n = 0;
      if ( i > 0 && tiles[i-1][j].hidden) n++;
      if (i < tilesX-1 && tiles[i+1][j].hidden) n++;
      if (i > 0 && j > 0 &&  tiles[i-1][j-1].hidden) n++;
      if (i < tilesX-1 && j > 0 &&  tiles[i+1][j-1].hidden) n++;
      if (i > 0 && j < tilesY-1 &&  tiles[i-1][j+1].hidden) n++;
      if (i < tilesX-1 && j < tilesY-1 &&  tiles[i+1][j+1].hidden) n++;
      if (j < tilesY-1 && tiles[i][j+1].hidden) n++;
      if (j > 0 &&  tiles[i][j-1].hidden) n++;
      tiles[i][j].hiddenNear = n;


      //count the number of flagged tiles near the current tile
      n = 0;
      if ( i > 0 && tiles[i-1][j].flagged) n++;
      if (i < tilesX-1 && tiles[i+1][j].flagged) n++;
      if (i > 0 && j > 0 &&  tiles[i-1][j-1].flagged) n++;
      if (i < tilesX-1 &&j > 0 &&  tiles[i+1][j-1].flagged) n++;
      if (i > 0 && j < tilesY-1 &&  tiles[i-1][j+1].flagged) n++;
      if (i < tilesX-1 &&j < tilesY-1 &&  tiles[i+1][j+1].flagged) n++;
      if (j < tilesY-1 && tiles[i][j+1].flagged) n++;
      if (j > 0 &&  tiles[i][j-1].flagged) n++;
      tiles[i][j].flaggedNear = n;


      //for each non hidden tile set all adjacent hidden tiles
      ArrayList<Tile> temp = new ArrayList<Tile>();
      if ( i > 0 && tiles[i-1][j].hidden && !tiles[i-1][j].flagged) {
        temp.add(tiles[i-1][j]);
      }
      if (i < tilesX-1 && tiles[i+1][j].hidden && !tiles[i+1][j].flagged) {
        temp.add(tiles[i+1][j]);
      }
      if (i > 0 && j > 0 &&  tiles[i-1][j-1].hidden && !tiles[i-1][j-1].flagged) {
        temp.add(tiles[i-1][j-1]);
      }
      if (i < tilesX-1 &&j > 0 &&  tiles[i+1][j-1].hidden && !tiles[i+1][j-1].flagged) {
        temp.add(tiles[i+1][j-1]);
      }
      if (i > 0 && j < tilesY-1 &&  tiles[i-1][j+1].hidden && !tiles[i-1][j+1].flagged) {
        temp.add(tiles[i-1][j+1]);
      }
      if (i < tilesX-1 &&j < tilesY-1 &&  tiles[i+1][j+1].hidden && !tiles[i+1][j+1].flagged) {
        temp.add(tiles[i+1][j+1]);
      }
      if (j < tilesY-1 && tiles[i][j+1].hidden && !tiles[i][j+1].flagged) {
        temp.add(tiles[i][j+1]);
      }
      if (j > 0 &&  tiles[i][j-1].hidden && !tiles[i][j-1].flagged) {
        temp.add(tiles[i][j-1]);
      }

      tiles[i][j].hiddensNear= (ArrayList)temp.clone();
    }
  }

  for (int i = 0; i< tilesX; i++) {
    for (int j = 0; j< tilesY; j++) {

      if (tiles[i][j].bombsNear - tiles[i][j].flaggedNear == 1 && tiles[i][j].hiddenNear != 1) {
        //if there is only 1 bomb left unflagged around it then all the hidden tiles near this tile are linked, which means that only one of them can be a bomb meaning that any subset of them can be at most 1

        ArrayList<Tile> temp = new ArrayList<Tile>();
        if ( i > 0 && tiles[i-1][j].hidden && !tiles[i-1][j].flagged) {
          temp.add(tiles[i-1][j]);
        }
        if (i < tilesX-1 && tiles[i+1][j].hidden && !tiles[i+1][j].flagged) {
          temp.add(tiles[i+1][j]);
        }
        if (i > 0 && j > 0 &&  tiles[i-1][j-1].hidden && !tiles[i-1][j-1].flagged) {
          temp.add(tiles[i-1][j-1]);
        }
        if (i < tilesX-1 &&j > 0 &&  tiles[i+1][j-1].hidden && !tiles[i+1][j-1].flagged) {
          temp.add(tiles[i+1][j-1]);
        }
        if (i > 0 && j < tilesY-1 &&  tiles[i-1][j+1].hidden && !tiles[i-1][j+1].flagged) {
          temp.add(tiles[i-1][j+1]);
        }
        if (i < tilesX-1 &&j < tilesY-1 &&  tiles[i+1][j+1].hidden && !tiles[i+1][j+1].flagged) {
          temp.add(tiles[i+1][j+1]);
        }
        if (j < tilesY-1 && tiles[i][j+1].hidden && !tiles[i][j+1].flagged) {
          temp.add(tiles[i][j+1]);
        }
        if (j > 0 &&  tiles[i][j-1].hidden && !tiles[i][j-1].flagged) {
          temp.add(tiles[i][j-1]);
        }

        //link em
        if ( i > 0 && tiles[i-1][j].hidden && !tiles[i-1][j].flagged) {
          tiles[i-1][j].linkedWith = (ArrayList)temp.clone();
          tiles[i-1][j].linked = true;
        }
        if (i < tilesX-1 && tiles[i+1][j].hidden && !tiles[i+1][j].flagged) {
          tiles[i+1][j].linkedWith = (ArrayList)temp.clone();
          tiles[i+1][j].linked = true;
        }
        if (i > 0 && j > 0 &&  tiles[i-1][j-1].hidden && !tiles[i-1][j-1].flagged) {
          tiles[i-1][j-1].linkedWith = (ArrayList)temp.clone();
          tiles[i-1][j-1].linked = true;
        }
        if (i < tilesX-1 &&j > 0 &&  tiles[i+1][j-1].hidden && !tiles[i+1][j-1].flagged) {
          tiles[i+1][j-1].linkedWith = (ArrayList)temp.clone();
          tiles[i+1][j-1].linked = true;
        }
        if (i > 0 && j < tilesY-1 &&  tiles[i-1][j+1].hidden && !tiles[i-1][j+1].flagged) {
          tiles[i-1][j+1].linkedWith = (ArrayList)temp.clone();
          tiles[i-1][j+1].linked = true;
        }
        if (i < tilesX-1 &&j < tilesY-1 &&  tiles[i+1][j+1].hidden && !tiles[i+1][j+1].flagged) {
          tiles[i+1][j+1].linkedWith = (ArrayList)temp.clone();
          tiles[i+1][j+1].linked = true;
        }
        if (j < tilesY-1 && tiles[i][j+1].hidden && !tiles[i][j+1].flagged) {
          tiles[i][j+1].linkedWith = (ArrayList)temp.clone();
          tiles[i][j+1].linked = true;
        }
        if (j > 0 &&  tiles[i][j-1].hidden && !tiles[i][j-1].flagged) {
          tiles[i][j-1].linkedWith = (ArrayList)temp.clone();
          tiles[i][j-1].linked = true;
        }
      }
    }
  }
}

class Tile {
  boolean bomb = false;
  boolean flagged = false;
  boolean hidden =  true;
  int bombsNear = 0;
  PVector pos;
  boolean changed = true;
  int hiddenNear = 8;
  int flaggedNear = 0;
  boolean targeted = false;
  boolean looksSexy = false;
  ArrayList<Tile> linkedWith = new ArrayList<Tile>();
  ArrayList<Tile> hiddensNear;//terribly named arrayList
  boolean linked = false;
  boolean unknown = false;
  int probabilityCount = 0;

  Tile(float x, float y) {
    pos = new PVector(x, y);
  }

  //---------------------------------------------------------------------------------------------------------------------------------------
  //shows the tile
  void show() {
    if (loser && bomb) {//if we lost then show all bombs
      hidden = false;
    }
    if (winner && !bomb) {//if we won then show all non bombs
      hidden = false;
    }
    fill(40);
    stroke(107);
    rect(pos.x, pos.y, tileSize, tileSize);

    if (!hidden) {//show number
      fill(150);
      rect(pos.x, pos.y, tileSize, tileSize);
      if (bomb) {//show bomb
        if (loser) {
          image(bombSprite, pos.x+1, pos.y+1, tileSize, tileSize);
        }
      } else {
        image(unhiddenSprite, pos.x+1, pos.y+1, tileSize, tileSize);
        switch(bombsNear) {//set the colour
        case 0:
          return ;
        case 1:
          fill(0, 0, 240);
          break;
        case 2:
          fill(34, 150, 34);
          break;
        case 3:
          fill(240, 0, 0);
          break;
        case 4:
          fill(0, 0, 128);
          break;
        case 5:
          fill(178, 34, 34);
          break;
        case 6:
          fill(0, 206, 209);
          break;
        case 7:
          fill(0);
          break;
        case 8:
          fill(100);
          break;
        }
        textFont(font);
        textSize(15);
        //fill(0);
        textAlign(CENTER, CENTER);
        text(bombsNear, pos.x+tileSize/2, pos.y+tileSize/2) ;
      }
    } else {
      if (flagged) {
        image(flag, pos.x+1, pos.y+1, tileSize, tileSize);
      } else {
        image(hiddenSprite, pos.x+1, pos.y+1, tileSize, tileSize);
      }
    }
  }
}

class AI {

  PVector pos = new PVector(0, 0);
  int targetX;
  int targetY;
  ArrayList<PVector> targets = new ArrayList<PVector>();
  int maxSpeed = 3000;
  boolean flagTarget = false;
  int totalArrangements = 0;

  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  AI() {
    //guess in the corners
    earlyGuess(true);
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  void pickNextTarget() {
    maxSpeed = 30000;
    //if any tiles have the same amount of unflagged bombs as they have hidden spaces near them then they are all bombs
    for (int i = 0; i< tilesX; i++) {
      for (int j = 0; j< tilesY; j++) {
        if (!tiles[i][j].hidden) {
          if (tiles[i][j].hiddenNear == tiles[i][j].bombsNear) {// - tiles[i][j].flaggedNear) {
            addAllHiddenNear(i, j, 1);
          }
        }
      }
    }
    //if any tiles have the same number of flagged tiles as there are bombs near it then all hidden spaces are safe
    for (int i = 0; i< tilesX; i++) {
      for (int j = 0; j< tilesY; j++) {
        if (!tiles[i][j].hidden) {
          if (tiles[i][j].bombsNear == tiles[i][j].flaggedNear) {
            addAllHiddenNear(i, j, 0);
          } else if (tiles[i][j].bombsNear <= tiles[i][j].flaggedNear) {
            //println("fuckkckckc");//error message
          }
        }
      }
    }
    if (targets.size() ==0) {//if no targets found
      checkLinked();
      if (targets.size() ==0) {//if no targets found
        pickRandomTarget();
      }
    }
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //checks all tiles for any linkages which can lead a conclusion
  void checkLinked() {
    for (int i = 0; i< tilesX; i++) {//for each tile
      for (int j = 0; j< tilesY; j++) {
        if (!tiles[i][j].hidden) {
          if (tiles[i][j].bombsNear != 1 &&  tiles[i][j].bombsNear != 0 && tiles[i][j].bombsNear - tiles[i][j].flaggedNear > 1 ) {
            for (int k = 0; k < tiles[i][j].hiddensNear.size(); k++) {//for each hiddes tile near the tile being checked

              if (tiles[i][j].hiddensNear.get(k).linked) {//if that tile is linked
                int numberLinked = 0;
                ArrayList<Tile> linkedTilesAdjacentToThis = new ArrayList<Tile>();
                for (int l = 0; l < tiles[i][j].hiddensNear.get(k).linkedWith.size(); l++) {//for every tile the linked tile is linked with
                  //count the number of tiles the k tile is linked with which are also adjacent to this tile
                  if (tiles[i][j].hiddensNear.contains(tiles[i][j].hiddensNear.get(k).linkedWith.get(l))) {
                    numberLinked ++;//note this will also count itself
                    linkedTilesAdjacentToThis.add(tiles[i][j].hiddensNear.get(k).linkedWith.get(l));
                  }
                }
                if (numberLinked >1) {
                  if (tiles[i][j].hiddenNear - (numberLinked -1) == tiles[i][j].bombsNear) {//this means that all tiles which aren't linked are bombs
                    for (int m = 0; m < tiles[i][j].hiddensNear.size(); m++) {//for each adjacent tile
                      if (!linkedTilesAdjacentToThis.contains(tiles[i][j].hiddensNear.get(m))) {//if its not in the linked group
                        targets.add(new PVector (tiles[i][j].hiddensNear.get(m).pos.x/tileSize, tiles[i][j].hiddensNear.get(m).pos.y/tileSize, 1));//thats a bomb
                        tiles[i][j].hiddensNear.get(m).targeted = true;
                      }
                    }
                    return;
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //when we have no hope
  void pickRandomTarget() {
    if (bombsLeft < 50) {//if there are too many bombs left the number of arrangements get stupid high and it there are too many then just guess randomly
      setProbabilities();
      boolean first = true;
      int min = 1000000;
      int minI = 0;
      int minJ = 0;
      //get the smallest probability
      for (int i = 0; i< tilesX; i++) {
        for (int j = 0; j< tilesY; j++) {
          if (first || tiles[i][j].probabilityCount < min) {
            if (!tiles[i][j].flagged && tiles[i][j].hidden && !tiles[i][j].unknown) {
              minI = i;
              minJ= j;
              min = tiles[i][j].probabilityCount;
              first = false;
            }
          }
        }
      }

      //target the smallest probability
      targetX = minI;
      targetY = minJ;

      tiles[targetX][targetY].targeted = true;
      flagTarget = false;
      //println();
      //println(targetX, targetY);
      //println("probablitiy: ", min, totalArrangements, "probability of bomb ", min.multiply( BigInteger.valueOf(100) ).divide(totalArrangements)  + " %");
    } else {
      //if too many bombs then guess
      earlyGuess(false);
    }
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //this was used when we had a cursor but now it just instantly clicks the target
  void move() {
    //if (dist(targetX*tileSize +10, targetY*tileSize+10, pos.x, pos.y) > 3) {
    //  PVector vel = new PVector((targetX*tileSize +10) - pos.x, (targetY*tileSize +10) - pos.y);
    //  vel.limit(maxSpeed);
    //  pos.add(vel);
    //} else {
    clickTarget();
    //}
  }


  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //called when all the hiddens near the input location are either a bomb or they're all safe
  void addAllHiddenNear(int i, int j, int oneIfBomb) {
    if (tiles[i][j].hidden) {
      return;
    }
    if ( i > 0 && tiles[i-1][j].hidden && !tiles[i-1][j].targeted) {
      targets.add(new PVector(i-1, j, oneIfBomb));
      tiles[i-1][j].targeted = true;
    }
    if (i < tilesX-1 && tiles[i+1][j].hidden && !tiles[i+1][j].targeted) {
      targets.add(new PVector(i+1, j, oneIfBomb));
      tiles[i+1][j].targeted = true;
    }
    if (i > 0 && j > 0 &&  tiles[i-1][j-1].hidden && !tiles[i-1][j-1].targeted) {
      targets.add(new PVector(i-1, j-1, oneIfBomb));
      tiles[i-1][j-1].targeted = true;
    }
    if (i < tilesX-1 &&j > 0 &&  tiles[i+1][j-1].hidden && !tiles[i+1][j-1].targeted) {
      targets.add(new PVector(i+1, j-1, oneIfBomb));
      tiles[i+1][j-1].targeted = true;
    }
    if (i > 0 && j < tilesY-1 &&  tiles[i-1][j+1].hidden && !tiles[i-1][j+1].targeted) {
      targets.add(new PVector(i-1, j+1, oneIfBomb));
      tiles[i-1][j+1].targeted = true;
    }
    if (i < tilesX-1 &&j < tilesY-1 &&  tiles[i+1][j+1].hidden && !tiles[i+1][j+1].targeted) {
      targets.add(new PVector(i+1, j+1, oneIfBomb));
      tiles[i+1][j+1].targeted = true;
    }
    if (j < tilesY-1 && tiles[i][j+1].hidden && !tiles[i][j+1].targeted) {
      targets.add(new PVector(i, j+1, oneIfBomb));
      tiles[i][j+1].targeted = true;
    }
    if (j > 0 &&  tiles[i][j-1].hidden && !tiles[i][j-1].targeted) {
      targets.add(new PVector(i, j-1, oneIfBomb));
      tiles[i][j-1].targeted = true;
    }
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //click on target
  void clickTarget() {
    Tile temp = tiles[targetX][targetY];
    if (!flagTarget) {
      if (temp.flagged) {//if clicking an already flagged target then fuckyou
        print("fuckYOu");
      } else {
        if (temp.bomb) {//if you clicked a bomb then goodnight
          //println("DEAD");
          gameOver=true;
          loser = true;
          return;
        }
        //didnt click a bomb so reveal it
        temp.hidden = false;
        temp.changed = true;

        if (temp.bombsNear ==0) {
          clickedZero(floor(temp.pos.x/tileSize), floor(temp.pos.y/tileSize));
        }
      }
    } else {
      if (!temp.flagged) {
        bombsLeft --;
        if (bombsLeft ==0) {
          //println("Winner");
          gameOver = true;
          winner = true;
          temp.flagged = true;//!temp.flagged;
          temp.changed= true;
          return;
        }
      }
      temp.flagged = true;//!temp.flagged;
      temp.changed = true;
    }

    setTileInfo();

    //remove any tiles which arn't hidden anymore
    for (int i = 0; i< targets.size(); i++) {
      Tile temp2 = tiles[(int)targets.get(i).x][(int)targets.get(i).y];
      if (!temp2.hidden) {
        targets.remove(i);
        i--;
      }
    }

    //get next target
    if (targets.size() != 0) {

      targetX = (int)(targets.get(0).x);
      targetY = (int)(targets.get(0).y);
      if (targets.get(0).z != 0) {
        flagTarget = true;
      } else {
        flagTarget = false;
      }

      targets.remove(0);
    } else {
      pickNextTarget();
    }
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  //this function sets the probability of every tile
  void setProbabilities() {
    //count the number of unknown tiles
    //unknown tiles being tiles we have no information about
    int unknownCount = 0;
    for (int i = 0; i< tilesX; i++) {//for each tile
      for (int j = 0; j< tilesY; j++) {
        if (tiles[i][j].hidden) {
          boolean unknownTile = true;
          tiles[i][j].unknown = false;
          if ( i > 0 && !tiles[i-1][j].hidden) unknownTile = false;
          if (i < tilesX-1 && !tiles[i+1][j].hidden) unknownTile = false;
          if (i > 0 && j > 0 &&  !tiles[i-1][j-1].hidden) unknownTile = false;
          if (i < tilesX-1 && j > 0 &&  !tiles[i+1][j-1].hidden) unknownTile = false;
          if (i > 0 && j < tilesY-1 &&  !tiles[i-1][j+1].hidden) unknownTile = false;
          if (i < tilesX-1 && j < tilesY-1 && !tiles[i+1][j+1].hidden) unknownTile = false;
          if (j < tilesY-1 && !tiles[i][j+1].hidden) unknownTile = false;
          if (j > 0 &&  !tiles[i][j-1].hidden) unknownTile = false;
          if (unknownTile) {
            tiles[i][j].unknown = true;
            unknownCount++;
          }
        }
      }
    }

    //now we need to identify independent sections
    //the mine field can be broken up into seperate sections, if two tiles are in different sections then they have no effect on each other
    //for example if you had a section of hidden tiles in the top left and a block of hidden tiles in the bottom right corner then they essentually have nothing to do with each other
    ArrayList<ArrayList<Tile>> sections = new ArrayList<ArrayList<Tile>>();

    for (int i = 0; i< tilesX; i++) {//for each tile
      for (int j = 0; j< tilesY; j++) {
        if (!tiles[i][j].hidden && !tiles[i][j].flagged && tiles[i][j].hiddenNear - tiles[i][j].flaggedNear != 0) {
          ////println("Tile", i, j);
          boolean alreadyInSection = false;
          for (int k = 0; k< sections.size(); k++) {//for each section
            if (sections.get(k).contains(tiles[i][j])) {//if the tile is already in this section then
              alreadyInSection = true;
              break;
            }
          }

          if (!alreadyInSection) {
            //if not in section then we have a new section so add it
            ArrayList<Tile> newSection = new ArrayList<Tile>();
            addConnected(newSection, i, j);
            sections.add(newSection);
          }
        }
      }
    }

    //so the sections should be defined

    ArrayList<ArrayList<ArrayList<Tile>>> sectionSolutions = new ArrayList<ArrayList<ArrayList<Tile>>>();


    //now we need to search for all possible positions that the bombs should be in
    for (int i = 0; i< sections.size(); i++) {
      sectionSolutions.add(getSolutions(sections.get(i)));
    }


    int[] sectionSelections = new int[sections.size()];

    //this is an list of all possible bomb arrangements
    ArrayList<ArrayList<Tile>> allBombArrangements = new   ArrayList<ArrayList<Tile>>();

    boolean finished = false;

    //in order to populate the allBombArrangements list we need to combine the section solutions

    while (!finished) {
      ArrayList<Tile> temp = new ArrayList<Tile>();
      for (int i = 0; i < sections.size(); i++) {
        if (sectionSolutions.get(i).isEmpty() == false) {
          for (int j = 0; j < sectionSolutions.get(i).get(sectionSelections[i]).size(); j++) {
            temp.add( sectionSolutions.get(i).get(sectionSelections[i]).get(j));
          }
        } else {
          finished = true;
          break;
        }
      }
      
      if (temp.size() == 0){
        gameOver = true;
        gameOverShow = true;
        finished = true;
        break;
      }

      if (temp.size() <= bombsLeft) {
        allBombArrangements.add(temp);
      }

      for (int i = sections.size()-1; i >= 0; i--) {
        sectionSelections[i] +=1;
        if (sectionSelections[i] >= sectionSolutions.get(i).size()) {//if the selection is out of bounds
          if (i ==0) {
            finished = true;
            break;
          }
          sectionSelections[i] = 0;
        } else {
          break;
        }
      }
    }

    //ok finally now we have an arrayList containing all the possible lists of bomb configurations
    //now we just need to go through the arrangements and add the number of times each tile is a bomb

    for (int i = 0; i< tilesX; i++) {
      for (int j = 0; j< tilesY; j++) {
        tiles[i][j].probabilityCount = 0;
      }
    }
    totalArrangements = 0;

    for (int i = 0; i < allBombArrangements.size(); i++) {
      //since the remaining bombs can be arranged in any way amoungst the unknown tiles then the number of arrangements for this element of allBombArrangements is nCr where n is the number
      // of unknown spaces left and r is the number of bombs left
      //this is where the numbers get stupid big and why I used big ints instead of long

      int numberOfBombsLeft = bombsLeft - allBombArrangements.get(i).size(); //get the number fo bombs left to be placed in unknown areas
      int combinations = numberOfCombinations((int)unknownCount, numberOfBombsLeft);


      totalArrangements  = totalArrangements + combinations;

      for (int j = 0; j < allBombArrangements.get(i).size(); j++) {//for each tile which is a bomb in this arrangement add the number of combinations that this arrangment has
        allBombArrangements.get(i).get(j).probabilityCount = allBombArrangements.get(i).get(j).probabilityCount + combinations;
      }
    }
  }
  //-------------------------------------------------------------------------------------------------------------------------
  int numberOfCombinations(int n, int r) {  //nCr
    if (r == 0) {
      return 1;
    }
    int result = 1;
    for (int i = 0; i < r; i++) {

      result = result * (n - i);
    }
    if (fact(r) == 0) {
      return result;
    } else {
      return result / fact(r);
    }
  }
  //-------------------------------------------------------------------------------------------------------------------------
  //factorial
  int fact(int n) {
    if (n == 1) {
      return 1;
    } else {
      int result = n;
      result = result * fact(n-1);
      return result;
    }
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //returns all the bomb arrangemnets possible in this section
  ArrayList<ArrayList<Tile>> getSolutions(ArrayList<Tile> section) {


    ArrayList<Tile> hiddensInSection = new ArrayList<Tile>();
    for (int i = 0; i< section.size(); i ++) {
      for (int j = 0; j < section.get(i).hiddensNear.size(); j++) {
        if (!hiddensInSection.contains(section.get(i).hiddensNear.get(j))) {//add all the hidden tiles in this section to an ArrayList
          hiddensInSection.add(section.get(i).hiddensNear.get(j));
        }
      }
    }


    ArrayList<ArrayList<Tile>> solutions = new ArrayList<ArrayList<Tile>>();
    ArrayList<ArrayList<Integer>> big = new  ArrayList<ArrayList<Integer>>();
    ArrayList<Tile> checking = new ArrayList<Tile>();
    ArrayList<Integer> checkingInt = new ArrayList<Integer>();
    ArrayList<Integer> tempList = new ArrayList<Integer>();

    for (int i = 0; i < hiddensInSection.size(); i++) {
      checkingInt = new ArrayList<Integer>();
      checkingInt.add(i);
      big.add(checkingInt);
    }

    while (true) {
      if (!big.isEmpty())
      {
        checkingInt = big.remove(0);
      } else {//once there are no more options to check
        break;
      }

      checking = new ArrayList<Tile>();
      for (int i = 0; i< 1; i++) {
        checking.add(hiddensInSection.get(checkingInt.get(i)));
      }

      if (solution(checking, section)) {
        solutions.add(checking);
      } else {//checking is not a solution
        if (!violated(checking, checkingInt, hiddensInSection, section)) {//if its voilated the ruiles of minesweeper then ignore it
          //if the checking list has not yet voilated the section then add more bombs to it
          for (int i = checkingInt.get(checkingInt.size()-1) +1; i < hiddensInSection.size(); i++ ) {//extend checking by one number with all possible niggers

            tempList = (ArrayList)checkingInt.clone();

            tempList.add(i);
            big.add(tempList);
          }
        }
      }
    }


    return solutions;
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //returns whether or not this checking array(an array of tiles which will be bombs) is a viable option
  boolean solution(ArrayList<Tile> checking, ArrayList<Tile> section) {
    for (int i = 0; i< section.size(); i++) {
      int count = 0;
      for (int j = 0; j < section.get(i).hiddensNear.size(); j++) {
        if (checking.contains(section.get(i).hiddensNear.get(j))) {//count the number of the hidden tiles near the tile that are in the tested solution
          count++;
        }
      }
      if (count != section.get(i).bombsNear - section.get(i).flaggedNear) {//if the number of boombs that the tile (in section) needs to be finished is not = count then this is not a solution
        return false;
      }
    }
    return true;
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //returns whether or not this checkign array (an array of tiles which will be bombs) has already violated the section,
  //i.e  if any of the tiles have more bombs then it says on the tile
  //might need to add more to violated like when there isnt enough bombs
  boolean violated(ArrayList<Tile> checking, ArrayList<Tile> section) {
    for (int i = 0; i< section.size(); i++) {
      int count = 0;
      for (int j = 0; j < section.get(i).hiddensNear.size(); j++) {
        if (checking.contains(section.get(i).hiddensNear.get(j))) {//count the number of the hidden tiles near the tile that are in the tested solution
          count++;
        }
      }
      if (count > section.get(i).bombsNear - section.get(i).flaggedNear) {//if the number of boombs that the tile (in section) needs to be finished is less then count then it is violated
        return true;
      }
    }

    return false;//still good
  }

  boolean violated(ArrayList<Tile> checking, ArrayList<Integer> checkingInt, ArrayList<Tile> hiddens, ArrayList<Tile> section) {
    for (int i = 0; i< section.size(); i++) {
      int count = 0;
      int missed = 0;
      for (int j = 0; j < section.get(i).hiddensNear.size(); j++) {
        if (checking.contains(section.get(i).hiddensNear.get(j))) {//count the number of the hidden tiles near the tile that are in the tested solution
          count++;
        } else {
          if (hiddens.indexOf(section.get(i).hiddensNear.get(j)) < checkingInt.get(checkingInt.size()-1)) {
            //if the tile has been missed then count it as missed
            missed ++;
          }
        }
      }
      if (count > section.get(i).bombsNear - section.get(i).flaggedNear) {//if the number of boombs that the tile (in section) needs to be finished is less then count then it is violated
        return true;
      }
      if (section.get(i).bombsNear - section.get(i).flaggedNear > section.get(i).hiddenNear - missed ) {//if the number of bombs required is less than the amout of spaces left unmissed then you fucked up
        return true;
      }
    }

    return false;//still good
  }






  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //add all connected tiles to the section
  void addConnected(ArrayList<Tile> section, int i, int j) {
    section.add(tiles[i][j]);
    for (int m = 0; m < tilesX; m++) {
      for (int n = 0; n < tilesY; n++) {
        if (!tiles[m][n].hidden && !tiles[m][n].flagged && !section.contains(tiles[m][n])) {
          for (int k = 0; k < tiles[m][n].hiddensNear.size(); k++) {
            if (tiles[i][j].hiddensNear.contains(tiles[m][n].hiddensNear.get(k))) {
              addConnected(section, m, n);
              break;
            }
          }
        }
      }
    }
  }
  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

  //a section is defined by the uncovered tiles surrounding it
  //therefor if the current tile has any
  boolean inSection(Tile t1, Tile t2) {
    for (int i = 0; i< t1.hiddensNear.size(); i++) {
      if (t2.hiddensNear.contains(t1.hiddensNear.get(i))) {//if they have any hidden tiles near in common
        return true;
      }
    }
    return false;
  }

  //---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  //guesses the corners if there are any left and if not just guesses randomly
  void earlyGuess(boolean firstGuess) {
    //note in minesweeper the first guess is never a bomb so I just keep guessing until I get not a bomb on the first guess
    //count the number of corners left
    int count = 0;
    count += (tiles[0][0].hidden && !tiles[0][0].flagged &&!(firstGuess && tiles[0][0].bomb)) ? 1:0;
    count += (tiles[0][tilesY-1].hidden && !tiles[0][tilesY-1].flagged&&!(firstGuess && tiles[0][tilesY-1].bomb)) ? 1:0;
    count += (tiles[tilesX-1][0].hidden && !tiles[tilesX-1][0].flagged &&!(firstGuess && tiles[tilesX-1][0].bomb)) ? 1:0;
    count += (tiles[tilesX-1][tilesY-1].hidden && !tiles[tilesX-1][tilesY-1].flagged && !(firstGuess && tiles[tilesX-1][tilesY-1].bomb)) ? 1:0;

    if (count ==0) {
      //then guess randomly
      targetX  = floor(random(tilesX));
      targetY  = floor(random(tilesY));
      while (tiles[targetX][targetY].flagged || !tiles[targetX][targetY].hidden) {

        targetX  = floor(random(tilesX));
        targetY  = floor(random(tilesY));
      }

      tiles[targetX][targetY].targeted = true;
      flagTarget = false;
      return;
    }


    //if any of the corners remain then click corners
    int rand = floor(random(4));
    switch(rand) {
    case 0:
      targetX = 0;
      targetY = 0;
      break;
    case 1:
      targetX = tilesX-1;
      targetY = 0;
      break;
    case 2:
      targetX = 0;
      targetY = tilesY -1;
      break;
    case 3:
      targetX = tilesX -1;
      targetY = tilesY -1;
      break;
    }
    flagTarget = false;

    //guess corners
    while (!tiles[targetX][targetY].hidden  || tiles[targetX][targetY].flagged || (firstGuess && tiles[targetX][targetY].bomb )) {

      rand = floor(random(4));
      switch(rand) {
      case 0:
        targetX = 0;
        targetY = 0;
        break;
      case 1:
        targetX = tilesX-1;
        targetY = 0;
        break;
      case 2:
        targetX = 0;
        targetY = tilesY -1;
        break;
      case 3:
        targetX = tilesX -1;
        targetY = tilesY -1;
        break;
      }
    }

    tiles[targetX][targetY].targeted = true;
    flagTarget = false;
  }
}
