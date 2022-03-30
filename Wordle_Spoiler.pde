boolean isJava = true;
float displayDensity = 1;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.time.format.DateTimeFormatter;

LocalDate today;
LocalDate day0;
LocalDate maxDate;
DateTimeFormatter myFormat;
String[] words;
String todayWord, thenWord;
int thisIndex;
int minDiff, maxDiff;
Mode currentMode;
int modeIndex;
Mode[] modes = new Mode[3];
boolean keyboard;

void settings() {
  if (isJava) size(500, 1000);
  else size(displayWidth, displayHeight);
}

void setup() {
  background(#538D4E);
  textAlign(CENTER, CENTER);
  textSize(30*displayDensity);
  fill(255);

  today = LocalDate.now();
  day0 = LocalDate.of(2021, 6, 19);
  words = loadStrings("wordle_answers.txt");
  thisIndex = int(day0.until(today, ChronoUnit.DAYS));
  minDiff = thisIndex;
  maxDiff = words.length-thisIndex-1;
  myFormat = DateTimeFormatter.ofPattern("dd MMMM YYYY");
  modes[0] = new indexToWord("Index");
  modes[1] = new wordToDate("Word");
  modes[2] = new dateToWord("Date");
  currentMode = modes[0];
  maxDate = day0.plus(words.length-1, ChronoUnit.DAYS);
}

void draw() {
  currentMode.display();
}

void keyPressed() {
  if (keyCode == RIGHT) changeMode(true);
  else if (keyCode == LEFT) changeMode(false);
  else if (key == '/') 
  println(' '); //<>//
  currentMode.calculate();
}

void mousePressed() {
  if (mouseButton == RIGHT || mouseY < height/10) {
    changeMode(true); //Increments mode
    return;
  }
  //if (!keyboard) {
  //  openKeyboard();
  //  keyboard = true;
  //} else {
  // closeKeyboard();
  // keyboard = false;
  //}
}

void changeMode(boolean plus) {
  if (plus) {
    modeIndex++;
    if (modeIndex > modes.length-1) modeIndex = 0;
  } else {
    modeIndex--;
    if (modeIndex < 0) modeIndex = modes.length-1;
  }

  currentMode = modes[modeIndex];
  currentMode.init();
}



class dateOutOfRangeException extends RuntimeException {
  dateOutOfRangeException() {
    super(String.format("Date must be between%n%s & %s", day0.format(myFormat), maxDate.format(myFormat)));
  }
}
