import 'package:dynamic_color/dynamic_color.dart';
import 'package:easy_qr_toolkit/core/constants/app_constants.dart';
import 'package:easy_qr_toolkit/core/routes/app_route.dart';
import 'package:easy_qr_toolkit/core/theme/app_theme.dart';
import 'package:easy_qr_toolkit/core/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class App extends ConsumerWidget {
  const App({super.key});

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
            theme: ThemeData(
                colorScheme: lightColorScheme,
                useMaterial3: true,
                textTheme: buildLightTextTheme()),
            themeMode: themeState.themeMode,
            darkTheme: ThemeData(
                colorScheme: darkColorScheme,
                textTheme: buildDarkTextTheme()),
            routes: appRoutes,
            navigatorObservers: [AppRoutes.routeObserver],
            initialRoute: AppRoutes.home,
            debugShowCheckedModeBanner: false,
          ),
        );
      },
    );
  }
}
