// https://processing.org/reference/camera_.html
class Cam {

  PVector pos = new PVector(0,0,0);
  PVector poi = new PVector(0,0,0);
  PVector up = new PVector(0,0,0);

  PVector mouse = new PVector(0,0,0);
  PGraphics3D p3d;
  PMatrix3D proj, cam, modvw, modvwInv, screen2Model;
  
  String displayText = "";
  PFont font;
  int fontSize = 12;

  void init() {
    p3d = (PGraphics3D) g;
    //proj = new PMatrix3D();
    cam = new PMatrix3D();
    //modvw = new PMatrix3D();
    modvwInv = new PMatrix3D();
    screen2Model = new PMatrix3D();
    
    font = createFont("Arial", fontSize);
  }
  
  PVector screenToWorldCoords(PVector p) {
    //proj = p3d.projection.get();
    cam = p3d.modelview.get(); //camera.get();
    //modvw = p3d.modelview.get();
    modvwInv = p3d.modelviewInv.get();
    screen2Model = modvwInv;
    screen2Model.apply(cam);
    float screen[] = { p.x, p.y, p.z };
    float model[] = { 0, 0, 0 };
    model = screen2Model.mult(screen, model);
    
    return new PVector(model[0] + (poi.x - width/2), model[1] + (poi.y - height/2), model[2]);
  }
  
  void screenToWorldMouse() {
    mouse = screenToWorldCoords(new PVector(mouseX, mouseY, poi.z));
  }
  
  Cam() {
    defaultPos();
    defaultPoi();
    defaultUp();
    init();
  }
  
  Cam(PVector _pos) {
    pos = _pos;
    defaultPoi();
    defaultUp();
    init();
  }
  
  Cam(PVector _pos, PVector _poi) {
    pos = _pos;
    poi = _poi;
    defaultUp();
    init();
  }
  
  Cam(PVector _pos, PVector _poi, PVector _up) {
    pos = _pos;
    poi = _poi;
    up = _up;
    init();
  }
  
  void update() {
    screenToWorldMouse();
  }
  
  void draw() {
    camera(pos.x, pos.y, pos.z, poi.x, poi.y, poi.z, up.x, up.y, up.z);
    drawText();
  }
  
  void run() {
    update();
    draw();
  }
  
  void move(float x, float y, float z) {
    PVector p = new PVector(x,y,z);
    pos = pos.add(p);
    poi = poi.add(p);
  }
  
  void defaultPos() {
    pos.x = width/2.0;
    pos.y = height/2.0;
    pos.z = (height/2.0) / tan(PI*30.0 / 180.0);
  }
  
  void defaultPoi() {
    poi.x = width/2.0;
    poi.y = height/2.0;
    poi.z = 0;
  }
  
  void defaultUp() {
    up.x = 0;
    up.y = 1;
    up.z = 0;
  }
  
  void reset() {
    defaultPos();
    defaultPoi();
    defaultUp();
  }
  
  void drawText() {
    if (!displayText.equals("")) {
      pushMatrix();  
      translate((pos.x - (width/2)) + (fontSize/2), (pos.y - (height/2)) + fontSize, poi.z);
      textFont(font, fontSize);
      text(displayText, 0, 0);
      popMatrix();
    }
  }
  
}

// TODO
// https://processing.org/reference/frustum_.html
// https://processing.org/reference/beginCamera_.html
// https://processing.org/reference/endCamera_.html