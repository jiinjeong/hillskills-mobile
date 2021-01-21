/* ************************************************************************
 * FILE : socialFeed.dart
 * DESC : Builds a social feed page, retrieving posts from 
 *        social media with certain hashtag.
 * ************************************************************************
 */

import 'package:flutter/material.dart';
import 'package:HillSkills/data/globalWidgets.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'dart:convert';
import 'package:twitter_api/twitter_api.dart';
import 'package:HillSkills/data/globals.dart';
import 'package:HillSkills/utils/backend/apiCredentials.dart';

const MAXPOSTS = 20;

// Class for social post info
class SocialPost {
  final int id;
  final String name;
  final String username;
  final String profilePic;
  final String content;
  final String imageLink;
  final String date;
  final int likes;
  final int retweets;

  SocialPost({this.id, this.name, this.username, this.profilePic,
              this.content, this.imageLink, this.date,
              this.likes, this.retweets});

  // Maps into JSON format
  factory SocialPost.fromJson(Map<String, dynamic> json) {
    return SocialPost(
      id: json[ID],
      name: json[USER][NAME],
      username: "@" + json[USER][SCREENNAME],
      profilePic: json[USER][PROFILEPIC],
      content: json[FULLTEXT],
      imageLink: json[ENTITIES].containsKey(MEDIA) ? 
        json[ENTITIES][MEDIA][0][MEDIASRC] : '',
      date: json[CREATEDDATE],
      likes: json[LIKES],
      retweets: json[RETWEET],
    );
  }
}

class SocialFeed extends StatefulWidget {
  @override
  SocialFeedState createState() => new SocialFeedState();
}

class SocialFeedState extends State<SocialFeed> {
  Future<List<SocialPost>> allfutureSocialPosts;
  TwitterCredential userTokens;

  // Initializes state of social feed.
  @override
  void initState() {
    super.initState();
    getTwitterCred();  // Gets Twitter credentials
    allfutureSocialPosts = getSocialPost();  // Gets social posts using credentials.
    currentTheme.addListener(setMyState);
  }

  @override
  void dispose() {
    super.dispose();
    currentTheme.removeListener(setMyState);
  }

  void setMyState() {
    setState(() {});
  }

  // Gets Twitter credentials from the backend.
  Future<void> getTwitterCred() async {
    TwitterCredential tokens = await apiCredentials.getTwitterCredfromFb();
    setState(() {
      userTokens = tokens;
    });
  }

  // Refreshes social feed.
  Future<void> _refreshSocialFeed() async {
    allfutureSocialPosts = getSocialPost();
    setState(() {});
  }
  
  // Gets social post with the twitter credentials from the backend.
  Future<List<SocialPost>> getSocialPost() async {
    List<SocialPost> allSocialPosts = [];
    await getTwitterCred();

    // Authorization info for Twitter API
    final _twitterOauth = new twitterApi(
      consumerKey: userTokens.apiKey,
      consumerSecret: userTokens.apiKeySecret,
      token: userTokens.accessToken,
      tokenSecret: userTokens.accessTokenSecret
    );

    // Make the request to Twitter API
    Future twitterRequest = _twitterOauth.getTwitterRequest(
      'GET',  // HTTP request type
      'search/tweets.json',  // Endpoint 
      options: {  // Query parameters
        'q': '#' + dynamicGlobals.hashtag,
        'result-type': 'mixed',
        'count': MAXPOSTS.toString(),
        'tweet_mode': 'extended',
      },
    );

    // Sends a HTTP request to Twitter API
    var response = await twitterRequest;

    // Check if the server returns a 200 OK response
    if (response.statusCode == 200) {
      var responseJson = jsonDecode(response.body)[STATUSES];
      // Adds each social post to our list of social posts.
      for (var i in responseJson) {
        allSocialPosts.add(SocialPost.fromJson(i));
      }
      return allSocialPosts;
    }
    else
      throw Exception('Failed to load post');
  }

  // Single styled card.
  socialCard(SocialPost post, bool last) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 150,
        maxHeight: double.infinity,
      ),
      child: Container(
        margin: new EdgeInsets.all(10.0),
        child: makeSocialContent(post),
        decoration: last
          ? null
          : BoxDecoration(border: Border(
              bottom: BorderSide(color: currentTheme.cardColor())
          ))
      ),
    );
  }

  // Gets only the text content of the post (without the hashtag and post link)
  getOnlyText(content){
    return content.substring(0, content.indexOf('#'));
  }

  // Gets only the hashtag(s) of the post.
  getOnlyHashtag(content){
    var endIndex = content.length;
    if (content.contains('http')) {
      endIndex = content.indexOf('http');
    }
    return content.substring(content.indexOf('#'), endIndex);
  }

  // Makes social feed content for the cards.
  makeSocialContent(SocialPost post) {
    return Stack(children: <Widget>[
      Container(alignment: Alignment.topRight, 
        padding: EdgeInsets.only(right: 13.0, top: 13.0),
        // Icon of the social media
        child: const Icon(MdiIcons.twitter, color: Colors.blue)),

      // Profile Pic
      Container(
        padding: EdgeInsets.only(left: 13.0, top: 13.0),
        child: Image.network(post.profilePic, height: 25)),

      // Author
      Container(
        padding: EdgeInsets.only(left: 45.0, top: 13.0),
        child: Text(post.name,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17))),

      // Username
      Container(alignment: Alignment.topRight, 
        padding: EdgeInsets.only(right: 45.0, top: 13.0),
        child: Text(post.username,
          style: TextStyle(color: Colors.grey, fontSize: 15))),

      // Content of Tweet
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          // Text content
          Container(
            padding: EdgeInsets.only(left: 13.0, top: 48.0, right: 13.0),
            child: Text(getOnlyText(post.content)),
          ),

          // Hashtag
          Container(
            padding: EdgeInsets.only(left: 13.0, top: 5.0, right: 13.0),
            child: Text(getOnlyHashtag(post.content),
              style: TextStyle(color: Colors.blue)),
          ),

          // Image
          Container(
            padding: EdgeInsets.only(left: 13.0, top: 5.0, right: 13.0),
            child: post.imageLink.isEmpty ? Text("") : 
              Center(child: Image.network(post.imageLink, fit: BoxFit.contain)),
          ),

          // Post Details
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              // Likes Icon
              Container(
                padding: EdgeInsets.only(left: 13.0, top: 8.0, right: 10.0, bottom: 12.0),
                child: post.likes != 0
                  ? Icon(
                    MdiIcons.heart,
                    color: Colors.pink
                  )
                  : Icon(
                    MdiIcons.heartOutline,
                  )
              ),

              // Likes-count
              Container(
                padding: EdgeInsets.only(right: 10.0, top: 5.0, bottom: 12.0),
                child: Text(post.likes.toString()),
              ),

              // Date
              Container(
                padding: EdgeInsets.only(top: 5.0, bottom: 12.0),
                child: Text(post.date.substring(0, post.date.indexOf('+'))),
              ),
            ]
          ),
        ],
      ),
    ]);
  }
  
  // Returns a feed (list of social posts)
  feed() {
    return FutureBuilder<List<SocialPost>>(
      future: allfutureSocialPosts,
      builder: (context, snapshot){

        // On error
        if (snapshot.hasError || (snapshot.hasData && snapshot.data.isEmpty)) {
          return ListView(children: [Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50),
              Text("No Tweets", style: TextStyle(fontSize: 22)),
              Text("Please try again later!", style: TextStyle(fontSize: 13)),
            ]
          )]);
        }

        // When data loaded
        if (snapshot.hasData) {
          return Center(
            child: ListView.builder(
              itemCount: snapshot.data.length, 
              itemBuilder: (context, index) {
                SocialPost socialpost = snapshot.data[index];
                return socialCard(socialpost, index == snapshot.data.length - 1);
              }
            )
          );
        }

        // While loading
        return Center(child: CircularProgressIndicator());
      }
    );
  }

  // Builds widget
  @override
  Widget build(BuildContext context) {

    // Provides refresh capabaility
    return HillSkillsRefreshIndicator(
      child: feed(),
      onRefresh: () => _refreshSocialFeed(),
    );
  }
}
