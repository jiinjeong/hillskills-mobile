/* ************************************************************************
 * FILE : settings.dart
 * DESC : Settings/preferences page to change theme, password,
 *        log out, or delete account.
 * ************************************************************************
 */

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:HillSkills/data/globals.dart';
import 'package:HillSkills/data/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:HillSkills/utils/backend/accountManagement.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:HillSkills/utils/navigation.dart';

// Settings page layout
class SettingsPage extends StatefulWidget {
  @override
  SettingsPageState createState() => new SettingsPageState();
}

// Dynamic data for profile
class SettingsPageState extends State<SettingsPage> {
  // Logout confirmation popup
  AlertDialog logoutDialog = AlertDialog(
    title: Text("Logout"),
    content: Text("Are you sure you want to logout from your account?"),
    actions: [
      // Cancel and go backs
      FlatButton(
        child: Text("Cancel"),
        onPressed: () async {
          locator<NavigationService>().pop();
        },
      ),

      // Logout user from firebase
      FlatButton(
        child: Text("Continue"),
        onPressed: () async {
          await AccountManagement().logout();
          await locator<NavigationService>().popAllPushNamed('/login');
        },
      )
    ],
  );

  sectionHeaderText(String title) {
    return Text(title, style: TextStyle(color: Colors.grey[600]));
  }

  logoutSetting() {
    return ListTile(
      title: Text("Logout"),
      leading: Icon(MdiIcons.logout),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return logoutDialog;
          }
        );
      },
    );
  }

  changePasswordSetting() {
    return ListTile(
      title: Text("Change Password"),
      leading: const Icon(MdiIcons.formTextboxPassword),
      onTap: () {
        locator<NavigationService>().navigateTo('/changePassword');
      },
    );
  }

   deleteAccount() {
    return ListTile(
      title: Text("Delete Account"),
      leading: const Icon(MdiIcons.delete),
      onTap: () => locator<NavigationService>().navigateTo('/deleteAccount')
    );
  }

  String dropdownValue = prefs.getString(CURRENT_THEME);
  darkMode() {
    List<DropdownMenuItem<String>> dropdownMenuItems =
      themeNames
      .map((String val) => DropdownMenuItem<String>(
        value: val,
        child: Text(val),
      ))
      .toList();

    return DropdownButtonHideUnderline(
      child: DropdownButton(
        value: dropdownValue,
        items: dropdownMenuItems,
        onChanged: (String value) async {
          setState(() {
            dropdownValue = value;
          });
          await switchThemeMode(value);
          
        },
      )
    );
  }

  darkModeSelector() {
    return ListTile(
      title: Text("Theme"),
      trailing: darkMode(),
    );
  }

  aboutPage(){
    return ListTile(
      title: Text("App Info"),
      leading: const Icon(Icons.info_outline),
      onTap: () => locator<NavigationService>().navigateTo('/about')
        .then((value) {
          // Navbar color
          currentTheme.registration = false;
          currentTheme.setNavbar();
        })
    );
  }

  tos(){
    return ListTile(
      title: Text("Terms Of Service"),
      leading: const Icon(MdiIcons.bookOutline),
      onTap: () => locator<NavigationService>().navigateTo('/tos')
    );
  }

  @override
  Widget build(BuildContext context) {

    // Body of widget
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: <Widget>[
          sectionHeaderText("Theme"),
          darkModeSelector(),
          
          sectionHeaderText("App"),
          aboutPage(),
          tos(),
          
          sectionHeaderText("Account"),
          changePasswordSetting(),
          logoutSetting(),
          deleteAccount(),
        ]
      )
    );
  }
}
