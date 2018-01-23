Data dataVert, dataMain;
ArrayList<Float> lidarPoints;
int vertCounter = 0;
String url = "";

void exportMain() {
  url = filePath + "/" + fileName + zeroPadding(counter+1,imgNames.size()) + "." + fileType;
  vertCounter = 0; 
  
  dataMain = new Data();
  dataMain.beginSave();
  dataVert = new Data();
  dataVert.beginSave();
  lidarPoints = new ArrayList<Float>();
  
  buffer = img;
  for (int y = 0; y < sH; y++) {
    for (int x = 0; x < sW; x++) {
      // FIXME: this loses Z-resolution about tenfold ...
      //       -> should grab the real distance instead...
      color argb = buffer.pixels[y*width+x];
      gray[y][x] = getGray(argb);
      if (gray[y][x] > 0) {
        vertCounter++;
        if (fileType.toLowerCase().equals("obj")) {
          objVert(x,y);
        } else if (fileType.toLowerCase().equals("ply")) {
          plyVert(x,y);
        } else if (fileType.toLowerCase().equals("asc")) {
          ascVert(x,y);
        } else if (fileType.toLowerCase().equals("bin")) {
          binVert(x,y);
        }
      }
    }
  }
  if (fileType.toLowerCase().equals("obj")) {
    objHeader();
    compileVert();
    objFooter();
    writeAscii();
  } else if (fileType.toLowerCase().equals("ply")) {
    plyHeader();
    compileVert(); // ply doesn't need a footer
    writeAscii();
  } else if (fileType.toLowerCase().equals("asc")) {
    compileVert(); // asc doesn't need header or footer
    writeAscii();
  } else if (fileType.toLowerCase().equals("bin")) {
    writeBin();
  }
}

void writeAscii() {
  dataMain.endSave(url);
}

void writeBin() {
  float[] floats = floatListToArray(lidarPoints);
  floatsToBytes(floats, url); 
}

float[] floatListToArray(ArrayList<Float> list) {
  float[] floats = new float[list.size()];
  for (int i=0; i<floats.length; i++) {
    floats[i] = list.get(i);
  }
  return floats;
}

void compileVert() {
  for (int i=0; i<dataVert.datalist.size(); i++) {
    String s = (String) dataVert.datalist.get(i);
    dataMain.add(s);
  }
}

//~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~
// OBJ
void objHeader() {
  dataMain.add("####");
  dataMain.add("#");
  dataMain.add("# Vertices: "+ vertCounter);
  dataMain.add("# Faces: 0");
  dataMain.add("#");
  dataMain.add("####");
}

void objVert(int x, int y) {
  dataVert.add("v " + x + " " + y + " " + gray[y][x]);
}

void objFooter() {
  dataMain.add("# " + vertCounter +" vertices, 0 vertex normals");
  dataMain.add("");
  dataMain.add("# 0 faces, 0 texture coords");
  dataMain.add("");
  dataMain.add("# End of File");
}

//~ ~ ~ ~ ~
// PLY
void plyHeader() {
  dataMain.add("ply");
  dataMain.add("format ascii 1.0");
  dataMain.add("comment VCGLIB generated");
  dataMain.add("element vertex " + vertCounter);
  dataMain.add("property float x");
  dataMain.add("property float y");
  dataMain.add("property float z");
  dataMain.add("property uchar red");
  dataMain.add("property uchar green");
  dataMain.add("property uchar blue");
  dataMain.add("property uchar alpha");
  dataMain.add("element face 0");
  dataMain.add("property list uchar int vertex_indices");
  dataMain.add("end_header");
}

void plyVert(int x, int y) {
  dataVert.add(x + " " + y + " " + gray[y][x] + " 192 192 192 255 "); //hard-coded vertex color for now. Trailing space is on purpose.
}

//~ ~ ~ ~ ~
// ASC
void ascVert(int x, int y) {
  dataVert.add(x + " " + y + " " + gray[y][x]);
}

//~ ~ ~ ~ ~
// BIN (Velodyne)
void binVert(int x, int y) {
  lidarPoints.add(float(x));
  lidarPoints.add(float(y));
  lidarPoints.add(gray[y][x]);
  lidarPoints.add(gray[y][x]);
}