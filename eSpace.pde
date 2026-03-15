/*
 * eSpace | Java Edition
 * A project by Shane Keagan
 * List of associated credentials:
 * es241.espace@gmail.com, For3weS24xxx123 // user counter and log - ACTIVE
 * 02xz9.espace@gmail.com, Hi2672yQrXxX321 // ad engine - NULL
 * af5b6.espace@gmail.com, Ra4uWil75xxX489 // spare email - NULL
 * support.espace@gmail.com, eSpaceisawesome42069 // support email - ACTIVE
 *
 * Wallpaper source: https://www.openprocessing.org/sketch/1051013 (modified)
 */

// ... add accessibility "LVL 2" to show labels and stuff
// ADD TO NEXT VERSION:
// create an ad engine that downloads email attachments and displays them as an ad (02xz9.espace@gmail.com) create as an object btw
//   if xHome changes from XFRAME to xActive then send an email stating the name of the ad + " #viewTypeA" and then use search(name + " #viewTypeA") to count individual views (incl. in object)
//   if the user logs in then send an email stating the name of the ad + " #viewTypeB" and then use search(name + " #viewTypeB") to count session views (incl. in object)
//   SEND THE EMAILS FROM THE USER'S EMAIL BECAUSE OUR ADDRESS WILL CRASH OR BUG IF TOO MANY USERS ARE LOGGING INTO IT TO SEND VIEW DATA CONSTANTLY
//   ad dims.: width - width / 4, height - width / 4 * 1080 / 1920, width / 4, width / 4 * 1080 / 1920
// create a background thread for javamail with SwingWorker and stack requests to the mail class in a queue with add a progress bar in the UI to indicate functions left in the queue
// bug when a user uses downloadAll, there is no merge for large files
// add arrays for field sizes and change applicable code -> change highlight effect to automatically adjust to that.
// select RAID type in settings... create an algorithm to convert RAID1 to RAID0 but not backwards
// allow users to use different emails from different providers

// NOTES:
// Gmail has 15Gb limit per account; 25Mb limit/email; eSpace manual limit: 600 emails (15Gb/25Mb)
//   RAID 0 has 100% space/email (1st) - striping
//   RAID 1 has 15Gb limit (last) - mirroring
//   Research how to build a parity,,, a parity is not a copy of the data uploaded!!!
//   RAID 3 has 66.66%-93.75% space/email (2.5nd) - parity not distributed (same as RAID 5 but all the parity data is written to the same drive)
//   RAID 5 has 66.66%-93.75% space/email (2nd) - distributed parity (supports 3-16 drives per array)
//   RAID 6 has 50%-87.5% space/email (3rd) - dual parity (supports 4-16 drives per array)
//   RAID 10 has 50% space/email (4th) - mirroring + striping

import javax.mail.*;
import javax.activation.*;
import javax.swing.*;
import java.net.NetworkInterface;
import java.net.SocketException;
import java.util.Enumeration;
import java.util.Date;
import java.util.Properties;
import java.util.Arrays;
import java.util.Random;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;

final int XFRAME = 1100; // x frame size (note: change in setup too)
final int YFRAME = 700; // y frame size (note: change in setup too)
float xActive = 0; // x-coordinate for active page
float yActive = 0; // y-coordinate for active page
float xHome = XFRAME; // x-coordinate for home page
float yHome = YFRAME; // y-coordinate for home page
float xLogin = xActive; // x-coordinate for login page
float yLogin = yActive; // y-coordinate for login page
float xSettings = XFRAME; // x-coordinate for settings page
float ySettings = YFRAME; // y-coordinate for settings page
float xSelect = XFRAME; // x-coordinate for select highlight, initial value is out of frame
float ySelect = YFRAME; // y-coordinate for select highlight, initial value is out of frame
int clickCount = 0; // how many mouse clicks
int clickRel; // fixes sticky keys!!!
PImage logo; // name of logo image
PImage bLogo; // name of second logo
PImage settingsWhite; // settings icon (white)
PImage settingsBlack; // settings icon (black)
PImage backWhite; // back icon (white)
PImage backBlack; // back icon (black)
PFont aFont; // Menlo-Regular-48
int xDivVar = 3; // width divisor for console
int yDivVar = 20; // height divisor for console
String [] emails; // access our usable file as a string
String [] transfer; // the string of the file being uploaded for the data
PrintWriter output; // in writer() method; usually only initialized in reset()
final String resetFile = "data/emails.txt"; // clean slate
final String useFile = "data/new.txt"; // stored version
final String historyFile = "data/history.txt"; // this is the data upload history file
final String addressFile = "data/address.txt"; // save for mac address to check piracy
String [] conData = new String [yDivVar];
String [] inLength; // front end data length only
String [] history; // files uploaded
String [] address; // the registered address for the software
ArrayList <String> macAddress = new ArrayList <String> (); // mac address(es)
int init; // initial program reset length
String fileName; // the file name derived from the directory
String parse; // the directory as a usable string
int saveClick; // save the current click count
BrowseWindow cloudBrowse; // the browse window class
Mail mail;// initiates the mail class
RAID1 aRAID; // enables RAID 1
Ad ad; // initiates the advertising engine
int verACol = #000000; // these are changing for light mode and dark
int verBCol = #FFFFFF; // these are changing for light mode and dark

void settings () {
  size (1100, 700); // note: change in variables too (XFRAME & YFRAME) ^^^
}

void setup () {
  // prints the thread used for the main class here
  try {
    println("GUI thread ID = " + Thread.currentThread().getId());
  }
  catch (Exception e) { // only happens if the whole launch sequence somehow fails
    println("ERROR");
  }
  surface.setResizable(true); // allows the main GUI to be resizeable (important for larger resolutions); doesn't work with og wallpaper
  frameRate (20); // this is the framerate so actions are consistent
  strokeWeight (width / 200); // this is for processing library draw graphics (outline thickness)
  String[] args = {"eSpace"}; // standard args declaration to run the PApplets
  // below code is assigning p3 variables
  logo = loadImage ("logo.png");
  bLogo = loadImage ("logo1.png");
  settingsWhite = loadImage ("settingsWhite.png");
  settingsBlack = loadImage ("settingsBlack.png");
  backWhite = loadImage ("back_white.png");
  backBlack = loadImage ("back_black.png");
  aFont = loadFont ("Geneva-48.vlw");
  emails = loadStrings (useFile);
  inLength = loadStrings (resetFile);
  history = loadStrings (historyFile);
  address = loadStrings (addressFile);
  setParticles(); // for wallpaper
  surface.setTitle ("eSpace | Java Edition Beta"); // title bar for applet
  //surface.setIcon (logo); // icon for applet
  currentList = new String [history.length]; // this is a dynamic list for the browse window, this is used for sorting the browse menu without changing original txt load src
  // below assigns variables to the current list
  for (int i = 0; i < history.length; i++) {
    currentList[i] = history[i];
  }
  init = inLength.length; /* used to distinguish in the new.txt how many lines are supposed to be static (or unchanged), adding emails to the array changes the new length of this.
   init is the initial (hence) length of the file. */
  for (int i = 0; i < conData.length; i++) {
    // this is building the right console log with strings instead of leaving nulls so other functions don't potentially go out of bounds
    conData [i] = "null " + i;
  }
  println ("DATABASE IN. SIZE: " + emails.length + "ln."); // tells how many lines were inputted during loadStrings; this was more used for debugging when first started. moderately useless now
  // below instantiates the objects after the p3 variables have been assigned, else the program will not run
  mail = new Mail();
  cloudBrowse = new BrowseWindow();
  aRAID = new RAID1();
  ad = new Ad();
  PApplet.runSketch(args, mail); // run sketches display the applets
  aRAID.create(emails);
}

/*
 * 
 *
 * main screen
 *
 *
 */

// writer
void writer (String [] in) { // writes changes to new.txt or useFile
  //output = createWriter ("data/create.txt"); // if the file isn't reading or writing properly you can recreate it using this
  in[14] = emails[14].split("\n")[0]; // changes the body text to 1 line so it doesn't displace the indexes
  saveStrings (useFile, in); // saves new stuff
  emails = loadStrings(useFile); // reloads what has just been saved
  //output.flush(); // associated with createWriter();
  //output.close(); // associated with createWriter();
  aRAID.create(emails); // re-creates the RAID data so that RAID functions still work after array has potentially been changed
}

// dynamic color
float red = 40;
float green = 150;
float blue = 150;
void dynoColor () { /* creates a color shift affect between green and blue bits on the RGB scale
 use this in placement of a p3 fill() method */
  if (green >= 150 && blue == 150) {
    green += 1;
    if (green >= 255) {
      green = 255;
    }
  }
  if (green >= 255 && blue >= 150) {
    blue += 1;
    if (blue >= 255) {
      blue = 255;
    }
  }
  if (green <= 255 && blue >= 255) {
    green -= 1;
    if (green <= 150) {
      green = 150;
    }
  }
  if (green == 150 && blue <= 255) {
    blue -= 1;
    if (blue <= 150) {
      blue = 150;
    }
  }
  fill (red, green, blue); // calls fill() so that this doesn't have to be rewritten after dynoColor changes the red, green, blue variables each time.
}

// wallpaper
// source: https://www.openprocessing.org/sketch/1051013
Particle [] particles;
float alpha;
void setParticles () {
  particles = new Particle [12000];
  for (int i = 0; i < 12000; i++) { 
    float x = random (width);
    float y = random (height);
    float adj = map (y, 0, height, 255, 0);
    int c = color (40, 255, adj);
    //int c = color (255, 25, 25, 200);
    particles [i] = new Particle (x, y, c);
  }
}

class Particle {
  float posX, posY, incr, theta;
  color c; // color of particles
  Particle (float xIn, float yIn, color cIn) {
    posX = xIn;
    posY = yIn;
    c = cIn;
  }
  public void move () {
    update();
    wrap();
    display();
  }
  void update () {
    incr += .008;
    theta = noise (posX * .006, posY * .004, incr) * TWO_PI;
    posX += 5 * cos (theta);
    posY += 5 * sin (theta);
  }
  void display () {
    if (posX > 0 && posX < width && posY > 0 && posY < height) {
      pixels [(int)posX + (int)posY * width] = c;
    }
  }
  void wrap () {
    if (posX < 0) posX = width;
    if (posX > width) posX = 0;
    if (posY < 0) posY = height;
    if (posY > height) posY = 0;
  }
}

void wallpaper () {
  alpha = map (mouseX, 0, width, 5, 35);
  fill (verACol, alpha);
  //fill (#FFFFFF, alpha);
  rect (0, 0, width, height);
  loadPixels();
  for (Particle p : particles) {
    p.move();
  }
  updatePixels();
}

// home nav and screen - very poor GUI design
void home (float x, float y) {
  noStroke (); // gets rid of the lines on p3 shapes for more consistent theme
  textAlign (LEFT, CENTER); // alligns the x-text left and y-text centered
  // console rects located as global variable
  if (verACol == #FFFFFF) {
    settingsWhite = loadImage ("settingsBlack.png");
    settingsBlack = loadImage ("settingsWhite.png");
  } else {
    settingsWhite = loadImage ("settingsWhite.png");
    settingsBlack = loadImage ("settingsBlack.png");
  }
  float logoRat = 0.72; // 775px/1072px
  float xLogoOffset = width / 100; // x distance from logo to left boarder
  float yLogoOffset = height / 60; // y distance from logo to top edge
  float xLogoSize = width / 10; // x size of logo
  float yLogoSize = xLogoSize * logoRat; // y size of logo in ratio to x size of logo
  float xTopBar = width - width / xDivVar; // top bar size for x (this was the original size; it now spans full width when the first parameter is passed through the rect()... NOT 2/3 width!)
  float yTopBar = yLogoSize + 2 * yLogoOffset; // top bar size for y
  float aTextSizeRatio = 6; // DON'T CHANGE
  float aTxt = yTopBar / aTextSizeRatio; // text size
  /* ------------------------- */
  float xBox = xTopBar / 2; // text box x size
  float yBox = aTxt * 6 / 4; // text box y size
  float xAccessibilityShift = (xTopBar - xBox) / 2; // shifts the boxes to the new layout (changes in settings)
  float yAccessibilityShift = yTopBar;
  //xAccessibilityShift = 0;
  //yAccessibilityShift = 0;
  float xTextBox = 0.4 * xTopBar - xAccessibilityShift; // text box x-coordinate
  float xxTextBox = 0.4 * xTopBar; // text box x-coordinate FOR THE TOP BAR ONLY!!!
  float yTextBox = 0.75 * aTxt; // text box base y-coordinate
  // calling the fileBrowser and console to the GUI
  yBrowseSize = height - yTopBar - 2 * height / yDivVar;
  cloudBrowse.browser(x + xBox, y + yTopBar, 2 * xBox);
  textSize (aTxt);
  console (x, y, xDivVar, yDivVar, conData, xLogoOffset);
  //float incVar = 1.5 * aTxt; // spacing multiplier for text box
  fill (#000000, 128);
  rect (x, y, xTopBar + width / xDivVar, yTopBar); // this is the main boarder for the top login display bar
  image (logo, x + xLogoOffset, y + yLogoOffset, xLogoSize, yLogoSize); // this is the espace emblem
  fill (#FFFFFF);
  fill (#C4C4C4);
  for (int i = 0; i < 3; i++) {
    // displays only the text boxes in the top login display bar
    rect (x + xxTextBox, y + yTextBox + i * yBox, xBox, yBox, height / 80);
  }
  float [] xEntryLoc = { // data entry point x-location for text boxes
    x + xxTextBox, 
    x + xxTextBox, 
    x + xxTextBox, 
    x + xTextBox - xLogoSize, 
    x + xTextBox - xLogoSize, 
    x + xTextBox - xLogoSize, 
    x + xTextBox - xLogoSize, 
    x + xTextBox - xLogoSize, 
    x + xTextBox - xLogoSize, 
    x + xTextBox - xLogoSize + xBox / 2, 
    x + xTextBox - xLogoSize, 
    x + xTextBox - xLogoSize, 
    x + xTextBox - xLogoSize, 
    x + xTextBox - xLogoSize + xBox * 2/3, 
    x + xTextBox - xLogoSize, 
    x + xTextBox - xLogoSize, 
    x + width / 1.5 - xBox / 3 + 2 * xAccessibilityShift, 
    x + width / 1.5 - xBox / 3 + 2 * xAccessibilityShift, 
    x + width / 1.5 - xBox / 3 + 2 * xAccessibilityShift, 
    x + width / 1.5 - xBox / 6 + xAccessibilityShift, 
    x + width / 1.5 - xBox / 3 + 2 * xAccessibilityShift
  };
  float [] yEntryLoc = { // data entry point y-location for text boxes
    y + yTextBox, 
    y + yTextBox + yBox, 
    y + yTextBox + 2 * yBox, 
    y + yTopBar + yTextBox, 
    y + yTopBar + yTextBox + 2 * yBox, 
    y + yTopBar + yTextBox + 4 * yBox, 
    y + yTopBar + yTextBox + 5 * yBox, 
    y + yTopBar + yTextBox + 7 * yBox, 
    y + yTopBar + yTextBox + 12 * yBox, 
    y + yTopBar + yTextBox + 12 * yBox, 
    y + yTopBar + yTextBox + 14 * yBox, 
    y + yTopBar + yTextBox + 16 * yBox, 
    y + yTopBar + yTextBox + 17 * yBox, 
    y + yTopBar + yTextBox + 16 * yBox, 
    y + yTopBar + yTextBox + 18 * yBox, 
    y + yTopBar + yTextBox + 20 * yBox, 
    y + yTopBar - yAccessibilityShift, 
    y + yTopBar + yBox - yAccessibilityShift, 
    y + yTopBar + 2 * yBox - yAccessibilityShift, 
    y + height - xBox / 6 - 6 * yAccessibilityShift - (yTopBar - xBox / 6) / 3, 
    y + yTopBar + 3 * yBox - yAccessibilityShift
  };
  float [] xBoxSizes = { // data entry point x-size
  };
  float [] yBoxSizes = { // data entry point y-size
  };
  String [] boxLabels = { // labels for text boxes
    "LOCAL E-MAIL:", 
    "PASSWORD:", 
    "E-MAIL HOST:", 
    "SET E-MAIL:", 
    "SET PASSWORD:", 
    " ", 
    " ", 
    "DESCRIPTION:", 
    " ", 
    " ", 
    " ", 
    "RETRIEVE:", 
    " ", 
    " ", 
    " ", 
    " ", 
    " ", 
    " ", 
    " ", 
    " ", 
    " "
  };
  // TEXT BOXES:
  int txtBoxMult = 4; // email body box size
  for (int i = 0; i < xEntryLoc.length - 18; i++) {
    fill (#C4C4C4);
    rect (x + xTextBox - xLogoSize, y + yTopBar + yTextBox + i * 2 * yBox, xBox, yBox, height / 80);
    fill (#95FFE5);
    rect (x + xTextBox - xLogoSize, y + yTopBar + yTextBox + 4 * yBox, xBox, yBox, height / 80);
    fill (#FFA683);
    rect (x + xTextBox - xLogoSize, y + yTopBar + yTextBox + 5 * yBox, xBox, yBox, height / 80);
    fill (#C4C4C4);
    rect (x + xTextBox - xLogoSize, y + yTopBar + yTextBox + 7 * yBox, xBox, yBox * txtBoxMult, height / 80);
    fill (#1AFF0F);
    rect (x + xTextBox - xLogoSize, y + yTopBar + yTextBox + 12 * yBox, xBox / 2, yBox, height / 80);
    fill (#1CFFD7);
    rect (x + xTextBox - xLogoSize + xBox / 2, y + yTopBar + yTextBox + 12 * yBox, xBox / 2, yBox, height / 80);
    if (parse != null) {
      dynoColor();
    } else {
      fill (verACol, 128);
    }
    rect (x + xTextBox - xLogoSize, y + yTopBar + yTextBox + 14 * yBox, xBox, yBox, height / 80);
    fill (#C4C4C4);
    rect (x + xTextBox - xLogoSize, y + yTopBar + yTextBox + 16 * yBox, xBox, yBox, height / 80);
    if (folderPath != null) {
      dynoColor();
    } else {
      fill (verACol, 128);
    }
    rect (x + xTextBox - xLogoSize, y + yTopBar + yTextBox + 17 * yBox, xBox, yBox, height / 80);
    fill (#D4FF2C);
    rect (xEntryLoc[13], yEntryLoc[13], xBox / 3, yBox, height / 80);
    fill (#FFA683);
    rect (xEntryLoc[14], yEntryLoc[14], xBox, yBox, height / 80);
    if (folderPath != null) {
      fill (#95FFE5);
    } else {
      fill (verACol, 128);
    }
    rect (xEntryLoc[15], yEntryLoc[15], xBox, yBox, height / 80);
    fill (#D4FF2C);
    rect (xEntryLoc[16], yEntryLoc[16], xBox / 3, yBox);
    fill (#1AFF0F);
    rect (xEntryLoc[17], yEntryLoc[17], xBox / 3, yBox);
    fill (#1CFFD7);
    rect (xEntryLoc[18], yEntryLoc[18], xBox / 3, yBox);
    image (settingsWhite, xEntryLoc[19], yEntryLoc[19], xBox / 6, xBox / 6);
    fill (#0000FF);
    rect (xEntryLoc[20], yEntryLoc[20], xBox / 3, yBox, 0, 0, 0, height / 80);
  }
  // GUI diagram for upload and download
  strokeWeight (width / 500);
  int opacity;
  if (xAccessibilityShift != 0) {
    opacity = 0;
  } else {
    opacity = 255;
  }
  stroke(verBCol, opacity);
  line(xEntryLoc[8] - width / 50, yEntryLoc[8] + yBox / 2, xEntryLoc[10] - width / 50, yEntryLoc[10] + yBox / 2);
  line (xEntryLoc[8] - width / 50, yEntryLoc[8] + yBox / 2, xEntryLoc[8], yEntryLoc[8] + yBox / 2);
  line (xEntryLoc[10] - width / 50, yEntryLoc[10] + yBox / 2, xEntryLoc[10], yEntryLoc[10] + yBox / 2);
  line(xEntryLoc[8] + width / 3 + width / 50, yEntryLoc[8] + yBox / 2, xEntryLoc[15] + width / 3 + width / 50, yEntryLoc[15] + yBox / 2);
  line (xEntryLoc[8] + width / 3, yEntryLoc[8] + yBox / 2, xEntryLoc[8] + width / 3 + width / 50, yEntryLoc[8] + yBox / 2);
  line (xEntryLoc[13] + width / 9, yEntryLoc[13] + yBox / 2, xEntryLoc[13] + width / 9 + width / 50, yEntryLoc[13] + yBox / 2);
  line (xEntryLoc[15] + width / 3, yEntryLoc[15] + yBox / 2, xEntryLoc[15] + width / 3 + width / 50, yEntryLoc[15] + yBox / 2);
  noStroke();
  fill(verBCol);
  // shows the current capacity of the array
  text ("Est. CURRENT CAPACITY: " + aRAID.getUsedCap() + "Mb of " + aRAID.maxCap + "Gb", x + xLogoOffset, y + height - aTxt);
  // highlight effect - start
  float yLim = random (height); // duplicate from setParticles ();
  float adj = map (yLim, 0, height, 255, 0); // duplicate from setParticles ();
  int c = color (40, 255, adj); // duplicate from setParticles ();
  float yHlghtMult; // y size multiplier for highlight effect
  if (globalPos == 7) {
    yHlghtMult = 4;
  } else {
    yHlghtMult = 1;
  }
  fill (#000000, 128);
  strokeWeight (width / 300);
  stroke (c);
  rect (x + xSelect, y + ySelect, xBox, yBox * yHlghtMult);
  noStroke ();
  // highlight effect - end
  // sticky keys fix - start
  if (mousePressed == true) {
    clickRel += 1;
  } else {
    clickRel = clickCount;
  }
  // sticky keys fix - end
  for (int i = 0; i < xEntryLoc.length; i++) {
    textDisplay (emails [i * 2], i, xLogoOffset, xLogoSize, yBox, xEntryLoc, yEntryLoc, boxLabels, aTxt);
    if (mousePressed == true && clickRel == clickCount + 1) {
      if (i < 7 || i > 10 && i < 12) {
        if (mouseX > xEntryLoc [i] && mouseX < xEntryLoc [i] + xBox && mouseY > yEntryLoc [i] && mouseY < yEntryLoc [i] + yBox) {
          if (i == 0 || i == 1) {
            shift (conData, "Click SYNC to finalize changes.");
          }
          if (i != 5 && i != 6) {
            xSelect = xEntryLoc [i];
            ySelect = yEntryLoc [i];
            globalPos = i; // for keyPressed () only!!!
          } else if (i == 5) {
            fill (#000000, 128);
            rect (x + xTextBox - xLogoSize, y + yTopBar + yTextBox + (i - 1) * yBox, xBox, yBox, height / 80);
            println ("DATABASE IN. SIZE: " + emails.length + "ln.");
            emails = expand (emails, emails.length + 4);
            emails [emails.length - 4] = emails [6];
            emails [emails.length - 3] = "array email^";
            emails [emails.length - 2] = emails [8];
            emails [emails.length - 1] = "array pass^";
            //emails = expand (emails, emails.length);
            println ("DATABASE:");
            for (int j = 0; j < emails.length; j++) {
              print (emails [j] + "  ||  ");
            }
            println ("");
            println ("DATABASE OUT. SIZE: " + emails.length + "ln.");
            shift (conData, emails [6] + " appended -> RAID: TRUE");
            println ("CONSOLE:");
            for (int j = 0; j < conData.length; j++) {
              print (conData [j] + "  ||  ");
            }
            println ("");
            emails [6] = inLength[6];
            emails [8] = inLength[8];
            writer(emails);
          } else if (i == 6) {
            boolean delStatus = false;
            fill (#000000, 128);
            rect (x + xTextBox - xLogoSize, y + yTopBar + yTextBox + (i - 1) * yBox, xBox, yBox, height / 80);
            if (emails.length == init) {
              shift (conData, "RAID partitions found: 0");
            }
            for (int j = xEntryLoc.length * 2 - 1; j < emails.length - 2; j++) {
              if (emails[6].equals (emails[j]) && emails[8].equals (emails[j + 2])) {
                delStatus = true;
                if (delStatus == true) {
                  shift (conData, emails [6] + " deleted.");
                  delete (j);
                }
              }
              if (j == emails.length - 3 && delStatus == false) {
                shift (conData, emails [6] + " not deleted.");
              }
            }
          }
        } else if (clickCount == 0) {
          xSelect = xEntryLoc [0]; // initial data
          ySelect = yEntryLoc [0]; // initial data
        }
      } else if (i == 7) { // !!! BODY TEXT
        if (mouseX > xEntryLoc [i] && mouseX < xEntryLoc [i] + xBox && mouseY > yEntryLoc [i] && mouseY < yEntryLoc [i] + txtBoxMult * yBox) {
          xSelect = xEntryLoc [i];
          ySelect = yEntryLoc [i];
          globalPos = i; // for keyPressed () only!!!
        }
      } else if (i == 8) { // !!! FILE UP.
        if (mouseX > xEntryLoc [i] && mouseX < xEntryLoc [i] + xBox / 2 && mouseY > yEntryLoc [i] && mouseY < yEntryLoc [i] + yBox) {
          fill (#000000, 128);
          rect (x + xTextBox - xLogoSize, y + yTopBar + yTextBox + 12 * yBox, xBox / 2, yBox, height / 80);
          selectInput("Select a file to process.", "fileSelected");
        }
      } else if (i == 9) { // !!! SELECT DIRECTORY
        if (mouseX > xEntryLoc [i] && mouseX < xEntryLoc [i] + xBox / 2 && mouseY > yEntryLoc [i] && mouseY < yEntryLoc [i] + yBox) {
          fill (#000000, 128);
          rect (x + xTextBox - xLogoSize + xBox / 2, y + yTopBar + yTextBox + 12 * yBox, xBox / 2, yBox, height / 80);
          selectFolder("Select a folder to process.", "folderSelected");
        }
      } else if (i == 10) { // !!! UPLOAD
        if (mouseX > xEntryLoc [i] && mouseX < xEntryLoc [i] + xBox && mouseY > yEntryLoc [i] && mouseY < yEntryLoc [i] + yBox) {
          if (parse != null) {
            fill (#000000, 128);
            rect (x + xTextBox - xLogoSize, y + yTopBar + yTextBox + 14 * yBox, xBox, yBox, height / 80);
            aRAID.upload();
            parse = null;
          } else {
            shift (conData, "Select a file to upload.");
          }
        }
      } else if (i == 12) { // !!! GET
        if (mouseX > xEntryLoc [i] && mouseX < xEntryLoc [i] + xBox && mouseY > yEntryLoc [i] && mouseY < yEntryLoc [i] + yBox) {
          if (folderPath != null) {
            fill (#000000, 128);
            rect (x + xTextBox - xLogoSize, y + yTopBar + yTextBox + 17 * yBox, xBox, yBox, height / 80);
            aRAID.search();
            aRAID.download();
            launch (folderPath);
          } else {
            shift (conData, "Set a directory to download data to.");
          }
        }
      } else if (i == 13) { // !!! BROWSE
        if (mouseX > xEntryLoc [i] && mouseX < xEntryLoc [i] + xBox / 3 && mouseY > yEntryLoc [i] && mouseY < yEntryLoc [i] + yBox) {
          fill (#000000, 128);
          rect (xEntryLoc[i], yEntryLoc[i], xBox / 3, yBox, height / 80);
          sortStatus = 0;
          history = loadStrings (historyFile);
          currentList = new String [history.length];
          for (int j = 0; j < currentList.length; j++) {
            currentList[j] = history[j];
          }
          winStatus *= -1;
        }
      } else if (i == 14) { // !!! DELETE
        if (mouseX > xEntryLoc [i] && mouseX < xEntryLoc [i] + xBox && mouseY > yEntryLoc [i] && mouseY < yEntryLoc [i] + yBox) {
          fill (#000000, 128);
          rect (xEntryLoc[i], yEntryLoc[i], xBox, yBox, height / 80);
          if (emails.length > inLength.length) {
            aRAID.search();
            aRAID.delete();
          }
        }
      } else if (i == 15) { // !!! DOWNLOAD ALL
        if (mouseX > xEntryLoc [i] && mouseX < xEntryLoc [i] + xBox && mouseY > yEntryLoc [i] && mouseY < yEntryLoc [i] + yBox) {
          if (folderPath != null) {
            fill (#000000, 128);
            rect (xEntryLoc[i], yEntryLoc[i], xBox, yBox, height / 80);
            allRAID();
            launch (folderPath);
          } else {
            shift (conData, "Set a directory to download data to.");
          }
        }
      } else if (i == 16) { // !!! SYNC
        if (mouseX > xEntryLoc [i] && mouseX < xEntryLoc [i] + xBox && mouseY > yEntryLoc [i] && mouseY < yEntryLoc [i] + yBox) {
          fill (#000000, 128);
          rect (xEntryLoc[i], yEntryLoc[i], xBox / 3, yBox);
          aRAID.sync();
        }
      } else if (i == 17) { // !!! UP. ARRAY
        if (mouseX > xEntryLoc [i] && mouseX < xEntryLoc [i] + xBox && mouseY > yEntryLoc [i] && mouseY < yEntryLoc [i] + yBox) {
          fill (#000000, 128);
          rect (xEntryLoc[i], yEntryLoc[i], xBox / 3, yBox);
          selectInput("Select a file to process.", "fileSelected");
          saveClick = clickCount;
        }
      } else if (i == 18) { // !!! GET ARRAY
        if (mouseX > xEntryLoc [i] && mouseX < xEntryLoc [i] + xBox && mouseY > yEntryLoc [i] && mouseY < yEntryLoc [i] + yBox) {
          fill (#000000, 128);
          rect (xEntryLoc[i], yEntryLoc[i], xBox / 3, yBox);
          selectFolder("Select a folder to process.", "folderSelected");
          saveClick = clickCount;
        }
      } else if (i == 19) { // SETTINGS BUTTON
        if (mouseX > xEntryLoc [i] && mouseX < xEntryLoc [i] + xBox / 6 && mouseY > yEntryLoc [i] && mouseY < yEntryLoc [i] + xBox / 6) {
          image (settingsBlack, xEntryLoc[19], yEntryLoc[19], xBox / 6, xBox / 6);
          xHome = XFRAME;
          yHome = YFRAME;
          xSettings = xActive;
          ySettings = yActive;
        }
      } else if (i == 20) {
        if (mouseX > xEntryLoc [i] && mouseX < xEntryLoc [i] + xBox && mouseY > yEntryLoc [i] && mouseY < yEntryLoc [i] + yBox) {
          fill (#000000, 128);
          rect (xEntryLoc[i], yEntryLoc[i], xBox / 3, yBox);
          aRAID.updateArraySave();
        }
      }
    }
    // hover on array upload button
    if (i == 17 && mousePressed == false) {
      if (mouseX > xEntryLoc [i] && mouseX < xEntryLoc [i] + xBox / 3 && mouseY > yEntryLoc [i] && mouseY < yEntryLoc [i] + yBox) {
        notification (x, y, "Message! [1]", "Please use a a valid\neSpace array (.txt) file\nfor your upload.\nOtherwise this will result in\n data errors.", #9999FF);
      }
    }
  }
  // for GET ARRAY button
  if (folderPath != null && saveClick == clickCount) {
    output = createWriter (folderPath + "/eSpace_array.txt");
    output.flush();
    output.close();
    String [] tempWrite = new String [aRAID.RAIDEmail.length * 2];
    for (int i = 1; i < tempWrite.length; i += 2) {
      tempWrite [i - 1] = aRAID.RAIDEmail[i / 2];
      tempWrite [i] = aRAID.RAIDPass[i / 2];
    }
    saveStrings (folderPath + "/eSpace_array.txt", tempWrite);
    launch (folderPath);
    shift (conData, "Downloaded RAID array as .txt");
    folderPath = null;
  }
  arrayUpload();
}

// for UP. ARRAY button
public void arrayUpload () {
  if (parse != null && saveClick == clickCount) {
    if (parse.charAt(parse.length() - 4) == '.' && parse.charAt(parse.length() - 3) == 't' && parse.charAt(parse.length() - 2) == 'x' && parse.charAt(parse.length() - 1) == 't') {
      final String tempEmail = emails [0];
      final String tempPass = emails [2];
      emails = new String [inLength.length];
      for (int i = 0; i < emails.length; i++) {
        if (i != 0 && i != 2) {
          emails [i] = inLength [i];
        } else if (i == 0) {
          emails[i] = tempEmail;
        } else if (i == 2) {
          emails[i] = tempPass;
        }
      }
      transfer = loadStrings(parse);
      for (int i = 0; i < transfer.length / 2; i++) {
        emails = expand (emails, emails.length + 4);
        emails [emails.length - 4] = transfer [i * 2];
        emails [emails.length - 3] = "array email^";
        emails [emails.length - 2] = transfer [i * 2 + 1];
        emails [emails.length - 1] = "array pass^";
      }
      saveStrings (useFile, emails);
      aRAID.create(emails);
      shift (conData, "Uploaded a new array!");
      shift (conData, "SYNC is recommended.");
      parse = null;
    } else {
      JOptionPane.showMessageDialog(frame, "Please select a formatted .txt file.");
      saveClick = -1;
      parse = null;
    }
  }
}

// to generate the file name
void fileNameGenerate () {
  int slashCount = 0;
  for (int i = 0; i < parse.length(); i++) {
    if (parse.charAt(i) == '/') {
      slashCount++;
    }
  }
  String [] sect = parse.split("/");
  fileName = sect [slashCount];
  println ("file name: " + fileName);
}

// for folder selected button
String folderPath;
void folderSelected(File route) {
  if (route == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    shift (conData, "Selected: " + route.getAbsolutePath());
    println("User selected: " + route.getAbsolutePath());
  }
  folderPath = route.getAbsolutePath();
}

// for file selected button
void fileSelected (File selection) {
  if (selection == null) {
    println("Window was closed or the user hit cancel.");
  } else {
    shift (conData, "Selected: " + selection.getAbsolutePath());
    println("User selected: " + selection.getAbsolutePath());
  }
  parse = selection.getAbsolutePath();
  fileNameGenerate();
}

int globalPos = 0; // carries the highlight position to keyPressed ()!

// shifts console variables and deletes last
void shift (String [] in, String add) {
  for (int i = in.length - 1; i > 0; i--) {
    in [i] = in [i - 1];
  }
  in [0] = add;
}

// deletes variables from array
void delete (int index) {
  int j = 0;
  String [] tempArray = new String [emails.length - 4];
  for (int i = 0; i < emails.length; i++) {
    if (i != index && i != index + 1 && i != index + 2 && i != index + 3) {
      tempArray [j] = emails [i];
      j++;
    }
  }
  emails = new String [tempArray.length];
  for (int i = 0; i < tempArray.length; i++) {
    emails [i] = tempArray [i];
  }
  emails[6] = inLength[6];
  emails[8] = inLength[8];
  writer (emails);
}

// updates user on functions in right console section
void console (float x, float y, float xDivVar, float yDivVar, String [] in, float offset) {
  float newYShift = height - 2 * height / yDivVar;
  for (int i = 0; i < 2; i += 2) {
    fill (#2E2E2E, 128);
    rect (x + width - 2 * width / xDivVar, y + height / yDivVar * i + newYShift, 2 * width / xDivVar, height / yDivVar);
    fill (#1F1F1F, 128);
    rect (x + width - 2 * width / xDivVar, y + height / yDivVar * (i + 1) + newYShift, 2 * width / xDivVar, height / yDivVar);
    for (int j = 0; j < 2; j++) {
      fill (#16FA03);
      text (in [j], x + width - 2 * width / xDivVar + offset, y + height / yDivVar * (j + 0.5) + newYShift);
    }
  }
}

// displays text in boxes
void textDisplay (String in, int pos, float xLogoOffset, float xLogoSize, float yBox, float [] x, float [] y, String [] label, float txtSize) {
  fill (verBCol);
  if (pos > 2) {
    if (pos != 7) {
      textAlign (LEFT, CENTER);
      text (in, x [pos] + xLogoOffset, y [pos] + yBox / 2);
    } else {
      textAlign (LEFT, TOP);
      text (in, x [pos] + xLogoOffset, y [pos] + yBox / 2 - txtSize / 2);
    }
    text (label [pos], x [pos] - 1.4 * xLogoSize, y [pos] + yBox / 2);
  }
  if (pos <= 2) {
    fill (#FFFFFF);
    text (in, x [pos] + xLogoOffset, y [pos] + yBox / 2);
    text (label [pos], x [pos] - 1.4 * xLogoSize, y [pos] + yBox / 2);
  }
}

void notification (float x, float y, String header, String body, int fillCol) {
  push();
  float txtSz = height / 40;
  textAlign (LEFT, TOP);
  rectMode (LEFT);
  fill (fillCol);
  rect (x, y, width / 5, height / 5);
  fill (#000000);
  textSize (txtSz);
  text (header, x + txtSz / 2, y + txtSz / 2);
  textSize (txtSz / 1.25);
  text (body, x + txtSz / 2, y + 2 * txtSz);
  pop();
}

void keyPressed () {
  if (keyCode != SHIFT) {
    if (xHome == xActive && yHome == yActive) {
      if (key == ENTER) {
        emails [22] = currentList [cloudBrowse.index];
        winStatus *= -1;
      }
      if (key == CODED) {
        if (keyCode == DOWN) {
          if (cloudBrowse.txtSize * (cloudBrowse.index + 3) > yBrowseSize && cloudBrowse.index < history.length - 1) {
            cloudBrowse.yDisplay -= cloudBrowse.txtSize;
          }
          cloudBrowse.index++;
        } else if (keyCode == UP) {
          if (cloudBrowse.txtSize * (cloudBrowse.index + 2) > yBrowseSize) {
            cloudBrowse.yDisplay += cloudBrowse.txtSize;
          }
          cloudBrowse.index--;
        }
      }
      if (key == BACKSPACE || key == DELETE) {
        if (emails [globalPos * 2].length() > 0) {
          emails [globalPos * 2] = emails [globalPos * 2].substring (0, emails [globalPos * 2].length() - 1);
        }
      } else {
        if (globalPos != 11) {
          if (textWidth (emails [globalPos * 2]) <= width / 3 - width / 50) { // width/3='xBox', width/50='2*xLogoOffset'
            emails [globalPos * 2] = emails [globalPos * 2] + key;
          }
        } else {
          if (textWidth (emails [globalPos * 2]) <= width / 3 - width / 9 - width / 50) { // width/3-width/9= box width, width/50='2*xLogoOffset'
            emails [globalPos * 2] = emails [globalPos * 2] + key;
          }
        }
        if (key == ENTER && globalPos == 7) {
          //emails [globalPos * 2] = emails [globalPos * 2] + key;
        } else if (key == ENTER && globalPos != 7) {
          // insert 'next field' code!!!
          println ("The 'ENTER' key feature doesn't work here :(");
          emails [globalPos * 2] = emails [globalPos * 2].substring (0, emails [globalPos * 2].length() - 1);
        }
      }
    } else if (xLogin == xActive && yLogin == yActive) {
      if (key == BACKSPACE || key == DELETE) {
        if (loginUser[loginGlobal].length() > 0) {
          loginUser[loginGlobal] = loginUser[loginGlobal].substring (0, loginUser[loginGlobal].length() - 1);
        }
      } else {
        if (textWidth (loginUser[loginGlobal]) < width / 6 && loginGlobal != 0) {
          loginUser[loginGlobal] = loginUser[loginGlobal] + key;
        } else if (loginGlobal == 0) {
          loginUser[loginGlobal] = loginUser[loginGlobal] + key;
        }
        if (key == ENTER) {
          println ("The 'ENTER' key feature doesn't work here :(");
          loginUser[loginGlobal] = loginUser[loginGlobal].substring (0, loginUser[loginGlobal].length() - 1);
        }
      }
    }
  }
  emails [4] = "GMAIL";
}

void mousePressed () {
  setParticles();
  // for the browsing
  if (xHome == xActive && yHome == yActive) {
    if (mouseX > cloudBrowse.accessX + 3 * cloudBrowse.accessWid / 4 && mouseX < cloudBrowse.accessX + cloudBrowse.accessWid) {
      if (mouseY > cloudBrowse.accessY && mouseY < cloudBrowse.accessY + cloudBrowse.txtSize) {
        cloudBrowse.colHere = #00CC00;
        if (sortStatus < 3) {
          sortStatus++;
        } else {
          sortStatus = 0;
        }
      }
    }
    if (sortStatus == 1) {
      for (int i = 0; i < currentList.length / 2; i++) {
        String temp = currentList[i];
        currentList[i] = currentList[currentList.length - i - 1];
        currentList[currentList.length - i - 1] = temp;
      }
      cloudBrowse.sortLabel = "NEW-OLD";
    } else if (sortStatus == 3) {
      for (int i = 0; i < currentList.length / 2; i++) {
        String temp = currentList[i];
        currentList[i] = currentList[currentList.length - i - 1];
        currentList[currentList.length - i - 1] = temp;
      }
      cloudBrowse.sortLabel = "<<ALPHABET";
    }
  }
}

void mouseReleased () {
  clickCount++;
  //println ("clickCount = " + clickCount);
  if (xHome == xActive && yHome == yActive) {
    if (mouseX > cloudBrowse.accessX + 3 * cloudBrowse.accessWid / 4 && mouseX < cloudBrowse.accessX + cloudBrowse.accessWid) {
      if (mouseY > cloudBrowse.accessY && mouseY < cloudBrowse.accessY + cloudBrowse.txtSize) {
        cloudBrowse.colHere = #0C9EC1;
      }
    }
  }
}

void draw () {
  //background (#000000);
  wallpaper ();
  textFont (aFont);
  login (xLogin, yLogin);
  home (xHome, yHome);
  settingsScreen (xSettings, ySettings);
  /*
  * This is to test page relativity
   login (100, 100);
   home (100, 100);
   settingsScreen (100, 100);
   */
}

/*
 * 
 *
 * login screen
 *
 *
 */

private String [] loginUser = new String [4]; // these are the text fields
int loginGlobal = 0;
float yHighLog = -1 * height; // y log highlight (initial loc)
int loginCol = #B9B9B9; // random color stuff
boolean createStatus; // status of creating an account
boolean addressCheck = false; // mac address check
boolean freshSoft = false; // always false unless the session indicates a fresh software

void loginBars (float x, float y, float wid, String inside, int col) {
  fill (col);
  rect (x, y, wid / 1.5, height / 20, height / 80);
  fill (#6A6A6A);
  float txtSz = height / 35;
  float offset = txtSz / 2;
  textSize (txtSz);
  text (inside, x - (wid / 3) + offset, y);
}

void login (float x, float y) {
  while (addressCheck == false) {
    getMac();
    if (address.length > 0) {
      println("Address save found!");
      int adSize = 0;
      ;
      // if statements make sure that the array lengths do not go out of bounds (if the saved address is a different length than the real address)
      if (address.length > macAddress.size()) {
        adSize = macAddress.size();
      } else {
        adSize = address.length;
      }
      // for loop checks to see if the mac address matches
      for (int i = 0; i < adSize; i++) {
        if (!macAddress.get(i).equals(address[i])) {
          saveStrings(resetFile, new String [0]);
          saveStrings(useFile, new String [0]);
          saveStrings(historyFile, new String [0]);
          JOptionPane.showMessageDialog(frame, "This software is considered pirated.\neSpace has initialized a 'self-destruct' function. All system data has been erased.");
          System.exit(0);
        } else {
          println("You survived... " + i);
        }
      }
    } else {
      println("This is a fresh software.");
      launch(dataPath("video.webloc"));
      freshSoft = true;
      String [] addresses = new String [macAddress.size()];
      for (int i = 0; i < macAddress.size(); i++) {
        addresses[i] = macAddress.get(i);
      }
      saveStrings(addressFile, addresses);
    }
    addressCheck = true;
  }
  JFrame frame = new JFrame ("eSpace Message");
  while (millis() < 4000) { // initiate everything ONLY within the first 4 seconds, else crashes
    JOptionPane.showMessageDialog(frame, "By clicking OK you are agreeing to the eSpace EULA.\n\nYour MAC Address(es): CONFIRMED\n" + macAddress);
    loginUser [0] = "Email";
    loginUser [1] = "Password";
    loginUser [2] = "Login";
    loginUser [3] = "Create a cloud";
  }
  push();
  rectMode (CENTER);
  imageMode (CENTER);
  textAlign (LEFT, CENTER);
  noStroke();
  fill (#E8E8E8, 32);
  float logoRat = 0.33; // 360px/1080px
  rect (x + width / 2, y + height / 2, width / 3, height / 1.5, height / 60);
  image (bLogo, x + width / 2, y + height / 6 + (width / 9 * logoRat), width / 4.5, width / 4.5 * logoRat);
  // help! button start
  fill (#5D5F5F);
  textSize (height / 35);
  text ("Help!", x + width / 2 - width / 9, y + height / 1.3);
  if (mousePressed == true && clickRel == clickCount + 1) {
    if (mouseX >= x + width / 2 - width / 9 && mouseX <= x + width / 2 - width / 9 + textWidth("Help!")) {
      if (mouseY >= y + height / 1.3 - height / 70 && mouseY <= y + height / 1.3 + height / 70) {
        fill (#FFFFFF);
        text ("Help!", x + width / 2 - width / 9, y + height / 1.3);
        launch(dataPath("video.webloc"));
        String forgotEmail = JOptionPane.showInputDialog(frame, "Enter the email of the account you can't access.");
        if (forgotEmail != null && forgotEmail.equals(emails[0])) {   
          println("Email accepted...");
          mail.recoverPass();
          JOptionPane.showMessageDialog(frame, "An email with your password has been sent to\n" + forgotEmail);
        } else {
          println("User did not provide valid credentials.");
          JOptionPane.showMessageDialog(frame, "Sorry, you did not provide the matching address.");
        }
      }
    }
  }
  // help! button end
  for (int i = 0; i < 4; i++) {
    float xStart = x + width / 2 - width / 9;
    float xEnd = x + width / 2 + width / 9;
    float yStart = y + height / 2 - height / 6 + ((i * 2) * height / 20) - height / 40;
    float yEnd = y + height / 2 - height / 6 + ((i * 2) * height / 20) + height / 40;
    loginBars (x + width / 2, y + height / 2 - height / 6 + ((i * 2) * height / 20), width / 3, loginUser[i], loginCol);
    loginBars (x + width / 2, y + yHighLog, width / 3, loginUser[loginGlobal], #C2EADC); // highlight effect
    if (mousePressed == true && clickRel == clickCount + 1) {
      if (i != 2 && i != 3) {
        if (mouseX > xStart && mouseX < xEnd && mouseY > yStart && mouseY < yEnd) {
          yHighLog = height / 2 - height / 6 + ((i * 2) * height / 20);
          loginGlobal = i;
        }
      } else if (i == 2) {
        if (mouseX > xStart && mouseX < xEnd && mouseY > yStart && mouseY < yEnd) {
          loginBars (x + width / 2, y + height / 2 - height / 6 + ((i * 2) * height / 20), width / 3, loginUser [i], #52CAFF);
          if (!loginUser[0].equals(emails[0]) || !loginUser[1].equals(emails[2])) {
            JOptionPane.showMessageDialog(frame, "The entered username or password doesn't match this system.\nIf you don't remember your credentials, click HELP.\nYou can start a new system by clicking CREATE A CLOUD.");
          } else { // LOGIN BUTTON
            shift (conData, "Help us build eSpace at www.espace.cloud"); // Welcome message to eSpace (returning user)
            shift (conData, "You came back... ;)"); // Welcome message to eSpace (returning user)
            xHome = xActive;
            yHome = yActive;
            xLogin = XFRAME;
            yLogin = YFRAME;
            aRAID.checkForArray();
          }
        }
      } else if (i == 3) {
        if (mouseX > xStart && mouseX < xEnd && mouseY > yStart && mouseY < yEnd) {
          loginBars (x + width / 2, y + height / 2 - height / 6 + ((i * 2) * height / 20), width / 3, loginUser [i], #52CAFF);
          for (int j = 0; j < loginUser[0].length(); j++) {
            if (loginUser[0].charAt(j) != '@' && createStatus != true) {
              createStatus = false;
            } else {
              createStatus = true;
            }
          }
          if (createStatus == false) {
            JOptionPane.showMessageDialog(frame, "Please enter the username and password that you want to create.\nE.g. example@gmail.com, Password123");
          } else if (createStatus == true) { // CREATE A CLOUD BUTTON
            if (freshSoft == true) {
              mail.universalMail ("es241.espace@gmail.com", "New User #JAVA", "This is confirmation of a new eSpace Java edition user.");
            }
            shift (conData, "Welcome to eSpace Java Edition!"); // Welcome message to eSpace (new user)
            inLength[0] = loginUser[0];
            inLength[2] = loginUser[1];
            writer(inLength);
            history = new String [0];
            saveStrings (historyFile, history);
            xHome = xActive;
            yHome = yActive;
            xLogin = XFRAME;
            yLogin = YFRAME;
            aRAID.checkForArray();
          }
        }
      }
    }
    // this is a hover effect for the create account button
    if (i == 3 && mousePressed == false) {
      if (mouseX > xStart && mouseX < xEnd && mouseY > yStart && mouseY < yEnd) {
        notification (x, y, "Account Requirements", "When creating an account\nuse a valid Gmail address\nwith the corresponding pass.", #FFFFFF);
      }
    }
  }
  pop();
  //text ( "user count = " + mail.getUserCount("imap"), width / 2, 400);
}

/*
 *
 *
 * settings screen
 *
 *
 */

float xGT = XFRAME;
float yGT = YFRAME;
int ourTheme = #000000;
int themeInt = 1;
void generalTab (float x, float y) {
  fill (verBCol, 64);
  rect (x, y, width * 2 / 3, height);
  // theme button (light and dark(
  if (themeInt == 1) {
    ourTheme = #000000;
    verACol = #000000;
    verBCol = #FFFFFF;
  } else {
    ourTheme = #FFFFFF;
    verACol = #FFFFFF;
    verBCol = #000000;
  }
  settingsButton(x - width / 3 + width / 2, y, width / 3, "THEME", 0, ourTheme);
  if (mousePressed == true && clickRel == clickCount + 1) {
    if (mouseX > x - width / 3 + width / 2 && mouseX < x + width / 2 && mouseY > y + width / 18 && mouseY < y + width / 18 + height / 20) {
      themeInt *= -1;
    }
  }
  // RAID 0 or 1 buttons
  settingsButton(x - width / 3 + width / 2, y, width / 6, "RAID 0", 1, ourTheme);
  if (mousePressed == true && clickRel == clickCount + 1) {
    if (mouseX > x - width / 3 + width / 2 && mouseX < x + width / 2 - width / 6 && mouseY > y + 2 * width / 18 && mouseY < y + 2 * width / 18 + height / 20) {
      
    }
  }
  settingsButton(x - width / 3 + width / 2 + width / 6, y, width / 6, "RAID 1", 1, ourTheme);
  if (mousePressed == true && clickRel == clickCount + 1) {
    if (mouseX > x - width / 3 + width / 2 + width / 6 && mouseX < x + width / 2 && mouseY > y + 2 * width / 18 && mouseY < y + 2 * width / 18 + height / 20) {
      println ("hi");
    }
  }
}

void settingsScreen (float x, float y) {
  generalTab(x + xGT, y + yGT);
  push();
  textAlign (LEFT, CENTER);
  fill (verACol, 128);
  rect (x, y, width / 3, height);
  image (backWhite, x, y, width / 18, width / 18);
  String [] menuText = {
    "General", 
    "Log Out", 
    "Clean Slate Protocal"
  };
  int rectCol = #B9B9B9;
  for (int i = 0; i < menuText.length; i++) {
    settingsButton (x, y, width / 3, menuText [i], i, rectCol);
  }
  if (mousePressed == true && clickRel == clickCount + 1) {
    if (mouseX > x && mouseX < x + width / 18 && mouseY > y && mouseY < y + width / 18) {
      image (backBlack, x, y, width / 18, width / 18);
      xSettings = XFRAME;
      ySettings = YFRAME;
      xHome = xActive;
      yHome = yActive;
    }
    // general button
    if (mouseX > x && mouseX < x + width / 3 && mouseY > y + width / 18 && mouseY < y + width / 18 + height / 20) {
      rectCol = #C2EADC;
      settingsButton (x, y, width / 3, menuText[0], 0, rectCol);
      xGT = width / 3;
      yGT = yActive;
    }
    // log out button
    if (mouseX > x && mouseX < x + width / 3 && mouseY > y + width / 9 && mouseY < y + width / 9 + height / 20) {
      rectCol = #52CAFF;
      settingsButton (x, y, width / 3, menuText[1], 1, rectCol);
      xSettings = XFRAME;
      ySettings = YFRAME;
      xLogin = xActive;
      yLogin = yActive;
    }
    // clean slate protocol
    if (mouseX > x && mouseX < x + width / 3 && mouseY > y + 3 * width / 18 && mouseY < y + 3 * width / 18 + height / 20) {
      rectCol = #52CAFF;
      settingsButton (x, y, width / 3, menuText[2], 2, rectCol);
      xSettings = XFRAME;
      ySettings = YFRAME;
      xLogin = xActive;
      yLogin = yActive;
    }
  }
  pop();
}

void settingsButton (float x, float y, float wid, String show, int index, int col) {
  float txtSz = height / 35;
  float offset = txtSz / 2;
  textSize (txtSz);
  fill (col);
  rect (x, y + width / 18 + width * index / 18, wid, height / 20, height / 80);
  fill (#6A6A6A);
  text (show, x + offset, y + width / 18 + width * index / 18 + height / 40);
}

/*
 *
 *
 * misc.
 *
 *
 */

static final void setDefaultClosePolicy(PApplet pa, boolean keepOpen) {
  final Object surf = pa.getSurface().getNative();
  final PGraphics canvas = pa.getGraphics();
  if (canvas.isGL()) {
    final com.jogamp.newt.Window w = (com.jogamp.newt.Window) surf;
    for (com.jogamp.newt.event.WindowListener wl : w.getWindowListeners()) {
      if (wl.toString().startsWith("processing.opengl.PSurfaceJOGL")) {
        w.removeWindowListener(wl);
        w.setDefaultCloseOperation(keepOpen?com.jogamp.nativewindow.WindowClosingProtocol.WindowClosingMode.DO_NOTHING_ON_CLOSE : com.jogamp.nativewindow.WindowClosingProtocol.WindowClosingMode.DISPOSE_ON_CLOSE);
      }
    }
  } else if (canvas instanceof processing.awt.PGraphicsJava2D) {
    final javax.swing.JFrame f = (javax.swing.JFrame)((processing.awt.PSurfaceAWT.SmoothCanvas) surf).getFrame(); 
    for (java.awt.event.WindowListener wl : f.getWindowListeners()) {
      if (wl.toString().startsWith("processing.awt.PSurfaceAWT")) {
        f.removeWindowListener(wl);
      }
    }
    f.setDefaultCloseOperation(keepOpen?f.DO_NOTHING_ON_CLOSE : f.DISPOSE_ON_CLOSE);
  }
}

// RAID array retrieve config #ALL
void allRAID () {
  mail.setSaveDirectory (parse);
  for (int i = init; i < emails.length; i += 4) {
    mail.downloadAll (imapType, emails [i], emails [i + 2]);
  }
}

// splits large files
int chunksNum = 0;
String [] splitUploadParts = new String [0];
private static int PART_SIZE = 25 * 1024 * 1024 - 1; // 25*1024*1024=25mb
void fileSplit () {
  File inputFile = new File(parse);
  FileInputStream inputStream;
  String newFileName;
  FileOutputStream filePart;
  int fileSize = (int) inputFile.length();
  int nChunks = 0, read = 0, readLength = PART_SIZE;
  byte [] byteChunkPart;
  try {
    inputStream = new FileInputStream(inputFile);
    while (fileSize > 0) {
      if (fileSize <= PART_SIZE) {
        readLength = fileSize;
      }
      byteChunkPart = new byte[readLength];
      read = inputStream.read(byteChunkPart, 0, readLength);
      fileSize -= read;
      assert (read == byteChunkPart.length);
      nChunks++;
      newFileName = parse + ".part" + Integer.toString (nChunks - 1);
      splitUploadParts = expand (splitUploadParts, splitUploadParts.length + 1);
      splitUploadParts [splitUploadParts.length - 1] = newFileName;
      filePart = new FileOutputStream(new File(newFileName));
      filePart.write(byteChunkPart);
      filePart.flush();
      filePart.close();
      byteChunkPart = null;
      filePart = null;
    }
    chunksNum = nChunks;
    inputStream.close();
    System.out.println("Done splitting.");
  } 
  catch (IOException exception) {
    exception.printStackTrace();
  }
}

// merges the large file parts
String fileDownloaded = "";
void fileMerge () {
  fileDownloaded = fileDownloaded.substring(0, fileDownloaded.length() - 6);
  File ofile = new File(folderPath + "/" + fileDownloaded);
  FileOutputStream fos;
  FileInputStream fis;
  byte [] fileBytes;
  int bytesRead = 0;
  println(chunksNum + " chunks found.");
  File [] list = new File [chunksNum];
  for (int i = 0; i < chunksNum; i++) {
    list[i] = new File(folderPath + "/" + fileDownloaded + ".part" + i);
  }
  try {
    fos = new FileOutputStream(ofile, true);
    for (File file : list) {
      fis = new FileInputStream(file);
      fileBytes = new byte[(int) file.length()];
      bytesRead = fis.read(fileBytes, 0, (int) file.length());
      assert(bytesRead == fileBytes.length);
      assert(bytesRead == (int) file.length());
      fos.write(fileBytes);
      fos.flush();
      fileBytes = null;
      fis.close();
      fis = null;
      // deletes the extra file after being merged
      if (file.delete()) {
        System.out.println("Deleted the file: " + file.getName());
      } else {
        System.out.println("Failed to delete the file.");
      }
    }
    //fos.close();
    fos = null;
    System.out.println("Done merge.");
  }
  catch (Exception exception) {
    exception.printStackTrace();
  }
}

void getMac () {
  try {
    Enumeration<NetworkInterface> networks = NetworkInterface.getNetworkInterfaces();
    while (networks.hasMoreElements()) {
      NetworkInterface network = networks.nextElement();
      byte [] mac = network.getHardwareAddress();
      if (mac != null) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < mac.length; i++) {
          sb.append(String.format("%02X%s", mac[i], (i < mac.length - 1) ? "-" : ""));
        }
        macAddress.add(sb.toString());
      }
    }
    System.out.println(macAddress);
  } 
  catch (SocketException e) {
    e.printStackTrace();
  }
}
