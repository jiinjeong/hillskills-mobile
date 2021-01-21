/* ************************************************************************
 * FILE : postCreateEdit.dart
 * DESC : Allows users to create or edit a post for looking/offering.
 * ************************************************************************
 */

import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:HillSkills/data/dynamicGlobals.dart';
import 'package:HillSkills/data/formFieldData.dart';
import 'package:HillSkills/utils/navigation.dart';
import 'package:HillSkills/utils/backend/feedInteraction.dart';
import 'package:HillSkills/data/globalWidgets.dart';
import 'package:HillSkills/data/globals.dart';
import 'contentModeration.dart';

// New post widget
class NewPost extends StatefulWidget {
  final int pageNum;
  final Post post;
  NewPost({this.pageNum, this.post, Key key}) : super(key: key);

  @override
  NewPostState createState() => new NewPostState();
}

// Dynamic new post class
class NewPostState extends State<NewPost> {

  // Form and scaffold keys
  final GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  final _scaffoldKey = new GlobalKey<ScaffoldState>();

  void setMyState() {
    setState(() {});
  }

  // Starting values for form
  String _postName = '';
  String _postDescription = '';
  String errorMessage = '';
  String _category = CATEGORY_PROMPT;
  PostTags _tags = new PostTags();
  int pageNum;
  FeedInteraction feed;
  String titleInitialValue = '';
  String descriptionInitialValue = '';
  String _postId;
  Text _appbarTitle;
  int postExpirationMonths = 1;

  // Initializes with feed selected
  @override
  void initState() {
    super.initState();

    // New post case
    if (this.widget.pageNum != null) {
      pageNum = this.widget.pageNum;
      feed = postTypes[pageNum];
      _appbarTitle = Text("New Post");
    }

    // Editing existing post case
    if (this.widget.post != null) {
      Post post = this.widget.post;
      _postId = post.id;
      _postName = post.title;
      _postDescription = post.description;
      _category = post.category;
      _tags = post.tags;
      titleInitialValue = post.title;
      descriptionInitialValue = post.description;
      pageNum = this.widget.post.feedNum;
      feed = postTypes[pageNum];
      _appbarTitle = Text("Edit Post");
    }
  }

  // Moderates content, generating popup dialog if necessary
  Future<void> contentModeration() async {    

    var moderated = false;

    // Cleans the bad content
    if (containsBadWords(_postName)){
      _postName = moderatedText(_postName);
      moderated = true;
    }
    if (containsBadWords(_postDescription)){
      _postDescription = moderatedText(_postDescription);
      moderated = true;
    }

    // AlertDialog for content moderation
    AlertDialog acceptModeration = AlertDialog(
      title: Text("Content Moderation"),
      content: Text("Your text has been moderated. Continue?"),
      actions: [
        FlatButton(
          child: Text("Cancel"),
          onPressed: () async {
            // Pops back to user edit screen
            locator<NavigationService>().pop(num: 2);
          },
        ),
        FlatButton(
          child: Text("Yes"),
          onPressed: () {
            submit();
            locator<NavigationService>().goHome();
          },
        )
      ],
    );

    // If moderated content, alerts user and asks if they want to continue.
    if (moderated){
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return acceptModeration;
        }
      );
    }
    // Else, allows automatic submission
    else {
      submit();
      locator<NavigationService>().goHome();
    }
  }

  // Sends new post to the feed and clears data
  Future<void> submit() async {

    User currentUser = FirebaseAuth.instance.currentUser;

    Post post = Post (
      author: currentUser.uid,
      title: _postName,
      description: _postDescription,
      category: _category,
      tags: _tags,
      feedNum: pageNum,
      id: _postId,
      monthsUntilExpiration: postExpirationMonths
    );

    if (this.widget.post == null)
      await feed.postToFeed(post);
    else
      await feed.updatePost(post);

    refreshGivenFeed(pageNum);
    postKey = UniqueKey();
  }

  // Which feed to use
  final Map<int, Widget> myTabs = const <int, Widget>{
    0: Text("Looking"),
    1: Text("Offering")
  };
  final Map<int, FeedInteraction> postTypes = <int, FeedInteraction>{
    0: lookingFeed,
    1: offeringFeed
  };

  @override
  Widget build(BuildContext context) {

    expirationInMonths() {
      List<DropdownMenuItem<int>> dropdownMenuItems = [
        DropdownMenuItem<int>(value: 1, child: Text('1 month', style: currentTheme.postTextStyle())),
        DropdownMenuItem<int>(value: 3, child: Text('3 months', style: currentTheme.postTextStyle())),
        DropdownMenuItem<int>(value: 6, child: Text('6 months', style: currentTheme.postTextStyle())),
      ];
      return Row(
        children: [
            Text("Post expires in:", style: currentTheme.postTextStyle()),
            Expanded(child: Container()),
            DropdownButtonHideUnderline(
              child: DropdownButton(
                value: postExpirationMonths,
                items: dropdownMenuItems,
                onChanged: (value) {
                  setState((){postExpirationMonths = value;});
                },
              )
            )
        ]
      );
    }

    // Confirmation popup
    AlertDialog confirm = AlertDialog(
      title: Text("Post"),
      content: (this.widget.post == null)
        ? Text("Submit post?")
        : Text("Update post?"),
      actions: [
        FlatButton(
          child: Text("Cancel"),
          onPressed: () async {
            locator<NavigationService>().pop();
          },
        ),
        FlatButton(
          child: (this.widget.post == null)
            ? Text("Post")
            : Text("Update"),
          onPressed: () {
            contentModeration();
          },
        )
      ],
    );

    // Field for name
    final postTitle = TextFormField(
      initialValue: titleInitialValue,
      textCapitalization: TextCapitalization.words,
      maxLength: 28,
      validator: (value) => value.isEmpty ?
        'Post must have title.'
        : value.length > 28
          ? 'Title must not exceed 28 characters.'
          : null,
      onSaved: (String value) {
        _postName = value;
      },
      decoration: InputDecoration(
        hintText: 'Title',
      ),
    );

    // Select feed (looking or offering)
    final chooseType = CupertinoSlidingSegmentedControl(
      backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
      groupValue: pageNum,
      children: myTabs,
      onValueChanged: (int i) {
        setState(() {
          pageNum = i;
          feed = postTypes[i];
        });
      }
    );

    // Select category
    final category = Container(
      child: GestureDetector(
        child: AbsorbPointer(
          child: TextFormField(
            validator: (value) => _category == CATEGORY_PROMPT
              ? 'Post must have category.'
              : null,
            decoration: InputDecoration(
              labelStyle: _category == CATEGORY_PROMPT
                ? TextStyle()
                : currentTheme.isDarkModeEnabled
                  ? TextStyle(color: Colors.white)
                  : TextStyle(color: Colors.black),
              labelText: _category,
              prefixIcon: Icon(
                Icons.format_list_numbered,
              ),
            ),
          ),
        ),
        onTap: () {
          setState(() {_category = categoryOptions[0];});
          showModalBottomSheet(
            isScrollControlled: true,
            shape: BOTTOM_SHEET,
            context: context,
            builder: (BuildContext context) {
              return SizedBox(
                height: 275,
                child: CupertinoTheme(
                  data: CupertinoThemeData(
                    brightness: Theme.of(context).brightness
                  ),
                  child: CupertinoPicker(
                    itemExtent: 50,
                    onSelectedItemChanged: (value) {
                      setState(() {
                        _category = categoryOptions[value];
                      });
                    },
                    children: categoryOptions.entries.map((entry) =>
                      Center(child: Text(entry.value))).toList(),
                  )
                )
              );
            }
          );
        }
      )
    );

    // Field for description
    final postDescription = TextFormField(
      initialValue: descriptionInitialValue,
      textCapitalization: TextCapitalization.sentences,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      maxLengthEnforced: true,
      maxLength: 280,
      minLines: 5,
      validator: (value) =>
          value.isEmpty ? 'Post must have description.' : null,
      onSaved: (String value) {
        _postDescription = value;
      },
      decoration: InputDecoration(
        hintText: 'Description',
      ),
    );

    // Page body
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: _appbarTitle,
        actions: this.widget.post != null
          ? <Widget>[ IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => generateDeletePopUp(
                  this.widget.post.id,
                  feedNum: this.widget.post.feedNum
                )
              );
            }
          ) ]
          : null
      ),

      // Post button
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.send),
          onPressed: () async {
            // Submit post
            _formKey.currentState.save();

            // Succeeeds
            if (_formKey.currentState.validate()) {
              // Confirm
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return confirm;
                  }
                );
            }
          }),

      // Post form
      body: Center(
        child: Form(
          key: this._formKey,
          child: ListView(
            padding: EdgeInsets.only(top: 20.0, left: 24.0, right: 24.0, bottom: 80),
            children: <Widget>[

              // Feed
              (this.widget.post == null) ? chooseType : Container(),
              SizedBox(height: 24.0),

              // Catgeory
              category,
              SizedBox(height: 20.0),

              // Title
              postTitle,

              // Expiration prompt for post creation
              this.widget.post == null
                ? expirationInMonths()
                : Container(),
              SizedBox(height: 8.0),

              // Tags for post
              Text(
                "Tags",
                style: TextStyle(
                  fontSize: 15.5,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400
                )
              ),
              SizedBox(height: 4.0),
              buildChips(_tags, this),
              SizedBox(height: 20.0),
              postDescription
            ],
          ),
        ),
      ),
    );
  }
}
