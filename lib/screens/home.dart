/* ************************************************************************
 * FILE : home.dart
 * DESC : Main page with bottom navigation to move between subpages. 
 * ************************************************************************
 */

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:HillSkills/data/globalWidgets.dart';
import 'package:HillSkills/data/globals.dart';
import 'package:HillSkills/utils/backend/feedInteraction.dart';
import 'package:HillSkills/utils/backend/userInteraction.dart';
import 'postFeed.dart';
import 'socialFeed.dart';
import 'package:HillSkills/utils/navigation.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'messages.dart';

// Homepage widget -- single use
class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => new HomePageState();
}

// Dynamic data for widget
class HomePageState extends State<HomePage> {

  // Switches the page content based on the tab selected
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  // Pages used in app
  List<Widget> pagesList;

  @override
  void initState() {
    super.initState();

    // Navbar color
    currentTheme.registration = false;
    currentTheme.setNavbar();

    // Creates feeds with relevant data
    looking = PostFeed(
      lookingFeed,
      lookingSearchController,
      key: UniqueKey()
    );

    offering = PostFeed(
      offeringFeed,
      offeringSearchController,
      key: UniqueKey()
    );

    MessagePage messagePage = MessagePage();

    SocialFeed socialPage = SocialFeed();

    pagesList = <Widget>[looking, offering, messagePage, socialPage];
  }

  // If search is open, closes on back button instead of closing page
  Future<bool> handlePopPage() async {
    if (_selectedIndex < 2) {
      PostFeed feed = pagesList[_selectedIndex];
      if (feed.searchBarContainer.open) {
        feed.searchBarContainer.searchbar.toggleSearch();
        return false;
      }
    }
    return true;
  }
  
  @override
  Widget build(BuildContext context) {
    return WillPopScope(

      // Useful for leaving search
      onWillPop: () => handlePopPage(),

      // Builds home widget
      child: Scaffold(

        // For snackbars 
        key: snackbarKeys[HOME],

        // The top app bar
        appBar: AppBar(
          centerTitle: true,
          toolbarHeight: 60.0,

          // Displays HillSkills logo
          title: Image.asset(
            'assets/logo_blue.png',
            fit: BoxFit.contain,
            color: currentTheme.defaultColor(),
            height: 45.0,
          ),
          brightness: currentTheme.isDarkModeEnabled ? Brightness.dark : Brightness.light,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,

          // User profile widget
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.account_circle, size: 27),
              tooltip: 'Show user account',
              onPressed: () async {
                locator<NavigationService>().navigateWithParameters(
                  '/profile',
                  await UserInteraction().loadCurrentUser()
                );
              },
              color: currentTheme.defaultColor(),
            )
          ]),

        // Body with content for the four subpages.
        body: IndexedStack(
          children: pagesList,
          index: _selectedIndex
        ),

        // Widget to add a new post
        floatingActionButton: _selectedIndex < 2
          ? FloatingActionButton(
            onPressed: () {
              locator<NavigationService>()
                .navigateWithParameters('/new', _selectedIndex % 2);
            },
            child: Icon(Icons.add),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black)
          : null,

        // Shadow for bottom navbar
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Colors.black.withAlpha(50),
                blurRadius: 4,
              ),
            ],
          ),

          // Bottom navigation bar
          child: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(MdiIcons.binoculars),
                label: 'Looking',
              ),
              BottomNavigationBarItem(
                icon: Icon(MdiIcons.hammerWrench),
                label: 'Offering',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.message),
                label: 'Messages',
              ),
              BottomNavigationBarItem(
                icon: Icon(MdiIcons.web),
                label: 'Feed',
              ),
            ],
            type: BottomNavigationBarType.fixed,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
          )
        )
      )
    );
  }
}
