/* ************************************************************************
 * FILE : addAvatar.dart
 * DESC : First page of the Registration Sequence, adding user avatar
 * ************************************************************************
 */

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:HillSkills/data/formFieldData.dart';
import 'package:HillSkills/data/globals.dart';
import 'package:HillSkills/data/theme.dart';
import 'package:HillSkills/data/globalWidgets.dart';
import 'package:HillSkills/utils/backend/userInteraction.dart';

// Login page widget
class AddAvatarPage extends StatefulWidget {

  final UserAccount account = UserAccount();

  @override
  AddAvatarPageState createState() => new AddAvatarPageState();
}

// Dynamic login data
class AddAvatarPageState extends State<AddAvatarPage> {

  @override
  void initState() {
    super.initState();
  }
  
  void setMyState() {
    setState(() {});
  }

  final topText = Text(
    "Create an avatar.",
    style: TextStyle(fontSize: 20, color: Colors.white),
    textAlign: TextAlign.center
  );

  // Layout for the page.
  @override
  Widget build(BuildContext context) {

    return Theme(
      data: light,
      child: Scaffold(
        backgroundColor: PRIMARY_COLOR,
        body: Center(
          child: Stack(children: [
            ListView(
              padding: SETUP_SPACING,
              children: <Widget>[
                SizedBox(height: 20.0),
                logo(),
                topText,
                SizedBox(height: 20.0),
                this.widget.account.userAvatar(),
                SizedBox(height: 30.0),
                new Container(height: 80, child: buildIconChips(
                  this.widget.account,
                  this
                )),
                SizedBox(height: 20.0),
                new Container(height: 50, child: buildColorChips(
                  this.widget.account,
                  this
                )),
              ]
            ),
            Positioned(
              bottom: 20.0,
              left: 0.0,
              right: 0.0,
              child: navigateButton('/newUser2', account: this.widget.account)
            ),
          ]),
        ),
      )
    );
  }

}
