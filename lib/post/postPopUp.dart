/* ************************************************************************
 * FILE : postPopUp.dart
 * DESC : Popup menu showcasing a single post
 * ************************************************************************
 */

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:HillSkills/data/dynamicGlobals.dart';
import 'package:HillSkills/data/globalWidgets.dart';
import 'package:HillSkills/utils/backend/feedInteraction.dart';
import 'package:HillSkills/data/globals.dart';
import 'package:HillSkills/utils/backend/userInteraction.dart';
import 'package:HillSkills/utils/navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:HillSkills/utils/backend/chatInteraction.dart';


// Takes Post object as parameter
class PostPopupPage extends StatefulWidget {
  final Post post;
  PostPopupPage(this.post, {Key key}) : super(key: key);

  @override
  PostPopupPageState createState() => new PostPopupPageState();
}

// Builds dynamic popup object
class PostPopupPageState extends State<PostPopupPage> {
  User currentUser = FirebaseAuth.instance.currentUser;
  String userName = '';
  bool isAdmin = false;
  int postAuthorStrikes = 0;
  UserAccount postAuthor;

  @override
  void initState() {
    super.initState();
    loadPostAuthor();
    loadCurrentUser();
  }

  void loadPostAuthor() async {
    postAuthor = await UserInteraction().loadSingleUser(this.widget.post.author);
    userName = postAuthor.userName;
    postAuthorStrikes = postAuthor.strikes;
    setState(() {});
  }

  void loadCurrentUser() async {
    var curr = await UserInteraction().loadSingleUser(currentUser.uid);
    isAdmin = curr.admin;
    setState(() {});
  }

  // Title text widget
  Text postTitle(titleStr) {
    return Text(
      titleStr,
      textAlign: TextAlign.left,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19)
    );
  }

  Widget postCategoryIcon(String category) {
    return Container(
      alignment: Alignment.topRight,
      child: currentTheme.isDarkModeEnabled
      ? categoryIcons[category]
      : blackCategoryIcons[category]
    );
  }

  // Descriptiont text widget
  Text postDescription(descStr) {
    return Text(
      descStr,
      textAlign: TextAlign.left,
      style: TextStyle(fontSize: 14)
    );
  }

  // Check if it is the owner of the post
  bool checkifOwner(id) {
    return (id == currentUser.uid);
  }

  Widget messageOrEditOption(post, id) {
    return checkifOwner(id) ? editButton(post) : messageButton();
  }

  Future<void> newChat(String otherUserId) async {
    Chat chat = await ChatInteraction().newChat(otherUserId);
    locator<NavigationService>().navigateWithParameters('/chat', chat);
  }

  // Floating button to message user
  Container messageButton() {
    return Container(
      alignment: Alignment.bottomRight,
      child: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: () {
          if (postAuthor != null) newChat(postAuthor.id);
        },
      ),
    );
  }

  // Floating button to edit post
  Container editButton(Post post) {
    return Container(
      alignment: Alignment.bottomRight,
      child: FloatingActionButton(
        child: Icon(Icons.edit),
        onPressed: () => locator<NavigationService>()
          .navigateWithParameters('/edit', post)
      ),
    );
  }

  Widget addAdminButton(post) {
    return isAdmin && postAuthor != null ? adminButton(post) : Container();
  }

  // Floating button to edit post
  Container adminButton(Post post) {
    return Container(
      alignment: Alignment.bottomLeft,
      child: FloatingActionButton.extended(
        icon: Icon(Icons.admin_panel_settings_outlined),
        label: Text("Admin"),
        onPressed: () async {

          AlertDialog postAdminPopUp = await generatePostAdminPopUp(
            post.id,
            feedNum: post.feedNum
          );

          showDialog(
            context: context,
            builder: (BuildContext context) => postAdminPopUp
          );
        },
      ),
    );
  }

  // Clickable username button
  Material userButton() {
      return Material(
        borderRadius: BorderRadius.circular(60.0),
        color: PRIMARY_COLOR,
        child: InkWell(
          borderRadius: BorderRadius.circular(60.0),
          child: ListTile(
            leading: Icon(Icons.account_circle, size: 40, color: Colors.white),
            trailing: SizedBox(width: 40),
            title: Container(
              child: Center(child:Text(
                this.userName,
                style: TextStyle(color: Colors.white)
              ))
            ),
          ),
          onTap: () {
            // Navigates to either own profile or the other user's profile
            if (postAuthor != null)
              locator<NavigationService>().navigateWithParameters(
                '/profile',
                postAuthor
              );
          }
        )
      );
  }
  
  // Tags added to post at creation
  postTags(List<String> tagStrs) {
    List<Widget> chips = new List();

    for (String tagText in tagStrs) {
      chips.add(
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: Chip(
            shape: StadiumBorder(
              side: BorderSide(
                color: currentTheme.isDarkModeEnabled
                  ? Colors.white54
                  : Colors.grey[700]
              )
            ),
            backgroundColor: Colors.transparent,
            label: Text(tagText),
          )
        )
      );
    }

    return horizontalChips(chips);
  }

  // Generates main post widget using above methods
  makePostPopupContent(Post post) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          userButton(),
          SizedBox(height: 10.0),
          postTags(post.tags.toArray()),
          SizedBox(height: post.tags.numberEnabled > 0 ? 10.0 : 0),
          Container(
            padding: EdgeInsets.all(10.0),
            child: Material(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      // Title
                      Expanded(flex: 3, child: Container(
                        child: postTitle(post.title))),

                      // Category Icon
                      Expanded(child: Container(
                        alignment: Alignment.topRight,
                        padding: EdgeInsets.only(left: 13),
                        child: postCategoryIcon(post.category)))
                    ]
                  ),
                  SizedBox(height: 10),
                  postDescription(post.description),
                ]
              ),
            )
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              addAdminButton(post),
              messageOrEditOption(post, this.widget.post.author),
            ]
          )
        ],
      )
    );
  }

  // Builds widget
  @override
  Widget build(BuildContext context) {
    return makePostPopupContent(this.widget.post);
  }
}
