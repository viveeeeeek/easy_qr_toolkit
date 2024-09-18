import 'package:dynamic_color/dynamic_color.dart';
import 'package:easy_qr_toolkit/core/routes/app_route.dart';
import 'package:easy_qr_toolkit/core/theme/app_theme.dart';
import 'package:easy_qr_toolkit/providers/qr_data_provider.dart';
import 'package:easy_qr_toolkit/views/home/home_view.dart';
import 'package:easy_qr_toolkit/views/qr_scan/qr_scan_view.dart';
import 'package:easy_qr_toolkit/views/qr_scan_history/qr_scan_history_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

class App extends StatelessWidget {
  const App({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => QrDataProvider()),
        ],
        child: DynamicColorBuilder(
            builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
          final lightColorScheme = buildLightColorScheme(context, lightDynamic);
          final darkColorScheme = buildDarkColorScheme(context, darkDynamic);
          return MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
                colorScheme: lightColorScheme,
                useMaterial3: true,
                textTheme: GoogleFonts.robotoTextTheme()),
            themeMode: ThemeMode.system,
            darkTheme: ThemeData(
                colorScheme: darkColorScheme, textTheme: buildDarkTextTheme()),
            routes: appRoutes,
            initialRoute: '/home',
          );
        }));
  }
}
