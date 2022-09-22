import java.util.Arrays;

public ArrayList<double[]> points = new ArrayList<double[]>();
Listener L=new Listener();
ArrayList<Poly> equations=new ArrayList<Poly>();
Poly inter= new Poly();

public static final float Limit=10;//to avoid very bad glitch

public void setup() {
  rectMode(CORNERS);
  textAlign(CENTER, CENTER);
  textSize(50);
  size(900,600);//Windows version
}

int click=0;

public void draw() {
  background (#BbCcaa);
  stroke(255, 0, 0);
  for (double[] P : points) {
    line((float)P[0]-5, (float)P[1], (float)P[0]+5, (float)P[1]);
    line((float)P[0], (float)P[1]-5, (float)P[0], (float)P[1]+5);
  }
  L.update();
  inter.draw(0.7);

  fill(#777777);
  stroke(#444444);
  strokeWeight(3);
  rect(0, 9*height/10, width, height);
  fill(#Ffffff);
  text("reset", width/2, 19*height/20);

  if (L.isClick()) {
    if (mouseY>9*height/10) {
      equations=new ArrayList<Poly>();
      inter=new Poly();
      points = new ArrayList<double[]>();
    } else
      addPoly(mouseX, mouseY);
  }
}

public void addPoly(double x, double y) {
  //first check if the point is too near another point on the x position
  for(double[] p:points)
    if(abs((float)(p[0]-x))<Limit)
      return;
  inter=new Poly(points.size()+1);
  for (int i=0; i<equations.size(); i++) {
    equations.set(i, equations.get(i).product(new Poly(new double[]{-x, 1.0f})));
    equations.get(i).factor(1/(points.get(i)[0]-x));
  }
  Poly N=new Poly(new double[]{1});
  for (double[] P : points) {
    N=N.product(new Poly(new double[]{-P[0]/(x-P[0]), 1/(x-P[0])}));
  }
  N.factor(y);
  equations.add(N);
  points.add(new double[]{x, y});
  for (Poly p : equations)
    inter=inter.add(p);
  println(inter.log(500));
}

public class Poly {

  private int deg;
  public int getDeg() {
    return(deg);
  }

  private double[] coef;
  public double getCoef(int power) {
    return coef[power];
  }
  public void setCoef(int power, double C) {
    coef[power]=C;
  }
  public void factorCoef(int power, double f) {
    coef[power]*=f;
  }
  public void addCoef(int power, double term) {
    coef[power]+=term;
  }


  public Poly() {
    this(0);
  }

  public Poly(int D) {
    deg=D;
    coef=new double[deg];
  }

  public void factor(double f) {
    for (int i=0; i<deg; i++)
      coef[i]*=f;
  }

  public Poly product(Poly p) {
    Poly out = new Poly(deg+p.getDeg());
    for (int i=0; i<p.getDeg(); i++) {
      double f=p.getCoef(i);
      for (int j=0; j<deg; j++)
        out.addCoef(i+j, coef[j]*f);
    }
    return out;
  }

  public void reset() {
    Arrays.fill(coef, 0);
  }

  public Poly add(Poly p) {
    Poly out = new Poly(max(p.getDeg(), deg));
    for (int i=0; i<out.getDeg(); i++)
      out.setCoef(i, (deg>i)?(((p.getDeg()>i)?p.getCoef(i):0)+coef[i]):p.getCoef(i));
    return out;
  }


  public Poly(double[] terme) {
    this(terme.length);
    for (int i=0; i<deg; i++)
      coef[i]=terme[i];
  }

  public double eval(double x) {
    double factor=1;
    double result=0;
    for (int i=0; i<deg; i++) {
      result+=coef[i]*factor;
      factor*=x;
    }
    return(result);
  }

  public double log(double x) {
    double factor=1;
    double result=0;
    println("log");
    for (int i=0; i<deg; i++) {
      println(factor);
      result+=coef[i]*factor;
      factor*=x;
    }
    return(result);
  }

  public void draw(float step) {
    double x=0;
    while (x<width) {
      line((float)x, (float)eval(x), (float)x+step, (float)eval(x+step));
      x+=step;
    }
  }

  public void addPoint(double x, double y) {
    double[] nextCoef= new double[deg+1];
    deg++;
    for (int i=0; i<deg; i++) {
      nextCoef[i]=((i==0)?0:(coef[i-1]))-((i==(deg-1))?0:coef[i]*x);
    }
  }
}

public class Listener {
  private boolean pressed=false;
  private boolean click=false;

  public boolean isClick() {
    return click;
  }

  public boolean isPressed() {
    return pressed;
  }

  public Listener() {
  }

  public void update() {
    /** Android Version
    click=(touchIsStarted&&!pressed);
    pressed=touchIsStarted;
    //**/
    //** Windows Version
    click=mousePressed&&!pressed;    
    pressed=mousePressed;
    //**/
  }
}
