/*
 * eSpace Ad API
 */

public class Ad {
  private int clCnt = 0;
  private int clRel;

  Ad () {
    System.out.println("Ad engine instance: initialized");
    try {
      System.out.println("Ad thread ID = " + Thread.currentThread().getId());
    }
    catch (Exception e) {
      System.out.println("Multithreading has failed.");
    }
  }

  public void pushVideo (float x, float y, float xDim, float yDim) {
    if (mousePressed == true) {
      clRel += 1;
    } else {
      clRel = clCnt;
    }
    if (mousePressed == true && clRel == clCnt + 1) {
      if (mouseX > x && mouseY > y && mouseX < x + xDim && mouseY < y + yDim) {
        System.out.println("CPC + 1!");
      }
    }
  }

  public void horBanner (float x, float y, float xDim, float yDim) {
  }

  public void verBanner (float x, float y, float xDim, float yDim) {
  }

  public void miniBox (float x, float y, float xDim, float yDim) {
  }
}
