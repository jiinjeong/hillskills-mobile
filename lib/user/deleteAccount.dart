/* ************************************************************************
 * FILE : deleteAccount.dart
 * DESC : Used to delete a user's account.
 * ************************************************************************
 */

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:HillSkills/data/formFieldData.dart';
import 'package:HillSkills/data/globals.dart';
import 'package:HillSkills/data/globalWidgets.dart';
import 'package:HillSkills/utils/backend/accountManagement.dart';
import 'package:HillSkills/utils/navigation.dart';

// Delete account page
class DeleteAccountPage extends StatefulWidget {
  @override
  DeleteAccountPageState createState() => new DeleteAccountPageState();
}

// Dynamic data for profile
class DeleteAccountPageState extends State<DeleteAccountPage> {

  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  StringData _password = StringData('');

  @override
  Widget build(BuildContext context) {

    FloatingActionButton confirmDelete = FloatingActionButton(
      child: Icon(Icons.delete_forever),
      onPressed: () async {
        _formKey.currentState.save();
        if (_formKey.currentState.validate()) {

          // Send reset email
          dynamic response = await AccountManagement().deleteUser(_password.string);

          // If email sent successfully
          if (response is bool && response) {
            await locator<NavigationService>().popAllPushNamed('/login');
          }

          // On error
          else showSnackBar(DELETE_ACCOUNT, response);
        }
      }
    );


    return Scaffold(
      key: snackbarKeys[DELETE_ACCOUNT],
      appBar: AppBar(title: Text("Delete Account")),
      floatingActionButton: confirmDelete,
      body: Form(
      key: _formKey,
        child: ListView(
          padding: STANDARD_SPACING,
          children: [
            Text(
              "Enter your password to confirm.",
              style: TextStyle(
                fontSize: 16
              ),
            ),
            SizedBox(height: 24.0),
            passwordField(_password)
          ]
        )
      )
    );
  }
}
