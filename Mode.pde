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
    textSize(50);
    text(text, width/2, 100);
    textSize(30);
    text(typing, width/2, height/2);
  }

  void calculate() {
  };

  boolean backspace() {
    if (clearNextClick) {
      typing = "";
      clearNextClick = false;
    }
    if (key == BACKSPACE && typing.length() > 0 && !typing.equals("+")) {
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
    if (key == '-') typing = "-";
    else if (key >= 48 && key <= 57) {
      if (typing.equals("") && key != '-') typing = "+";
      typing += key;
    } else if (key == ENTER) {
      try {
        typing = toDate(int(typing));
        clearNextClick = true;
      }
      catch (IndexOutOfBoundsException e) {
        typing = e.getMessage();
        clearNextClick = true;
      }
    }
  }

  String toDate(int n) {
    int num = thisIndex + n;
    if (num < 0 || num > words.length-1)
      throw new IndexOutOfBoundsException("Index must be between " + minDiff + " & " + maxDiff);
    return words[num].toUpperCase();
  }
}

class wordToDate extends Mode {

  wordToDate(String text) {
    super(text);
  }

  void init() {
    typing = "";
  }

  void calculate() {
    if (backspace()) return;
    if (key >= 65 && key <= 90 || key >= 97 && key <= 122) {
      if (typing.length() >= 5) return;
      typing += key;
      typing = typing.toUpperCase();
    } else if (key == ENTER) {
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
      clearNextClick = true;
    } else typing = "";
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
    textSize(50);
    text(text, width/2, 100);
    if (typing.equals("")) {
      String s0 = new String(charsArray[0]);
      String s1 = new String(charsArray[1]);
      String s2 = new String(charsArray[2]);
      String s = String.format("%s /%s /%s", s0, s1, s2);
      textSize(30);
      text(s, width/2, height/2);
    } else text(typing, width/2, height/2);
  }

  void myCalculate() {
    clearTyping();
    if (letterIndex >= 4) {
      if (key == ENTER) {
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
        typing = words[index];
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
    if (key == BACKSPACE) {
      if (letterIndex == 0 && wordIndex > 0) {
        letterIndex = 2;
        wordIndex--;
      }
      if (letterIndex >= 1) letterIndex--;
      charsArray[wordIndex][letterIndex] = '_';
    }
  }
}