/* ************************************************************************
 * FILE : admin.dart
 * DESC : Administrator page.
 * ************************************************************************
 */

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:HillSkills/post/postListView.dart';
import 'package:HillSkills/user/userListView.dart';
import 'package:HillSkills/utils/backend/feedInteraction.dart';
import 'package:flutter/cupertino.dart';

// Admin page layout
class AdminPage extends StatefulWidget {
  @override
  AdminPageState createState() => new AdminPageState();
}

class AdminPageState extends State<AdminPage> {
  Widget reportedLookingPosts;
  Widget reportedOfferingPosts;
  Widget reportedUsers;

    // Loads the reported posts and profiles
  Future<void> loadData() async {
    // Reported Looking posts
    reportedLookingPosts = await getReportedPosts(lookingFeed);
    setState(() {});

    // Reported Offering posts
    reportedOfferingPosts = await getReportedPosts(offeringFeed);
    setState(() {});

    // Reported Offering posts
    reportedUsers = await getReportedUsers(userFeed);
    setState(() {});
  }

  Future<Widget> getReportedPosts(FeedInteraction feed) async {
    return postListView(
      await feed.getSnapshotWithReports()
    );
  }

  Future<Widget> getReportedUsers(FeedInteraction feed) async {
    return userListView(
      await feed.getSnapshotWithReports()
    );
  }
  
  @override
  void initState() {
    super.initState();
    loadData();
  }


  int currPage = 0;

  final Map<int, Widget> logoWidgets = const <int, Widget>{
    0: Text('Reported Posts'),
    1: Text('Reported Profiles'),
  };

  getCurrPage(){
    switch(currPage){
      case 0: 
        return loadReportedPosts(); 
        break;
      case 1: 
        return loadReportedUsers(); 
        break;
    }
  }

  loadReportedPosts(){
    List<Widget> posts = [];
    if(reportedLookingPosts != null && reportedLookingPosts.runtimeType != Container){
      posts.add(reportedLookingPosts);
    }
    if(reportedOfferingPosts != null && reportedOfferingPosts.runtimeType != Container){
      posts.add(reportedOfferingPosts);
    }
    
    if(posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(height: (MediaQuery.of(context).size.height * 0.3)),
            Text("No Reported Posts", style: TextStyle(fontSize: 22)),
            Text("Come back later!", style: TextStyle(fontSize: 13)),
          ]
        )
      );
    }
      return ListView(primary: false, shrinkWrap: true, children: posts);
  }

  loadReportedUsers(){
    List<Widget> users = [];
    if(reportedUsers != null && reportedUsers.runtimeType != Container){
      users.add(reportedUsers);
    }
    if(users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(height: (MediaQuery.of(context).size.height * 0.3)),
            Text("No Reported Users", style: TextStyle(fontSize: 22)),
            Text("Come back later!", style: TextStyle(fontSize: 13)),
          ]
        )
      );
    }
    return ListView(primary: false, shrinkWrap: true, children: users);
  }

  pagePicker(){
    return CupertinoSlidingSegmentedControl<int>(
      children: logoWidgets,
      onValueChanged: (int val) {
        setState(() {
          currPage = val;
        });
      },
      groupValue: currPage,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Body of widget
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Page'),
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: <Widget>[
          pagePicker(),
          getCurrPage(),
        ]
      )
    );
  }
}