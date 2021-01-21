/* ************************************************************************
 * FILE : createBio.dart
 * DESC : Second page of the Registration Sequence, adding bio
 * ************************************************************************
 */

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:HillSkills/data/globals.dart';
import 'package:HillSkills/data/theme.dart';
import 'package:HillSkills/data/globalWidgets.dart';
import 'package:HillSkills/data/formFieldData.dart';
import 'package:HillSkills/utils/backend/userInteraction.dart';


// Login page widget
class AddBioPage extends StatefulWidget {

  final UserAccount account;
  AddBioPage(this.account);

  @override
  AddBioPageState createState() => new AddBioPageState();
}

// Dynamic login data
class AddBioPageState extends State<AddBioPage> {

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  UsernameField username;

  @override
  void initState() {
    super.initState();
    username = UsernameField(this.widget.account);
  }

  final topText = Text(
    "Introduce yourself.",
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
          child: Form(
            key: this._formKey,
            child: Stack(children: [
              ListView(
                padding: SETUP_SPACING,
                children: <Widget>[
                  logo(),
                  topText,
                  smallerText,
                  SizedBox(height: 25.0),
                  username.createField(),
                  SizedBox(height: 25.0),
                  bioField(this.widget.account),
                ],
              ),
              Positioned(
                bottom: 20.0,
                left: 0.0,
                right: 0.0,
                child: Center(
                  child: navigateButton(
                    '/newUser3',
                    account: this.widget.account,
                    validator: _formKey
                  ),
                )
              )
            ])
          )
        )
      )
    );
  }
}
