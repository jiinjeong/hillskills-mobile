/* ************************************************************************
 * FILE : staticProfile.dart
 * DESC : User profile page displaying one's personal info
 *        with options to edit and log-out.
 * ************************************************************************
 */

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:HillSkills/data/globalWidgets.dart';
import 'package:HillSkills/utils/backend/accountManagement.dart';
import 'package:HillSkills/data/globals.dart';
import 'package:HillSkills/data/dynamicGlobals.dart';
import 'package:HillSkills/utils/backend/userInteraction.dart';

// User profile page widget
class StaticProfilePage extends StatefulWidget {
  final Map<String, dynamic> profileContents;

  StaticProfilePage(this.profileContents);


  @override
  StaticProfilePageState createState() => new StaticProfilePageState();
}

// Dynamic data for profile
class StaticProfilePageState extends State<StaticProfilePage> {

  Map<String, dynamic> profileContents;


  // Loads data belonging to given user
  Future<void> loadData() async {

    // Stops logout error
    if (!AccountManagement().loggedIn())
      return;

    // Images
    //loadPhotos();
  
  }

  /* Future<void> loadPhotos() async {
    await userAccount.loadPhotos();
    setState(() {});
  } */

  
  @override
  void initState() {
    super.initState();
    this.profileContents = this.widget.profileContents;
    loadData();
    currentTheme.addListener(loadData);
  }

  @override
  void dispose() {
    super.dispose();
    currentTheme.removeListener(loadData);
  }


  Widget _buildChips() {
    List<Widget> chips = new List();
    print(this.profileContents["skills"]);
    List<String> skillStrs = SkillTags().fromArray(this.profileContents["skills"]).toArray();

    for (int i = 0; i < skillStrs.length; i++) {

      Chip filterChip = Chip(
        label: Text(
          skillStrs[i],
          style: TextStyle(
            color: currentTheme.isDarkModeEnabled
              ? Colors.white54
              : Colors.grey[700]
          ),
        ),
        backgroundColor: Colors.transparent,
        shape: StadiumBorder(side: BorderSide(
          color: currentTheme.isDarkModeEnabled
            ? Colors.white54
            : Colors.grey[700]
        )),
      );

      chips.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: 2), child: filterChip
      ));
    }

    return horizontalChips(chips);
  }

  showAvatarAndUsername(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
           Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: avatarColors[this.profileContents["avatar"]["color"]],
              ),
              child: Icon(
                skillIcons[this.profileContents["avatar"]["icon"]],
                color: Colors.white,
                size: 120 * 0.475
              )
          ),

          SizedBox(
            height: 10.0,
          ),

          // Username
          Text(
            this.profileContents["username"],
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(height: 14.0),

        ],
      ),
    );
  }

  showTags(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I\'m good at:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600
          )
        ),
        SizedBox(height: 8.0),
        Container(child: _buildChips()),
        SizedBox(height: 14.0)
      ]
    );
  }
  
  showBio(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'A little about myself:',
          style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600
          )
        ),
        SizedBox(height: 8.0),
        Text(
          this.profileContents["bio"],
          style: TextStyle(
            fontSize: 16,
          )
        ),
        SizedBox(height: 14.0),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {

    // Main widget for profile pags
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile At Time Of Strike"),
      ),
      
      // Body is currently static placeholder data -- wil be rewritten
      body:  ListView(
        children: <Widget>[Padding(
          padding: STANDARD_SPACING,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              showAvatarAndUsername(),
              // Bio
              showBio(),
              // Tags
              showTags(),
              // Photos 
            ]
          )
          ),
        ]
      )
    );
  }
}
