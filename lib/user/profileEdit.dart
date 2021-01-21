/* ************************************************************************
 * FILE : profileEdit.dart
 * DESC : Allows users to edit their profile.
 * ************************************************************************
 */

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:HillSkills/data/formFieldData.dart';
import 'package:HillSkills/data/globalWidgets.dart';
import 'package:HillSkills/utils/backend/userInteraction.dart';
import 'package:HillSkills/utils/imagePicker.dart';
import 'package:HillSkills/utils/navigation.dart';

// User profile page widget
class ProfileEditPage extends StatefulWidget {
  ProfileEditPage(this.account);
  final UserAccount account;

  @override
  ProfileEditPageState createState() => new ProfileEditPageState();
}

// Dynamic data for profile
class ProfileEditPageState extends State<ProfileEditPage> {
  UsernameField username;
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  UserAccount account;

  // Loads data from current profile
  @override
  void initState() {
    super.initState();
    this.account = this.widget.account.clone();
    username = UsernameField(this.account);
    username.uniqueUsernameAsync(this.account.userName);
  }

  void setMyState() {
    setState(() {});
  }

  // Generates popup asking user to confirm changes
  AlertDialog generateConfirmDialog() {
    return AlertDialog(
      title: const Text("Update account"),
      content: const Text("Confirm changes?"),
      actions: <Widget>[

        // Cancel button
        FlatButton(
          child: const Text("Cancel"),
          onPressed: () => locator<NavigationService>().pop(),
        ),

        // Confirm button
        FlatButton(
          child: const Text("Confirm"),
          onPressed: () async {
            // Update account
            UserInteraction().updateUser(this.account);
            // Return to profile page
            locator<NavigationService>().pop(num: 2, result: this.account);
          },
        ),
      ],
    );
  }

  // Dropdown editor for avatar
  HillSkillsExpansion avatarEditor() {
    return HillSkillsExpansion(
      title: 'Edit Avatar:',
      fontWeight: FontWeight.w500,
      children:[ListView(
        shrinkWrap: true,
        primary: false,
        children:[
          this.account.userAvatar(radius: 100),
          SizedBox(height: 30.0),
          buildIconChips(this.account, this),
          SizedBox(height: 20.0),
          buildColorChips(this.account, this),
        ]
      )]
    );
  }

  // Dropdown editor for skills
  HillSkillsExpansion skillEditor() {
    return HillSkillsExpansion(
      title: 'Edit Skills:',
      fontWeight: FontWeight.w500,
      children: [
        buildSkillChips(this.account, this),
      ],
    );
  }

  // Dropdown editor for photos
  HillSkillsExpansion photoEditor() {
    return HillSkillsExpansion(
      title: 'Edit Images:',
      fontWeight: FontWeight.w500,
      children: [
        ImagePickerWidget(this.account),
      ],
    );
  }

  // Dropdown editor for username
  HillSkillsExpansion userNameEditor() {
    return HillSkillsExpansion(
      initiallyExpanded: true,
      title: 'Edit Username:',
      fontWeight: FontWeight.w500,
      children:[username.createField()]
    );
  }

  // Dropdown editor for bio
  HillSkillsExpansion bioEditor() {
    return HillSkillsExpansion(
    initiallyExpanded: true,
    title: 'Edit Bio:',
    fontWeight: FontWeight.w500,
    children: [bioField(this.account)]
    );
  }

  @override
  Widget build(BuildContext context) {

    // Main widget for profile pags
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),

      // Save button
      floatingActionButton: FloatingActionButton(
        onPressed: () {

          // checks form data valid
          _formKey.currentState.save();
          if (_formKey.currentState.validate())

            // Confimration dialog
            showDialog(
              context: context,
              child: generateConfirmDialog(),
            );
        },
        child: Icon(Icons.done),
      ),

      // Contains menus to edit different sections of profile
      body: Center(child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0, bottom: 80.0),
          children: [
            // Username
            userNameEditor(),
            // Bio
            bioEditor(),
            // Avatar
            avatarEditor(),
            // Tagss
            skillEditor(),
            // Photos
            photoEditor()
          ]
        )
      ))
    );
  }
}
