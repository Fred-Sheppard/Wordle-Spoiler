//Todo: check if list update made changes

boolean isJava = false; //<>//
//float displayDensity = 1;
int mouseButton = 255;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.time.format.DateTimeFormatter;
import android.widget.Toast;
import android.app.Activity;

LocalDate today;
LocalDate day0;
LocalDate maxDate;
DateTimeFormatter myFormat;
Activity act;
String[] words;
String todayWord, thenWord;
int thisIndex;
int minDiff, maxDiff;
Mode currentMode;
int modeIndex;
Mode[] modes = new Mode[3];
boolean keyboard;
int fetchTimeout = 10000;
int fetchTimeStamp;

void settings() {
  if (isJava) {size(500, 1000);}
  else {size(displayWidth, displayHeight);}
}

void setup() {
  orientation(PORTRAIT);
  background(#538D4E);
  textAlign(CENTER, CENTER);
  textSize(30*displayDensity);
  fill(255);

  act = this.getActivity();
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
    println(' ');
  currentMode.calculate();
}

void mousePressed() {
  float h = height*.05-width*.05;
  if (mouseX > width*.05 && mouseX < width*.15 && mouseY > h && mouseY < h+width*.1) {
    thread("fetchList");
    return;
  } else if (mouseButton == RIGHT || mouseX > width*9/10) {
    changeMode(true); //Increments mode
    return;
  } else if (mouseX < width/10) {
    changeMode(false);
    return;
  }
  if (!keyboard) {
    openKeyboard();
    keyboard = true;
  } else {
   closeKeyboard();
   keyboard = false;
  }
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

void fetchList() {
  if (millis() < fetchTimeStamp) return;
  String[] strings = loadStrings("https://www.nytimes.com/games/wordle/main.af610646.js");
  PrintWriter output = createWriter("wordle_answers.txt");
  String list = strings[0].substring(130729, 149200);
  list = list.replace("\"", "");
  String[] split = list.split(",");
  for (String s : split) {
    output.println(s);
  }
  output.flush();
  output.close();
  showToast("Updated List");
  fetchTimeStamp = millis() + fetchTimeout;
}

class dateOutOfRangeException extends RuntimeException {
  dateOutOfRangeException() {
    super(String.format("Date must be between%n%s & %s", day0.format(myFormat), maxDate.format(myFormat)));
  }
}

void showToast(final String message) { 
  act.runOnUiThread(new Runnable() {
    public void run() { 
      android.widget.Toast.makeText(act.getApplicationContext(), message, android.widget.Toast.LENGTH_SHORT).show();
    }
  }
  );
}
