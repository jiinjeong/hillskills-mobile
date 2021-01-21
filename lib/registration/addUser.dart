/* ************************************************************************
 * FILE : registration.dart
 * DESC : For user to register/create account
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


// Login page widget
class RegistrationPage extends StatefulWidget {
  @override
  RegistrationPageState createState() => new RegistrationPageState();
}

// Dynamic login data
class RegistrationPageState extends State<RegistrationPage> {
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  StringData _email = StringData('');
  StringData _password = StringData('');
  StringData _passwordConfirm = StringData('');

  // Validates data and attempts an account creation
  Future<void> createAccount() async {
    
    // Check data is valid
    _formKey.currentState.save();
    if (_formKey.currentState.validate()) {

      // Test login
      dynamic response = await AccountManagement().createNewAccount(_email.string, _password.string);

      // Email sent
      if (response is bool && response) {
        locator<NavigationService>().pop();
        showSnackBar(LOGIN, 'See email to verify account');
      }

      // On error
      else showSnackBar(CREATE_ACCOUNT, response);
    }
  }

  final topText = Text(
    "Create New Account",
    style: TextStyle(fontSize: 20, color: Colors.white),
    textAlign: TextAlign.center
  );

  // Layout for the page
  @override
  Widget build(BuildContext context) {

    final email = emailField(_email);
    final password = newPasswordField(_password);
    final confirmPassword = passwordConfirmField(_password, _passwordConfirm);

    // Creates a button to push next page (route)
    final signUpButton = HillSkillsButton(
      'Sign Up',
      createAccount
    );

    return Theme(
      data: light,
      child: Scaffold(
        appBar: setupAppBar,
        key: snackbarKeys[CREATE_ACCOUNT],
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
                  SizedBox(height: 25.0),
                  email,
                  SizedBox(height: 25.0),
                  password,
                  SizedBox(height: 25.0),
                  confirmPassword,
                  SizedBox(height: 60.0),
                  signUpButton
                ],
              )
            ])
          )
        )
      )
    );
  }
}
