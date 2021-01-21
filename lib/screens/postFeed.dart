/* ************************************************************************
 * FILE : postFeed.dart
 * DESC : Class to produce a feed of posts (looking or offering)
 * ************************************************************************
 */

import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:HillSkills/data/globalWidgets.dart';
import 'package:HillSkills/data/globals.dart';
import 'package:HillSkills/post/filterPopUp.dart';
import 'package:HillSkills/post/postListView.dart';
import 'package:HillSkills/post/searchbar.dart';
import 'package:HillSkills/utils/backend/feedInteraction.dart';

// Looking and offering subpages
PostFeed looking;
PostFeed offering;

// Used to contain searchbar in stateless widgets
class SearchBarContainer{
  SearchBar searchbar;
  bool open = false;
}

// Used to contain snapshot in stateless widgets
class SnapshotContainer {
  bool searchMode = false;
  QuerySnapshot regularSnapshot;
  AlgoliaQuerySnapshot searchSnapshot;
  bool failed = false;
  String searchString;

  dynamic snapshot() {
    return searchMode
      ? searchSnapshot
      : regularSnapshot;
  }
}

// Two widget with respective gradients and feeds from which to refresh
class PostFeed extends StatefulWidget {
  final FeedInteraction feed;
  final SnapshotContainer snapshotContainer = SnapshotContainer();
  final Filter filter = Filter();
  final SearchBarContainer searchBarContainer = SearchBarContainer();
  final FocusNode searchController;

  // Keys differentiate widgets
  PostFeed(this.feed, this.searchController, {Key key}) : super(key: key){

    // Searchbar used in feed
    searchBarContainer.searchbar = SearchBar(this, searchController, key: UniqueKey());
  }
  final PostFeedState myState = new PostFeedState();

  @override
  PostFeedState createState() => myState;

  // Refreshes regular feed
  Future<void> refresh({online = true}) async {
    snapshotContainer.failed = false;
    try{ snapshotContainer.regularSnapshot = await feed.getSnapshot(online); }
    catch(e) {
      snapshotContainer.failed = true;
      showSnackBar(HOME, 'Error loading data!');
    }
    setMyState();
  }

  // Refreshes search feed
  Future<void> refreshSearch() async {
    snapshotContainer.failed = false;
    try{
      snapshotContainer.searchSnapshot =
        await feed.getSearchSnapshot(snapshotContainer.searchString);
    }
    catch(e) {
      snapshotContainer.failed = true;
      showSnackBar(HOME, 'Error loading data!');
    }
    setMyState();
  }

  // Searches feed for particular string
  Future<void> search(String searchString) async {
    snapshotContainer.searchMode = true;
    snapshotContainer.searchString = searchString;
    snapshotContainer.searchSnapshot = null;
    setMyState();
    await refreshSearch();
  }

  // CLoses search and returns to regular feed
  void exitSearch() {
    snapshotContainer.searchMode = false;
    setMyState();
    snapshotContainer.searchSnapshot = null;
  }

  // Simply feed state
  void setMyState() {
    myState.setMyState();
  }
}

// Dynamic widget for feeds
class PostFeedState extends State<PostFeed> {
  
  @override
  void initState() {
    super.initState();

    // Refresh at launch time
    this.widget.refresh(online: false);

    // Listen for theme changes
    currentTheme.addListener(setMyState);
  }

  @override
  void dispose() {
    currentTheme.removeListener(setMyState);
    super.dispose();
  }

  void setMyState() {
    setState(() {});
  }

  // Builds widget
  @override
  Widget build(BuildContext context) {

    // Wraps feed for refresh
    return HillSkillsRefreshIndicator(

      // Top-level feed list
      child: Stack(children: [
        ListView(
          padding: EdgeInsets.only(left: 14, right: 14, top: 14, bottom: 160),
          children: [

            // Searchbar
            this.widget.searchBarContainer.searchbar,
            
            // Posts
            this.widget.snapshotContainer.snapshot() != null
              ? postListView(
                this.widget.snapshotContainer.snapshot(),
                filter: this.widget.filter
              )
              : Container()
        ]),

        // Loading animations
        this.widget.snapshotContainer.failed ||
          this.widget.snapshotContainer.snapshot() != null

          // On failed to load
          ? Container()

          // While loading
          : Center(child: CircularProgressIndicator())
      ]),

      // Refreshes on swipe down
      onRefresh: () => this.widget.snapshotContainer.searchMode
        ? this.widget.refreshSearch()
        : this.widget.refresh()
    );
  }
}
