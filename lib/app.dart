import 'package:dynamic_color/dynamic_color.dart';
import 'package:easy_qr_toolkit/core/constants/app_constants.dart';
import 'package:easy_qr_toolkit/core/routes/app_route.dart';
import 'package:easy_qr_toolkit/core/theme/app_theme.dart';
import 'package:easy_qr_toolkit/core/theme/theme_provider.dart';
import 'package:easy_qr_toolkit/features/home/view/home_view.dart';
import 'package:easy_qr_toolkit/features/scanner/view/qr_scan_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class App extends ConsumerWidget {
  final Uri? initialWidgetUri;

  const App({super.key, this.initialWidgetUri});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeControllerProvider);

    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        final lightColorScheme = buildLightColorScheme(
          lightDynamic: lightDynamic,
          seedColor: themeState.seedColor,
          isDynamic: themeState.isDynamic,
        );
        final darkColorScheme = buildDarkColorScheme(
          darkDynamic: darkDynamic,
          lightDynamic: lightDynamic,
          seedColor: themeState.seedColor,
          isDynamic: themeState.isDynamic,
        );

        final brightness = MediaQuery.platformBrightnessOf(context);
        final isDarkMode = brightness == Brightness.dark;

        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarContrastEnforced: false,
            systemStatusBarContrastEnforced: false,
            statusBarIconBrightness:
                isDarkMode ? Brightness.light : Brightness.dark,
            systemNavigationBarIconBrightness:
                isDarkMode ? Brightness.light : Brightness.dark,
          ),
          child: MaterialApp(
            title: AppConstants.appName,
            theme: buildLightTheme(lightColorScheme),
            themeMode: themeState.themeMode,
            darkTheme: buildDarkTheme(darkColorScheme),
            routes: appRoutes,
            navigatorObservers: [AppRoutes.routeObserver],
            // Use onGenerateInitialRoutes to handle cold start navigation
            // ensuring a valid stack [Home] or [Home, Scan] immediately.
            onGenerateInitialRoutes: (String initialRouteName) {
              final List<Route<dynamic>> routes = [
                MaterialPageRoute(builder: (context) => const HomeView()),
              ];

              if (initialWidgetUri != null &&
                  initialWidgetUri.toString() ==
                      AppConstants.scanWidgetDeepLink) {
                routes.add(
                  MaterialPageRoute(builder: (context) => const QRScanView()),
                );
              }

              return routes;
            },
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}
