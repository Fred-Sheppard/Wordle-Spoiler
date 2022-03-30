class Mode {

  String text;
  String typing;
  boolean clearNextClick;

  Mode(String text) {
    this.text = text;
    init();
  }

  void init() {
  }

  void display() {
    background(#538D4E);
    textSize(50*displayDensity);
    text(text, width/2, height/4);
    textSize(30*displayDensity);
    text(typing, width/2, height/2);
    fill(0, 255, 0);
    rect(0, 0, width, height/10);
    fill(255);
  }

  void calculate() {
  }

  boolean backspace() {
    if ((key == BACKSPACE || keyCode == 67) && typing.length() > 0 && !typing.equals("+")) {
      typing = typing.substring(0, typing.length()-1);
      return true;
    }
    return false;
  }
}


class indexToWord extends Mode {

  indexToWord(String text) {
    super(text);
  }

  void init() {
    typing = "+";
  }


  void calculate() {
    if (backspace()) return;
    if (key == '-') {
      clearNextClick = false;
      typing = "-";
    } else if (key >= 48 && key <= 57) {
      checkClearNextClick("+");
      if (typing.equals("") && key != '-') typing = "+";
      typing += key;
    } else if (key == ENTER || keyCode == 66) {
      if (checkClearNextClick("+")) return;
      if (typing.equals("+") || typing.equals("-")) return;
      int num = int(typing);
      if (num < minDiff || num > maxDiff) {
        typing = new IndexOutOfBoundsException("").getMessage();
        clearNextClick = true;
      }
      try {
        typing = toDate(num);
        clearNextClick = true;
      }
      catch (IndexOutOfBoundsException e) {
        typing = e.getMessage();
        clearNextClick = true;
      }
    }
  }

  boolean checkClearNextClick(String s) {
    if (clearNextClick) {
      typing = s;
      clearNextClick = false;
      return true;
    }
    return false;
  }

  String toDate(int n) {
    int num = thisIndex + n;
    if (num < 0 || num > words.length-1)
      throw new IndexOutOfBoundsException("Index must be between " + minDiff + " & " + maxDiff);
    return words[num].toUpperCase();
  }

  class IndexOutOfBoundsException extends RuntimeException {
    IndexOutOfBoundsException(String errorMessage) {
      super(errorMessage);
    }
  }
}

class wordToDate extends Mode {

  int letterIndex;

  wordToDate(String text) {
    super(text);
  }

  void init() {
    typing = "_____";
  }

  void calculate() {
    if (backspace()) return;
    if (key >= 65 && key <= 90 || key >= 97 && key <= 122) {
      if (letterIndex >= 5) return;
      if (clearNextClick) {
        typing = "_____";
        letterIndex = 0;
        clearNextClick = false;
      }
      char[] chars = new char[typing.length()];
      chars = typing.toCharArray();
      chars[letterIndex] = key;
      letterIndex++;
      typing = new String(chars);
      typing = typing.toUpperCase();
    } else if (key == ENTER || keyCode == 66) {
      if (typing.equals("_____")) return;
      if (clearNextClick) {
        typing = "_____";
        clearNextClick = false;
        return;
      }
      letterIndex = 0;
      LocalDate date;
      try {
        date = toDate(typing);
      }
      catch (WordNotFoundException e) {
        typing = e.getMessage();
        clearNextClick = true;
        return;
      }
      int timeToDate = int(today.until(date, ChronoUnit.DAYS));
      String str;
      if (timeToDate > 0) str = timeToDate + " days from now";
      else if (timeToDate < 0) str = -timeToDate + " days ago";
      else str = "Today :)";
      String format = date.format(myFormat);
      typing = format +"\n" + str;
      letterIndex = 0;
      clearNextClick = true;
    } else typing = "_____";
  }

  LocalDate toDate(String word) {
    word = word.toLowerCase();
    int index;
    boolean exists = false;
    for (index = 0; index < words.length; index++) {
      if (word.equals(words[index])) {
        exists = true;
        break;
      }
    }
    if (!exists) throw new WordNotFoundException("Word not found in list");
    return day0.plus(index, ChronoUnit.DAYS);
  }

  //Returns true on letter deletion
  boolean backspace() {
    if ((key == BACKSPACE) && letterIndex > 0) { // || keyCode == 67
      char[] chars = new char[typing.length()];
      chars = typing.toCharArray();
      chars[--letterIndex] = '_';
      typing = new String(chars);
      return true;
    }
    return false;
  }

  class WordNotFoundException extends RuntimeException {
    WordNotFoundException(String errorMessage) {
      super(errorMessage);
    }
  }
}

class dateToWord extends Mode {

  char[][] charsArray;
  int wordIndex = 0;
  int letterIndex = 0;
  String typing = "";

  dateToWord(String text) {
    super(text);
  }

  void init() {
    typing = "";
    letterIndex = 0;
    wordIndex = 0;
    charsArray = new char[3][];
    for (int i = 0; i < charsArray.length; i++) {
      charsArray[i] = new char[2];
    }
    charsArray[2] = new char[4];

    for (char[] array : charsArray) {
      for (int i = 0; i < array.length; i++) {
        array[i] = '_';
      }
    }
  }


  void display() {
    background(#538D4E);
    textSize(50*displayDensity);
    text(text, width/2, height/4);
    float textHeight = textAscent()+textDescent();
    textSize(30*displayDensity);
    text(today.format(myFormat), width/2, height/4+textHeight);
    if (typing.equals("")) {
      String s0 = new String(charsArray[0]);
      String s1 = new String(charsArray[1]);
      String s2 = new String(charsArray[2]);
      String s = String.format("%s/%s/%s", s0, s1, s2);
      textSize(40*displayDensity);
      text(s, width/2, height/2);
    } else {
      textSize(30*displayDensity);
      text(typing, width/2, height/2);
    }
    fill(0, 255, 0);
    rect(0, 0, width, height/10);
    fill(255);
  }

  void myCalculate() {
    clearTyping();
    if (letterIndex >= 4) {
      if (key == ENTER || keyCode == 66) {
        if (clearNextClick) {
          clearNextClick = false;
          return;
        }
        String[] strings = new String[3];
        int[] ints = new int[3];
        for (int i = 0; i < strings.length; i++) {
          strings[i] = new String(charsArray[i]);
          ints[i] = int(strings[i]);
        }
        letterIndex = 0;
        wordIndex = 0;

        LocalDate date = null;
        try {
          date = LocalDate.of(ints[2], ints[1], ints[0]);
        }
        catch (Exception e) {
          throw new dateOutOfRangeException();
        }
        if (date.isBefore(day0) || date.isAfter(maxDate)) {
          throw new dateOutOfRangeException();
        }
        int index = int(day0.until(date, ChronoUnit.DAYS));
        typing = words[index].toUpperCase();
        clearNextClick = true;
      } else return;
    } else if (key >= 48 && key <= 57) {
      char[] word = charsArray[wordIndex];
      word[letterIndex] = key;
      letterIndex++;
      if (letterIndex >= 2 && wordIndex < 2) {
        letterIndex = 0;
        wordIndex++;
      }
    }
  }

  void calculate() {
    try {
      myCalculate();
    }
    catch (dateOutOfRangeException e) {
      typing = e.getMessage();
      clearNextClick = true;
      return;
    }
  }

  void clearTyping() {
    if (clearNextClick) {
      typing = "";
      for (char[] word : charsArray) {
        for (int i = 0; i < word.length; i++) {
          word[i] = '_';
        }
      }
      clearNextClick = false;
      return;
    }
    if (key == BACKSPACE || keyCode == 67) {
      if (letterIndex == 0 && wordIndex > 0) {
        letterIndex = 2;
        wordIndex--;
      }
      if (letterIndex >= 1) letterIndex--;
      charsArray[wordIndex][letterIndex] = '_';
    }
  }
}
