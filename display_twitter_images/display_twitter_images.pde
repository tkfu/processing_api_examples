import java.util.Date;
import twitter4j.*;
//Build an ArrayList to hold all of the words that we get from the imported tweets
ArrayList<String> words = new ArrayList();
QueryResult result;
ConfigurationBuilder cb = new ConfigurationBuilder();
Twitter twitter;
Query query;
ArrayList<twitterPic> twitterCache = new ArrayList<twitterPic>(); 

void setup() {
  //Set the size of the stage, and the background to black.
  println("setup");
  frameRate(0.2);
  size(1280, 640);
  
  //Credentials
  cb.setOAuthConsumerKey("xxxx");
  cb.setOAuthConsumerSecret("xxxx");
  cb.setOAuthAccessToken("xxxx-xxxx");
  cb.setOAuthAccessTokenSecret("xxxx");
 
  //Make the twitter object and prepare the query
  twitter = new TwitterFactory(cb.build()).getInstance();
  query = new Query("#OniriaClimactic");
  query.setCount(20);
}
 
void draw() {
  if (updateTwitterCache()){
    displayImages();
  }
}

boolean updateTwitterCache() {
  boolean retVal = false; 
  
  try {
    result = twitter.search(query);
    ArrayList tweets = (ArrayList) result.getTweets();
 
    for (int i = 0; i < tweets.size(); i++) {
      Status t = (Status) tweets.get(i);
      String user = t.getUser().getName();
      String msg = t.getText();
      for (MediaEntity mediaEntity : t.getMediaEntities()) {
        if (mediaEntity.getType().equals("photo")) {
          String imgUrl = mediaEntity.getMediaURL();
          boolean imgIsCached = false;
          
          for (twitterPic pic : twitterCache){ // iterate through the cache looking for a matching id
            if (pic.url.equals(imgUrl)) {imgIsCached = true;} 
          }
          
          if (!imgIsCached) {
          twitterCache.add(0,new twitterPic(imgUrl,getSquareImage(loadImage(imgUrl, "png"),320)));
          retVal = true; // make sure we return true if we updated the cache
          println("imgUrl " + imgUrl + " added.");
          } else {println("imgUrl " + imgUrl + " already exists.");}
        }
        
      }
      Date d = t.getCreatedAt();
    };
  }
  catch (TwitterException te) {
    println("Couldn't connect: " + te);
  };
  
  return retVal;
}

void displayImages() {
  // display the first 8 images in twitterCache
  int i = 0;
  for (int a = 0; a < 1280; a = a+320) {
    for (int b = 0; b < 640; b = b+320) {
      image(twitterCache.get(i).img, a, b);
      i++;
      if (i == twitterCache.size()) {i=0;} // start back at index 0 if we get to an element that doesn't exist
    }
  }
}

PImage getSquareImage(PImage img, int size){
  
  PImage returnImg = new PImage();
  
  if (img.width == img.height) { returnImg = img; }
  
  if (img.width > img.height) {
    int start = (img.width-img.height)/2;
    returnImg = img.get(start,0,img.height,img.height);
  }

  if (img.width < img.height) {
    int start = (img.height-img.width)/2;
    returnImg = img.get(0,start,img.width,img.width);
  }
  returnImg.resize(size,size);
  return returnImg;
}

class twitterPic {
  // simple class that stores an Twitter image and its associated ID
  String url;
  PImage img;

  twitterPic(String url,PImage img){
      this.url = url;
      this.img = img;
  }
}