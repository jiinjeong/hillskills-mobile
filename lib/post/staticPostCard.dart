/* ************************************************************************
 * FILE : staticPostCard.dart
 * DESC : Constructs a visual representation of a postCard item
 * ************************************************************************
 */

import 'package:flutter/material.dart';
import 'package:HillSkills/data/dynamicGlobals.dart';
import 'package:HillSkills/data/globals.dart';
import 'package:HillSkills/utils/navigation.dart';
import 'package:HillSkills/utils/dateFormatting.dart';
import 'package:flutter/cupertino.dart';

class StaticPostCard extends StatefulWidget {
  final Map<String, dynamic> postContents;

  // Keys differentiate widgets
  StaticPostCard(this.postContents);

  @override
  StaticPostCardState createState() => StaticPostCardState();
}

class StaticPostCardState extends State<StaticPostCard> {

  Map<String, dynamic> postContents;

  @override
  void initState() {
    super.initState();
    this.postContents = this.widget.postContents;
  }


  // Text for popup
  Text popUpText(String textStr) {
    return Text(textStr, style: TextStyle(
      color: Colors.white,
      fontSize: 16,
      fontWeight: FontWeight.normal
    ));
  }


  // Makes content for the cards, using Post item
  makePostContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[

        // First row
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            // Category Icon
            Padding(
              padding: EdgeInsets.only(right: 10.5),
              child: categoryIcons[this.postContents["category"]]
            ),

            // Title
            Expanded(flex: 10,
              child: Text(this.postContents["title"],
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 19
                )
              )
            ),


            // Report
            InkWell(
              borderRadius: BorderRadius.all(Radius.circular(100)),
              child: Container(
                padding: EdgeInsets.all(3),
                child: Icon(Icons.more_vert, color: Colors.white)
              ),
              onTap: (){}
            )
          ]
        ),

        // Description
        Expanded(
          flex: 3,
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                TextStyle currentTextStyle = Theme.of(context).textTheme.bodyText1;
                int maxLines = ((constraints.maxHeight / currentTextStyle.fontSize) * 0.8).floor();
                maxLines = maxLines > 0 ? maxLines : 1;
                return Text(
                  this.postContents["description"],
                  overflow: TextOverflow.ellipsis,
                  maxLines: maxLines,
                  style: TextStyle(color: Colors.white)
                );
              }
            )
          )
        ),

        // Date
        Expanded(child: Container(
          alignment: Alignment.bottomRight,
          child: Text(
            niceDate(this.postContents["dateTimeStr"]),
            style: TextStyle(color: Colors.white, fontSize: 13)
          )
        )),
  
      ]
    );
  }

 
  // Builds widget
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Post Resulting in Strike"),
      ),
      
      // Body is currently static placeholder data -- wil be rewritten
      body: Container(

        // Style for card
        margin: EdgeInsets.all(10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(new Radius.circular(10.0)),
          gradient: this.postContents["feedNum"] == 0
            ? currentTheme.lookingGradient()
            : currentTheme.offeringGradient()
        ),
        height: 150.0,

        // Click and hold animations for card
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.all(new Radius.circular(10.0)),

            // Generates card content
            child: Container(
              margin: EdgeInsets.all(14),
              child: SizedBox(
                child: makePostContent(context)
              )
            ),
            onTap: () => locator<NavigationService>().launchStaticPost(this.postContents),
          )
        ),
      )
    );
  }

}
