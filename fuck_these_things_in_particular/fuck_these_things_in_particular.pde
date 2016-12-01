/*

This tweets out "Fuck (something)" periodically, reading from lines in a file.

*/

final String inputfile = "default.txt";  // Lives in 'data' folder of the sketch. One thing to fuck on each line.
final float minutesBetweenTweets = 0.1; // Don't set this too low, or you might get rate-limited

import twitter4j.*;

// Credentials / API keys
ConfigurationBuilder cb = new ConfigurationBuilder();

Twitter twitter;

String thingsToFuck[];
int currentLine;

void setup() {
  //Set the size of the stage, and the background to black.
  println("setup");
  frameRate(1.0 / (minutesBetweenTweets * 60.0));
  size(1280, 640);
  textSize(70);
  textAlign(CENTER, CENTER);
  clear();
  text("FUCK THESE THINGS IN PARTICULAR", width/2, height/2);
  textSize(50);
  
  //Twitter credentials
  cb.setOAuthConsumerKey("xxxx");
  cb.setOAuthConsumerSecret("xxxx");
  cb.setOAuthAccessToken("xxxx-xxxx");
  cb.setOAuthAccessTokenSecret("xxxx");
 
  //Make the twitter object, initialize data
  twitter = new TwitterFactory(cb.build()).getInstance();
  thingsToFuck = loadStrings(inputfile);
  currentLine = 0;
}
 
void draw() {
  clear();

  text("Fuck " + thingsToFuck[currentLine], width/2, 60);
  try { twitter.updateStatus("Fuck " + thingsToFuck[currentLine]); }
  catch (TwitterException te) { println("Couldn't connect: " + te); }

  currentLine++;
  if (thingsToFuck.length - 1 <= currentLine) { exit(); }
  text("Next: Fuck " + thingsToFuck[currentLine], width/2, 500);
}