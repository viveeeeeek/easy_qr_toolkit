import 'package:dynamic_color/dynamic_color.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:material_ui/material_ui.dart';

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

TextTheme _applyGoogleFont(TextTheme base, Color color) {
  return TextTheme(
    displayLarge:
        GoogleFonts.outfit(textStyle: base.displayLarge, color: color),
    displayMedium:
        GoogleFonts.outfit(textStyle: base.displayMedium, color: color),
    displaySmall:
        GoogleFonts.outfit(textStyle: base.displaySmall, color: color),
    headlineLarge:
        GoogleFonts.outfit(textStyle: base.headlineLarge, color: color),
    headlineMedium:
        GoogleFonts.outfit(textStyle: base.headlineMedium, color: color),
    headlineSmall:
        GoogleFonts.outfit(textStyle: base.headlineSmall, color: color),
    titleLarge: GoogleFonts.outfit(textStyle: base.titleLarge, color: color),
    titleMedium: GoogleFonts.outfit(textStyle: base.titleMedium, color: color),
    titleSmall: GoogleFonts.outfit(textStyle: base.titleSmall, color: color),
    bodyLarge: GoogleFonts.outfit(textStyle: base.bodyLarge, color: color),
    bodyMedium: GoogleFonts.outfit(textStyle: base.bodyMedium, color: color),
    bodySmall: GoogleFonts.outfit(textStyle: base.bodySmall, color: color),
    labelLarge: GoogleFonts.outfit(textStyle: base.labelLarge, color: color),
    labelMedium: GoogleFonts.outfit(textStyle: base.labelMedium, color: color),
    labelSmall: GoogleFonts.outfit(textStyle: base.labelSmall, color: color),
  );
}

/// Text theme for dark theme
TextTheme buildDarkTextTheme() {
  return _applyGoogleFont(Typography.material2021().white, Colors.white);
}

/// Text theme for light theme
TextTheme buildLightTextTheme() {
  return _applyGoogleFont(Typography.material2021().black, Colors.black);
}
