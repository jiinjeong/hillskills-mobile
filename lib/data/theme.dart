/* ************************************************************************
 * FILE : theme.dart
 * DESC : Stores the light and dark theme colors, fonts, etc.. 
 * ************************************************************************
 */

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:HillSkills/data/globals.dart';

// Current app theme (light or dark)
class CurrentTheme with ChangeNotifier {

  bool registration = true;
  bool gallery = false;

  // Stores static dark mode value
  static bool darkModeEnabled = false;
  get isDarkModeEnabled {
    return darkModeEnabled;
  }

  // Returns current theme
  ThemeMode theme() {
    return darkModeEnabled ? ThemeMode.dark : ThemeMode.light;
  }

  // Color used on some app elements
  Color defaultColor() {
    return darkModeEnabled ? Colors.white : PRIMARY_COLOR;
  }

  // Gradients used on cards
  LinearGradient lookingGradient() {
    return darkModeEnabled ? lookingGradientDark : lookingGradientLight;
  }
  LinearGradient offeringGradient() {
    return darkModeEnabled ? offeringGradientDark : offeringGradientLight;
  }

  // Color used for cards and some other visual elements
  Color cardColor() {
    return isDarkModeEnabled
      ? Colors.grey[800]
      : Colors.grey[300];
  }

  // Color used for caursor
  Color cursorColor() {
    return isDarkModeEnabled
      ? Colors.white
      : Colors.black;
  }
  
  // Used for light text
  TextStyle postTextStyle() {
    return TextStyle(
      fontSize: 16,
      color: isDarkModeEnabled
        ? Colors.grey[500]
        : Colors.grey[800],
      fontWeight: FontWeight.w400
    );
  }

  // Sets navbar theme
  void setNavbar() {

    // In gallery
    if(this.gallery) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.black,
          systemNavigationBarIconBrightness: Brightness.light
        )
      );
      return;
    }

    // In registration
    if(this.registration) {
      SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: PRIMARY_COLOR,
          systemNavigationBarIconBrightness: Brightness.light
        )
      );
      return;
    }

    darkModeEnabled
      ? SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: Color(0xFF121212),
          systemNavigationBarIconBrightness: Brightness.light
        )
      )
      : SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(
          systemNavigationBarColor: Color(0xFFFAFAFA),
          systemNavigationBarIconBrightness: Brightness.dark
        )
      );
  }

  // Switches theme
  void switchTheme() {
    
    // Stes navbar color
    setNavbar();

    // Informs home to update theme
    notifyListeners();
  }

  // Switches theme to dark
  void enableDark() {
    darkModeEnabled = true;
    setNavbar();

    // Informs home to update theme
    notifyListeners();
  }

  // Switches theme to dark
  void enableLight() {
    darkModeEnabled = false;
    setNavbar();

    // Informs home to update theme
    notifyListeners();
  }
}

// Used to switch themes
Future<void> switchThemeMode(String name) async {
  switch(name) {

    // Switches theme to light
    case LIGHT:
      await prefs.setString(CURRENT_THEME, LIGHT);
      if (currentTheme.isDarkModeEnabled) currentTheme.enableLight();
      break;

    // Switches theme to dark
    case DARK:
      await prefs.setString(CURRENT_THEME, DARK);
      if (!currentTheme.isDarkModeEnabled) currentTheme.enableDark();
      break;

    // Switches theme to system
    default:
      await prefs.setString(CURRENT_THEME, SYSTEM);
      if (WidgetsBinding.instance.window.platformBrightness == Brightness.dark)
        currentTheme.enableDark();
      else
        currentTheme.enableLight();
      break;
  }
}

// Light theme
ThemeData light = ThemeData(
  fontFamily: 'Poppins',
  primaryColor: PRIMARY_COLOR,
  accentColor: SECONDARY_COLOR,
  dividerColor: Colors.grey[50],
  brightness: Brightness.light,
  backgroundColor: const Color(0xFFE5E5E5),
  textSelectionColor: Color(0x212121).withOpacity(0.3),
  textSelectionHandleColor: Color(0xFFd6ba8b),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: PRIMARY_COLOR, foregroundColor: Colors.white),
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: EdgeInsets.all(15.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        width: 0,
        style: BorderStyle.none,
      ),
    ),
    filled: true,
    fillColor: Colors.grey[200],
  ),
  chipTheme: chipThemeLight,
  cardColor: Colors.white,
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    )
  ),
  indicatorColor: PRIMARY_COLOR,
);

// Dark theme
ThemeData dark = ThemeData(
  fontFamily: 'Poppins',
  primaryColor: PRIMARY_COLOR,
  accentColor: Colors.white,
  dividerColor: const Color(0xFF121212),
  scaffoldBackgroundColor: const Color(0xFF121212),
  brightness: Brightness.dark,
  backgroundColor: const Color(0xFFE5E5E5),
  canvasColor: Colors.grey[900],
  textSelectionColor: Color(0x212121).withOpacity(0.3),
  textSelectionHandleColor: Color(0xFFd6ba8b),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: PRIMARY_COLOR, foregroundColor: Colors.white),
  inputDecorationTheme: InputDecorationTheme(
    contentPadding: EdgeInsets.all(15.0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        width: 0,
        style: BorderStyle.none,
      ),
    ),
    filled: true,
    fillColor: Colors.grey[900],
  ),
  chipTheme: chipThemeDark,
  bottomNavigationBarTheme:
      BottomNavigationBarThemeData(backgroundColor: Color(0xFF121212)),
  cardColor: const Color(0xFF121212),
  dialogTheme: DialogTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    backgroundColor: Colors.grey[900]
  ),
  indicatorColor: Colors.white
);

// Light theme for tags
ChipThemeData chipThemeLight = ChipThemeData(
  labelStyle: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 15.5,
      fontWeight: FontWeight.w400,
      color: Colors.grey[700]),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
  backgroundColor: Colors.grey[200],
  selectedColor: SECONDARY_COLOR,
  secondarySelectedColor: SECONDARY_COLOR,
  disabledColor: PRIMARY_COLOR,
  padding: EdgeInsets.all(4),
  checkmarkColor: Colors.grey[600],
  brightness: Brightness.light,
  secondaryLabelStyle: TextStyle(
      fontSize: 15.5, fontWeight: FontWeight.w400, color: Colors.grey[600]),
);

// Dark theme for tags
ChipThemeData chipThemeDark = ChipThemeData(
  labelStyle: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 15.5,
      fontWeight: FontWeight.w400,
      color: Colors.white54),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
  backgroundColor: Colors.grey[900],
  selectedColor: PRIMARY_COLOR,
  secondarySelectedColor: PRIMARY_COLOR,
  disabledColor: PRIMARY_COLOR,
  padding: EdgeInsets.all(4),
  checkmarkColor: Colors.white54,
  brightness: Brightness.dark,
  secondaryLabelStyle: TextStyle(
      fontSize: 15.5, fontWeight: FontWeight.w400, color: Colors.white54),
);

// Gradients for cards
LinearGradient lookingGradientLight = LinearGradient(
  colors: [Colors.blue[900], Color(0xFF0c2771)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight
);
LinearGradient lookingGradientDark = LinearGradient(
  colors: [Colors.blue[700], Colors.blue[900]],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight
);
LinearGradient offeringGradientLight = LinearGradient(
  colors: [Colors.orange[600], Color(0xFFFF6F00)],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight
);
LinearGradient offeringGradientDark = LinearGradient(
  colors: [Colors.orange[400], Colors.orange[600]],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight
);

// Themes for searchBar
InputDecorationTheme lightSearchTheme = InputDecorationTheme(
  contentPadding: EdgeInsets.all(15.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: BorderSide(
      width: 0,
      style: BorderStyle.none,
    ),
  ),
  filled: true,
  fillColor: Colors.grey[300],
);
InputDecorationTheme darkSearchTheme = InputDecorationTheme(
  contentPadding: EdgeInsets.all(15.0),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(30),
    borderSide: BorderSide(
      width: 0,
      style: BorderStyle.none,
    ),
  ),
  filled: true,
  fillColor: Colors.grey[800],
);