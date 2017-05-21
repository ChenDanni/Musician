import processing.sound.*;
import processing.serial.*;
Serial port;
int val = -1;  // 0:left 1:middle 2:right 
int rectX, rectY;      // Position of square button
int circleX, circleY;  // Position of circle button
int rectSize = 90;     // Diameter of rect
int circleSize = 93;   // Diameter of circle

color rectColor;
color circleColor;
color baseColor;
color lineColor;
color hitColor;
color shadowColor;
color scoreColor;
color progressColor;
int upw;
int downw;
int uph;
int downh;
int ups;
int upend;
int ddw;
int dds;
int time;
int hit;
int scoreP = 0;
int state;
PImage b1;
PFont f;
PFont sf;
SoundFile sound;
float soundLen;
boolean play = false;
boolean finish = false;
int overIndex = -1; //-1 not over; i over i
boolean rectOver = false;
boolean circleOver = false;
boolean restart = false;
boolean start = false;
float spendT = 0.6;
int add;
int framerate = 80;
int mul = 8;
int total = 374;
class C{
  public int type; //0,1,2,3 left,middle,right,stop
  public int y;
  public int time;
  public boolean hit;
  public C(int type,int time){
    this.type = type;
    this.time = time;
    y = (int)(uph - time + spendT*framerate);
    hit = false;
  }
}
ArrayList<C> cs;
int num;
int runIndex;
int runEnd;

void init(){
  cs = new ArrayList<C>();
  initC();
  num = cs.size();
  runIndex = -1;
  runEnd = -1;
  time = 0;
  state = 0;
  play = false;
  finish = false;
  overIndex = -1; //-1 not over; i over i
  restart = false;
  val = -1;
}

void setup() {
  size(400,600);
  frameRate(framerate);
  String arduinoPort = Serial.list()[1];
  port = new Serial(this,arduinoPort,9600);
  
  rectColor = color(0);
  circleColor = color(255);
  baseColor = color(255,0,0,191);
  lineColor = color(#D3880F);
  hitColor = color(#DCBCAB);
  shadowColor = color(#B8ADAA);
  scoreColor = color(0, 0, 0, 63);
  progressColor = color(#D11E18);
  upw = width/16;
  downw = width/3;
  uph = height/5;
  downh = height - height/4;
  ups = (width - 3*upw)/2;
  upend = width - ups;
  ddw = upw + (width/3 - upw)*16/11;
  dds = (width - ddw)/2;
  cs = new ArrayList<C>();
  initC();
  num = cs.size();
  runIndex = -1;
  runEnd = -1;
  time = 0;
  state = 0;
  add = int((downh - uph)/(framerate*spendT));
  println("add: " + add);
  
  hit = 0;
  sf = createFont("Arial", 22, true);
  f = createFont("Arial", 16, true);
  textFont(f,18);
  
  sound = new SoundFile(this,"sakula.mp3");
  //soundLen = sound.duration()*framerate;
  soundLen = 10200;
  
  //---
  println("sound len : " + soundLen);
  
  b1 = loadImage("b3.png");
  
  circleX = width/2+circleSize/2+10;
  circleY = uph;
  rectX = width/2-rectSize-10;
  rectY = 0;
  ellipseMode(CENTER);
  smooth();
}
void checkRestart(){
  if (val == 3){
    restart = true;
  }
  val = -1;
}

void drawStart(){
  drawBackground();
  fill(0, 0, 0, 63);
  rect(0,0,width,height);
  fill(0,0,0);
  textFont(sf,20);
  text("WELCOME",155,140);
  text("4: left",160,185);
  text("5: middle",160,215);
  text("6: right",160,245);
  text("press '0' to start the game...",100,285);
  
}
void draw() {
  if (0 < port.available()){
      val = port.read();
  }
  if (!start){
    if (val == 3){
      start = true;
      val = -1;
    }
    drawStart();
  }else{
    if (finish){
      checkRestart();
      if (restart){
        init();
      }else {
        drawFinish();
        sound.stop();
      }
      //background(baseColor);
    }else{
      drawBackground();
      noStroke();
      update();
  
      if (!play){
        sound.play(1,1);
        play = true;
      }
      refresh();
      drawRunning();
      drawPoints();
      if (scoreP != 0){
        drawHit();
      }
      drawProcess();
    } 
  }
}

void drawProcess(){
  fill(progressColor);
  rect(0,height - 3,width*runIndex/total,3);
}
void drawFinish(){
  //background(baseColor);
  drawBackground();
  fill(0, 0, 0, 63);
  rect(0,0,width,height);
  fill(0,0,0);
   textFont(sf,20);
  text("Finish the game!",135,200);
  text("You score is: " + hit*10,135,250);
  text("Hit: " + hit + " / " + total,150,300);
   textFont(sf,14);
  text("press '0' to restart the game...",125,330);
}

void drawRunning(){
  int start = 0;
  if (start < runIndex) start = runIndex;
  for (int i = start;i < num;i++){
    int type = cs.get(i).type;
    int y = cs.get(i).y;
    boolean h = cs.get(i).hit;
    
    drawC(type,y,h);
  }
}

void drawC(int type,int y,boolean hit){
  //stroke(0);
  int rw = upw + (downw - upw)*((y - uph)*100/(downh - uph))/100;
  int cSize = rw*3/4;
  int x = rw/2 + ups - ups*((y - uph)*100/(downh - uph))/100;
  if (type == 2){
    x = x + 2*rw;
  }else if (type == 1){
    x = x + rw;
  }
  
  fill(shadowColor);
  ellipse(x + cSize/12,y + cSize/15,cSize,cSize/2);
  
  if (hit){ 
    fill(hitColor);
  }
  else fill(circleColor); 
  ellipse(x,y,cSize,cSize/2);
  
}

void refresh(){
  time++;
  if (time > soundLen){
    finish = true;
  }
  int i = 0;
  int start = 0;
  if (start < runIndex) start = runIndex;
  for (i = start;i < num;i++){
    if (cs.get(i).y > height){
      runIndex++;
      break;
    }
  }
  for (i = runEnd + 1;i < num;i++){
    if (cs.get(i).y > uph){
      //println("-----time: " + time + "  ______y: " + cs.get(i).y);
      runEnd++;
      break;
    }
  }
  
  for (i = start;i <= runEnd;i++){
    cs.get(i).y += add;
  }
  for (i = runEnd + 1;i < num;i++){
    cs.get(i).y += 1;
  }
}

void update() {
  
  fill(color(#FDCCA2));
  //if ((mouseX > 0)&&(mouseX < downw)){
  if (val == 0){  
    triangle(0,height,1,downh,ups + 1,uph);
    quad(0,height,ups,uph,ups + upw,uph,dds,height);
  //}else if (mouseX < 2*downw){
  }else if (val == 1){  
    quad(dds + 1,height,ups + upw + 1,uph,ups + 2*upw,uph,dds + ddw,height);
  }else if (val == 2){
    quad(dds + ddw + 1,height,ups + 2*upw + 1,uph,width - ups,uph,width,height);
    triangle(width,height,width - ups,uph,width,downh);
  }
  
  for (int i = runIndex;i <= runEnd;i++){
    if (i == -1) break;
    overIndex = -1;
    if (!cs.get(i).hit){
      if(overC(cs.get(i).type, cs.get(i).y)){
        overIndex = i;
        cs.get(i).hit = true;
        hit++;
        scoreP = 1;
        break;
      }
    }
  }
  
}

void drawHit(){
  fill(250,238,228);
  textFont(sf,40);
  text(hit + " hits",width/2 - 30,height/2 - 10 - scoreP);
  textFont(f,18);
  scoreP++;
  if (scoreP == 20) scoreP = 0;
}

boolean overC(int type, int y){
  if (((y - downh < 70)&&(y - downh > -30))&&(type == val)){
    return true;
  }
  //float disY = y - mouseY;
  //if ((downh - y > -30)&&(downh - y < 30)){
  //  if ((disY > downh - height)&&(disY < 30)&&(mouseX > type*downw)&&(mouseX < (type + 1)*downw)){
  //    return true;
  //  }
  //} 
  return false;
}

void drawPoints(){
  fill(255);
  text("scores: " + hit,width - 100,40);
  text("time: " + time,width - 100,90);
}

void drawBackground(){
  noStroke();
  background(baseColor);
  
  image(b1,0,0,width,height);
  
  fill(lineColor);
  rect(0,uph - 1,width,1);
  //rect(0,height - height/7,width,2);
  stroke(lineColor);
  line(ups,uph,0,downh);
  line(upend,uph,width,downh);
  //road
  line(ups+upw,uph,downw,downh);
  line(ups+2*upw,uph,2*downw,downh);
  
  //fill(progressColor);
  stroke(progressColor);
  //rect(0,downh,width,50);
  line(downw,downh,dds,height);
  line(2*downw,downh,dds + ddw,height);
}

void initC(){
C c2 = new C(1,48*mul);
C c3 = new C(2,49*mul);
C c4 = new C(0,53*mul);
C c5 = new C(0,60*mul);
C c6 = new C(1,62*mul);
C c7 = new C(1,71*mul);
C c8 = new C(1,76*mul);
C c9 = new C(0,78*mul);
C c10 = new C(2,89*mul);
C c11 = new C(1,100*mul);
C c12 = new C(1,106*mul);
C c13 = new C(2,107*mul);
C c14 = new C(2,108*mul);
C c15 = new C(1,109*mul);
C c16 = new C(2,110*mul);
C c17 = new C(1,111*mul);
C c18 = new C(1,112*mul);
C c19 = new C(2,114*mul);
C c20 = new C(2,115*mul);
C c21 = new C(0,116*mul);
C c22 = new C(0,117*mul);
C c23 = new C(0,118*mul);
C c24 = new C(0,121*mul);
C c25 = new C(1,122*mul);
C c26 = new C(0,124*mul);
C c27 = new C(1,126*mul);
C c28 = new C(1,127*mul);
C c29 = new C(2,128*mul);
C c30 = new C(2,129*mul);
C c31 = new C(2,133*mul);
C c32 = new C(0,134*mul);
C c33 = new C(1,135*mul);
C c34 = new C(1,136*mul);
C c35 = new C(0,137*mul);
C c36 = new C(0,143*mul);
C c37 = new C(2,144*mul);
C c38 = new C(0,162*mul);
C c39 = new C(2,166*mul);
C c40 = new C(1,167*mul);
C c41 = new C(0,173*mul);
C c42 = new C(0,174*mul);
C c43 = new C(2,175*mul);
C c44 = new C(1,176*mul);
C c45 = new C(0,177*mul);
C c46 = new C(0,179*mul);
C c47 = new C(1,180*mul);
C c48 = new C(2,184*mul);
C c49 = new C(1,186*mul);
C c50 = new C(2,187*mul);
C c51 = new C(1,188*mul);
C c52 = new C(2,192*mul);
C c53 = new C(2,193*mul);
C c54 = new C(0,195*mul);
C c55 = new C(0,196*mul);
C c56 = new C(2,199*mul);
C c57 = new C(0,200*mul);
C c58 = new C(2,201*mul);
C c59 = new C(1,204*mul);
C c60 = new C(1,206*mul);
C c61 = new C(2,210*mul);
C c62 = new C(0,211*mul);
C c63 = new C(1,213*mul);
C c64 = new C(1,217*mul);
C c65 = new C(1,221*mul);
C c66 = new C(2,223*mul);
C c67 = new C(0,225*mul);
C c68 = new C(2,228*mul);
C c69 = new C(0,229*mul);
C c70 = new C(0,231*mul);
C c71 = new C(1,232*mul);
C c72 = new C(0,234*mul);
C c73 = new C(1,236*mul);
C c74 = new C(1,238*mul);
C c75 = new C(2,239*mul);
C c76 = new C(2,241*mul);
C c77 = new C(2,245*mul);
C c78 = new C(0,246*mul);
C c79 = new C(1,253*mul);
C c80 = new C(0,263*mul);
C c81 = new C(0,268*mul);
C c82 = new C(2,279*mul);
C c83 = new C(0,285*mul);
C c84 = new C(0,289*mul);
C c85 = new C(1,290*mul);
C c86 = new C(0,291*mul);
C c87 = new C(1,292*mul);
C c88 = new C(2,294*mul);
C c89 = new C(1,297*mul);
C c90 = new C(2,305*mul);
C c91 = new C(1,308*mul);
C c92 = new C(1,309*mul);
C c93 = new C(0,311*mul);
C c94 = new C(2,312*mul);
C c95 = new C(1,317*mul);
C c96 = new C(1,318*mul);
C c97 = new C(2,322*mul);
C c98 = new C(0,324*mul);
C c99 = new C(0,327*mul);
C c100 = new C(0,329*mul);
C c101 = new C(1,333*mul);
C c102 = new C(0,334*mul);
C c103 = new C(2,337*mul);
C c104 = new C(0,341*mul);
C c105 = new C(2,348*mul);
C c106 = new C(0,351*mul);
C c107 = new C(1,355*mul);
C c108 = new C(2,356*mul);
C c109 = new C(2,367*mul);
C c110 = new C(2,378*mul);
C c111 = new C(1,393*mul);
C c112 = new C(1,398*mul);
C c113 = new C(2,399*mul);
C c114 = new C(1,400*mul);
C c115 = new C(2,401*mul);
C c116 = new C(0,404*mul);
C c117 = new C(1,411*mul);
C c118 = new C(1,416*mul);
C c119 = new C(0,420*mul);
C c120 = new C(2,447*mul);
C c121 = new C(2,451*mul);
C c122 = new C(1,457*mul);
C c123 = new C(2,458*mul);
C c124 = new C(2,462*mul);
C c125 = new C(1,465*mul);
C c126 = new C(2,466*mul);
C c127 = new C(0,467*mul);
C c128 = new C(0,468*mul);
C c129 = new C(1,470*mul);
C c130 = new C(0,484*mul);
C c131 = new C(1,487*mul);
C c132 = new C(0,488*mul);
C c133 = new C(2,494*mul);
C c134 = new C(1,502*mul);
C c135 = new C(1,513*mul);
C c136 = new C(0,514*mul);
C c137 = new C(0,526*mul);
C c138 = new C(0,527*mul);
C c139 = new C(2,528*mul);
C c140 = new C(1,532*mul);
C c141 = new C(1,534*mul);
C c142 = new C(2,547*mul);
C c143 = new C(2,555*mul);
C c144 = new C(1,567*mul);
C c145 = new C(2,568*mul);
C c146 = new C(1,576*mul);
C c147 = new C(1,578*mul);
C c148 = new C(2,579*mul);
C c149 = new C(1,580*mul);
C c150 = new C(0,582*mul);
C c151 = new C(2,583*mul);
C c152 = new C(0,585*mul);
C c153 = new C(0,586*mul);
C c154 = new C(0,589*mul);
C c155 = new C(2,598*mul);
C c156 = new C(1,601*mul);
C c157 = new C(1,604*mul);
C c158 = new C(2,618*mul);
C c159 = new C(0,619*mul);
C c160 = new C(2,620*mul);
C c161 = new C(0,629*mul);
C c162 = new C(2,632*mul);
C c163 = new C(1,645*mul);
C c164 = new C(0,660*mul);
C c165 = new C(0,663*mul);
C c166 = new C(2,700*mul);
C c167 = new C(0,704*mul);
C c168 = new C(0,738*mul);
C c169 = new C(2,739*mul);
C c170 = new C(1,740*mul);
C c171 = new C(2,743*mul);
C c172 = new C(2,747*mul);
C c173 = new C(0,750*mul);
C c174 = new C(0,752*mul);
C c175 = new C(2,760*mul);
C c176 = new C(1,762*mul);
C c177 = new C(0,764*mul);
C c178 = new C(2,777*mul);
C c179 = new C(2,779*mul);
C c180 = new C(0,781*mul);
C c181 = new C(1,784*mul);
C c182 = new C(2,791*mul);
C c183 = new C(1,792*mul);
C c184 = new C(0,794*mul);
C c185 = new C(0,795*mul);
C c186 = new C(2,798*mul);
C c187 = new C(1,808*mul);
C c188 = new C(1,809*mul);
C c189 = new C(2,810*mul);
C c190 = new C(0,813*mul);
C c191 = new C(1,814*mul);
C c192 = new C(2,815*mul);
C c193 = new C(2,816*mul);
C c194 = new C(2,817*mul);
C c195 = new C(1,818*mul);
C c196 = new C(1,819*mul);
C c197 = new C(1,820*mul);
C c198 = new C(1,823*mul);
C c199 = new C(1,824*mul);
C c200 = new C(2,828*mul);
C c201 = new C(0,829*mul);
C c202 = new C(2,831*mul);
C c203 = new C(2,833*mul);
C c204 = new C(0,835*mul);
C c205 = new C(0,837*mul);
C c206 = new C(1,838*mul);
C c207 = new C(2,843*mul);
C c208 = new C(2,845*mul);
C c209 = new C(0,846*mul);
C c210 = new C(0,850*mul);
C c211 = new C(0,853*mul);
C c212 = new C(2,856*mul);
C c213 = new C(1,857*mul);
C c214 = new C(2,861*mul);
C c215 = new C(2,866*mul);
C c216 = new C(1,867*mul);
C c217 = new C(2,871*mul);
C c218 = new C(2,875*mul);
C c219 = new C(2,876*mul);
C c220 = new C(2,882*mul);
C c221 = new C(1,885*mul);
C c222 = new C(1,886*mul);
C c223 = new C(0,889*mul);
C c224 = new C(1,890*mul);
C c225 = new C(0,891*mul);
C c226 = new C(0,892*mul);
C c227 = new C(1,896*mul);
C c228 = new C(1,897*mul);
C c229 = new C(2,898*mul);
C c230 = new C(2,905*mul);
C c231 = new C(0,906*mul);
C c232 = new C(0,907*mul);
C c233 = new C(2,908*mul);
C c234 = new C(1,912*mul);
C c235 = new C(1,914*mul);
C c236 = new C(1,922*mul);
C c237 = new C(0,923*mul);
C c238 = new C(2,925*mul);
C c239 = new C(0,927*mul);
C c240 = new C(0,930*mul);
C c241 = new C(1,931*mul);
C c242 = new C(1,932*mul);
C c243 = new C(1,933*mul);
C c244 = new C(2,934*mul);
C c245 = new C(2,935*mul);
C c246 = new C(2,936*mul);
C c247 = new C(0,937*mul);
C c248 = new C(2,940*mul);
C c249 = new C(1,943*mul);
C c250 = new C(2,944*mul);
C c251 = new C(1,945*mul);
C c252 = new C(1,947*mul);
C c253 = new C(1,948*mul);
C c254 = new C(0,949*mul);
C c255 = new C(1,950*mul);
C c256 = new C(1,951*mul);
C c257 = new C(2,952*mul);
C c258 = new C(1,955*mul);
C c259 = new C(2,956*mul);
C c260 = new C(1,957*mul);
C c261 = new C(1,958*mul);
C c262 = new C(1,960*mul);
C c263 = new C(1,963*mul);
C c264 = new C(0,969*mul);
C c265 = new C(2,970*mul);
C c266 = new C(2,982*mul);
C c267 = new C(0,985*mul);
C c268 = new C(2,988*mul);
C c269 = new C(2,989*mul);
C c270 = new C(1,991*mul);
C c271 = new C(0,992*mul);
C c272 = new C(2,993*mul);
C c273 = new C(0,994*mul);
C c274 = new C(2,997*mul);
C c275 = new C(2,998*mul);
C c276 = new C(2,999*mul);
C c277 = new C(2,1000*mul);
C c278 = new C(0,1004*mul);
C c279 = new C(0,1011*mul);
C c280 = new C(2,1012*mul);
C c281 = new C(0,1014*mul);
C c282 = new C(1,1015*mul);
C c283 = new C(2,1017*mul);
C c284 = new C(0,1019*mul);
C c285 = new C(0,1020*mul);
C c286 = new C(1,1026*mul);
C c287 = new C(0,1028*mul);
C c288 = new C(1,1029*mul);
C c289 = new C(2,1030*mul);
C c290 = new C(0,1032*mul);
C c291 = new C(0,1033*mul);
C c292 = new C(0,1036*mul);
C c293 = new C(1,1037*mul);
C c294 = new C(0,1039*mul);
C c295 = new C(0,1043*mul);
C c296 = new C(0,1044*mul);
C c297 = new C(1,1045*mul);
C c298 = new C(0,1047*mul);
C c299 = new C(2,1048*mul);
C c300 = new C(0,1050*mul);
C c301 = new C(1,1051*mul);
C c302 = new C(0,1052*mul);
C c303 = new C(1,1053*mul);
C c304 = new C(0,1054*mul);
C c305 = new C(2,1057*mul);
C c306 = new C(0,1062*mul);
C c307 = new C(0,1064*mul);
C c308 = new C(0,1065*mul);
C c309 = new C(1,1066*mul);
C c310 = new C(1,1068*mul);
C c311 = new C(2,1069*mul);
C c312 = new C(1,1070*mul);
C c313 = new C(0,1072*mul);
C c314 = new C(0,1073*mul);
C c315 = new C(2,1074*mul);
C c316 = new C(0,1077*mul);
C c317 = new C(1,1079*mul);
C c318 = new C(2,1082*mul);
C c319 = new C(2,1086*mul);
C c320 = new C(1,1089*mul);
C c321 = new C(2,1095*mul);
C c322 = new C(0,1100*mul);
C c323 = new C(0,1101*mul);
C c324 = new C(1,1105*mul);
C c325 = new C(2,1106*mul);
C c326 = new C(0,1108*mul);
C c327 = new C(2,1109*mul);
C c328 = new C(2,1110*mul);
C c329 = new C(2,1111*mul);
C c330 = new C(2,1112*mul);
C c331 = new C(2,1113*mul);
C c332 = new C(0,1114*mul);
C c333 = new C(2,1116*mul);
C c334 = new C(2,1117*mul);
C c335 = new C(2,1119*mul);
C c336 = new C(2,1123*mul);
C c337 = new C(2,1124*mul);
C c338 = new C(2,1125*mul);
C c339 = new C(0,1128*mul);
C c340 = new C(2,1129*mul);
C c341 = new C(1,1130*mul);
C c342 = new C(1,1131*mul);
C c343 = new C(1,1132*mul);
C c344 = new C(0,1137*mul);
C c345 = new C(2,1138*mul);
C c346 = new C(2,1139*mul);
C c347 = new C(2,1143*mul);
C c348 = new C(2,1149*mul);
C c349 = new C(2,1150*mul);
C c350 = new C(0,1152*mul);
C c351 = new C(2,1153*mul);
C c352 = new C(0,1156*mul);
C c353 = new C(1,1157*mul);
C c354 = new C(2,1164*mul);
C c355 = new C(2,1167*mul);
C c356 = new C(0,1168*mul);
C c357 = new C(1,1170*mul);
C c358 = new C(1,1171*mul);
C c359 = new C(0,1172*mul);
C c360 = new C(2,1173*mul);
C c361 = new C(0,1174*mul);
C c362 = new C(1,1176*mul);
C c363 = new C(2,1177*mul);
C c364 = new C(1,1179*mul);
C c365 = new C(1,1182*mul);
C c366 = new C(0,1183*mul);
C c367 = new C(1,1187*mul);
C c368 = new C(2,1189*mul);
C c369 = new C(2,1190*mul);
C c370 = new C(1,1191*mul);
C c371 = new C(0,1193*mul);
C c372 = new C(1,1194*mul);
C c373 = new C(1,1195*mul);
C c374 = new C(1,1197*mul);
cs.add(c2);
cs.add(c3);
cs.add(c4);
cs.add(c5);
cs.add(c6);
cs.add(c7);
cs.add(c8);
cs.add(c9);
cs.add(c10);
cs.add(c11);
cs.add(c12);
cs.add(c13);
cs.add(c14);
cs.add(c15);
cs.add(c16);
cs.add(c17);
cs.add(c18);
cs.add(c19);
cs.add(c20);
cs.add(c21);
cs.add(c22);
cs.add(c23);
cs.add(c24);
cs.add(c25);
cs.add(c26);
cs.add(c27);
cs.add(c28);
cs.add(c29);
cs.add(c30);
cs.add(c31);
cs.add(c32);
cs.add(c33);
cs.add(c34);
cs.add(c35);
cs.add(c36);
cs.add(c37);
cs.add(c38);
cs.add(c39);
cs.add(c40);
cs.add(c41);
cs.add(c42);
cs.add(c43);
cs.add(c44);
cs.add(c45);
cs.add(c46);
cs.add(c47);
cs.add(c48);
cs.add(c49);
cs.add(c50);
cs.add(c51);
cs.add(c52);
cs.add(c53);
cs.add(c54);
cs.add(c55);
cs.add(c56);
cs.add(c57);
cs.add(c58);
cs.add(c59);
cs.add(c60);
cs.add(c61);
cs.add(c62);
cs.add(c63);
cs.add(c64);
cs.add(c65);
cs.add(c66);
cs.add(c67);
cs.add(c68);
cs.add(c69);
cs.add(c70);
cs.add(c71);
cs.add(c72);
cs.add(c73);
cs.add(c74);
cs.add(c75);
cs.add(c76);
cs.add(c77);
cs.add(c78);
cs.add(c79);
cs.add(c80);
cs.add(c81);
cs.add(c82);
cs.add(c83);
cs.add(c84);
cs.add(c85);
cs.add(c86);
cs.add(c87);
cs.add(c88);
cs.add(c89);
cs.add(c90);
cs.add(c91);
cs.add(c92);
cs.add(c93);
cs.add(c94);
cs.add(c95);
cs.add(c96);
cs.add(c97);
cs.add(c98);
cs.add(c99);
cs.add(c100);
cs.add(c101);
cs.add(c102);
cs.add(c103);
cs.add(c104);
cs.add(c105);
cs.add(c106);
cs.add(c107);
cs.add(c108);
cs.add(c109);
cs.add(c110);
cs.add(c111);
cs.add(c112);
cs.add(c113);
cs.add(c114);
cs.add(c115);
cs.add(c116);
cs.add(c117);
cs.add(c118);
cs.add(c119);
cs.add(c120);
cs.add(c121);
cs.add(c122);
cs.add(c123);
cs.add(c124);
cs.add(c125);
cs.add(c126);
cs.add(c127);
cs.add(c128);
cs.add(c129);
cs.add(c130);
cs.add(c131);
cs.add(c132);
cs.add(c133);
cs.add(c134);
cs.add(c135);
cs.add(c136);
cs.add(c137);
cs.add(c138);
cs.add(c139);
cs.add(c140);
cs.add(c141);
cs.add(c142);
cs.add(c143);
cs.add(c144);
cs.add(c145);
cs.add(c146);
cs.add(c147);
cs.add(c148);
cs.add(c149);
cs.add(c150);
cs.add(c151);
cs.add(c152);
cs.add(c153);
cs.add(c154);
cs.add(c155);
cs.add(c156);
cs.add(c157);
cs.add(c158);
cs.add(c159);
cs.add(c160);
cs.add(c161);
cs.add(c162);
cs.add(c163);
cs.add(c164);
cs.add(c165);
cs.add(c166);
cs.add(c167);
cs.add(c168);
cs.add(c169);
cs.add(c170);
cs.add(c171);
cs.add(c172);
cs.add(c173);
cs.add(c174);
cs.add(c175);
cs.add(c176);
cs.add(c177);
cs.add(c178);
cs.add(c179);
cs.add(c180);
cs.add(c181);
cs.add(c182);
cs.add(c183);
cs.add(c184);
cs.add(c185);
cs.add(c186);
cs.add(c187);
cs.add(c188);
cs.add(c189);
cs.add(c190);
cs.add(c191);
cs.add(c192);
cs.add(c193);
cs.add(c194);
cs.add(c195);
cs.add(c196);
cs.add(c197);
cs.add(c198);
cs.add(c199);
cs.add(c200);
cs.add(c201);
cs.add(c202);
cs.add(c203);
cs.add(c204);
cs.add(c205);
cs.add(c206);
cs.add(c207);
cs.add(c208);
cs.add(c209);
cs.add(c210);
cs.add(c211);
cs.add(c212);
cs.add(c213);
cs.add(c214);
cs.add(c215);
cs.add(c216);
cs.add(c217);
cs.add(c218);
cs.add(c219);
cs.add(c220);
cs.add(c221);
cs.add(c222);
cs.add(c223);
cs.add(c224);
cs.add(c225);
cs.add(c226);
cs.add(c227);
cs.add(c228);
cs.add(c229);
cs.add(c230);
cs.add(c231);
cs.add(c232);
cs.add(c233);
cs.add(c234);
cs.add(c235);
cs.add(c236);
cs.add(c237);
cs.add(c238);
cs.add(c239);
cs.add(c240);
cs.add(c241);
cs.add(c242);
cs.add(c243);
cs.add(c244);
cs.add(c245);
cs.add(c246);
cs.add(c247);
cs.add(c248);
cs.add(c249);
cs.add(c250);
cs.add(c251);
cs.add(c252);
cs.add(c253);
cs.add(c254);
cs.add(c255);
cs.add(c256);
cs.add(c257);
cs.add(c258);
cs.add(c259);
cs.add(c260);
cs.add(c261);
cs.add(c262);
cs.add(c263);
cs.add(c264);
cs.add(c265);
cs.add(c266);
cs.add(c267);
cs.add(c268);
cs.add(c269);
cs.add(c270);
cs.add(c271);
cs.add(c272);
cs.add(c273);
cs.add(c274);
cs.add(c275);
cs.add(c276);
cs.add(c277);
cs.add(c278);
cs.add(c279);
cs.add(c280);
cs.add(c281);
cs.add(c282);
cs.add(c283);
cs.add(c284);
cs.add(c285);
cs.add(c286);
cs.add(c287);
cs.add(c288);
cs.add(c289);
cs.add(c290);
cs.add(c291);
cs.add(c292);
cs.add(c293);
cs.add(c294);
cs.add(c295);
cs.add(c296);
cs.add(c297);
cs.add(c298);
cs.add(c299);
cs.add(c300);
cs.add(c301);
cs.add(c302);
cs.add(c303);
cs.add(c304);
cs.add(c305);
cs.add(c306);
cs.add(c307);
cs.add(c308);
cs.add(c309);
cs.add(c310);
cs.add(c311);
cs.add(c312);
cs.add(c313);
cs.add(c314);
cs.add(c315);
cs.add(c316);
cs.add(c317);
cs.add(c318);
cs.add(c319);
cs.add(c320);
cs.add(c321);
cs.add(c322);
cs.add(c323);
cs.add(c324);
cs.add(c325);
cs.add(c326);
cs.add(c327);
cs.add(c328);
cs.add(c329);
cs.add(c330);
cs.add(c331);
cs.add(c332);
cs.add(c333);
cs.add(c334);
cs.add(c335);
cs.add(c336);
cs.add(c337);
cs.add(c338);
cs.add(c339);
cs.add(c340);
cs.add(c341);
cs.add(c342);
cs.add(c343);
cs.add(c344);
cs.add(c345);
cs.add(c346);
cs.add(c347);
cs.add(c348);
cs.add(c349);
cs.add(c350);
cs.add(c351);
cs.add(c352);
cs.add(c353);
cs.add(c354);
cs.add(c355);
cs.add(c356);
cs.add(c357);
cs.add(c358);
cs.add(c359);
cs.add(c360);
cs.add(c361);
cs.add(c362);
cs.add(c363);
cs.add(c364);
cs.add(c365);
cs.add(c366);
cs.add(c367);
cs.add(c368);
cs.add(c369);
cs.add(c370);
cs.add(c371);
cs.add(c372);
cs.add(c373);
cs.add(c374);
}