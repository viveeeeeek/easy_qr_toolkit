import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ColorScheme buildLightColorScheme(
    BuildContext context, ColorScheme? lightDynamic) {
  // final themeProvider = Provider.of<AppThemeService>(context);
  // final appThemeSharedPrefsProvider = Provider.of<AppThemePrefs>(context);

  // bool isDynamic = appThemeSharedPrefsProvider.isDynamiThemeEnabled;

  try {
    if (lightDynamic != null) {
      return lightDynamic.harmonized();
    } else {
      return ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.light,
      );
    }
  } catch (e) {
    // print('Error getting light color scheme: $e');
    return const ColorScheme.light(); // Return a default color scheme on error
  }
}

ColorScheme buildDarkColorScheme(
    BuildContext context, ColorScheme? darkDynamic) {
  // final themeProvider = Provider.of<AppThemeService>(context);
  // final appThemeSharedPrefsProvider = Provider.of<AppThemePrefs>(context);

  // bool isDynamic = appThemeSharedPrefsProvider.isDynamiThemeEnabled;

  try {
    if (darkDynamic != null) {
      return darkDynamic.harmonized();
    } else {
      return ColorScheme.fromSeed(
        seedColor: Colors.green,
        brightness: Brightness.dark,
      );
    }
  } catch (e) {
    // print('Error getting light color scheme: $e');
    return const ColorScheme.dark(); // Return a default color scheme on error
  }
}

/// Text theme for dark theme
TextTheme buildDarkTextTheme() {
  return GoogleFonts.outfitTextTheme().apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  );
}

/// Text theme for light theme
TextTheme buildLightTextTheme() {
  return GoogleFonts.outfitTextTheme().apply(
    bodyColor: Colors.black,
    displayColor: Colors.black,
  );
}
