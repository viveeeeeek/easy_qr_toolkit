import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ColorScheme buildLightColorScheme({
  required ColorScheme? lightDynamic,
  required Color seedColor,
  required bool isDynamic,
}) {
  if (isDynamic && lightDynamic != null) {
    return lightDynamic.harmonized();
  }
  return ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  );
}

ColorScheme buildDarkColorScheme({
  required ColorScheme? darkDynamic,
  required Color seedColor,
  required bool isDynamic,
}) {
  if (isDynamic && darkDynamic != null) {
    return darkDynamic.harmonized();
  }
  return ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  );
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
