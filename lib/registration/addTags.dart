/* ************************************************************************
 * FILE : addTags.dart
 * DESC : Fourth page in Registration sequence, adding user tags
 * ************************************************************************
 */

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:HillSkills/data/formFieldData.dart';
import 'package:HillSkills/data/globals.dart';
import 'package:HillSkills/data/hillskillsButton.dart';
import 'package:HillSkills/data/theme.dart';
import 'package:HillSkills/utils/backend/userInteraction.dart';
import 'package:HillSkills/data/globalWidgets.dart';
import 'package:HillSkills/utils/navigation.dart';


// Login page widget
class AddTagsPage extends StatefulWidget {

  final UserAccount account;
  AddTagsPage(this.account);

  @override
  AddTagsPageState createState() => new AddTagsPageState();
}

// Dynamic login data
class AddTagsPageState extends State<AddTagsPage> {

  void setMyState() {
    setState(() {});
  }

  void completeSetup() async {

    // Ensure tags selected
    if (this.widget.account.skills.numberEnabled > 0) {

      try {
        // Update account
        await UserInteraction().updateUser(this.widget.account);

        // Navbar color
        currentTheme.registration = false;
        currentTheme.setNavbar();

        // Go home
        locator<NavigationService>().popAllPushNamed('/home');

      } catch (error) {
        showSnackBar(SKILLTAGS, 'There was an error. Please try again later.');
      }

      
    }
    else showSnackBar(SKILLTAGS, 'Please select at least one skill!');
  }

  final topText = Text(
    "Choose at least one \n thing you're good at!",
    style: TextStyle(fontSize: 20, color: Colors.white),
    textAlign: TextAlign.center
  );

  // Layout for the page.
  @override
    Widget build(BuildContext context) {
      return Theme(
        data: light,
        child: Scaffold(
          appBar: setupAppBar,
          key: snackbarKeys[SKILLTAGS],
          backgroundColor: PRIMARY_COLOR,
          body: Center(
            child: Stack(
            children: [
              ListView(
                padding: SETUP_SPACING,
                children: <Widget>[
                  topText,
                  SizedBox(height: 30.0),
                  buildSkillChips(this.widget.account, this),
                ]
              ),
              Positioned(
                bottom: 20.0,
                left: 0.0,
                right: 0.0,
                child: Center(
                  child: HillSkillsButton('Complete Setup', completeSetup)
                )
              )
            ]
          )
        )
      )
    );
  }
}
