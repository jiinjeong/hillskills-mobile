/* ************************************************************************
 * FILE : searchBar.dart
 * DESC : Contains class producing a searchbar for post feeds.
 * ************************************************************************
 */

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:HillSkills/data/globals.dart';
import 'package:HillSkills/screens/postFeed.dart';
import 'package:HillSkills/utils/navigation.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

// Create a state for the search bar
class SearchBar extends StatefulWidget {
  final PostFeed postFeed;
  final SearchBarState myState = new SearchBarState();
  final FocusNode searchFocus;

  SearchBar(this.postFeed, this.searchFocus, {Key key}) : super(key: key);

  @override
  SearchBarState createState() => myState;

  // Toggles search open/close
  void toggleSearch() {
    myState.openCloseSearch();
  }
}

// Build the search bar
class SearchBarState extends State<SearchBar>
  with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  bool searchOpen = false;
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

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

  // Searches for string in feed
  void searchFor(String searchString) {
    this.widget.postFeed.search(searchString);
  }

  // Search icon and space to type text
  Row searchField() {
    return Row( children: <Widget>[

      // Magnifying glass or back arrow
      Padding(
        padding: EdgeInsets.only(left: 22, top: 16, bottom: 16, right: 16),
        child: Icon(searchOpen
          ? Icons.arrow_back
          : Icons.search
        )
      ),
      
      // Area to type search
      Expanded(child: IgnorePointer(
        ignoring: !searchOpen,
        child: TextField(
          controller: _searchController,
          focusNode: this.widget.searchFocus,
          onSubmitted: (searchString) => searchFor(searchString),
          textInputAction: TextInputAction.search,
          cursorColor: currentTheme.cursorColor(),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.all(0),
            fillColor: Colors.transparent,
            hintText: 'Search',
            hintStyle: searchOpen
              ? null
              : TextStyle(color: currentTheme.cursorColor())
          ),
        )
      ))
    ]);
  }

  // Function creates icon buttons with limited padding for search
  filterButton(){
    return InkWell(
      borderRadius: BorderRadius.all(Radius.circular(100)),
      child: Container(
        child: Icon(

          // Turn on or off filter icon
          this.widget.postFeed.filter.enabled
            ? MdiIcons.filterOffOutline
            : MdiIcons.filterOutline
        ),
        padding: EdgeInsets.only(left: 22, top: 16, bottom: 16, right: 22),
      ),

      onTap: () {
        // Either turn off filter or allow for selection
        if(this.widget.postFeed.filter.enabled) {
          setState(() {this.widget.postFeed.filter.clear();});
          this.widget.postFeed.setMyState();
        }
        else
          locator<NavigationService>().launchFeedFilters(this.widget.postFeed, this, UniqueKey());
      },
      onLongPress: () {
        // Allow forselection on long press
        if(this.widget.postFeed.filter.enabled)
          locator<NavigationService>().launchFeedFilters(this.widget.postFeed, this, UniqueKey());
      },
    );
  }

  // Handles launching and closing search
  void openCloseSearch() {
    // Opens searchbar and focuses keyboard
    if (!searchOpen) {
      setState((){searchOpen = true;});
      this.widget.postFeed.searchBarContainer.open = true;
      this.widget.searchFocus.requestFocus();
    }

    // CLoses and clear searchbar
    else {
      this.widget.searchFocus.unfocus();
      this.widget.postFeed.filter.enabled = false;
      _searchController.clear();
      setState(() {searchOpen = false;});
      this.widget.postFeed.searchBarContainer.open = false;
      this.widget.postFeed.exitSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container(
      padding: EdgeInsets.only(bottom: 5),
      child: Material(
        borderRadius: VERY_ROUND,
        color: currentTheme.cardColor(),
        child: InkWell(
          borderRadius: VERY_ROUND,
          // Launches search text field
          onTap: () => openCloseSearch(),
          // Row includes search field and filter icon
          child: Row(
            children: [
              Expanded(child: searchField()),
              filterButton()
            ]
          )
        )
      )
    );
  }
}
