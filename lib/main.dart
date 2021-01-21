/* ************************************************************************
 * FILE : main.dart
 * DESC : Starts and runs the app
 * ************************************************************************
 */
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:HillSkills/utils/backend/accountManagement.dart';
import 'package:package_info/package_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/router.dart' as router;
import 'utils/navigation.dart';
import 'data/theme.dart';
import 'data/globals.dart';

// Main function
void main() async {
  
  // Theme navbar
  currentTheme.setNavbar();

  WidgetsFlutterBinding.ensureInitialized();

  // Sets default preferences
  prefs = await SharedPreferences.getInstance();
  if (!prefs.containsKey(CURRENT_THEME))
    await prefs.setString(CURRENT_THEME, SYSTEM);

  // Setup Firebase.
  await Firebase.initializeApp();

  // Setup Algolia
  if (AccountManagement().loggedIn())
    algoliaInstance = await apiCredentials.getAlgoliaCredfromFb();

  // Fetches some globals from backend
  if (AccountManagement().loggedIn())
    await dynamicGlobals.loadGlobals();

  // Fetches version number
  packageInfo = await PackageInfo.fromPlatform();

  // For navigation outside widgets.
  setupLocator();

  // Determine whether user is new
  newAccount = await AccountManagement().isUserNew();

  // Gets system theme
  WidgetsFlutterBinding.ensureInitialized();
  await switchThemeMode(prefs.getString(CURRENT_THEME));

  runApp(MyApp());
}

// Builds app
class MyApp extends StatefulWidget {
  @override
  MyAppState createState() => new MyAppState();
}

class MyAppState extends State<MyApp> with WidgetsBindingObserver {

  // Set app theme on change
  @override
  void initState() {
    super.initState();
    // Listens for opening/closing
    WidgetsBinding.instance.addObserver(this);
    // Listens for theme changes from settings
    currentTheme.addListener(setMyState);
    // Theme navbar
    currentTheme.setNavbar();
  }

  @override
  void dispose() {
    super.dispose();
    currentTheme.removeListener(setMyState);
    WidgetsBinding.instance.removeObserver(this);
  }

  // Sets navbar theme on relaunch
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if(state == AppLifecycleState.resumed){
      currentTheme.setNavbar();
    }
  }

  // Sets system theme on change
  @override
  void didChangePlatformBrightness() {
    switchThemeMode(prefs.getString(CURRENT_THEME));
  }

  void setMyState() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    // Sets the initial screen to either login or main, depending on
    // logged-in status.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      navigatorKey: locator<NavigationService>().navigatorKey,
      onGenerateRoute: router.generateRoute,
      initialRoute: AccountManagement().loggedIn()
        ? newAccount
          ? '/newUser1'
          : '/home'
        : '/login',
      theme: light,
      darkTheme: dark,
      themeMode: currentTheme.theme(),
    );
  }
}