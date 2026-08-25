import 'package:material_ui/material_ui.dart';

class AppRoutes {
  static const String home = '/home';
  static const String scan = '/scan';
  static const String history = '/scan_history';
  static const String settings = '/settings';

  /// Global route observer for tracking navigation events
  static final RouteObserver<PageRoute> routeObserver =
      RouteObserver<PageRoute>();
}

class AppConstants {
  static const String appName = 'Easy QR Toolkit';
  // This is our custom URI Intent to launch the Scan Flow in the app.
  static const String scanWidgetDeepLink = 'esqr://scan';
  
  // Developer and External links
  static const String developerName = 'Vivek Sonawane';
  static const String githubUrl = 'https://github.com/viveeeeeek';
  static const String projectRepoUrl = 'https://github.com/viveeeeeek/easy_qr_toolkit';
  static const String playStoreUrl = 'https://play.google.com/store/apps/details?id=com.billionants.easy_qr_toolkit';
}

class AppPrefsKeys {
  static const String isDynamicColor = 'is_dynamic_color';
  static const String seedColor = 'seed_color';
  static const String themeMode = 'theme_mode';
}
