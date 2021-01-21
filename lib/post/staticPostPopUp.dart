/* ************************************************************************
 * FILE : saticPostPopUp.dart
 * DESC : Popup menu showcasing a single post
 * ************************************************************************
 */

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:HillSkills/data/dynamicGlobals.dart';
import 'package:HillSkills/data/globalWidgets.dart';
import 'package:HillSkills/data/globals.dart';
import 'package:HillSkills/utils/backend/userInteraction.dart';


// Takes Post object as parameter
class StaticPostPopupPage extends StatefulWidget {
  final Map<String, dynamic> postContents;
  StaticPostPopupPage(this.postContents);

  @override
  StaticPostPopupPageState createState() => new StaticPostPopupPageState();
}

// Builds dynamic popup object
class StaticPostPopupPageState extends State<StaticPostPopupPage> {

  Map<String, dynamic> postContents;
  UserAccount postAuthor;
  String username = '';

  @override
  void initState() {
    super.initState();
    loadPostAuthor();
    this.postContents = this.widget.postContents;
  }

  void loadPostAuthor() async {
    postAuthor = await UserInteraction().loadSingleUser(this.widget.postContents["author"]);
    username = postAuthor.userName;
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

  // Floating button to message user
  Container messageButton() {
    return Container(
      alignment: Alignment.bottomRight,
      child: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: () {},
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
              child: Center(child: Text(
                username,
                style: TextStyle(color: Colors.white)
              ))
            ),
          ),
          onTap: () {
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
  makePostPopupContent() {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          userButton(),
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
                        child: postTitle(this.postContents["title"]))),

                      // Category Icon
                      Expanded(child: Container(
                        alignment: Alignment.topRight,
                        padding: EdgeInsets.only(left: 13),
                        child: postCategoryIcon(this.postContents["category"])))
                    ]
                  ),
                  SizedBox(height: 10),
                  postDescription(this.postContents["description"]),
                ]
              ),
            )
          ),
          SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              messageButton(),
            ]
          )
        ],
      )
    );
  }

  // Builds widget
  @override
  Widget build(BuildContext context) {
    return makePostPopupContent();
  }
}
