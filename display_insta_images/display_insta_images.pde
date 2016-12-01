String apiKey = "xxxxxxx"; // insert valid API key
String tagSearch;
JSONArray instagramData;
ArrayList<instaPic> instaCache = new ArrayList<instaPic>(); 

void setup() {
  println("setup");
  frameRate(0.2);
  size(1280, 640);
  tagSearch = "pizza";
}

void draw() {
  // pull new data, then try to update the cache with the new data. if there's anything new to display, display it
  instagramData = loadJSONObject("https://api.instagram.com/v1/tags/"+tagSearch+"/media/recent?count=20&access_token="+apiKey).getJSONArray("data");
  if (updateInstaCache(instagramData)){
    displayImages();
  }
}

boolean updateInstaCache(JSONArray data){

  // updates the cache based on new data; returns true if anything changed, false otherwise
  boolean retVal = false; 

  for (int i = data.size() - 1; i >= 0; i--) { // iterate through the images, starting at the last one
    String imgId = data.getJSONObject(i).getString("id"); // instagram's id for the image

    boolean imgIsCached = false; // assume the image isn't in the cache yet
    for (instaPic pic : instaCache){ // iterate through the cache looking for a matching id
      if (pic.id.equals(imgId)) {imgIsCached = true;} 
    }

    if (!imgIsCached) {
      instaCache.add(0,new instaPic(imgId,loadImage(data.getJSONObject(i).getJSONObject("images").getJSONObject("low_resolution").getString("url"), "png")));
      retVal = true; // make sure we return true if we updated the cache
      println("imgId " + imgId + " added.");
    } else {println("imgId " + imgId + " already exists.");}
  }

  while (instaCache.size() > 20) {instaCache.remove(20);} // trim the cache down, oldest images first. we keep more than we display, just in case

  return retVal;
}

void displayImages() {
  // display the first 8 images in instaCache
  int i = 0;
  for (int a = 0; a < 1280; a = a+320) {
    for (int b = 0; b < 640; b = b+320) {
      image(instaCache.get(i).img, a, b);
      i++;
      if (i == instaCache.size()) {i=0;} // start back at index 0 if we get to an element that doesn't exist
    }
  }
}

class instaPic {
  // simple class that stores an Instagram image and its associated ID
  String id;
  PImage img;

  instaPic(String id,PImage img){
      this.id = id;
      this.img = img;
  }
}