/* ************************************************************************
 * FILE : userListView.dart
 * DESC : Builds stream of userCard items
 * ************************************************************************
 */

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:HillSkills/user/userCard.dart';
import 'package:HillSkills/utils/backend/userInteraction.dart';

// Given a snapshot, builds a list of post cards
Widget userListView(dynamic snapshot) {
  if (snapshot is QuerySnapshot)
    return firebaseUserListView(snapshot);
  else throw FlutterError("Malformed snapshot passed to builder");
}

// Builds cards from firebase snapshot
Widget firebaseUserListView(QuerySnapshot snapshot) {

  if (snapshot.docs.isEmpty)
    return Container();

  return ListView.builder(
    primary: false, // Always contained in other ListView
    shrinkWrap: true,
    itemCount: snapshot.docs.length,
    itemBuilder: (context, index) {
      QueryDocumentSnapshot doc = snapshot.docs[index];
      UserAccount user = UserAccount().fromJson(doc.data(), doc.id);
      return UserCard(user);
    }
  );
}
