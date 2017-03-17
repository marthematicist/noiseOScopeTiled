float centerH = 0;
float widthH = 0.7;

float minS = 0.0;
float maxS = 1.0;
float minB = 0.3;
float maxB = 1.0;
float alpha = 0.03;
float transStart = 0.45;
float transWidth = 0.02;

float ah = 0.005;
float as = 0.055;
float ab = 0.055;
float af = 0.012;
float ag = 1;

float th = 0.060;
float ts = 0.030;
float tb = 0.010;
float tf = 0.005;
float tc = 0.003;
float tA = 0.4;

int numSpokes = 12;
float ang;
int w = 1;

float[] px;
float[] py;

color[] P;
int pRes;
int numTilesX;
int numTilesY;

float xRes;
float yRes;
void setup() {
  size( 800 , 480 );
  xRes = float(width);
  yRes = float(height);
  pRes = height/2;
  centerH = random(0, 1);
  noStroke();
  background(0);
  ang = 2*PI/float(numSpokes);
  println( ang );

  
  P = new color[pRes*pRes];
  for ( int x = 0; x < pRes; x++ ) {
    for ( int y = 0; y < pRes; y++ ) {
      P[x+y*pRes] = color(0,0,0);
    }
  }
  
  px = new float[pRes*pRes];
  py = new float[pRes*pRes];
  for ( int x = 0; x < pRes; x++ ) {
    for ( int y = 0; y < pRes; y++ ) {
      float x2 = float(x) + 0.5;
      float y2 = float(y) + 0.5;
      PVector v = new PVector( x2, y2 );
      float a = (v.heading() + PI)%ang;
      if ( a > 0.5*ang ) { 
        a = ang - a;
      }
      float r = v.mag();
      px[x+y*pRes] = r*cos(a);
      py[x+y*pRes] = r*sin(a);
    }
  }
  numTilesX = width / pRes;
  numTilesY = height / pRes;
}

void draw() {
  float t = tA*float(frameCount);
  for ( int x = 0; x < pRes; x++ ) {
    for ( int y = 0; y < pRes; y++ ) {
      float x2 = px[x+y*pRes];
      float y2 = py[x+y*pRes];

      float f = noise( ag*af*(30*xRes + x2), ag*af*(30*yRes + y2), tf*t ) ;
      color c;
      if ( f > transStart && f < transStart+transWidth ) {
        c = lerpColor( P[x+y*pRes], color(255, 255, 255), alpha );
      } else if ( f >= transStart+transWidth ) {
        float h = (frameCount*tc*tA + centerH + widthH*noise( ag*ah*(0*xRes + x2), ag*ah*y2, th*t ) )%1;
        float s = lerp( minS, maxS, noise( ag*as*(10*xRes + x2), ag*as*(10*yRes + y2), ts*t ) );
        float b = lerp( minB, maxB, noise( ag*ab*(20*xRes + x2), ag*ab*(20*yRes + y2), tb*t ) );
        c = lerpColor( P[x+y*pRes], hsbColor(h*360, s, b), alpha );
      } else {
        c = lerpColor( P[x+y*pRes], color(0, 0, 0), alpha );
      }
      P[x+y*pRes] = c;
    }
  }
  loadPixels();
  for( int x = -numTilesX ; x < numTilesX ; x++ ) {
    for( int y = -numTilesY ; y < numTilesY ; y++ ) {
      int x0 = width/2 + x*pRes;
      int y0 = height/2 + y*pRes;
      boolean revX = false;
      if( abs(x)%2 == 1 ) { revX = true; }
      boolean revY = false;
      if( abs(y)%2 == 1 ) { revY = true; }
      drawTile( P , x0 , y0 , revX , revY );
    }
  }
  updatePixels();


  println(frameRate);
}

void drawTile( color[] tile , int x0 , int y0 , boolean revX , boolean revY ) {
  int minX = x0;
  if( minX < 0 ) { minX = 0; }
  int minY = y0;
  if( minY < 0 ) { minY = 0; }
  int maxX = x0 + pRes;
  if( maxX > width ) { maxX = width; }
  int maxY = y0 + pRes;
  if( maxY > height ) {maxY = height; }
  for( int x = minX ; x < maxX ; x++ ) {
    for( int y = minY ; y < maxY ; y++ ) {
      int x1;
      if( !revX ) { x1 =  x - x0; }
      else { x1 = pRes - (x-x0)-1; }
      int y1;
      if( !revY ) { y1 =  y - y0; }
      else { y1 = pRes - (y-y0)-1; }
      pixels[x+y*width] = P[x1+y1*pRes];
    }
  }
}

void mouseMoved() {
}
void mouseDragged() {
}

color hsbColor( float h, float s, float b ) {
  float c = b*s;
  float x = c*( 1 - abs( (h/60) % 2 - 1 ) );
  float m = b - c;
  float rp = 0;
  float gp = 0;
  float bp = 0;
  if ( 0 <= h && h < 60 ) {
    rp = c;  gp = x;  bp = 0;
  }
  if ( 60 <= h && h < 120 ) {
    rp = x;  gp = c;  bp = 0;
  }
  if ( 120 <= h && h < 180 ) {
    rp = 0;  gp = c;  bp = x;
  }
  if ( 180 <= h && h < 240 ) {
    rp = 0;  gp = x;  bp = c;
  }
  if ( 240 <= h && h < 300 ) {
    rp = x;  gp = 0;  bp = c;
  }
  if ( 300 <= h && h < 360 ) {
    rp = c;  gp = 0;  bp = x;
  }
  return color( (rp+m)*255, (gp+m)*255, (bp+m)*255 );
}