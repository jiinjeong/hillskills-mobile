/* ************************************************************************
 * FILE : about.dart
 * DESC : Used to display details about the app
 * ************************************************************************
 */

import 'package:HillSkills/data/dynamicGlobals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:HillSkills/data/globals.dart';
import 'package:HillSkills/data/globalWidgets.dart';
import 'package:url_launcher/url_launcher.dart';

// About app page
class AboutPage extends StatelessWidget {

  // Lanch the in built mailing app
  void launchEmail(command) async {
    if (await canLaunch(command)) {
      await launch(command);
    }
  }

  // Text for about page
  aboutTextArea(String title, double size, [
    FontWeight weight = FontWeight.w400, 
    Color color = Colors.white70]){
    return Text(
      title,
      style: TextStyle(
        fontSize: size, 
        color: color,
        fontWeight: weight),
       textAlign: TextAlign.center
    );
  }

  // Email button
  Widget emailButton() {
    return TextButton(
      onPressed: () => launchEmail(
        'mailto:coding@hamilton.edu'), 
      child: aboutTextArea(
        "Want to reach out?\nEmail coding@hamilton.edu",
        18,
        FontWeight.w500,
        Colors.white
      )
    );
  }

  // Layout for the page
  @override
  Widget build(BuildContext context) {

    // Body of widget
    return Scaffold(
      appBar: setupAppBar,
      backgroundColor: PRIMARY_COLOR,

      body: ListView(
        padding: SETUP_SPACING,
        physics: BouncingScrollPhysics(),
        children: [

          // Name/version
          aboutTextArea("HillSkills", 40, FontWeight.bold, Colors.white),
          aboutTextArea("Version ${packageInfo.version}", 17, FontWeight.w300),

          // Logo
          SizedBox(height: 25),
          logo(showText: false, size: 100),
          SizedBox(height: 50),

          // App description
          aboutTextArea(appDescription, 16),
          SizedBox(height: 35),

          // Contact button
          emailButton(),
          SizedBox(height: 20),
          
          // Copyright
          Container(
            child: aboutTextArea("©2020 Hamilton College", 14),
            padding: EdgeInsets.symmetric(vertical: 20),
            alignment: Alignment.bottomCenter,
          )
        ]
      )
    );
  }
}
