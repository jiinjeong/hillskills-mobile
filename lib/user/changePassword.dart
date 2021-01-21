/* ************************************************************************
 * FILE : chnagePassword.dart
 * DESC : Used to change password when the old pw is known.
 * ************************************************************************
 */

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:HillSkills/data/formFieldData.dart';
import 'package:HillSkills/data/globals.dart';
import 'package:HillSkills/data/globalWidgets.dart';
import 'package:HillSkills/utils/backend/accountManagement.dart';
import 'package:HillSkills/utils/navigation.dart';

// Change password account page
class ChangePasswordPage extends StatefulWidget {
  @override
  ChangePasswordPageState createState() => new ChangePasswordPageState();
}

// Dynamic data for profile
class ChangePasswordPageState extends State<ChangePasswordPage> {

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  StringData _oldPassword = StringData('');
  StringData _password = StringData('');
  StringData _passwordConfirm = StringData('');

  @override
  Widget build(BuildContext context) {

    FloatingActionButton confirmChange = FloatingActionButton(
      child: Icon(Icons.check),
      onPressed: () async {
        _formKey.currentState.save();
        if (_formKey.currentState.validate()) {

          // Send reset email
          dynamic response = await AccountManagement().updatePassword(
            _oldPassword.string,
            _password.string
          );

          // If email sent successfully
          if (response is bool && response) {
            locator<NavigationService>().pop();
          }

          // On error
          else showSnackBar(CHANGE_PASSWORD, response);
        }
      }
    );


    return Scaffold(
      appBar: AppBar(title: Text("Change Password")),
      floatingActionButton: confirmChange,
      key: snackbarKeys[CHANGE_PASSWORD],
      body: Form(
        key: _formKey,
        child: ListView(
          padding: STANDARD_SPACING,
          children: [
            Text(
              "Enter your old password to confirm.",
              style: TextStyle(
                fontSize: 16
              ),
            ),
            SizedBox(height: 16.0),
            passwordField(_oldPassword),
            SizedBox(height: 24.0),
            Text(
              "New password.",
              style: TextStyle(
                fontSize: 16
              ),
            ),
            SizedBox(height: 16.0),
            passwordConfirmField(_password, _passwordConfirm),
            SizedBox(height: 24.0),
            Text(
              "Confirm new password.",
              style: TextStyle(
                fontSize: 16
              ),
            ),
            SizedBox(height: 16.0),
            passwordField(_password),
          ]
        )
      )
    );
  }
}
