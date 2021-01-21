/* ************************************************************************
 * FILE : router.dart
 * DESC : Defines routes for navigation
 * ************************************************************************
 */

import 'package:HillSkills/data/globals.dart';
import 'package:HillSkills/screens/about.dart';
import 'package:HillSkills/user/termsofservice.dart';
import 'package:flutter/material.dart';
import 'package:HillSkills/post/staticPostCard.dart';
import 'package:HillSkills/screens/home.dart';
import 'package:HillSkills/screens/login.dart';
import 'package:HillSkills/user/changePassword.dart';
import 'package:HillSkills/user/deleteAccount.dart';
import 'package:HillSkills/user/profile.dart';
import 'package:HillSkills/user/admin.dart';
import 'package:HillSkills/user/profileEdit.dart';
import 'package:HillSkills/post/postCreateEdit.dart';
import 'package:HillSkills/user/settings.dart';
import 'package:HillSkills/registration/addTags.dart';
import 'package:HillSkills/registration/addUser.dart';
import 'package:HillSkills/registration/addAvatar.dart';
import 'package:HillSkills/registration/addUsernameBio.dart';
import 'package:HillSkills/registration/addPics.dart';
import 'package:HillSkills/registration/forgotPassword.dart';
import 'package:HillSkills/screens/chat.dart';
import 'package:HillSkills/utils/imageViewer.dart';
import 'package:HillSkills/user/staticProfile.dart';


// Different named routes to aid in navigation
Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/login':
      return MaterialPageRoute(builder: (context) => LoginPage());
      break;
    case '/home':
      return MaterialPageRoute(builder: (context) => HomePage());
      break;
    case '/profile':
      var userAccount = settings.arguments;
      return MaterialPageRoute(builder: (context) => ProfilePage(userAccount));
      break;
    case '/staticprofile':
      var staticProfData = settings.arguments;
      return MaterialPageRoute(builder: (context) => StaticProfilePage(staticProfData));
      break;
    case '/staticpost':
      var staticPostData = settings.arguments;
      return MaterialPageRoute(builder: (context) => StaticPostCard(staticPostData));
      break;
    case '/profileEdit':
      var userAccount = settings.arguments;
      return MaterialPageRoute(builder: (context) => ProfileEditPage(userAccount));
      break;
    case '/new':
      int pageNum = settings.arguments;
      return MaterialPageRoute(builder: (context) => NewPost(pageNum: pageNum));
      break;
    case '/chat':
      var chatDocument = settings.arguments;
      return MaterialPageRoute(builder: (context) => ChatPage(chatDocument));
      break;
    case '/signup':
      return MaterialPageRoute(builder: (context) => RegistrationPage());
      break;
    case '/changePassword':
      return MaterialPageRoute(builder: (context) => ChangePasswordPage());
      break;
    case '/forgotPassword':
      return MaterialPageRoute(builder: (context) => ForgotPasswordPage());
      break;
    case '/newUser1':
      return MaterialPageRoute(builder: (context) => AddAvatarPage());
      break;
    case '/newUser2':
      var account = settings.arguments;
      return MaterialPageRoute(builder: (context) => AddBioPage(account));
      break;
    case '/newUser3':
      var account = settings.arguments;
      return MaterialPageRoute(builder: (context) => AddPicsPage(account));
      break;
    case '/newUser4':
      var account = settings.arguments;
      return MaterialPageRoute(builder: (context) => AddTagsPage(account));
      break; 
    case '/admin':
      return MaterialPageRoute(builder: (context) => AdminPage());
      break;
    case '/edit':
      var post = settings.arguments;
      return MaterialPageRoute(builder: (context) => NewPost(post: post));
      break;
    case '/about':
      currentTheme.registration = true;
      currentTheme.setNavbar();
      return MaterialPageRoute(builder: (context) => AboutPage());
      break;
    case '/tos':
      return MaterialPageRoute(builder: (context) => TermsOfService());
      break;
    case '/settings':
      return MaterialPageRoute(builder: (context) => SettingsPage());
      break;
    case '/gallery':
      currentTheme.gallery = true;
      currentTheme.setNavbar();
      List imagesData = settings.arguments;
      var images = imagesData[0];
      var index = imagesData[1];
      return MaterialPageRoute(builder: (context) => ImageViewer(images, index));
      break;
    case '/deleteAccount':
      return MaterialPageRoute(builder: (context) => DeleteAccountPage());
      break;
    default:
      return null;
      break;
  }
}
