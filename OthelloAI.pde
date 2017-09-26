//オセロの基本的な部分の実装に関しては以下のページを参考にしています
//Processingで100行オセロ: http://qiita.com/nmbakfm/items/88e4531d4414e38d1f59

final int BSIZE = 100;
int[][] field;
boolean bBlacksTurn;//黒の番かどうか

int num=0;

int [][] score_field={
  {50, 1, 3, 3, 3, 3, 1, 50}, 
  {1, 1, 2, 2, 2, 2, 1, 1}, 
  {3, 2, 2, 2, 2, 2, 2, 3}, 
  {3, 2, 2, 2, 2, 2, 2, 3}, 
  {3, 2, 2, 2, 2, 2, 2, 3}, 
  {3, 2, 2, 2, 2, 2, 2, 3}, 
  {1, 1, 2, 2, 2, 2, 1, 1}, 
  {50, 1, 3, 3, 3, 3, 1, 50}
};

void setup() {
  size(800, 800);
  bBlacksTurn = true;
  field = new int[8][8];
  for (int i=0; i<8; ++i) {
    for (int j=0; j<8; ++j) {
      if ((i==3||i==4)&&(j==3||j==4)) {
        field[i][j] = ((i+j)%2==0)?1:-1; // initial stones;
      } else {
        field[i][j] = 0;
      }
    }
  }
}

void draw() {

  //draw field
  background(0, 128, 0);
  stroke(0);
  for (int i=1; i<8; ++i) {
    line(i*BSIZE, 0, i*BSIZE, height);
    line(0, i*BSIZE, width, i*BSIZE);
  }
  noStroke();
  fill(0);

  // draw stones
  noStroke();
  for (int i=0; i<8; ++i) {
    for (int j=0; j<8; ++j) {
      if (field[i][j]==1) {
        fill(0);
        ellipse((i*2+1)*BSIZE/2, (j*2+1)*BSIZE/2, BSIZE*0.8, BSIZE*0.8);
      } else if (field[i][j]==-1) {
        fill(255);
        ellipse((i*2+1)*BSIZE/2, (j*2+1)*BSIZE/2, BSIZE*0.8, BSIZE*0.8);
      }
    }
  }

  //白の番だったら白のオートプレイを行う
  if (!bBlacksTurn) {
    wAutoPlay();
  }
  //黒が置く場所が無ければ白の番に引き渡す
  if (getPuttableArray(blackStone()).size()==0) {
    bBlacksTurn=false;
  }

  /*//黒の番だったら黒のオートプレイを行う
   if (bBlacksTurn) {
   bAutoPlay();
   }
   //白が置く場所が無ければ黒の番に引き渡す
   if (getPuttableArray(whiteStone()).size()==0) {
   bBlacksTurn=true;
   }*/

  save(num+".png");
}

void mouseReleased() {  
  int x = mouseX/BSIZE;
  int y = mouseY/BSIZE;

  boolean puttable = false;
  if (field[x][y]==0) {
    puttable = checkDirection(x, y, -1, -1) | puttable;
    puttable = checkDirection(x, y, -1, 0) | puttable;
    puttable = checkDirection(x, y, -1, 1) | puttable;

    puttable = checkDirection(x, y, 0, -1) | puttable;
    puttable = checkDirection(x, y, 0, 1) | puttable;

    puttable = checkDirection(x, y, 1, -1) | puttable;
    puttable = checkDirection(x, y, 1, 0) | puttable;
    puttable = checkDirection(x, y, 1, 1) | puttable;

    if (puttable) {
      field[x][y] = currentStone();
      bBlacksTurn = !bBlacksTurn;
      num++;
    }
  }
}

void wAutoPlay() {
  /*** 白が置ける場所を把握してその場所を配列に格納する ***/
  ArrayList <int []> w_puttable_array=getPuttableArray(whiteStone());
  /*** 白が置ける場所を把握してその場所を配列に格納する ***/

  /*** 白のおける場所がなければ黒の番に移行する ***/
  if (w_puttable_array.size()==0) {
    bBlacksTurn=!bBlacksTurn;
    return;
  }
  /*** 白のおける場所が無ければ黒の番に移行する ***/

  /*** とりあえずランダムに選択してその場所に置く ***/
  ArrayList<int []>w_score_puttable_array=new ArrayList<int []>();
  for (int i=0; i<w_puttable_array.size(); i++) {
    for (int j=0; j<score_field[w_puttable_array.get(i)[0]][w_puttable_array.get(i)[1]]; j++) {
      w_score_puttable_array.add(w_puttable_array.get(i));
      println(w_puttable_array.get(i));
    }
  }
  int rand=(int)random(0, w_score_puttable_array.size());
  int []w_put_xy=w_score_puttable_array.get(rand);
  checkDirection(w_put_xy[0], w_put_xy[1], -1, -1);
  checkDirection(w_put_xy[0], w_put_xy[1], -1, 0);
  checkDirection(w_put_xy[0], w_put_xy[1], -1, 1);

  checkDirection(w_put_xy[0], w_put_xy[1], 0, -1);
  checkDirection(w_put_xy[0], w_put_xy[1], 0, 1);

  checkDirection(w_put_xy[0], w_put_xy[1], 1, -1);
  checkDirection(w_put_xy[0], w_put_xy[1], 1, 0);
  checkDirection(w_put_xy[0], w_put_xy[1], 1, 1);

  field[w_put_xy[0]][w_put_xy[1]]=whiteStone();
  bBlacksTurn=!bBlacksTurn;
  /*** とりあえずランダムに選択してその場所に置く ***/

  /*** 盤面が進むごとに隅の重要性を下げる ***/
  score_field[0][0]--;
  score_field[0][7]--;
  score_field[7][0]--;
  score_field[7][7]--;
  /*** 盤面が進むごとに隅の重要性を下げる ***/

  /*** 隅が取られていたら、その列の評価を上げる ***/
  if (field[0][0]==whiteStone() || field[7][0]==whiteStone()) {
    score_field[1][0]=50;
    score_field[2][0]=50;
    score_field[3][0]=50;
    score_field[4][0]=50;
    score_field[5][0]=50;
    score_field[6][0]=50;
  }
  if (field[7][0]==whiteStone() || field[7][7]==whiteStone()) {
    score_field[7][1]=50;
    score_field[7][2]=50;
    score_field[7][3]=50;
    score_field[7][4]=50;
    score_field[7][5]=50;
    score_field[7][6]=50;
  }
  if (field[7][7]==whiteStone() || field[0][7]==whiteStone()) {
    score_field[1][7]=50;
    score_field[2][7]=50;
    score_field[3][7]=50;
    score_field[3][7]=50;
    score_field[3][7]=50;
    score_field[3][7]=50;
  }
  if (field[0][0]==whiteStone() || field[0][7]==whiteStone()) {
    score_field[0][1]=50;
    score_field[0][2]=50;
    score_field[0][3]=50;
    score_field[0][4]=50;
    score_field[0][5]=50;
    score_field[0][6]=50;
  }
  /*** 隅が取られていたら、その列の評価を上げる ***/
}

void bAutoPlay() {
  /*** 白が置ける場所を把握してその場所を配列に格納する ***/
  ArrayList <int []> b_puttable_array=getPuttableArray(blackStone());
  /*** 白が置ける場所を把握してその場所を配列に格納する ***/

  /*** 白のおける場所がなければ黒の番に移行する ***/
  if (b_puttable_array.size()==0) {
    bBlacksTurn=!bBlacksTurn;
    return;
  }
  /*** 白のおける場所が無ければ黒の番に移行する ***/

  /*** とりあえずランダムに選択してその場所に置く ***/
  ArrayList<int []>b_score_puttable_array=new ArrayList<int []>();
  for (int i=0; i<b_puttable_array.size(); i++) {
    for (int j=0; j<score_field[b_puttable_array.get(i)[0]][b_puttable_array.get(i)[1]]; j++) {
      b_score_puttable_array.add(b_puttable_array.get(i));
      println(b_puttable_array.get(i));
    }
  }
  int rand=(int)random(0, b_score_puttable_array.size());
  int []b_put_xy=b_score_puttable_array.get(rand);
  checkDirection(b_put_xy[0], b_put_xy[1], -1, -1);
  checkDirection(b_put_xy[0], b_put_xy[1], -1, 0);
  checkDirection(b_put_xy[0], b_put_xy[1], -1, 1);

  checkDirection(b_put_xy[0], b_put_xy[1], 0, -1);
  checkDirection(b_put_xy[0], b_put_xy[1], 0, 1);

  checkDirection(b_put_xy[0], b_put_xy[1], 1, -1);
  checkDirection(b_put_xy[0], b_put_xy[1], 1, 0);
  checkDirection(b_put_xy[0], b_put_xy[1], 1, 1);

  field[b_put_xy[0]][b_put_xy[1]]=blackStone();
  bBlacksTurn=!bBlacksTurn;
  /*** とりあえずランダムに選択してその場所に置く ***/

  /*** 盤面が進むごとに隅の重要性を下げる ***/
  score_field[0][0]--;
  score_field[0][7]--;
  score_field[7][0]--;
  score_field[7][7]--;
  /*** 盤面が進むごとに隅の重要性を下げる ***/

  /*** 隅が取られていたら、その列の評価を上げる ***/
  if (field[0][0]==blackStone() || field[7][0]==blackStone()) {
    score_field[1][0]=50;
    score_field[2][0]=50;
    score_field[3][0]=50;
    score_field[4][0]=50;
    score_field[5][0]=50;
    score_field[6][0]=50;
  }
  if (field[7][0]==blackStone() || field[7][7]==blackStone()) {
    score_field[7][1]=50;
    score_field[7][2]=50;
    score_field[7][3]=50;
    score_field[7][4]=50;
    score_field[7][5]=50;
    score_field[7][6]=50;
  }
  if (field[7][7]==blackStone() || field[0][7]==blackStone()) {
    score_field[1][7]=50;
    score_field[2][7]=50;
    score_field[3][7]=50;
    score_field[3][7]=50;
    score_field[3][7]=50;
    score_field[3][7]=50;
  }
  if (field[0][0]==blackStone() || field[0][7]==blackStone()) {
    score_field[0][1]=50;
    score_field[0][2]=50;
    score_field[0][3]=50;
    score_field[0][4]=50;
    score_field[0][5]=50;
    score_field[0][6]=50;
  }
  /*** 隅が取られていたら、その列の評価を上げる ***/
}

ArrayList<int []>getPuttableArray(int stone) {
  ArrayList <int []> puttable_array=new ArrayList<int []>();
  for (int y=0; y<8; y++) {
    for (int x=0; x<8; x++) {
      boolean puttable=false;
      if (field[x][y]==0) {
        puttable = justCheckDirection(x, y, -1, -1) | puttable;
        puttable = justCheckDirection(x, y, -1, 0) | puttable;
        puttable = justCheckDirection(x, y, -1, 1) | puttable;

        puttable = justCheckDirection(x, y, 0, -1) | puttable;
        puttable = justCheckDirection(x, y, 0, 1) | puttable;

        puttable = justCheckDirection(x, y, 1, -1) | puttable;
        puttable = justCheckDirection(x, y, 1, 0) | puttable;
        puttable = justCheckDirection(x, y, 1, 1) | puttable;
      }
      if (puttable) {
        int [] puttable_xy={x, y};
        puttable_array.add(puttable_xy);
      }
    }
  }
  return puttable_array;
}

//チェックするだけです！
boolean justCheckDirection(int x, int y, int directionX, int directionY) {
  if (checkBound(x+directionX, y+directionY) && field[x+directionX][y+directionY] != currentStone()) {
    return justCheckStones(x, y, directionX, directionY);
  }
  return false;
}

//チェックするだけです！
boolean justCheckStones(int x, int y, int directionX, int directionY) {
  if (checkBound(x+directionX, y+directionY) && field[x+directionX][y+directionY]==currentStone()) { // find
    return true;
  } else if (checkBound(x+directionX, y+directionY) && field[x+directionX][y+directionY]==0) { // not find
    return false;
  } else if (checkBound(x+directionX, y+directionY) && justCheckStones(x+directionX, y+directionY, directionX, directionY)) {
    return true;
  } else {
    return false;
  }
}

boolean checkDirection(int x, int y, int directionX, int directionY) {
  if (checkBound(x+directionX, y+directionY) && field[x+directionX][y+directionY] != currentStone()) {
    return checkStones(x, y, directionX, directionY);
  }
  return false;
}

boolean checkStones(int x, int y, int directionX, int directionY) {
  if (checkBound(x+directionX, y+directionY) && field[x+directionX][y+directionY]==currentStone()) { // find
    return true;
  } else if (checkBound(x+directionX, y+directionY) && field[x+directionX][y+directionY]==0) { // not find
    return false;
  } else if (checkBound(x+directionX, y+directionY) && checkStones(x+directionX, y+directionY, directionX, directionY)) {
    field[x+directionX][y+directionY] = currentStone(); // reverse
    return true;
  } else {
    return false;
  }
}

boolean checkBound(int x, int y) {
  return x>=0 && x<8 && y>=0 && y<8;
}

int currentStone() {
  return (bBlacksTurn)?1:-1;
}

int blackStone() {
  return 1;
}

int whiteStone() {
  return -1;
}