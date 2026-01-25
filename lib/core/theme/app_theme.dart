import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ColorScheme buildLightColorScheme({
  required ColorScheme? lightDynamic,
  required Color seedColor,
  required bool isDynamic,
}) {
  if (isDynamic && lightDynamic != null) {
    return ColorScheme.fromSeed(
      seedColor: lightDynamic.primary,
      brightness: Brightness.light,
    );
  }
  return ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  );
}

ColorScheme buildDarkColorScheme({
  required ColorScheme? darkDynamic,
  required ColorScheme? lightDynamic,
  required Color seedColor,
  required bool isDynamic,
}) {
  if (isDynamic && darkDynamic != null) {
    // Use lightDynamic's primary as the seed if available, as it's typically
    // the source color (Tone 40), ensuring a more accurate palette generation
    // than darkDynamic's primary (Tone 80).
    return ColorScheme.fromSeed(
      seedColor: lightDynamic?.primary ?? darkDynamic.primary,
      brightness: Brightness.dark,
    );
  }
  return ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  );
}

/// Light Theme
ThemeData buildLightTheme(ColorScheme colorScheme) {
  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    textTheme: buildLightTextTheme(),
  );
}

/// Dark Theme
ThemeData buildDarkTheme(ColorScheme colorScheme) {
  return ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    textTheme: buildDarkTextTheme(),
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
