/* ************************************************************************
 * FILE : postCard.dart
 * DESC : Constructs a visual representation of a postCard item
 * ************************************************************************
 */

import 'package:flutter/material.dart';
import 'package:HillSkills/data/dynamicGlobals.dart';
import 'package:HillSkills/data/globalWidgets.dart';
import 'package:HillSkills/utils/backend/accountManagement.dart';
import 'package:HillSkills/utils/backend/adminInteraction.dart';
import 'package:HillSkills/utils/backend/feedInteraction.dart';
import 'package:HillSkills/data/globals.dart';
import 'package:HillSkills/utils/navigation.dart';
import 'package:HillSkills/utils/dateFormatting.dart';
import 'package:flutter/cupertino.dart';


// CITE: https://medium.com/swlh/use-valuenotifier-like-pro-6441d9ddad05
// DESC: Explained boolean notifiers
Map<Key, LikeNotifier> likeNotifiers = {};
class LikeNotifier extends ValueNotifier<bool> {

  Key key;
  LikeNotifier(Post post, {@required this.key}) : super(post.liked);

  void toggle() {
    value = !value;
  }

  void clear() {
    if(!this.hasListeners)
      likeNotifiers.remove(this.key);
  }
}

PostCard createPostCard(Post post) {
  return PostCard(post, key: ValueKey(post.feedNum.toString() + '*FEED*' + post.id));
}

class PostCard extends StatefulWidget {
  final Post post;

  // Keys differentiate widgets
  PostCard(this.post, {@required Key key}) : super(key: key);

  @override
  PostCardState createState() => PostCardState();
}

class PostCardState extends State<PostCard> {

  LikeNotifier liked;
  bool owner;

  @override
  void initState() {
    super.initState();

    liked = likeNotifiers.containsKey(this.widget.key)
      ? likeNotifiers[this.widget.key]
      : likeNotifiers[this.widget.key] = LikeNotifier(
        this.widget.post,
        key: this.widget.key
      );

    owner = AccountManagement().currentUserId() == this.widget.post.author;

    liked.addListener(setMyState);
  }

  @override
  void dispose() {
    super.dispose();
    liked.removeListener(setMyState);
    liked.clear();
  }

  void setMyState() {
    setState(() {});
  }

  // Toggles like status
  void changeLikedStatus() {

    // Like / un-like
    liked.value
      ? getFeed(this.widget.post.feedNum).unlikePost(this.widget.post.id)
      : getFeed(this.widget.post.feedNum).likePost(this.widget.post.id);
      
    // Change value
    this.widget.post.liked = true;
    liked.toggle();
  }

  // Text for popup
  Text popUpText(String textStr) {
    return Text(textStr, style: TextStyle(
      color: currentTheme.cursorColor(),
      fontSize: 16,
      fontWeight: FontWeight.normal
    ));
  }

  // Generates a popup allowing user to report or like or delete
  SimpleDialog postControlsPopup() {
    return SimpleDialog(
      children: [

        // Like
        TextButton(
          onPressed:  () {
            changeLikedStatus();
            locator<NavigationService>().pop();
          },
          child: popUpText(liked.value ? "Unbookmark Post" : "Bookmark Post")
        ),


        owner
          // Delete
          ? TextButton(
            onPressed:  () => showDialog(
              context: context,
              builder: (BuildContext context) => generateDeletePopUp(
                this.widget.post.id,
                feedNum: this.widget.post.feedNum,
                dialogsBelow: 1
              )
            ),
            child: popUpText("Delete Post")
          )

          // Report
          : TextButton(
            onPressed:  () {
              AdminInteraction().reportPost(
                this.widget.post,
                this.widget.post.feedNum
              );
              locator<NavigationService>().pop();
            },
            child: popUpText("Report Post")
          ),

          owner
            // Edit
            ? TextButton(
              onPressed:  () {
                locator<NavigationService>().pop();
                locator<NavigationService>()
                  .navigateWithParameters('/edit', this.widget.post);
              },
              child: popUpText("Edit Post")
            )
            : Container()
      ]
    );
  }

  // Create a clickbale icon to like and unlike a post
  likeIcon(){
    return InkWell(
      borderRadius: BorderRadius.all(Radius.circular(100)),
      child: Container(
        padding: EdgeInsets.all(3),
        child: Icon(
          liked.value ? Icons.star : Icons.star_outline,
          color: Colors.white
        )
      ),
      onTap: () => changeLikedStatus()
    );
  }

  // Makes content for the cards, using Post item
  makePostContent(BuildContext context, String id, int feedNum) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[

        // First row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            // Category Icon
            Padding(
              padding: EdgeInsets.only(right: 10.5),
              child: categoryIcons[this.widget.post.category]
            ),

            // Title
            Expanded(flex: 10,
              child: Text(this.widget.post.title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 19
                )
              )
            ),

            // Liked
            likeIcon(),

            // Report
            InkWell(
              borderRadius: BorderRadius.all(Radius.circular(100)),
              child: Container(
                padding: EdgeInsets.all(3),
                child: Icon(Icons.more_vert, color: Colors.white)
              ),
              onTap: () => showDialog(
                context: context,
                builder: (BuildContext context) => postControlsPopup()
              )
            )
          ]
        ),

        // Description
        Expanded(
          flex: 3,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                TextStyle currentTextStyle = Theme.of(context).textTheme.bodyText1;
                int maxLines = ((constraints.maxHeight / currentTextStyle.fontSize) * 0.8).floor();
                maxLines = maxLines > 0 ? maxLines : 1;
                return Text(
                  this.widget.post.description,
                  overflow: TextOverflow.ellipsis,
                  maxLines: maxLines,
                  style: TextStyle(color: Colors.white)
                );
              }
            )
          )
        ),

        // Date
        Expanded(child: Container(
          alignment: Alignment.bottomRight,
          child: Text(
            niceDate(this.widget.post.dateTimeStr),
            style: TextStyle(color: Colors.white, fontSize: 13)
          )
        )),
  
      ]
    );
  }

  // Builds widget
  @override
  Widget build(BuildContext context) {
    return Container(

      // Style for card
      margin: EdgeInsets.only(top: 10.0, bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(new Radius.circular(10.0)),
        gradient: this.widget.post.feedNum == 0
          ? currentTheme.lookingGradient()
          : currentTheme.offeringGradient()
      ),
      height: 150.0,

      // Click and hold animations for card
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.all(new Radius.circular(10.0)),

          // Generates card content
          child: Container(
            margin: EdgeInsets.all(14),
            child: SizedBox(
              child: makePostContent(context, this.widget.post.id, this.widget.post.feedNum)
            )
          ),
          onTap: () => locator<NavigationService>().launchPost(this.widget.post),

          // Allows owner to delete
          onLongPress: () => showDialog(
            context: context,
            builder: (BuildContext context) => postControlsPopup()
          )
        )
      ),
    );
  }
}
