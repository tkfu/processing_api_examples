/*

This is a silly little sketch that takes a single artist as an input, tweets out "Fuck [artist]",
then finds a similar artist, and tweets out "Fuck [artist2]". It keeps on doing this until you 
tell it to stop, or until it can't find any more sufficiently similar artists.

You'll need to set up a twitter app at https://apps.twitter.com/ and put in your credentials, 
and also grab an API key for last.fm (http://www.last.fm/api/intro).

*/

final String startingArtist = "beatles";
final float minutesBetweenTweets = 0.1; // Don't set this too low, or you might get rate-limited
final float minimumMatchLevel = 0.4;    // the minimum similarity score for bands to be considered related; set it very low or 0 and it will run forever.

import twitter4j.*;

// Credentials / API keys
ConfigurationBuilder cb = new ConfigurationBuilder();
String lfmAPIKey = "xxxx"; // http://www.last.fm/api/intro

Twitter twitter;
ArrayList<LastfmArtist> fuckedArtists = new ArrayList<LastfmArtist>();
LastfmArtist currentArtist;

void setup() {
  //Set the size of the stage, and the background to black.
  println("setup");
  frameRate(1.0 / (minutesBetweenTweets * 60.0));
  size(1280, 640);
  textSize(80);
  textAlign(CENTER, CENTER);
  clear();
  text("FUCK YOUR FAVOURITE BAND", width/2, height/2);
  textSize(50);
  
  //Twitter credentials
  cb.setOAuthConsumerKey("xxxx");
  cb.setOAuthConsumerSecret("xxxx");
  cb.setOAuthAccessToken("xxxx-xxxx");
  cb.setOAuthAccessTokenSecret("xxxx");
 
  //Make the twitter object and prepare the query
  twitter = new TwitterFactory(cb.build()).getInstance();
  
  currentArtist = searchArtist(startingArtist);

}
 
void draw() {
  clear();
  text("Fuck " + currentArtist.name, width/2, 60);
  try { twitter.updateStatus("Fuck " + currentArtist.name); }
  catch (TwitterException te) { println("Couldn't connect: " + te); }
  
  fuckedArtists.add(currentArtist);
  try { currentArtist = getNewArtistToFuck(currentArtist); } catch (Exception e) {
    try { twitter.updateStatus("I ran out of music to hate on. For now."); */println("I ran out of music to hate on. For now." + e); exit(); }
    catch (TwitterException te) { println("Couldn't connect: " + te + "exiting"); exit(); }
  }
  text("Next: Fuck " + currentArtist.name, width/2, 500);
}

class LastfmArtist {
  // simple class that stores an artist's name and their associated musicbrainz id
  String name;
  String mbid;

  LastfmArtist(String name,String mbid){
      this.name = name;
      this.mbid = mbid;
  }
  
  LastfmArtist(processing.data.JSONObject artist){
    this.name = artist.getString("name");
    try { this.mbid = artist.getString("mbid"); }
    catch (Exception e) { this.mbid = ""; }
  }
  
  @Override
  public boolean equals(Object object){
    boolean eq = false;

    if (object != null && object instanceof LastfmArtist)
    {
      eq = this.mbid.equals(((LastfmArtist) object).mbid)
           && this.name.equals(((LastfmArtist) object).name);
    } 
      return eq;
    }
    
   @Override
   public String toString() {
     return this.name + " (" + this.mbid + ")";
   }
}

LastfmArtist getNewArtistToFuck(LastfmArtist oldArtist) throws Exception {
  processing.data.JSONArray data;
  if (!oldArtist.mbid.equals("")) { // search by id first
    data = loadJSONObject("http://ws.audioscrobbler.com/2.0/?method=artist.getsimilar" +
                                      "&mbid=" + oldArtist.mbid + 
                                      "&api_key=" + lfmAPIKey + 
                                      "&format=json" +
                                      "&limit=50")
                                      .getJSONObject("similarartists")
                                      .getJSONArray("artist");
  } else { //fall back to name if id doesn't exist
    data = loadJSONObject("http://ws.audioscrobbler.com/2.0/?method=artist.getsimilar" +
                                      "&artist=" + oldArtist.name.replaceAll(" ", "%20") + 
                                      "&api_key=" + lfmAPIKey + 
                                      "&format=json" +
                                      "&limit=50")
                                      .getJSONObject("similarartists")
                                      .getJSONArray("artist");
  }
  
  for (int i = 0; i < data.size(); i++) { 
    if (data.getJSONObject(i).getFloat("match") > minimumMatchLevel) {
      LastfmArtist artistToFuck = new LastfmArtist(data.getJSONObject(i));
  
      //make sure we don't repeat ourselves or get into a loop
      if ( !fuckedArtists.contains(artistToFuck) ) { 
        return artistToFuck;
      };
    } else {println("Match level with " + data.getJSONObject(i).getString("name") + " too low: " + data.getJSONObject(i).getFloat("match"));}
  }
  throw new Exception("I ran out of music to hate on.");
}

LastfmArtist searchArtist(String artist) {
  
  return new LastfmArtist(loadJSONObject("http://ws.audioscrobbler.com/2.0/?method=artist.search" +
                                     "&artist=" + artist.replaceAll(" ", "%20") + 
                                     "&api_key=" + lfmAPIKey + 
                                     "&format=json&limit=1")
                                     .getJSONObject("results")
                                     .getJSONObject("artistmatches")
                                     .getJSONArray("artist")
                                     .getJSONObject(0));
}