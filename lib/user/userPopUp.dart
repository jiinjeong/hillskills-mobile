/* ************************************************************************
 * FILE : userPopUp.dart
 * DESC : Popup menu showcasing a single user
 * ************************************************************************
 */

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:HillSkills/data/dynamicGlobals.dart';
import 'package:HillSkills/data/globalWidgets.dart';
import 'package:HillSkills/data/globals.dart';
import 'package:HillSkills/utils/backend/userInteraction.dart';
import 'package:HillSkills/utils/navigation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:HillSkills/utils/backend/chatInteraction.dart';


// Takes Post object as parameter
class UserPopUpPage extends StatefulWidget {
  final UserAccount user;
  UserPopUpPage(this.user);

  @override
  UserPopupPageState createState() => new UserPopupPageState();
}

// Builds dynamic popup object
class UserPopupPageState extends State<UserPopUpPage> {

  User currentUser = FirebaseAuth.instance.currentUser;
  bool isAdmin = false;

  @override
  void initState() {
    super.initState();
    loadCurrentUser();
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
  bool checkifOwner(user) {
    return (user.id == currentUser.uid);
  }

  Widget messageOrEditOption(user) {
    return checkifOwner(user) ? Container() : messageButton(user);
  }

  Future<void> newChat(String otherUserId) async {
    Chat chat = await ChatInteraction().newChat(otherUserId);
    locator<NavigationService>().navigateWithParameters('/chat', chat);
  }

  // Floating button to message user
  Container messageButton(user) {
    return Container(
      alignment: Alignment.bottomRight,
      child: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: () {
          if (user != null) newChat(user.id);
        },
      ),
    );
  }

  Widget addAdminButton(user) {
    return isAdmin ? adminButton(user) : Container();
  }

  // Floating button to edit post
  Container adminButton(user) {
    return Container(
      alignment: Alignment.bottomLeft,
      child: FloatingActionButton.extended(
        icon: Icon(Icons.admin_panel_settings_outlined),
        label: Text("Admin"),
        onPressed: () async {

          AlertDialog postAdminPopUp = await generateUserAdminPopUp(user);

          showDialog(
            context: context,
            builder: (BuildContext context) => postAdminPopUp
          );
        },
      ),
    );
  }

  // Clickable username button
  Material userButton(UserAccount user) {
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
                user.userName,
                style: TextStyle(color: Colors.white)
              ))
            ),
          ),
          onTap: () {
            // Navigates to either own profile or the other user's profile
            if (user != null)
              locator<NavigationService>().navigateWithParameters(
                '/profile',
                user
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
  makeUserPopupContent(UserAccount user) {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          userButton(user),
          SizedBox(height: 100),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              addAdminButton(user),
              messageOrEditOption(user),
            ]
          )
        ],
      )
    );
  }

  // Builds widget
  @override
  Widget build(BuildContext context) {
    return makeUserPopupContent(this.widget.user);
  }
}
