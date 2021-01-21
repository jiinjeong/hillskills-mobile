/* ************************************************************************
 * FILE : postStream.dart
 * DESC : Builds stream of postCard items
 * ************************************************************************
 */

import 'package:algolia/algolia.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:HillSkills/post/filterPopUp.dart';
import 'package:HillSkills/utils/backend/feedInteraction.dart';
import 'package:HillSkills/post/postCard.dart';

// Given a snapshot, builds a list of post cards
Widget postListView(dynamic snapshot, {Filter filter}) {
  if (snapshot is QuerySnapshot || snapshot is CustomQuerySnapshot)
    return firebaseListView(snapshot, filter);
  else if (snapshot is AlgoliaQuerySnapshot)
    return algoliaListView(snapshot, filter);
  else throw FlutterError("Malformed snapshot passed to builder.\n\nType was:\n"
    + snapshot.runtimeType.toString() + "\n");
}

// Builds cards from firebase snapshot
Widget firebaseListView(dynamic snapshot, Filter filter) {

  if (snapshot.docs.isEmpty)
    return Container();

  return ListView.builder(
    primary: false, // Always contained in other ListView
    shrinkWrap: true,
    itemCount: snapshot.docs.length,
    itemBuilder: (context, index) {
      QueryDocumentSnapshot doc = snapshot.docs[index];
      Post post = Post().fromJson(doc.id, doc.data());

      // If filtered out
      if (filter != null && filter.enabled && !filter.matchesFilter(post))
        return Container();

      return createPostCard(post);
    }
  );
}

// Builds cards from algolia snapshot
Widget algoliaListView(AlgoliaQuerySnapshot snapshot, Filter filter) {

  if (snapshot.hits.isEmpty)
    return Container();

  return ListView.builder(
    primary: false, // Always contained in other ListView
    shrinkWrap: true,
    itemCount: snapshot.hits.length,
    itemBuilder: (context, index) {
      AlgoliaObjectSnapshot doc = snapshot.hits.elementAt(index);
      Map<String, dynamic> docData = doc.data;
      Post post = Post().fromJson(doc.objectID, docData);

      // If filtered out
      if (filter != null && filter.enabled && !filter.matchesFilter(post))
        return Container();

      return createPostCard(post);
    }
  );
}
