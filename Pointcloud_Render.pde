import peasy.*;
import superCAD.*;
//import processing.opengl.*;

//**************************************
boolean record3D = true; // records 3D rendering or just time-corrects original depth map
int sW = 640;
int sH = 480;
float recordedFps = 30; //fps you shot at
int numberOfFolders = 1;  //right now you must set this manually!
String readFilePath = "data";
String readFileName = "shot";
String readFileType = "tga"; // record with tga for speed
String writeFilePath = "render";
String writeFileName = "shot";
String writeFileType = "tga";  // render with png to save space
float zscale = 3; //orig 3, 1 looks better in 2D image but 3 looks better for OBJ
float zskew = 10;
//**************************************

String readString = "";
String writeString = "";
int shotNumOrig = 1;
int shotNum = shotNumOrig;
int readFrameNumOrig = 1;
int readFrameNum = readFrameNumOrig;
int readFrameNumMax;
int writeFrameNum = readFrameNum;
int addFrameCounter = 0;
int subtractFrameCounter = 0;

PeasyCam cam;
float[][] gray = new float[sH][sW];

File dataFolder;
String[] numFiles; 

PImage img, buffer;


void setup() {
  reInit();
  if (record3D) {
    size(sW, sH, P3D);
    cam = new PeasyCam(this, sW);
  }
  else {
    size(sW, sH, P2D);
  }
  //smooth();
  stroke(255);
}

void reInit() {
  readFrameNum = readFrameNumOrig;
  writeFrameNum = readFrameNum;
  addFrameCounter = 0;
  subtractFrameCounter = 0;
  countFolder();
}

void draw() {
  background(0);
  if (shotNum<=numberOfFolders) {
    if (readFrameNum<readFrameNumMax) {
      readString = readFilePath + "/" + readFileName + shotNum + "/" + readFileName + shotNum + "_frame" + readFrameNum + "." + readFileType;
      img = loadImage(readString);
      if (record3D) {
        objGenerate();
      }
      else {
        image(img, 0, 0);
      }
      writeFile(1);
      readFrameNum++;
    } else {
    if (shotNum==numberOfFolders) {
      exit();
    }
    else {
      shotNum++;
      reInit();
    }
    }
  }else {
  exit();
}

}

void countFolder() {
  dataFolder = new File(sketchPath, readFilePath + "/" + readFileName + shotNum+"/");
  numFiles = dataFolder.list();
  readFrameNumMax = numFiles.length+1;
}

void writeFile(int reps) {
  for (int i=0;i<reps;i++) {
    writeString = writeFilePath + "/" + writeFileName + shotNum + "/" + writeFileName + shotNum + "_frame"+writeFrameNum+"."+writeFileType;

    saveFrame(writeString);

    if (record3D&&reps>1) {
      objGenerate();
    }
    //println("written: " + writeString + diffReport);
    writeFrameNum++;
  }
}


static final int gray(color value) { 
  return max((value >> 16) & 0xff, (value >> 8 ) & 0xff, value & 0xff);
}

void objGenerate() {
  background(0);
  if (record3D) {
    objBegin();
  }
  buffer = img;
  for (int y = 0; y < sH; y++) {
    for (int x = 0; x < sW; x++) {
      // FIXME: this loses Z-resolution about tenfold ...
      //       -> should grab the real distance instead...
      color argb = buffer.pixels[y*width+x];
      gray[y][x] = gray(argb);
    }
  }

  // Kyle McDonald's original source used here
  pushMatrix();
  translate(-sW / 2, -sH / 2);  
  int step = 2;
  for (int y = step; y < sH; y += step) {
    float planephase = 0.5 - (y - (sH / 2)) / zskew;
    for (int x = step; x < sW; x += step)
    {
      stroke(gray[y][x]);
      //point(x, y, (gray[y][x] - planephase) * zscale);
      line(x, y, (gray[y][x] - planephase) * zscale, x+1, y, (gray[y][x] - planephase) * zscale);
    }
  }
  popMatrix();
  if (record3D) {
    objEnd();
  }
}

void objBegin() {
  beginRaw("superCAD.ObjFile", writeFilePath + "/" + writeFileName + shotNum + "/" + writeFileName + shotNum + "_frame"+writeFrameNum+"."+ "obj"); // Start recording to the file
}

void objEnd() {
  endRaw();
}

//~~~   END   ~~~

