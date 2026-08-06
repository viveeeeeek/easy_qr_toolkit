import 'package:flutter/material.dart';

class AppRoutes {
  static const String home = '/home';
  static const String scan = '/scan';
  static const String history = '/scan_history';

  /// Global route observer for tracking navigation events
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();
}

class AppConstants {
  static const String appName = 'Easy QR Toolkit';
  // This is our custom URI Intent to launch the Scan Flow in the app.
  static const String scanWidgetDeepLink = 'esqr://scan';
}

class AppPrefsKeys {
  static const String isDynamicColor = 'is_dynamic_color';
  static const String seedColor = 'seed_color';
  static const String themeMode = 'theme_mode';
}
