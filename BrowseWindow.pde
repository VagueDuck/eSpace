// browsing window

int winStatus = -1;
int sortStatus = 0; // options for sort (0 is old to new, 1 is new to old, 2 is alphabetical, 3 is reverse alphabetical)
String [] currentList; // current sorted list of files
float yBrowseSize; // the size of the browser size (used in KeyPressed () )

public class BrowseWindow {
  int index = 0;
  float yDisplay = 0;
  float txtSize = 14; // this is pretty self explanitory
  String sortLabel = "SORT"; // the text over the sort button to indicate what order it is in
  float accessWid; // this is the parameter of width passed via browser
  float accessX;
  float accessY;

  public void display (float xx, float yy, float wid, float y, String [] list) {
    push();
    fill (#00CC00);
    rect (xx, yy + y + txtSize * (index + 1), wid, txtSize);
    if (index < 0) {
      index = 0;
    } else if (index > list.length - 1) {
      index = list.length - 1;
    }
    textAlign (LEFT, CENTER);
    textSize (txtSize);
    int opacity;
    for (int i = 0; i < list.length; i++) {
      // this if statement makes the list text invisible unless within the spec size
      if (yy + y + txtSize / 2 + txtSize * (i + 1) > yy + yBrowseSize - txtSize) {
        opacity =  0;
      } else {
        opacity = 255;
      }
      fill (#FFFFFF, opacity);
      text (list[i], xx, yy + y + txtSize / 2 + txtSize * (i + 1));
    }
    pop();
  }

  int colHere = #0C9EC1; // starting color of sort button

  public void browser (float x, float y, float wid) {
    accessWid = wid;
    accessX = x;
    accessY = y;
    display (x, y, wid, yDisplay, currentList);
    push();
    textSize (txtSize);
    fill (#0000FF);
    rect (x, y, wid, txtSize);
    fill (colHere);
    rect (x + 3 * wid / 4, y, wid / 4, txtSize);
    fill (#FFFFFF);
    textAlign (LEFT, CENTER);
    text (sortLabel, x + 3 * wid / 4, y + txtSize / 2);
    text ("Use 'UP' & 'DOWN' arrow keys to browse your uploaded files.", x, y + txtSize / 2);
    pop();
    if (sortStatus == 0) {
      // resets the order of the sort to just the plain file (oldest to newest)
      currentList = new String [history.length]; // THIS IS A TEST FOR DISPLAY REFRESH
      for (int i = 0; i < currentList.length; i++) {
        currentList[i] = history[i];
      }
      sortLabel = "OLD-NEW";
    } else if (sortStatus == 2) {
      Arrays.sort(currentList);
      sortLabel = "ALPHABET>>";
    }
  }
}
