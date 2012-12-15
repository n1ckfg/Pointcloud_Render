import peasy.*;
import superCAD.*;
//import processing.opengl.*;

//**************************************
int sW = 640;
int sH = 360;
ArrayList photoArrayNames;
int counter = 0;
String fileName = "frame";
String filePath = "render";
String fileType = "obj";
float zscale = 3; //orig 3, 1 looks better in 2D image but 3 looks better for OBJ
float zskew = 10;
//**************************************

PeasyCam cam;
float[][] gray;

File dataFolder;
String[] numFiles; 

PImage img, buffer;

void setup() {
  countFrames();
  img = loadImage((String) photoArrayNames.get(counter));
  sW = img.width;
  sH = img.height;
  size(sW, sH, P3D);
  cam = new PeasyCam(this, sW);
  gray = new float[sH][sW];
  stroke(255);
}

void draw() {
  background(0);
  img = loadImage((String) photoArrayNames.get(counter));
  objMain();
  //~~~ 
  pushMatrix();
  translate(-sW / 2, -sH / 2);  
  int step = 2;
  for (int y = step; y < sH; y += step) {
    float planephase = 0.5 - (y - (sH / 2)) / zskew;
    for (int x = step; x < sW; x += step){
      stroke(gray[y][x]);
      //point(x, y, (gray[y][x] - planephase) * zscale);
      line(x, y, (gray[y][x] - planephase) * zscale, x+1, y, (gray[y][x] - planephase) * zscale);
    }
  }
  popMatrix();
  //~~~
  if(counter<photoArrayNames.size()) counter++;
  if(counter==photoArrayNames.size()) exit();
}

static final int gray(color value) { 
  return max((value >> 16) & 0xff, (value >> 8 ) & 0xff, value & 0xff);
}

void countFrames() {
  photoArrayNames = new ArrayList();
    try {
        //loads a sequence of frames from a folder
        File dataFolder = new File(sketchPath, "data/"); 
        String[] allFiles = dataFolder.list();
        for (int j=0;j<allFiles.length;j++) {
          if (allFiles[j].toLowerCase().endsWith("png")||allFiles[j].toLowerCase().endsWith("jpg")||allFiles[j].toLowerCase().endsWith("jpeg")||allFiles[j].toLowerCase().endsWith("gif")||allFiles[j].toLowerCase().endsWith("tga")) {
            photoArrayNames.add(allFiles[j]);
          }
        }
    }catch(Exception e){ }
  }

String zeroPadding(int _val, int _maxVal){
  String q = ""+_maxVal;
  return nf(_val,q.length());
}

//~~~   END   ~~~

