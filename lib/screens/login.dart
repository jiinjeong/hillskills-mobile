/* ************************************************************************
 * FILE : login.dart
 * DESC : Page to handle user login with email and password
 * ************************************************************************
 */

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:HillSkills/data/dynamicGlobals.dart';
import 'package:HillSkills/data/formFieldData.dart';
import 'package:HillSkills/data/hillskillsButton.dart';
import 'package:HillSkills/utils/backend/accountManagement.dart';
import 'package:HillSkills/utils/navigation.dart';
import 'package:HillSkills/data/globals.dart';
import 'package:HillSkills/data/theme.dart';
import 'package:HillSkills/data/globalWidgets.dart';

// Login page widget
class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => new LoginPageState();
}

// Dynamic login data
class LoginPageState extends State<LoginPage> {

  // Store form data in memory
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  StringData _email = StringData('');
  StringData _password = StringData('');

  // Widgets and controllers used on page
  ScrollController tosController = ScrollController();
  HillSkillsButton loginButton;
  HillSkillsButton registrationButton;


  // Validates data and attempts a login
  Future<dynamic> submit() async {

    // Check data is valid
    if (_formKey.currentState.validate()) {

      // Test login
      return await AccountManagement().login(_email.string, _password.string);
    }
  }

  // Continue login by pushing next screen
  continueLogin() async {
    if(await AccountManagement().isUserNew()) showDialog(
      context: context,
      builder: (BuildContext context) => tosPopup()
    );
    else locator<NavigationService>().popAllPushNamed('/home');
  }

  // Checks whether login works and returns error if not
  void loginFunction() async {

    // Saves form
    _formKey.currentState.save();

    // Confirms login works
    dynamic response = await submit();

    // Good login -- shows login with TOS
    if (response is bool && response) continueLogin();

    // Bad login - shows error message
    else if (response is String)
      showSnackBar(LOGIN, response);
  }

  // Forgot password button
  Flex forgotPasswordButton = Flex(
    direction: Axis.horizontal,
    mainAxisAlignment: MainAxisAlignment.start,
    children:[TextButton(
      child: Text(
        'Forgot password?',
        style: TextStyle(color: Colors.white)),
      onPressed: () {
        locator<NavigationService>().navigateTo('/forgotPassword');
      }
    )]
  );

  // Once logged in, displays terms of service and privacy policy for the user to accept/decline.
  Widget tosPopup() {
    return AlertDialog(
      title: Text("User Agreement"),
      content: Container(
        height: 250,
        child: Scrollbar(
          controller: tosController,
          isAlwaysShown: true,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(right: 10),
            controller: tosController,
            child: Text(tos)
          )
        )
      ),
      actions: [
        // If they decline the TOS, throw away their email and pass
        FlatButton(
          child: Text("Decline"),
          onPressed: () async {
            AccountManagement().logout();
            locator<NavigationService>().pop();
          },
        ),

        // If the user accepts, save login and continue
        FlatButton(
          child: Text("Accept"),
          onPressed: () =>
            locator<NavigationService>().popAllPushNamed('/newUser1'),
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();

    // Navbar color
    currentTheme.registration = true;
    currentTheme.setNavbar();

    // Sets theme to system
    switchThemeMode(SYSTEM);

    // Pressable button for login.
    loginButton = HillSkillsButton(
      'LOGIN',
      loginFunction,
      bold: true
    );

    registrationButton = navigateButton(
      '/signup',
      text: 'New? Create an account!'
    );
  }

  @override
  Widget build(BuildContext context) {

    // Layout for the page.
    return Theme(
      data: light,
      child: Scaffold(
        key: snackbarKeys[LOGIN],
        backgroundColor: PRIMARY_COLOR,
        body: Center(
          child: Form(
            key: this._formKey,
            child: Stack(
              children: [
                ListView(
                  padding:
                    EdgeInsets.only(top: 80.0, left: 24.0, right: 24.0),
                  children: <Widget>[
                    logo(size: 190.0),
                    SizedBox(height: 14.0),
                    emailField(_email),
                    SizedBox(height: 16.0),
                    passwordField(_password),
                    forgotPasswordButton,
                    SizedBox(height: 16.0),
                    loginButton,
                    SizedBox(height: 40.0),
                    registrationButton
                  ]
                ),
              ],
            ),
          ),
        ),
      )
    );
  }
}
