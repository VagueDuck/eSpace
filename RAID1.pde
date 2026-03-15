// RAID 1 Setup
// mirror

int currentPartition; // this is a counter that keeps track of which partition (inbox) in the RAID array the system is at
//String popHost = "pop.gmail.com";
//String popPort = "995";
//String popType = "pop3";
String imapHost = "imap.gmail.com"; // imap active host
String imapPort = "993"; // imap active port
String imapType = "imap"; // imap type name (same)
String smtpHost = "smtp.gmail.com"; // smtp active host
String smtpPort = "587"; // smtp active port
String smtpType = "smtp"; // smtp type name (same)

String subjectAdder = "";

// RAID 1 config #RAID1
public class RAID1 {
  String [] RAIDEmail; // emails in array
  String [] RAIDPass; // passwords in array

  int maxCap = 15; // max capacity (Gb)

  public int getUsedCap () { // used capacity (Mb)
    return history.length * 25;
  }

  /*
  // the override was used when RAID1 class implemented Runnable
   @Override
   public void run () {
   }
   */

  // constructor
  RAID1 () {
    System.out.println ("RAID 1 built!");
    // below prints the thread ID to the system
    try {
      System.out.println("RAID 1 thread ID = " + Thread.currentThread().getId());
    }
    catch (Exception e) { // this shouldn't happen... but ya
      System.out.println("Multithreading has failed.");
    }
  }

  String [] subjects;
  public void createSubjects (String type, String userName, String password) {
    try {
      Store store = mail.normalSession.getStore(type);
      store.connect(userName, password);
      Folder folderInbox = store.getFolder("INBOX");
      folderInbox.open(Folder.READ_WRITE);
      Message[] arrayMessages = folderInbox.getMessages();   
      subjects = new String [arrayMessages.length];
      for (int i = 0; i < arrayMessages.length; i++) {
        Message message = arrayMessages[i];
        String subject = message.getSubject();
        subjects[i] = subject;
      }
      store.close();
    } 
    catch (NoSuchProviderException ex) {
      System.out.println("No provider.");
      ex.printStackTrace();
    } 
    catch (MessagingException ex) {
      System.out.println("Could not connect to the message store.");
      ex.printStackTrace();
    }
  }
  
  Random rand = new Random ();
  // syncs the inbox to the uploads list (& history file) to browse
  public void sync () {
    visLogic *= -1;
    mail.talk = "Syncing the system...";
    if (RAIDEmail.length > 0) {
      int randomPartition = rand.nextInt(RAIDEmail.length); // randomly chooses a partition to download from so hacking any single email won't necessarily destroy the cloud.
      createSubjects(imapType, RAIDEmail[randomPartition], RAIDPass[randomPartition]);
      saveStrings (historyFile, subjects); // history
      saveStrings (useFile, emails); // allows you to change the central email and password
      history = loadStrings(historyFile);
      shift (conData, "RAID 1 SYNC complete.");
    } else {
      shift (conData, "The last SYNC is still saved to the system.");
      shift (conData, "Your RAID 1 array is empty; SYNC failed.");
    }
    visLogic *= -1;
  }

  public void create (String [] file) {
    RAIDEmail = new String [(file.length - init) / 4];
    RAIDPass = new String [(file.length - init) / 4];
    System.out.println ("Array built with:");
    for (int i = 0; i < RAIDEmail.length; i++) {
      RAIDEmail [i] = file [i * 4 + init];
      RAIDPass [i] = file [i * 4 + init + 2];
      System.out.println (RAIDEmail [i] + ", " + RAIDPass [i]);
    }
  }

  public void upload () {
    subjectAdder = "";
    if (new File (parse).length() < 25 * 1024 * 1024) { // if the file is less than 25Mb
      shift (conData, "Starting upload type #A...");
      for (int i = 0; i < RAIDEmail.length; i++) {
        mail.sendMail (RAIDEmail[i]);
      }
    } else {
      shift (conData, "Starting upload type #B...");
      fileSplit();
      subjectAdder = "#:" + chunksNum;
      String fileNameSave = fileName;
      for (int i = 0; i < RAIDEmail.length; i++) {
        for (int j = 0; j < splitUploadParts.length; j++) {
          parse = splitUploadParts[j];
          fileName = fileNameSave + ".part" + j;
          mail.sendMail (RAIDEmail[i]);
          if (new File (parse).delete()) {
            System.out.println("Deleted the file: " + new File (parse).getName());
          } else {
            System.out.println("Failed to delete the file.");
          }
        }
      }
    }
    history = expand (history, history.length + 1);
    history [history.length - 1] = emails[14].split("\n")[0] + subjectAdder;
    saveStrings (historyFile, history);
  }

  public void download () {
    shift (conData, "Download starting...");
    if (emails[22].charAt(emails[22].length() - 3) == '#' && emails[22].charAt(emails[22].length() - 2) == ':') {
      mail.downloadItem (imapType, RAIDEmail [currentPartition], RAIDPass [currentPartition]);
      chunksNum = emails[22].charAt(emails[22].length() - 1) - 48;
      fileMerge();
    } else {
      mail.downloadItem (imapType, RAIDEmail [currentPartition], RAIDPass [currentPartition]);
    }
    shift (conData, "Download finished!");
  }

  public void search () {
    shift (conData, "Searching partitions...");
    int i = 0;
    mail.itemID = -1;
    while (mail.itemID == -1 && i < RAIDEmail.length) {
      shift (conData, "Partition #" + i + " being parsed.");
      currentPartition = i;
      mail.searchEmail (imapType, RAIDEmail [i], RAIDPass [i], emails [22]);
      i++;
    }
  }

  public void delete () {
    mail.deleteMessages (RAIDEmail [currentPartition], RAIDPass [currentPartition], mail.searchSubject);
    sync();
    shift (conData, "'" + mail.searchSubject + "' set to delete.");
  }

  // checks the main email to see if there is an array file to reference
  public void checkForArray () {
    String subjectCode = "Array_Save_#42069";
    System.out.println("System checking for array...");
    mail.searchSubject = null;
    mail.searchEmail (imapType, emails[0], emails[2], subjectCode);
    if (mail.searchSubject == null) {
      shift (conData, "No array save found for this login.");
    } else {
      selectFolder("Select a folder to process.", "folderSelected");
      int startSync = JOptionPane.showConfirmDialog(null, "eSpace has found data previously used with this email.\nWould you like to sync this data?", "eSpace", JOptionPane.YES_NO_OPTION);
      if (startSync == JOptionPane.YES_OPTION) {
        parse = folderPath + "/eSpace_array.txt";
        File save_array = new File(parse);
        mail.downloadItem(imapType, emails[0], emails[2]); // downloads only if there is an array found
        saveClick = clickCount; // required to initiate the arrayUpload() method
        arrayUpload();
        sync(); // this syncs the uploaded array to the system
        // delete the file downloaded to the system
        if (save_array.delete()) {
          println("deleted: " + save_array.getName());
        } else {
          println("Failed to reset changes.");
        }
        // reset variables and clean the function (just to make sure; might not be necessary)
        folderPath = null;
        shift (conData, "The most recent array save has synced.");
      } else {
        folderPath = null;
        parse = null;
        shift (conData, "The user opted not to sync.");
      }
    }
  }

  // changes the array save in the main email when changes are made.
  public void updateArraySave () {
    mail.deleteMessages(emails[0], emails[2], "Array_Save_#42069");
    selectFolder("Select a folder to process.", "folderSelected");
    int startSync = JOptionPane.showConfirmDialog(frame, "Please click YES to proceed with the save.", "eSpace", JOptionPane.YES_NO_OPTION);
    if (startSync == JOptionPane.YES_OPTION) {
      parse = folderPath + "/eSpace_array.txt";
      File save_array = new File(parse);
      // Get-start
      output = createWriter (parse);
      output.flush();
      output.close();
      String [] tempWrite = new String [aRAID.RAIDEmail.length * 2];
      for (int i = 1; i < tempWrite.length; i += 2) {
        tempWrite [i - 1] = aRAID.RAIDEmail[i / 2];
        tempWrite [i] = aRAID.RAIDPass[i / 2];
      }
      saveStrings (parse, tempWrite);
      // Get-end
      mail.universalMail(emails[0], "Array_Save_#42069", "", parse, "eSpace_array.txt");
      if (save_array.delete()) {
        println("deleted: " + save_array.getName());
      } else {
        println("Failed to reset changes.");
      }
      shift (conData, "Saved array changes to " + emails[0]);
    }
    folderPath = null;
    parse = null;
  }
}
