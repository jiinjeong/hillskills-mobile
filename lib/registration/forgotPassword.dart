/* ************************************************************************
 * FILE : forgotPassword.dart
 * DESC : Used when user has forgotten password.
 * ************************************************************************
 */

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:HillSkills/data/formFieldData.dart';
import 'package:HillSkills/data/globals.dart';
import 'package:HillSkills/data/hillskillsButton.dart';
import 'package:HillSkills/data/theme.dart';
import 'package:HillSkills/data/globalWidgets.dart';
import 'package:HillSkills/utils/backend/accountManagement.dart';
import 'package:HillSkills/utils/navigation.dart';


// Forgot password page
class ForgotPasswordPage extends StatefulWidget {
  @override
  ForgotPasswordPageState createState() => new ForgotPasswordPageState();
}

// Dynamic password retrieval data
class ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  StringData _email = StringData('');

  // Validates data and attempts to reset password
  Future<void> resetPassword() async {
    
    // Check data is valid
    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {

      // Send reset email
      dynamic response = await AccountManagement().forgotPassword(_email.string);

      // If email sent successfully
      if (response is bool && response) {
        locator<NavigationService>().pop();
        showSnackBar(LOGIN, 'See email for recovery instructions');
      }

      // On error
      else showSnackBar(FORGOT_PASSWORD, response);
    }
  }

  final topText = Text(
    "Recover Password",
    style: TextStyle(fontSize: 20, color: Colors.white),
    textAlign: TextAlign.center
  );

  // Layout for the page
  @override
  Widget build(BuildContext context) {

    final email = emailField(_email);

    // Creates a button to send email and return to previous page
    final submitButton = HillSkillsButton(
      'Send',
      resetPassword
    );

    return Theme(
      data: light,
      child: Scaffold(
        appBar: setupAppBar,
        key: snackbarKeys[FORGOT_PASSWORD],
        backgroundColor: PRIMARY_COLOR,
        body: Center(
          child: Form(
            key: this._formKey,
            child: Stack(children: [
              ListView(
                padding: SETUP_SPACING,
                children: <Widget>[
                  SizedBox(height: 80.0),
                  logo(),
                  topText,
                  SizedBox(height: 25.0),
                  email,
                  SizedBox(height: 60.0),
                  submitButton
                ],
              )
            ])
          )
        )
      )
    );
  }
}
