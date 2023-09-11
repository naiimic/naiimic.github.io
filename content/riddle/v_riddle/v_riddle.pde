ArrayList<Bacteria> bacterias = new ArrayList<Bacteria>();
color aColor = color(255, 0, 0); // Red
color bColor = color(0, 0, 255); // Blue;
PVector foodPos;
boolean foodDropped = false;
int foodDropCount = 0;
int maxDrops = 11;
int[] histogramCounts = new int[maxDrops + 2]; 
int frameCount = 0; 
Bacteria selectedBacterium = null; 
PFont boldFont;
int foodNumber = 0;
int simulationNumber = 1;
final int MAX_SIMULATIONS = 1000;

void setup() {
  size(300, 600);
  frameRate(100); 
  resetSimulation();
  boldFont = createFont("Avenir-Roman", 16);  // SansSerif-Bold font with size 16
  textFont(boldFont);  // Set it as the default font
}

void draw() {
  background(255); 
  drawBucket();

  if (foodDropCount < maxDrops && !foodDropped) {
    if (frameCount > 60) { 
      dropFood();
      frameCount = 0; 
    } else {
      frameCount++;
    }
  }

  if (foodDropped) {
    fill(0, 255, 0); 
    ellipse(foodPos.x, foodPos.y, 10, 10);
  }

  ArrayList<Bacteria> newBacterias = new ArrayList<Bacteria>();

  for (Bacteria b : bacterias) {
    if (foodDropped && selectedBacterium != null && b == selectedBacterium) {
      b.moveTowards(foodPos);
    } else {
      b.moveRandom();
    }
    b.show(); 

    if (foodDropped && b.eat(foodPos)) {
      newBacterias.add(new Bacteria(b.x, b.y, b.col));
      foodDropped = false;
      foodDropCount++;
      selectedBacterium = null; 
    }
  }

  bacterias.addAll(newBacterias);

  if (foodDropCount == maxDrops) {
    int countA = 0;
    for (Bacteria bact : bacterias) {
      if (bact.col == aColor) {
        countA++;
      }
    }
    histogramCounts[countA]++;
    simulationNumber++;
    foodNumber = 0;
    resetSimulation();
    //printProbabilities();
  }

  displayHistogram();
  displayLegend();
}

void displayLegend() {
  int countA = 0;
  int countB = 0;

  // Calculate counts of A and B
  for (Bacteria bact : bacterias) {
    if (bact.col == aColor) {
      countA++;
    } else {
      countB++;
    }
  }

  // Draw a semi-transparent white background box for the legend
  fill(255, 255, 255, 150);  // Last parameter is the alpha (transparency) value
  rect(37.5, 37.5, 70, 56.25);

  // Set up text size
  textSize(16);
  textFont(boldFont); // Apply the bold font
  
  fill(0); // Set color to black
  text("Food " + foodNumber, 45, 52.5);
  fill(aColor);
  text("A: " + countA, 45, 67.5);
  fill(bColor);
  text("B: " + countB, 45, 82.5);
}

void drawBucket() {
  fill(64, 164, 223);
  strokeWeight(5);
  stroke(0);
  rect(37.5, 37.5, 225, 225);
}

void resetSimulation() {  
  
  if (simulationNumber > MAX_SIMULATIONS - 1) {
      noLoop();  // This stops the draw loop
      return;
  }
  bacterias.clear();
  bacterias.add(new Bacteria(150, 200, aColor));
  bacterias.add(new Bacteria(250, 200, bColor));
  foodDropped = false;
  foodDropCount = 0;
  dropFood();
}

void dropFood() {
  foodNumber++;
  foodPos = new PVector(random(41.25, 258.75), random(41.25, 258.75));
  foodDropped = true;

  float aCount = 0;
  float bCount = 0;
  for (Bacteria b : bacterias) {
    if (b.col == aColor) {
      aCount++;
    } else {
      bCount++;
    }
  }

  float aChance = aCount / (aCount + bCount);

  if (random(1) < aChance) {
    selectClosestBacterium(aColor);
  } else {
    selectClosestBacterium(bColor);
  }
}

void selectClosestBacterium(color colType) {
  float minDistance = Float.MAX_VALUE;
  Bacteria closestBacterium = null;

  for (Bacteria b : bacterias) {
    if (b.col == colType) {
      float distance = dist(b.x, b.y, foodPos.x, foodPos.y);
      if (distance < minDistance) {
        minDistance = distance;
        closestBacterium = b;
      }
    }
  }

  selectedBacterium = closestBacterium;
}

void displayHistogram() {
  strokeWeight(2);  // Thinner lines
  int maxCount = 0;
  for (int i = 1; i < histogramCounts.length; i++) {
    if (histogramCounts[i] > maxCount) {
      maxCount = histogramCounts[i];
    }
  }

  // Check to avoid division by zero in the map function
  if (maxCount == 0) {
    maxCount = 1;
  }
  
  float barWidth = 12;  // Adjusted the width of bars
  float barSpacing = 8;  // Adjusted spacing between bars
  
  // Calculate starting x-position to center the histogram
  float totalWidth = (maxDrops + 1) * (barWidth + barSpacing) - barSpacing; // total width of all bars + spaces
  float startX = (width - totalWidth) / 2;
  
  for (int i = 1; i <= maxDrops + 1; i++) {
    float barHeight = map(histogramCounts[i], 0, maxCount, 0, 225);
    fill(aColor);
    rect(startX + i * (barWidth + barSpacing) - barWidth, height - 37.5 - barHeight, barWidth, barHeight);
  }

  fill(0, 255);
  textSize(14);
  textAlign(CENTER);
  for (int i = 1; i <= maxDrops + 1; i++) {
    text(i, startX + i * (barWidth + barSpacing) - barWidth/2, height - 20);  
  }

  textSize(14);
  textAlign(RIGHT);
  translate(25, height/1.75);
  rotate(-HALF_PI);
  text("P(A = n) after " + simulationNumber + " simulations", 0, 0);
  rotate(HALF_PI);
  translate(-25, -height/1.75);
  textAlign(LEFT);
}

class Bacteria {
  float x, y;
  color col;
  float speed = 3;
  PVector velocity;
  PVector acceleration;
  float maxForce = 0.2;
  boolean isSeekingFood = false; // To track if this bacterium is seeking food

  Bacteria(float x, float y, color col) {
    this.x = x;
    this.y = y;
    this.col = col;
    this.velocity = PVector.random2D();
    this.acceleration = new PVector();
    this.maxForce = 0.5; 
  }

  void moveRandom() {
    PVector randomForce = PVector.random2D().mult(0.2); // Adjust the force as needed
    acceleration.add(randomForce);
    applyForce();
    handleWallCollision(); // Added wall collision handling
  }

  void moveTowards(PVector target) {
    PVector desired = PVector.sub(target, new PVector(x, y));
    desired.normalize();
    desired.mult(speed);
    
    PVector steer = PVector.sub(desired, velocity);
    steer.limit(maxForce);
    
    acceleration.add(steer);
    applyForce();
    handleWallCollision(); // Added wall collision handling
  }

  void applyForce() {
    velocity.add(acceleration);
    velocity.limit(speed);
    x += velocity.x;
    y += velocity.y;

    // Reset acceleration for the next frame
    acceleration.mult(0);
  }

  // Handle wall collisions
  void handleWallCollision() {
    if (x < 41.25 || x > 258.75) {
      velocity.x *= -1; // Reverse x-velocity on collision
      x = constrain(x, 41.25, 258.75); // Ensure it stays within the bucket
    }
    if (y < 41.25 || y > 258.75) {
      velocity.y *= -1; // Reverse y-velocity on collision
      y = constrain(y, 41.25, 258.75); // Ensure it stays within the bucket
    }
  }

  void show() {
    stroke(0); // Reset to the default stroke
    fill(col);
    ellipse(x, y, 15, 15);
  }

  boolean eat(PVector foodPosition) {
    float d = dist(x, y, foodPosition.x, foodPosition.y);
    return d < 15;  // Increase the radius a bit for easier capturing
  }
  
  boolean shouldSeekFood() {
    ArrayList<Bacteria> sameTypeBacterium = new ArrayList<Bacteria>();
  
    for (Bacteria b : bacterias) {
      if (b.col == this.col) {
        sameTypeBacterium.add(b);
      }
    }
  
    float aChance = (float) sameTypeBacterium.size() / bacterias.size();
    return random(1) < aChance;
  }
}

//void printProbabilities() {
//  int totalSimulations = 0;
//  for (int count : histogramCounts) {
//    totalSimulations += count;
//  }
  
//  println("Probabilities after " + totalSimulations + " simulations:");
//  for (int i = 1; i <= maxDrops + 1; i++) {
//    float probability = (float) histogramCounts[i] / totalSimulations;
//    println("P(A = " + i + "): " + probability);
//  }
//}
