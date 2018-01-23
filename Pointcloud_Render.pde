import peasy.*;
import superCAD.*;
//import processing.opengl.*;

//**************************************
int sW = 640;
int sH = 360;
ArrayList imgNames;
int counter = 0;
String filePath = "render";
String fileType = "obj"; //obj, ply, png...always lower case
float zscale = 3; //orig 3, 1 looks better in 2D image but 3 looks better for OBJ, PLY
float zskew = 10;
//**************************************
boolean firstRun = true;

PeasyCam cam;
float[][] gray;

String[] numFiles; 

PImage img, buffer;

void setup() {
  size(50, 50, P3D);
  Settings settings = new Settings("settings.txt");
  if(fileType.equals("png")){
    zscale = 1; //looks better if saving frames
  }else if(fileType.equals("ply")||fileType.equals("obj")){
    zscale = 3;
  }
  chooseFolderDialog();
  while(firstRun){
    try{
      if(imgNames.size() > 0) img = loadImage((String) imgNames.get(counter));
    }catch(Exception e){ }
  }
  sW = img.width;
  sH = img.height;
  surface.setSize(sW, sH);
  cam = new PeasyCam(this, sW);
  gray = new float[sH][sW];
  stroke(255);
}

void draw() {
  background(0);
  img = loadImage((String) imgNames.get(counter));
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
  if(fileType.equals("png")) saveFrame(filePath + "/" + fileName + zeroPadding(counter+1,imgNames.size()) + "." + fileType);
  if(counter<imgNames.size())counter++;
  if(counter==imgNames.size()){
    openAppFolderHandler();
    exit();
  }
}

static final int gray(color value) { 
  return max((value >> 16) & 0xff, (value >> 8 ) & 0xff, value & 0xff);
}

String zeroPadding(int _val, int _maxVal){
  String q = ""+_maxVal;
  return nf(_val,q.length());
}

//~~~   END   ~~~