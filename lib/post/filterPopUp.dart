/* ************************************************************************
 * FILE : filterPopUp.dart
 * DESC : Contains class that pops up catagories for search
 * ************************************************************************
 */

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:HillSkills/data/dynamicGlobals.dart';
import 'package:HillSkills/data/globalWidgets.dart';
import 'package:HillSkills/data/globals.dart';
import 'package:HillSkills/data/tags.dart';
import 'package:HillSkills/screens/postFeed.dart';
import 'package:HillSkills/utils/backend/feedInteraction.dart';
import 'package:HillSkills/data/formFieldData.dart';
import 'package:HillSkills/utils/navigation.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class CategoryTags extends HillSkillsTags {
  CategoryTags() {
    this.tagLabels = categoryOptionsList;
    this.generateTagValues();
  }
}

class Filter {
  bool enabled = false;
  CategoryTags categoryFilter = CategoryTags();
  PostTags tagFilter = PostTags();

  // Checks if no filters selected
  bool noFiltersSelected() {

    // Neither enabled
    return categoryFilter.empty() && tagFilter.empty();
  }

  // Checks if post matches filter
  bool matchesFilter(Post post) {

    // Neither enabled
    if (categoryFilter.empty() && tagFilter.empty())
      return true;
    
    // Tags enabled
    if (categoryFilter.empty())
      return post.tags.atLeastOneOf(tagFilter);

    // Categories enabled
    if (tagFilter.empty())
      return categoryFilter[post.category];

    // Both enabled
    return post.tags.atLeastOneOf(tagFilter) && categoryFilter[post.category];
  }

  // Clears filters
  void clear() {
    enabled = false;
    categoryFilter = CategoryTags();
    tagFilter = PostTags();
  }
}


// Takes Post object as parameter
class PostFeedFilters extends StatefulWidget {
  final PostFeed postFeed;
  final dynamic searchBarState;
  PostFeedFilters(this.postFeed, this.searchBarState, {Key key}) : super(key: key);

  @override
  PostFeedFiltersState createState() => new PostFeedFiltersState();
}

// Builds dynamic catagory filter popup
class PostFeedFiltersState extends State<PostFeedFilters> {

  @override
  void initState() {
    super.initState();
  }

  void setMyState() async {
    setState(() {});
  }

  // Save button
  floatingActionButton(){ 
    return Container(
      alignment: Alignment.bottomRight,
      child:  FloatingActionButton(
        onPressed: () {

          // Add filters and refresh if filters selected
          if (! this.widget.postFeed.filter.noFiltersSelected()) {
            this.widget.postFeed.filter.enabled = true;
            this.widget.searchBarState.setMyState();
            this.widget.postFeed.setMyState();
          }
          locator<NavigationService>().pop();
        },
        child: Icon(MdiIcons.filterOutline),
      )
    );
  }

  // Builds filter tags for categories
  Widget categoryFilters() {

    List<Widget> chips = chipListBuilder(
      tags: this.widget.postFeed.filter.categoryFilter,
      parent: this,
      borders: true
    );

    return Container(
      width: 700,
      child: Wrap(
        direction: Axis.horizontal,
        crossAxisAlignment: WrapCrossAlignment.start,
        runAlignment: WrapAlignment.start,
        spacing: 1.0,
        runSpacing: 1.0,
        children: chips,
      )
    );
  }

  // Builds widget
  @override
  Widget build(BuildContext context) {
    
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(padding: EdgeInsets.all(10), child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter by Category', style: TextStyle(fontSize: 16)),
              SizedBox(height: 7),
              
              // Build catagory widget inside a scrollabe wrap
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: categoryFilters(),
              ),

              // Divider
              Container(
                height: 20,
                decoration: BoxDecoration(border: Border(
                  bottom: BorderSide(color: currentTheme.cardColor())
                ))
              ),

              SizedBox(height: 20),
              Text('Filter by Tags', style: TextStyle(fontSize: 16)),
              SizedBox(height: 7),

              // Create the selectable tag space
              Container(
                child: buildChips(
                  this.widget.postFeed.filter.tagFilter,
                  this,
                  borders: true
                )
              ),

              SizedBox(height: 32),
            ]
          )),

          // Submit button
          floatingActionButton()
        ]
      )
    );
  }
}