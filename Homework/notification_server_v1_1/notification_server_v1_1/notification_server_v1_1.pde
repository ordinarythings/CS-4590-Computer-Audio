//<import statements here>

import java.util.concurrent.TimeUnit;

import guru.ttslib.*;

import controlP5.*;
import beads.*;

//to use this, copy notification.pde, notification_listener.pde and notification_server.pde from this sketch to yours.
//Example usage below.

//name of a file to load from the data directory
String eventDataJSON1 = "ExampleData_1.json";
String eventDataJSON2 = "ExampleData_2.json";
String eventDataJSON3 = "ExampleData_3.json";

NotificationServer server;
ArrayList<Notification> notifications;

Example example;

static final String MRBROLA_LOCATION = "/usr/lib/x86_64-linux-gnu/mbrola";
TTS tts;

ControlP5 p5;
RadioButton environmentButtons;
color fore = color(255, 255, 255);
color back = color(0, 0, 0);

RadioButton eventStream;

RadioButton tweetButton;
RadioButton emailButton;
RadioButton textButton;
RadioButton missedCallButton;
RadioButton voiceMailButton;

RadioButton batteryButtons;
RadioButton connectionButtons;

Gain g;

void setup() {
  
  size(600, 600);
  
  p5 = new ControlP5(this);

  environmentButtons = p5.addRadioButton("environmentButtons")
    .setPosition(50, 40)
    .setSize(40, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setItemsPerRow(2)
    .setSpacingColumn(80)
    .setSpacingRow(10)
    .setNoneSelectedAllowed(false)
    .addItem("Public Transit", 0)
    .addItem("Jogging", 1)
    .addItem("Party", 2)
    .addItem("Lecturing", 3)
    .activate(2);

  batteryButtons = p5.addRadioButton("batteryButtons")
    .setPosition(300, 120)
    .setSize(40, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setItemsPerRow(2)
    .setSpacingColumn(80)
    .setSpacingRow(10)
    .setNoneSelectedAllowed(false)
    .addItem("Critical Battery", 0)
    .addItem("Low Battery", 1)
    .addItem("Medium Battery", 2)
    .addItem("High Battery", 3)
    .activate(2);

  connectionButtons = p5.addRadioButton("connectionButtons")
    .setPosition(300, 200)
    .setSize(40, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setItemsPerRow(2)
    .setSpacingColumn(80)
    .setSpacingRow(10)
    .setNoneSelectedAllowed(false)
    .addItem("Low Connection", 0)
    .addItem("Medium Connection", 1)
    .addItem("High Connection", 2)
    .activate(2);

  eventStream = p5.addRadioButton("eventStream")
    .setPosition(300, 40)
    .setSize(40, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setItemsPerRow(2)
    .setSpacingColumn(100)
    .setSpacingRow(10)
    .setNoneSelectedAllowed(false)
    .addItem("ExampleData_1.json", 0)
    .addItem("ExampleData_2.json", 1)
    .addItem("ExampleData_3.json", 2)
    .activate(0);

  tweetButton = p5.addRadioButton("tweetButton")
    .setPosition(50, 120)
    .setSize(40, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .addItem("Enable Tweets", 1)
    .activate(0);

  emailButton = p5.addRadioButton("emailButton")
    .setPosition(50, 150)
    .setSize(40, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .addItem("Enable Emails", 1)
    .activate(0);
  
  textButton = p5.addRadioButton("textButton")
    .setPosition(50, 180)
    .setSize(40, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .addItem("Enable Texts", 1)
    .activate(0);

  missedCallButton = p5.addRadioButton("missedCallButton")
    .setPosition(50, 210)
    .setSize(40, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .addItem("Enable Missed Calls", 1)
    .activate(0);

  voiceMailButton = p5.addRadioButton("voiceMailButton")
    .setPosition(50, 240)
    .setSize(40, 20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .addItem("Enable Voice Mails", 1)
    .activate(0);

  p5.addButton("notificationReport")
    .setSize(100, 20)
    .setPosition(50, 300)
    .setLabel("Notification Report");

  
  //loading the event stream, which also starts the timer serving events
  
  /**
   * MBrola has a more pleasant voice than the defualt, but I had to download the voice profile.
   */
  System.setProperty("mbrola.base", MRBROLA_LOCATION);
  tts = new TTS("mbrola_us1");
  tts.setPitch(200);

  
  ac = new AudioContext();
  g = new Gain(ac, 2, .3);

  example = new Example(ac, g);

  // Sleep to let the ac start playing
  try {
    TimeUnit.SECONDS.sleep(2);
  } catch(InterruptedException e) {
    Thread.currentThread().interrupt();
  }

  //START NotificationServer setup
  server = new NotificationServer();
  server.loadEventStream(eventDataJSON1);
  //instantiating a custom class (seen below) and registering it as a listener to the server
  server.addListener(example);
  //END NotificationServer setup 
}

void draw() {
  //this method must be present (even if empty) to process events such as keyPressed()
  background(back);
  stroke(fore);

  text("Sound Environment", 50, 30);
  text("Notification Stream", 300, 30);
  text("Enabled Notifications", 50, 110);
  text("System Status Triggers", 300, 110);
  
}

void keyPressed() {
  //example of stopping the current event stream and loading the second one
  if (key == RETURN || key == ENTER) {
    server.stopEventStream(); //always call this before loading a new stream
    server.loadEventStream(eventDataJSON2);
    println("**** New event stream loaded: " + eventDataJSON2 + " ****");
  }
}

void environmentButtons(int i) {
  if (i != -1) {
    println("Setting to " + Integer.toString(i));
    example.setEnvironment(Environment.values()[i]);
  } else {
    example.setEnvironment(null);
  }
}

void tweetButton(int i) {
  example.updateNotificationPolicy(NotificationType.Tweet, i == 1 ? true : false);
}

void emailButton(int i) {
  example.updateNotificationPolicy(NotificationType.Email, i == 1 ? true : false);
}

void missedCallButton(int i) {
  example.updateNotificationPolicy(NotificationType.MissedCall, i == 1 ? true : false);
}

void textButton(int i) {
  example.updateNotificationPolicy(NotificationType.MissedCall, i == 1 ? true : false);
}

void voiceMailButton(int i) {
  example.updateNotificationPolicy(NotificationType.VoiceMail, i == 1 ? true : false);
}

void batteryButtons(int i) {
  NotificationSound sound;
  if (i == 0) {
    sound = NotificationSound.CRITICAL_BATTERY;
  } else if (i == 1) {
    sound = NotificationSound.LOW_BATTERY;
  } else if (i == 2) {
    sound = NotificationSound.MEDIUM_BATTERY;
  } else {
    sound = NotificationSound.HIGH_BATTERY;
  }
  addInput(getSamplePlayer(sound));
}

void connectionButtons(int i) {
  NotificationSound sound;
  if (i == 0) {
    sound = NotificationSound.LOW_CONNECTION;
  } else if (i == 1) {
    sound = NotificationSound.MEDIUM_CONNECTION;
  } else {
    sound = NotificationSound.HIGH_CONNECTION;
  }
  addInput(getSamplePlayer(sound));
}


void eventStream(int i) {
  //example of stopping the current event stream and loading the second one
  if (key == RETURN || key == ENTER) {
    server.stopEventStream(); //always call this before loading a new stream
    server.loadEventStream(eventDataJSON2);
    println("**** New event stream loaded: " + eventDataJSON2 + " ****");
  }

  String file;
  switch (i) {
    case 0:
      file = eventDataJSON1;
      break;
    case 1:
      file = eventDataJSON2;
      break;
    case 2:
      file = eventDataJSON3;
      break;
    default:
      throw new RuntimeException("Should never get here");
  }
  example.updateNotificationStream(file);
}

void notificationReport(int i) {
  example.getReport();
}

//in your own custom class, you will implement the NotificationListener interface 
//(with the notificationReceived() method) to receive Notification events as they come in
class Example implements NotificationListener {

  private Environment environment;
  private AudioContext ac;
  private Gain masterGain;
  private UserProfile userProfile;
  private String eventDataFile;

  public Example(AudioContext ac, Gain g) {
    //setup here
    this.eventDataFile = eventDataJSON1;
    this.environment = Environment.PARTY;
    this.ac = ac;
    this.masterGain = g;
    this.userProfile = new UserProfile(eventDataJSON1);
    ac.out.addInput(g);
    g.addInput(getSamplePlayer(this.environment, SamplePlayer.LoopType.LOOP_FORWARDS));
    ac.start();
  }
  
  //this method must be implemented to receive notifications
  public synchronized void notificationReceived(Notification notification) { 
    println("<Listener> " + notification.getType().toString() + " notification received at " 
    + Integer.toString(notification.getTimestamp()) + "millis.");
  
    NotificationManager manager = getNotificationManager(notification.getType());
    manager.processNotification(notification, this.userProfile, this.environment);
  }

  public Environment getEnvironment() {
    server.stopEventStream(); //always call this before loading a new stream
    server.loadEventStream(eventDataFile);
    userProfile.rebuild(eventDataFile); 
    return this.environment;
  }

  public void setEnvironment(Environment e) {
    this.environment = e;
    this.masterGain.clearInputConnections();

    println("<Listener> Resetting the environment and event stream");
    g.addInput(getSamplePlayer(this.environment, SamplePlayer.LoopType.LOOP_FORWARDS));
    this.updateNotificationStream(this.eventDataFile);
  }
  
  public void updateNotificationPolicy(NotificationType t, boolean enable) {
    this.userProfile.updateNotificationPolicy(t, enable);
  }

  public void updateNotificationStream(String eventDataFile) {
    println("<Listener> Building a new notification stream for " + eventDataFile); 
    server.stopEventStream(); //always call this before loading a new stream
    server.loadEventStream(eventDataFile);
    userProfile.rebuild(eventDataFile); 
    this.eventDataFile = eventDataFile;
  }

  public synchronized void getReport() {
    this.userProfile.getReport();
  }
}
