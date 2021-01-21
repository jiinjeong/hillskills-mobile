/* ************************************************************************
 * FILE : userCard.dart
 * DESC : Constructs a visual representation of a userCard item
 * ************************************************************************
 */

import 'package:flutter/material.dart';
import 'package:HillSkills/utils/backend/accountManagement.dart';
import 'package:HillSkills/data/globals.dart';
import 'package:HillSkills/utils/backend/userInteraction.dart';
import 'package:HillSkills/utils/navigation.dart';
import 'package:flutter/cupertino.dart';

class UserCard extends StatelessWidget {
  final UserAccount user;

  // Keys differentiate widgets
  UserCard(this.user);
  

  // Check if current user is the owner of the post
  bool checkifOwner() {
    return AccountManagement().currentUserId() == user.id;
  }

  // Makes content for the cards, using Post item
  makeUserContent(BuildContext context, UserAccount user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[

        // First row
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            // Category Icon
            Expanded(child: Container(
              alignment: Alignment.bottomLeft,
              padding: EdgeInsets.only(bottom: 13),
              child: user.userAvatar(radius: 30))
            ),

            SizedBox(width: 13),
            
            // Title
            Expanded(flex: 10, 
            child: Container(
              child: Text(user.userName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 19
                )
              )
            )
          )
        ]
      ),

      // Description
      Expanded(flex: 3, child: Container(
        padding: EdgeInsets.only(bottom: 12),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            TextStyle currentTextStyle = Theme.of(context).textTheme.bodyText1;
            int maxLines = ((constraints.maxHeight / currentTextStyle.fontSize) * 0.8).floor();
            maxLines = maxLines > 0 ? maxLines : 1;
            return Text(
              user.bio,
              overflow: TextOverflow.ellipsis,
              maxLines: maxLines,
              style: TextStyle(color: Colors.white)
            );
          }
        )
      ))
    ]);
  }

   displayProfiles(context){
     
    return Container(
      // Style for card
      margin: EdgeInsets.only(top: 10.0, bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(new Radius.circular(10.0)),
        gradient: currentTheme.lookingGradient()
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
              child: makeUserContent(context, user)
            )
          ),
          onTap: () => locator<NavigationService>().launchProfilePopUp(user),
        )
      ),
    );
  }

  // Builds widget
  @override
  Widget build(BuildContext context) {
    return displayProfiles(context);
  }
}
