import peasy.*;
import superCAD.*;

int inputWidth = 640;
int inputHeight = 480;
int numFrames = 10;
int writeNumStart = 0;
int readNumStart = 0;
int currentFrame = 0;
int fps = 60;
String readFilePath = "frames";
String readFileName = "foo";
String readFileType = "png";
String writeFilePath = "render";
String writeFileName = "render_"+readFileName;
String writeFileType = "png";
boolean recordObj = true;
boolean recordFrame = false;
float zscale = 1; //orig 3
float zskew = 10;
PeasyCam cam;
float[][] gray = new float[inputHeight][inputWidth];
PImage frame;

/*
 Simple Kinect point-cloud demo v. 0.2
 
 Henry Palonen <h@yty.net>
 
 Using Daniel Shiffman's great processing-library for Kinect:
 http://www.google.com/url?sa=D&q=http://www.shiffman.net/2010/11/14/kinect-and-processing/&usg=AFQjCNH8kZWDMhFueeNBn5x97XoDR3v9oQ
 
 Based on Kyle McDonalds Structure Light scanner:
 http://www.openprocessing.org/visuals/?visualID=1014
 
 Using also SuperCAD for outputting the .obj - files: http://labelle.spacekit.ca/supercad/
 
 History
 -------
 17.11.2010 - 0.1 - First version, simple point-cloud working
 18.11.2010 - 0.2 - Output to .obj for importing to Blender, gray-color for distance and small lines as output
 
 */

void setup() {
  size(inputWidth, inputHeight, P3D);
  frameRate(fps);
  smooth();
  cam = new PeasyCam(this, width);
  //initKinect();
  stroke(255);
}

void draw () {
  frame = loadImage(readFilePath + "/" + readFileName + (currentFrame+readNumStart) +"."+readFileType);
  println(readFileName + (currentFrame+readNumStart) +"."+readFileType+ " loaded");  
  background(0);

  if (recordObj) {
    beginRaw("superCAD.ObjFile", "render/"+ writeFileName+(currentFrame+writeNumStart)+".obj"); // Start recordObjing to the file
  }

  for (int y = 0; y < inputHeight; y++) {
    for (int x = 0; x < inputWidth; x++) {
      // FIXME: this loses Z-resolution about tenfold ...
      //       -> should grab the real distance instead...
      color argb = frame.pixels[y*width+x];
      gray[y][x] = gray(argb);
    }
  }

  // Kyle McDonald's original source used here
  translate(-inputWidth / 2, -inputHeight / 2);  
  int step = 2;
  for (int y = step; y < inputHeight; y += step) {
    float planephase = 0.5 - (y - (inputHeight / 2)) / zskew;
    for (int x = step; x < inputWidth; x += step)
    {
      stroke(gray[y][x]);
      //point(x, y, (gray[y][x] - planephase) * zscale);
      line(x, y, (gray[y][x] - planephase) * zscale, x+1, y, (gray[y][x] - planephase) * zscale);
    }
  }

  if (recordFrame) {
    saveFrame("render/"+ writeFileName+(currentFrame+writeNumStart)+"."+writeFileType);
    println(writeFileName+(currentFrame+writeNumStart)+"."+writeFileType+" saved");
  }

  if (recordObj) {
    endRaw();
    //recordObj = false; // Stop recordObjing to the file
    println(writeFileName+(currentFrame+writeNumStart)+".obj saved");
  }

  if (currentFrame<numFrames-1) {
    currentFrame++;
  } 
  else {
    if (recordFrame||recordObj) {
      println("render finished");
      recordFrame=false;
      recordObj=false;
      stop();
    }
    currentFrame=0;
  }
}

//~~~~~~~~~~~~~~~~~~~~~~~

static final int gray(color value) { 
  return max((value >> 16) & 0xff, (value >> 8 ) & 0xff, value & 0xff);
}

//---

void keyPressed() {
  if (key == 'R' || key == 'r') { // Press R to save the file
    recordObj = true;
  }
  if (key == ' ') {
    currentFrame=0;
    recordFrame = true;
  }
}

//---

void stop() {
  super.stop();
  exit();
}

//~~~   END   ~~~

