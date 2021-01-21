/* ************************************************************************
 * FILE : addPics.dart
 * DESC : Third page of the Registration Sequence, adding example pictures
 * ************************************************************************
 */

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:HillSkills/data/globals.dart';
import 'package:HillSkills/data/theme.dart';
import 'package:HillSkills/utils/backend/userInteraction.dart';
import 'package:HillSkills/utils/imagePicker.dart';
import 'package:HillSkills/data/globalWidgets.dart';

// Login page widget
class AddPicsPage extends StatefulWidget {

  final UserAccount account;
  AddPicsPage(this.account);

  @override
  AddPicsPageState createState() => new AddPicsPageState();
}

// Dynamic login data
class AddPicsPageState extends State<AddPicsPage> {
  
  ImagePickerWidget uploadPics;
  
  @override
  void initState() {
    super.initState();
    uploadPics = new ImagePickerWidget(this.widget.account);
  }

  final topText = Text(
    "Show off your creations.",
    style: TextStyle(fontSize: 20, color: Colors.white),
    textAlign: TextAlign.center
  );

  final smallerText = Text(
    "Users who view your profile will see this.",
    style: TextStyle(fontSize: 11, color: Colors.white),
    textAlign: TextAlign.center
  );

  // Layout for the page.
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: light,
      child: Scaffold(
        appBar: setupAppBar,
        backgroundColor: PRIMARY_COLOR,
        body: Center(
          child: Stack(children: [
            ListView(
              padding: SETUP_SPACING,
              children: <Widget>[
                logo(),
                topText,
                smallerText,
                uploadPics
              ],
            ),
            Positioned(
              bottom: 20.0,
              left: 0.0,
              right: 0.0,
              child: navigateButton('/newUser4', account: this.widget.account)
            ),
          ]),
        ),
      )
    );
  }
}
