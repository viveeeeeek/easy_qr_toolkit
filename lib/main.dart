import 'package:easy_qr_toolkit/app.dart';
import 'package:easy_qr_toolkit/core/providers/package_info_provider.dart';
import 'package:easy_qr_toolkit/core/providers/shared_preferences_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:home_widget/home_widget.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  final sharedPrefs = await SharedPreferences.getInstance();
  final packageInfo = await PackageInfo.fromPlatform();
  final Uri? widgetUri = await HomeWidget.initiallyLaunchedFromHomeWidget();

  runApp(
    ProviderScope(
      overrides: <Override>[
        sharedPreferencesProvider.overrideWithValue(sharedPrefs),
        packageInfoProvider.overrideWithValue(packageInfo),
      ],
      child: App(initialWidgetUri: widgetUri),
    ),
  );
}
