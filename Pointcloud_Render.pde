//github sync test
/*
//--Kinect sectup
import org.openkinect.*;
import org.openkinect.processing.*;
Kinect kinect;
boolean depth = true;
boolean rgb = false;
boolean ir = false;
float deg = 15;
//--
*/

int inputWidth = 640;
int inputHeight = 480;
int numFrames = 20;
int writeNumStart = 1;
int readNumStart = 1;
int currentFrame = 0;
int fps = 60;
String readFilePath = "frames";
String readFileName = "shot1_";
String readFileType = "tga";
String writeFilePath = "render";
String writeFileName = "render_"+readFileName;
String writeFileType = "png";


import peasy.*;
import superCAD.*;

boolean recordObj = false;
boolean recordFrame = true;

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
float zscale = 1; //orig 3
float zskew = 10;

PeasyCam cam;

float[][] gray = new float[inputHeight][inputWidth];

PImage frame;

static final int gray(color value) { 
  return max((value >> 16) & 0xff, (value >> 8 ) & 0xff, value & 0xff);  
} 

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
  
  if (recordObj == true) {
    beginRaw("superCAD.ObjFile", "kinec_out.obj"); // Start recordObjing to the file
  }
  
  //depth.pixels = NativeKinect.getDepthMap();
 // depth.updatePixels();

  //NativeKinect.update();
  
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
  
    if(recordFrame==true){
saveFrame("render/"+ writeFileName+(currentFrame+writeNumStart)+"."+writeFileType);
println(writeFileName+(currentFrame+writeNumStart)+"."+writeFileType+" saved");
}

if(currentFrame<numFrames-1){
  currentFrame++;
} else {
  if(recordFrame==true){
    println("render finished");
  recordFrame=false;
stop();  
}
currentFrame=0;
}
  
  if (recordObj == true) {
    endRaw();
    recordObj = false; // Stop recordObjing to the file
    println("kinec_out.obj saved");
  }
  

  
}


void keyPressed() {
  if (key == 'R' || key == 'r') { // Press R to save the file
    recordObj = true;
  }
  if (key == ' '){
    currentFrame=0;
  recordFrame = true;
  }
}

/*
void initKinect(){
  kinect = new Kinect(this);
  kinect.start();
  kinect.enableDepth(depth);
  kinect.enableRGB(rgb);
  kinect.enableIR(ir);
  kinect.tilt(deg);
}
*/

void stop() {
  //kinect.quit();
  super.stop();
}
