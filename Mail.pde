// mail functions

int visLogic = -1; // visibility true or false (mult by -1)

public class Mail extends PApplet {
  float txtSize = 14; // text size for the GUI
  String talk = "Unidentified function loading..."; // what text the window displays

  void setup () {
    System.out.println("Mail thread ID = " + Thread.currentThread().getId());
    surface.setTitle("eSpace Mail Engine");
    surface.setIcon (logo); // icon for applet
    surface.setResizable(true);
    setDefaultClosePolicy(this, true);
    noStroke();
  }

  public void settings () {
    size (480, 160);
  }

  float aRotVar = 0;
  float bRotVar = 180;
  float aSpeed = 3;
  float bSpeed = 2;
  void draw () {
    int bgCol = #FFFFFF;
    background (bgCol);
    if (visLogic == -1) { // to show/hide window write: visLogic *= -1;
      mail.getSurface().setVisible(false);
    } else {
      mail.getSurface().setVisible(true);
    }
    textAlign (CENTER, CENTER);
    textFont (aFont, txtSize);
    // for the loading indicator
    // first matrix
    pushMatrix();
    aRotVar += aSpeed;
    if (aRotVar >= 360) {
      aRotVar = 0;
    }
    translate (width / 2, height / 2);
    rotate (radians(aRotVar));
    fill (#52CAFF);
    circle (0, 0, height / 2);
    fill (bgCol);
    rect (0, 0, height / 4, height / 4);
    circle (0, 0, height / 3);
    popMatrix();
    // second matrix
    pushMatrix();
    push();
    bRotVar += bSpeed;
    if (bRotVar >= 360) {
      bRotVar = 0;
    }
    if (aRotVar == 0) {
      bSpeed *= -1;
    }
    translate (width / 2, height / 2);
    rotate (radians(bRotVar));
    fill (bgCol);
    rectMode(CENTER);
    rect (height / 8, 0, height / 4 + txtSize, height / 12);
    pop();
    popMatrix();
    // for the status text
    fill (#000000);
    text (talk, width / 2, height / 2);
  }

  Mail () {
    System.out.println("Mail instance: initialized");
    createSMTP (smtpHost, smtpPort, smtpType); // SMTP session for sending mail
    createSession (imapHost, imapPort, imapType); // normal IMAP session
  }

  // Session - run in setup()
  Session normalSession;
  void createSession (String host, String port, String type) {
    Properties properties = new Properties();

    // server setting
    properties.put("mail." + type + ".host", host);
    properties.put("mail." + type + ".port", port);

    // SSL setting
    properties.setProperty("mail." + type + ".socketFactory.class", "javax.net.ssl.SSLSocketFactory");
    properties.setProperty("mail." + type + ".socketFactory.fallback", "false");
    properties.setProperty("mail." + type + ".socketFactory.port", String.valueOf(port));

    normalSession = Session.getInstance(properties);
  }

  public class Auth extends Authenticator {
    public Auth() {
      super();
    }

    public PasswordAuthentication getPasswordAuthentication() {
      String username, password;
      username = emails [0];
      password = emails [2];
      println ("email: " + emails [0]);
      println ("pass.: " + emails [2]);
      System.out.println("*authenticating your stuff*");
      shift (conData, "Authenticating " + emails[0] + "...");
      return new PasswordAuthentication(username, password);
    }
  }

  // SMTP session
  Session SMTPSession;
  void createSMTP (String host, String port, String type) {
    Properties props = new Properties();

    props.put("mail.transport.protocol", type);
    props.put("mail.smtp.host", host);
    props.put("mail.smtp.port", port);
    props.put("mail.smtp.auth", "true");
    // Gmail requires TTLS
    props.put("mail.smtp.starttls.enable", "true");

    // Create the session
    SMTPSession = Session.getInstance(props, new Auth());
  }

  public void deleteMessages (String userName, String password, String subjectToDelete) {
    visLogic *= -1;
    talk = "Deleting " + subjectToDelete + "...";
    try {
      // connects to the message store
      Store store = normalSession.getStore("imap");
      store.connect(userName, password);

      // opens the inbox folder
      Folder folderInbox = store.getFolder("INBOX");
      folderInbox.open(Folder.READ_WRITE);

      // fetches new messages from server
      Message[] arrayMessages = folderInbox.getMessages();

      for (int i = 0; i < arrayMessages.length; i++) {
        Message message = arrayMessages[i];
        String subject = message.getSubject();
        if (subject.contains(subjectToDelete)) {
          message.setFlag(Flags.Flag.DELETED, true);
          System.out.println("Marked DELETE for message: " + subject);
        }
      }

      // expunges the folder to remove messages which are marked deleted
      boolean expunge = true;
      folderInbox.close(expunge);
      // ***OR***
      //folderInbox.expunge();
      //folderInbox.close(false);

      // disconnect
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
    catch (Exception e) {
      println ("Something went wrong.");
    }
    visLogic *= -1;
  }

  private String saveDirectory;
  //Sets the directory where attached files will be stored.
  public void setSaveDirectory (String dir) {
    this.saveDirectory = dir;
  }

  // downloads a specific subject from search
  public void downloadItem (String type, String userName, String password) {
    visLogic *= -1;
    talk = "Downloading " + searchSubject + "...";
    setSaveDirectory (folderPath);
    if (foundMessages.length > 0) {
      try {
        // connects to the message store
        Store store = normalSession.getStore(type);
        store.connect(userName, password);

        // opens the inbox folder
        Folder folderInbox = store.getFolder("INBOX");
        folderInbox.open(Folder.READ_ONLY);

        // fetches new messages from server
        Message [] arrayMessages = folderInbox.getMessages();

        for (int i = 0; i < arrayMessages.length; i++) {
          Message message = arrayMessages[i];
          Address[] fromAddress = message.getFrom();
          String from = fromAddress[0].toString();
          String subject = message.getSubject();
          String sentDate = message.getSentDate().toString();
          String contentType = message.getContentType();
          String messageContent = "";

          // store attachment file name, separated by comma
          String attachFiles = "";

          if (subject.equals(searchSubject)) {
            if (contentType.contains("multipart")) {
              // content may contain attachments
              Multipart multiPart = (Multipart) message.getContent();
              int numberOfParts = multiPart.getCount();
              for (int partCount = 0; partCount < numberOfParts; partCount++) {
                MimeBodyPart part = (MimeBodyPart) multiPart.getBodyPart(partCount);
                if (Part.ATTACHMENT.equalsIgnoreCase(part.getDisposition())) {
                  // this part is attachment
                  String fileName = part.getFileName();
                  attachFiles += fileName + ", ";
                  part.saveFile(saveDirectory + File.separator + fileName);
                } else {
                  // this part may be the message content
                  messageContent = part.getContent().toString();
                }
              }

              if (attachFiles.length() > 1) {
                attachFiles = attachFiles.substring(0, attachFiles.length() - 2);
              }
            } else if (contentType.contains("text/plain") || contentType.contains("text/html")) {
              Object content = message.getContent();
              if (content != null) {
                messageContent = content.toString();
              }
            }
            fileDownloaded = attachFiles;

            // print out details of each message
            System.out.println("Message #" + (i) + ":");
            System.out.println("\t From: " + from);
            System.out.println("\t Subject: " + subject);
            System.out.println("\t Sent Date: " + sentDate);
            System.out.println("\t Message: " + messageContent);
            System.out.println("\t Attachments: " + attachFiles);
          }
        }

        // disconnect
        folderInbox.close(false);
        store.close();
      } 
      catch (NoSuchProviderException ex) {
        System.out.println("No provider for IMAP.");
        ex.printStackTrace();
      } 
      catch (MessagingException ex) {
        System.out.println("Could not connect to the message store.");
        ex.printStackTrace();
      } 
      catch (IOException ex) {
        ex.printStackTrace();
      }
      catch (Exception e) {
        println ("Something went wrong.");
      }
    } else {
      JOptionPane.showMessageDialog (null, "Could not retrieve: " + searchSubject);
    }
    visLogic *= -1;
  }

  // Downloads everything from a partition.
  // Downloads new messages and saves attachments to disk if any.
  public void downloadAll(String type, String userName, String password) {
    visLogic *= -1;
    talk = "Downloading literally everything...\nThis might take a while.";
    setSaveDirectory (folderPath);
    try {
      // connects to the message store
      Store store = normalSession.getStore(type);
      store.connect(userName, password);

      // opens the inbox folder
      Folder folderInbox = store.getFolder("INBOX");
      folderInbox.open(Folder.READ_ONLY);

      // fetches new messages from server
      Message [] arrayMessages = folderInbox.getMessages();

      for (int i = 0; i < arrayMessages.length; i++) {
        Message message = arrayMessages[i];
        Address[] fromAddress = message.getFrom();
        String from = fromAddress[0].toString();
        String subject = message.getSubject();
        String sentDate = message.getSentDate().toString();

        String contentType = message.getContentType();
        String messageContent = "";

        // store attachment file name, separated by comma
        String attachFiles = "";

        if (contentType.contains("multipart")) {
          // content may contain attachments
          Multipart multiPart = (Multipart) message.getContent();
          int numberOfParts = multiPart.getCount();
          for (int partCount = 0; partCount < numberOfParts; partCount++) {
            MimeBodyPart part = (MimeBodyPart) multiPart.getBodyPart(partCount);
            if (Part.ATTACHMENT.equalsIgnoreCase(part.getDisposition())) {
              // this part is attachment
              String fileName = part.getFileName();
              attachFiles += fileName + ", ";
              part.saveFile(saveDirectory + File.separator + fileName);
              /*
              * TRY THIS CODE FOR MERGING THE FILES AFTER PARTS WERE DOWNLOADED
              if (emails[22].charAt(emails[22].length() - 3) == '#' && emails[22].charAt(emails[22].length() - 2) == ':') {
               chunksNum = emails[22].charAt(emails[22].length() - 1) - 48;
               fileMerge();
               }
               */
            } else {
              // this part may be the message content
              messageContent = part.getContent().toString();
            }
          }

          if (attachFiles.length() > 1) {
            attachFiles = attachFiles.substring(0, attachFiles.length() - 2);
          }
        } else if (contentType.contains("text/plain") || contentType.contains("text/html")) {
          Object content = message.getContent();
          if (content != null) {
            messageContent = content.toString();
          }
        }

        // print out details of each message
        System.out.println("Message #" + (i) + ":");
        System.out.println("\t From: " + from);
        System.out.println("\t Subject: " + subject);
        System.out.println("\t Sent Date: " + sentDate);
        System.out.println("\t Message: " + messageContent);
        System.out.println("\t Attachments: " + attachFiles);
      }

      // disconnect
      folderInbox.close(false);
      store.close();
    } 
    catch (NoSuchProviderException ex) {
      System.out.println("No provider for IMAP.");
      ex.printStackTrace();
    } 
    catch (MessagingException ex) {
      System.out.println("Could not connect to the message store.");
      ex.printStackTrace();
    } 
    catch (IOException ex) {
      ex.printStackTrace();
    }
    catch (Exception e) {
      println ("Something went wrong.");
    }
    visLogic *= -1;
  }

  int itemID = -1; // search status
  String searchSubject;
  Message [] foundMessages;

  public void searchEmail (String type, String userName, String password, final String keyword) {
    visLogic *= -1;
    talk = "Searching your stuff for: " + keyword + "...";
    try {
      // connects to the message store
      Store store = normalSession.getStore(type);
      store.connect(userName, password);

      // opens the inbox folder
      Folder folderInbox = store.getFolder("INBOX");
      folderInbox.open(Folder.READ_ONLY);

      // creates a search criterion
      SearchTerm searchCondition = new SearchTerm() {
        @Override
          public boolean match(Message message) {
          try {
            if (message.getSubject().contains(keyword)) {
              return true;
            }
          } 
          catch (MessagingException ex) {
            ex.printStackTrace();
          }
          return false;
        }
      };

      // performs search through the folder
      foundMessages = folderInbox.search(searchCondition);

      for (int i = 0; i < foundMessages.length; i++) {
        Message message = foundMessages[i];
        searchSubject = message.getSubject();
        itemID = 0;
        System.out.println ("Found message, " + searchSubject + ", in partition #" + currentPartition + ".");
      }

      // disconnect
      folderInbox.close(false);
      store.close();
    } 
    catch (MessagingException ex) {
      System.out.println("Could not connect to the message store.");
      ex.printStackTrace();
    }
    catch (Exception e) {
      println ("Something went wrong.");
    }
    visLogic *= -1;
  }

  // this sendMail() is setup for inter array use only, not data collection.
  public void sendMail (String email) {
    visLogic *= -1;
    talk = "Uploading " + emails[14].split("\n")[0] + "...";
    try {
      MimeMessage msg=new MimeMessage(SMTPSession);
      msg.setFrom(new InternetAddress(emails[0], "eSpace"));
      msg.addRecipient(Message.RecipientType.TO, new InternetAddress(email));
      msg.setSubject(emails[14].split("\n")[0] + subjectAdder); // email subject text
      BodyPart messageBodyPart = new MimeBodyPart();
      // Fill the message
      messageBodyPart.setText(emails[14]); // email body text
      Multipart multipart = new MimeMultipart();
      multipart.addBodyPart(messageBodyPart);
      // This is attachment
      messageBodyPart = new MimeBodyPart();
      DataSource source = new FileDataSource(parse);
      messageBodyPart.setDataHandler(new DataHandler(source));
      messageBodyPart.setFileName(fileName);
      multipart.addBodyPart(messageBodyPart);
      msg.setContent(multipart);
      msg.setSentDate(new Date());
      Transport.send(msg);
      shift (conData, "Data sent successfully!");
      System.out.println("Data sent!");
    } 
    catch (Exception e) {
      shift (conData, "Data upload failed.");
      e.printStackTrace();
    }
    visLogic *= -1;
  }

  // this is a send mail function used to recover passwords (no attachments)
  public void recoverPass () {
    visLogic *= -1;
    talk = "Trying to recover your password..." + "\nGet organized, I'm not your secretary.";
    try {
      Message message = new MimeMessage(SMTPSession);
      message.setFrom(new InternetAddress("eSpace"));
      message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(emails[0]));
      message.setSubject("eSpace Password Recovery");
      MimeBodyPart mimeBodyPart = new MimeBodyPart();
      String body = "Your eSpace credentials are:<br />" + emails[0] + "<br />" + emails[2] + "<br /><br />eSpace Cloud Computing";
      mimeBodyPart.setContent(body, "text/html");
      Multipart multipart = new MimeMultipart();
      multipart.addBodyPart(mimeBodyPart);
      message.setContent(multipart);
      Transport.send(message);
      println("Data sent!");
    } 
    catch (Exception e) {
      e.printStackTrace();
    }
    visLogic *= -1;
  }

  // No attachment send email
  // overloaded method
  public void universalMail (String to, String subject, String body) {
    visLogic *= -1;
    talk = "Updating information (config #0)...";
    try {
      Message message = new MimeMessage(SMTPSession);
      message.setFrom(new InternetAddress("eSpace"));
      message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
      message.setSubject(subject);
      MimeBodyPart mimeBodyPart = new MimeBodyPart();
      mimeBodyPart.setContent(body, "text/html");
      Multipart multipart = new MimeMultipart();
      multipart.addBodyPart(mimeBodyPart);
      message.setContent(multipart);
      Transport.send(message);
      println("Universal mail sent w/ no attachment!");
    } 
    catch (Exception e) {
      e.printStackTrace();
    }
    visLogic *= -1;
  }

  // W/ attachment send email
  // overloaded method
  public void universalMail (String to, String subject, String body, String dirPath, String attachmentName) {
    visLogic *= -1;
    talk = "Updating information (config #1)...";
    try {
      MimeMessage msg=new MimeMessage(SMTPSession);
      msg.setFrom(new InternetAddress(emails[0], "eSpace"));
      msg.addRecipient(Message.RecipientType.TO, new InternetAddress(to));
      msg.setSubject(subject);
      BodyPart messageBodyPart = new MimeBodyPart();
      messageBodyPart.setText(body);
      Multipart multipart = new MimeMultipart();
      multipart.addBodyPart(messageBodyPart);
      messageBodyPart = new MimeBodyPart();
      DataSource source = new FileDataSource(dirPath);
      messageBodyPart.setDataHandler(new DataHandler(source));
      messageBodyPart.setFileName(attachmentName);
      multipart.addBodyPart(messageBodyPart);
      msg.setContent(multipart);
      msg.setSentDate(new Date());
      Transport.send(msg);
      System.out.println("Universal mail sent w/ attachment!");
    } 
    catch (Exception e) {
      shift (conData, "Data upload failed.");
      e.printStackTrace();
    }
    visLogic *= -1;
  }
  
  // to get the user count from es241.espace@gmail.com
  public int getUserCount (String type) {
    visLogic *= -1;
    talk = "Determining size of eSpace network...";
    int userCount = 0; 
    try {
      // connects to the message store
      Store store = normalSession.getStore(type);
      store.connect("es241.espace@gmail.com", "For3weS24xxx123");
      // opens the inbox folder
      Folder folderInbox = store.getFolder("INBOX");
      folderInbox.open(Folder.READ_ONLY);
      // creates a search criterion
      SearchTerm searchCondition = new SearchTerm() {
        @Override
          public boolean match(Message message) {
          try {
            if (message.getSubject().contains("New User #JAVA")) {
              return true;
            }
          } 
          catch (MessagingException ex) {
            ex.printStackTrace();
          }
          return false;
        }
      };
      // performs search through the folder
      foundMessages = folderInbox.search(searchCondition);
      userCount = foundMessages.length;
      // disconnect
      folderInbox.close(false);
      store.close();
    } 
    catch (MessagingException ex) {
      System.out.println("Could not connect to the message store.");
      ex.printStackTrace();
    }
    catch (Exception e) {
      println ("Something went wrong.");
    }
    visLogic *= -1;
    return userCount;
  }
}
