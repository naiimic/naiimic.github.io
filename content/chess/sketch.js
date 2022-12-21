var test;
var moving = false;

var tileSize = 75;
var movingPiece;
var whitesMove = true;
var moveCounter = 10;
var images = [];
var whiteAI = false;
var blackAI = true;

var depthPara;
var depthPlus;
var depthMinus;
var tempMaxDepth = 3;

function setup() {
  createCanvas(600, 600);
  htmlStuff();

  for (var i = 1; i < 13; i++) {
    images.push(loadImage("assets/" + i + ".png"));
  }
  test = new Board();
}

function draw() {

  background(100);
  showGrid();
  test.show();
  runAIs();
}

function runAIs() {
  maxDepth = tempMaxDepth;
  if (!test.isDead() && !test.hasWon()) {
    if (blackAI) {
      if (!whitesMove) {
        if (moveCounter < 0) {
          test = maxFunAB(test, -400, 400, 0);
          whitesMove = true;
          moveCounter = 10;
        } else {
          moveCounter--;
        }
      }
    }
    if (whiteAI) {
      if (whitesMove) {
        if (moveCounter < 0) {
          test = minFunAB(test, -400, 400, 0);
          whitesMove = false;
          moveCounter = 10;
        } else {
          moveCounter--;
        }
      }
    }
  }
}

function showGrid() {
  for (var i = 0; i < 8; i++) {
    for (var j = 0; j < 8; j++) {
      if ((i + j) % 2 == 1) {
        fill("#b58863");
      } else {
        fill("#f0d9b5");
      }
      noStroke();
      rect(i * tileSize, j * tileSize, tileSize, tileSize);

    }
  }
}

function mousePressed() {
  var x = floor(mouseX / tileSize);
  var y = floor(mouseY / tileSize);
  if (!test.isDone()) {
    if (!moving) {
      movingPiece = test.getPieceAt(x, y);
      if (movingPiece != null && movingPiece.white == whitesMove) {

        movingPiece.movingThisPiece = true;
      } else {
        return;
      }
    } else {
      if (movingPiece.canMove(x, y, test)) {
        movingPiece.move(x, y, test);
        movingPiece.movingThisPiece = false;
        whitesMove = !whitesMove;
      } else {
        movingPiece.movingThisPiece = false;

      }
    }
    moving = !moving;
  }
}
//---------------------------------------------------------------------------------------------------------------------
function htmlStuff() {
  createP(
    ""
  )
}
