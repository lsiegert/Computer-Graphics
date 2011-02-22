void setup(){
  size(600, 400);
  colorMode(RGB, 1);
  noLoop();
  background(0.5, 0.5, 0.5);
}

// Load sphere data from file
ArrayList loadSpheres() {
  ArrayList spheres = new ArrayList();
  String[] lines = loadStrings("spheres.tsv");

  for (int i=0; i<lines.length; i++){
    String[] pieces = split(lines[i], "\t");
    spheres.add(new Sphere(pieces));
  }
  return spheres;
}  

// Draw the scene
void draw(){
  PVector viewer = new PVector(240, 248, 5000);
  PVector light = new PVector(700, 400, 2000);
  float kd = 0.9;
  float ka = 0.2;

  ArrayList allSpheres = loadSpheres();

  for (int x1 = 0; x1 < width; x1++){
    for (int y1 = 0; y1 < height; y1++){
      PVector pixel = new PVector(x1,y1,0);
      HashMap spheret = RaySphereInt(viewer, pixel, allSpheres);
      Sphere intersected = (Sphere) spheret.get("sphere");

      // Determine the color of the current pixel
      if(intersected != null) {
        ArrayList allButInt = (ArrayList) allSpheres.clone();
        allButInt.remove(intersected);
        PVector intPoint = (PVector) spheret.get("intPoint");
        HashMap spheret2 = RaySphereInt(intPoint,light,allButInt);
        Sphere shadower = (Sphere) spheret2.get("sphere");

        // Determine if another sphere shades this one
        if(shadower != null) {
          stroke(ka*intersected.r, ka*intersected.g, ka*intersected.b);
        } 
        else {
          // Diffuse shading
          float t = (Float) spheret.get("t");
          float dx = pixel.x - viewer.x;
          float dy = pixel.y - viewer.y;
          float dz = pixel.z - viewer.z;
          float ix = viewer.x + t*dx;
          float iy = viewer.y + t*dy;
          float iz = viewer.z + t*dz;
          PVector n = new PVector(ix-intersected.cx, iy-intersected.cy, iz-intersected.cz);
          PVector l = new PVector(light.x-ix, light.y-iy, light.z-iz);
          n.normalize();
          l.normalize();
          float factor = n.dot(l);

          float rr = intersected.r;
          float gg = intersected.g;
          float bb = intersected.b;

          stroke(kd*factor*rr + ka*rr, kd*factor*gg + ka*gg, kd*factor*bb + ka*bb);
        }
      } 
      else {
        HashMap spheret3 = RaySphereInt(pixel,light,allSpheres);
        Sphere shadower = (Sphere) spheret3.get("sphere");
        if(shadower != null) {
          // half background color
          stroke(0.25, 0.25, 0.25);
        } 
        else {
          // full background color
          stroke(0.5, 0.5, 0.5);
        }
      }
      // Draw the current pixel
      point(x1,y1);
    }
  }
  // Save to a file
  save("spheres.png");
}

// Ray Sphere Intersection formulas
HashMap RaySphereInt(PVector p0, PVector p1, ArrayList spheres){
  // Distances between x,y,z of endpoints
  float dx = p1.x - p0.x;
  float dy = p1.y - p0.y;
  float dz = p1.z - p0.z;

  // Initialize to 1. t is always between 0 and 1
  float mint = 1;
  // Closest sphere to endpoint p0
  Sphere mins = null;
  // Initialize to 0,0,0
  PVector intPoint = new PVector(0,0,0);
  HashMap values = new HashMap();

  // Find the nearest sphere
  for(int i=0; i < spheres.size(); i++){
    Sphere s = (Sphere)spheres.get(i);

    PVector ve = new PVector(p0.x, p0.y, p0.z);
    PVector vd = new PVector(dx, dy, dz);
    PVector vc = new PVector(s.cx, s.cy, s.cz);

    float a = vd.dot(vd);
    ve.sub(vc);
    float b = 2*vd.dot(ve);
    float c = ve.dot(ve) - s.radius*s.radius;

    float discriminant = b*b-4*a*c;
    float t = (-b - sqrt(discriminant)) / (2*a);
    PVector intersectionPoint = new PVector(p0.x + dx, p0.y + dy, p0.z + dz);

    if (discriminant > 0 && (0 < t) && (t < 1) && t <= mint){
      mint = t;
      mins = s;
      intPoint = intersectionPoint;
    }
  }

  // Returns either the closest sphere, or null if no intersection
  values.put("sphere", mins);
  values.put("t", mint);
  values.put("intPoint", intPoint);
  return values; 
}

class Sphere {
  int cx,cy,cz,radius;
  float r,g,b;
  public Sphere(String[] pieces) {
    cx = int(pieces[0]);
    cy = int(pieces[1]);
    cz = int(pieces[2]);
    radius = int(pieces[3]);
    r = float(pieces[4]);
    g = float(pieces[5]);
    b = float(pieces[6]);
  }
}

