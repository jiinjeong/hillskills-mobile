/* ************************************************************************
 * FILE : termsOfService.dart
 * DESC : Used to display details about the app
 * ************************************************************************
 */

import 'package:HillSkills/data/dynamicGlobals.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// Terms of service page
class TermsOfService extends StatelessWidget {

  // Layout for the page
  @override
  Widget build(BuildContext context) {

    // Body of widget
    return Scaffold(
      appBar: AppBar(
        title: Text('Terms Of Service'),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Text(
          tos,
          style: TextStyle(fontSize: 16),
        )
      )
    );
  }
}
