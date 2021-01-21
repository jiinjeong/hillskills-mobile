/* ************************************************************************
 * FILE : profile.dart
 * DESC : User profile page displaying one's personal info
 *        with options to edit and log-out.
 * ************************************************************************
 */

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:HillSkills/data/globalWidgets.dart';
import 'package:HillSkills/post/postListView.dart';
import 'package:HillSkills/utils/backend/accountManagement.dart';
import 'package:HillSkills/utils/backend/feedInteraction.dart';
import 'package:HillSkills/utils/backend/userInteraction.dart';
import 'package:HillSkills/utils/navigation.dart';
import 'package:HillSkills/data/globals.dart';

// User profile page widget
class ProfilePage extends StatefulWidget {

  ProfilePage(this.userAccount);
  final UserAccount userAccount;

  @override
  ProfilePageState createState() => new ProfilePageState();
}

// Dynamic data for profile
class ProfilePageState extends State<ProfilePage> {
  UserAccount userAccount;
  Stream lookingStream;
  Stream offeringStream;
  Stream<CustomQuerySnapshot> likedStream;
  bool isAdmin = false;

  // Loads data belonging to given user
  void loadData() {

    // Stops logout error
    if (!AccountManagement().loggedIn())
      return;

    // Liked posts
    likedStream = checkifOwner()
      ? getLikedSnapshot()
      : Stream.value(CustomQuerySnapshot([]));

    // Looking
    lookingStream = lookingFeed.getFilteredStream(AUTHOR, isEqualTo: userAccount.id);

    // Offering
    offeringStream = offeringFeed.getFilteredStream(AUTHOR, isEqualTo: userAccount.id);

    // Images
    loadPhotos();

    // Admin priviledges
    checkIfAdmin();
  }

  void checkIfAdmin() async {
    UserAccount currentUser = await UserInteraction().loadSingleUser(AccountManagement().currentUserId());
    isAdmin = currentUser.admin;
    setState(() {});
  }

  Future<void> loadPhotos() async {
    await userAccount.loadPhotos();
    setState(() {});
  }
  
  @override
  void initState() {
    super.initState();
    this.userAccount = this.widget.userAccount;
    loadData();
    currentTheme.addListener(loadData);
  }

  @override
  void dispose() {
    super.dispose();
    currentTheme.removeListener(loadData);
  }

  // Check if current user is the owner of the post
  bool checkifOwner() {
    return this.userAccount != null
    && this.userAccount.id == AccountManagement().currentUserId();
  }

  Widget _buildChips() {
    List<Widget> chips = new List();
    List<String> skillStrs = this.userAccount.skills.toArray();

    for (int i = 0; i < skillStrs.length; i++) {

      Chip filterChip = Chip(
        label: Text(
          skillStrs[i],
          style: TextStyle(
            color: currentTheme.isDarkModeEnabled
              ? Colors.white54
              : Colors.grey[700]
          ),
        ),
        backgroundColor: Colors.transparent,
        shape: StadiumBorder(side: BorderSide(
          color: currentTheme.isDarkModeEnabled
            ? Colors.white54
            : Colors.grey[700]
        )),
      );

      chips.add(Padding(
        padding: EdgeInsets.symmetric(horizontal: 2), child: filterChip
      ));
    }

    return horizontalChips(chips);
  }

  showAvatarAndUsername(){
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          this.userAccount.userAvatar(radius: 120),
          SizedBox(
            height: 10.0,
          ),

          // Username
          Text(
            this.userAccount.userName,
            style: Theme.of(context).textTheme.headline6,
          ),
          SizedBox(height: 14.0),

        ],
      ),
    );
  }

  showTags(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'I\'m good at:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600
          )
        ),
        SizedBox(height: 8.0),
        Container(child: _buildChips()),
        SizedBox(height: 14.0)
      ]
    );
  }

  showPhotos(){
    return this.userAccount.photos != null
    && this.userAccount.photos.isEmpty
      ? Container()
      : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Text(
            'Here are some things I\'ve done:',
            style: TextStyle( 
              fontSize: 16,
              fontWeight: FontWeight.w600
            )
          ),
          SizedBox(height: 8.0),
          SizedBox(
            height: 200.0,
            child: this.userAccount.photos == null

              // Loading
              ? Center(child: CircularProgressIndicator())

              // Images list
              : ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: this.userAccount.photos.length,
                itemBuilder: (BuildContext context, int index) => InkWell(
                  child: Card(
                    elevation: 0,
                    semanticContainer: true,
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    child: Image(image: this.userAccount.photos[index])
                  ),
                  onTap: () => locator<NavigationService>()
                    .navigateWithParameters('/gallery', [this.userAccount.photos, index])
                    .then((response) {
                      currentTheme.gallery = false;
                      currentTheme.setNavbar();
                    })
                )
              )

          ),
          SizedBox(height: 14.0),
        ]
      );
  }

  showBio(){
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'A little about myself:',
          style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w600
          )
        ),
        SizedBox(height: 8.0),
        Text(
          this.userAccount.bio,
          style: TextStyle(
            fontSize: 16,
          )
        ),
        SizedBox(height: 14.0),
      ],
    );
  }
  
  // Posts from stream in dropdown
  Widget postListDropDown({@required Stream stream, @required String title}){
    return StreamBuilder(
      stream: stream,
      builder: (BuildContext context, AsyncSnapshot snapshot) {

        // If no data yet
        if (!snapshot.hasData && !snapshot.hasError) return Center(child: CircularProgressIndicator());
        else if (snapshot.hasError || snapshot.data == null || snapshot.data.docs.isEmpty) return Container();

        // Expansion tile
        return HillSkillsExpansion(
          title: title,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          children: [
            postListView(snapshot.data)
          ]
        );
      }
    );
  }

  // Admin button
  Widget adminButton() {
    return IconButton(
      icon: Icon(Icons.admin_panel_settings_outlined),
        tooltip: 'Admin',
        onPressed: () => locator<NavigationService>().navigateTo('/admin')
    );
  }
  
  Widget profileEditButton() {
    return IconButton(
      icon: Icon(Icons.edit),
      tooltip: 'Edit',
      onPressed: () {
        locator<NavigationService>().navigateWithParameters(
          '/profileEdit',
          this.userAccount
        ).then((result) {

          // Update account
          if (result != null && result is UserAccount) {
            if (result.photos == null) {
              result.photos = this.userAccount.photos;
            }
            setState(() { this.userAccount = result; });
          }
        });
      }
    );
  }

  // Setting page
  Widget settingsButton(){
    return IconButton(
        icon: Icon(Icons.settings),
        tooltip: 'Preferences',
        onPressed: () => locator<NavigationService>().navigateTo('/settings')
    );
  }

  makeBottomSheet(BuildContext context, UserAccount user) {
    return CupertinoActionSheet(
      actions: <Widget>[
        CupertinoActionSheetAction(
          child: Text('View Strikes'),
          onPressed: () async {

          AlertDialog postAdminPopUp = await generateStrikesPopUp(user);

          showDialog(
            context: context,
            builder: (BuildContext context) => postAdminPopUp
          );
        },
        ),
        CupertinoActionSheetAction(
          child: Text('Give Strike', style: TextStyle(color: Colors.red)),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) => 
                  generateStrikeUserPopUp(this.userAccount)
            );
          },
        ),
      ],

      cancelButton: CupertinoActionSheetAction(
        child: Text('Cancel'),
        onPressed: () {
          Navigator.pop(context);
        },

      )
    );
  }

  List<Widget> ownerButtons() {
    if(this.userAccount.admin){
      return <Widget> [adminButton(), profileEditButton(), settingsButton()];
    }
    return <Widget>[profileEditButton(), settingsButton()];
  }

  List<Widget> otherUserButtons() {
    return <Widget> [
      IconButton(
        icon: Icon(Icons.flag),
        tooltip: 'Report',
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) => 
                  generateReportUserPopUp(this.userAccount)
          );
        }
      ),
      isAdmin
        ? Container(
          //alignment: Alignment.topRight,
          padding: EdgeInsets.only(right: 13),
          child: GestureDetector(
            child: Icon(Icons.more_vert, color: Colors.white),
            onTap: () {
              showCupertinoModalPopup(
                context: context,
                builder: (BuildContext context) 
                  => makeBottomSheet(context, this.userAccount));
            }
          )
        )
        
        : Container(),
    ];
  }

  @override
  Widget build(BuildContext context) {

    // Main widget for profile pags
    return Scaffold(
      appBar: AppBar(
        title: Text(this.userAccount.userName),
        actions: checkifOwner()
          ? ownerButtons()
          : otherUserButtons()
      ),
      
      // Body is currently static placeholder data -- wil be rewritten
      body:  ListView(
        children: <Widget>[Padding(
          padding: STANDARD_SPACING,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              showAvatarAndUsername(),
              // Bio
              showBio(),
              // Tags
              showTags(),
              // Photos 
              showPhotos(),
              SizedBox(height: 4),
              // Liked posts
              postListDropDown(stream: likedStream, title: 'My bookmarked posts:'),
              SizedBox(height: 4),
              // Looking posts
              postListDropDown(stream: lookingStream, title: 'Currently looking for:'),
              SizedBox(height: 4),
              // Offering posts
              postListDropDown(stream: offeringStream, title: 'Currently offering:'),
            ]
          )
          ),
        ]
      )
    );
  }
}
