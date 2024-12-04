import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode themeMode = ThemeMode.light; // Default to light mode

  ThemeProvider() {
    _loadThemeMode(); // Load the saved theme mode on initialization
  }
  bool get isDarkMode {
    if (themeMode == ThemeMode.system) {
      final brightness = SchedulerBinding.instance!.window.platformBrightness;
      return brightness == Brightness.dark;
    } else {
      return themeMode == ThemeMode.dark;
    }
  }

  void toggleTheme(bool isOn) async {
    themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    // Save the user's theme preference
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isDarkMode', isOn);
  }
  Future<void> _loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

class ChangeThemeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return FlutterSwitch(
      width: 70,
      height: 45,
      toggleSize: 45.0,
      value: themeProvider.isDarkMode,
      borderRadius: 30.0,
      padding: 2.0,
      activeToggleColor: Color(0xFF6E40C9),
      inactiveToggleColor: Color(0xFF2F363D),
      activeSwitchBorder: Border.all(
        color: Color(0xFF3C1E70),
        width: 6.0,
      ),
      inactiveSwitchBorder: Border.all(
        color: Color(0xFFD1D5DA),
        width: 6.0,
      ),
      activeColor: Color(0xFF271052),
      inactiveColor: Colors.white,
      activeIcon: Icon(
        Icons.nightlight_round,
        color: Color(0xFFF8E3A1),
      ),
      inactiveIcon: Icon(
        Icons.wb_sunny,
        color: Color(0xFFFFDF5D),
      ),
      onToggle: (val) {
        final provider = Provider.of<ThemeProvider>(context, listen: false);
        provider.toggleTheme(val);
      },
    );
  }
}

class Mytheme {
  static ThemeData lightTheme(BuildContext context) => ThemeData(
    brightness: Brightness.light, // Indicates light mode behavior
    primaryColor: HexColor('FFFFFF'), // Custom primary color for light mode
    fontFamily: GoogleFonts.poppins().fontFamily,
    cardColor: HexColor('F9F9F9'), // Card background color for light mode
    canvasColor: HexColor('FAFAFA'), // Background color for light mode
    scaffoldBackgroundColor: HexColor('FFFFFF'), // Main background color
    appBarTheme: AppBarTheme(
      color: Colors.white, // AppBar color for light mode
      elevation: 0.0,
      iconTheme: IconThemeData(color: Colors.black), // Icon color in AppBar
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.black), // Text color for primary body text
      bodyMedium: TextStyle(color: Colors.black87), // Text color for secondary body text
      displayLarge: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), // Headlines
    ),
    iconTheme: IconThemeData(
      color: Colors.black, // Default icon color
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: HexColor('E0E0E0'), // Button background color
      textTheme: ButtonTextTheme.primary, // Text color for buttons
    ),
  );





  static ThemeData darkTheme(BuildContext context) => ThemeData(
    brightness: Brightness.dark, // Indicates dark mode behavior
    primaryColor: HexColor('181A20'), // Custom primary color for dark mode
    fontFamily: GoogleFonts.poppins().fontFamily,
    cardColor: HexColor('28282B'), // Card background color for dark mode
    canvasColor: HexColor('181A20'), // Background color for dark mode
    scaffoldBackgroundColor: HexColor('121212'), // Main background color
    appBarTheme: AppBarTheme(
      color: HexColor('121212'), // AppBar color for dark mode
      elevation: 0.0,
      iconTheme: IconThemeData(color: Colors.white), // Icon color in AppBar
    ),
    textTheme: TextTheme(
      bodyLarge: TextStyle(color: Colors.white), // Text color for primary body text
      bodyMedium: TextStyle(color: Colors.white70), // Text color for secondary body text
      displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), // Headlines
    ),
    iconTheme: IconThemeData(
      color: Colors.white, // Default icon color
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: HexColor('121212'), // Button background color
      textTheme: ButtonTextTheme.primary, // Text color for buttons
    ),
  );


  static Color creamColor = Color(0xfff4f5fc);
  static Color darkBluishColor = Color(0xff1a191c);
  static Color darkColor = HexColor('121212'); // Updated to #181A20
  static Color lightBluishColor = Color(0xFF6E40C9);
}


