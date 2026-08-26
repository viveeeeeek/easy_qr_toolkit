import 'package:easy_qr_toolkit/core/providers/package_info_provider.dart';
import 'package:easy_qr_toolkit/core/providers/shared_preferences_provider.dart';
import 'package:easy_qr_toolkit/features/settings/view/settings_view.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('SettingsView renders all sections and widgets correctly',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    PackageInfo.setMockInitialValues(
      appName: 'Easy QR Toolkit',
      packageName: 'com.billionants.easy_qr_toolkit',
      version: '3.1.0',
      buildNumber: '6',
      buildSignature: '',
    );
    final packageInfo = await PackageInfo.fromPlatform();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          packageInfoProvider.overrideWithValue(packageInfo),
        ],
        child: const MaterialApp(
          home: SettingsView(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify AppBar title (SliverAppBar.large contains both expanded and collapsed title widgets)
    expect(find.text('Settings'), findsWidgets);

    // Verify Appearance Section elements
    expect(find.text('Appearance'), findsOneWidget);
    expect(find.text('Dynamic Color'), findsOneWidget);
    expect(find.text('Custom Theme Colors'), findsOneWidget);
    expect(find.text('Theme Mode'), findsOneWidget);
    expect(find.text('System'), findsWidgets);
    expect(find.text('Light'), findsWidgets);
    expect(find.text('Dark'), findsWidgets);

    // Verify About App Section elements
    expect(find.text('Easy QR Toolkit'), findsOneWidget);
    expect(find.text('v3.1.0 (6)'), findsOneWidget);
    expect(find.text('Rate on Google Play'), findsOneWidget);
    expect(find.text('Share App'), findsOneWidget);
    expect(find.text('Open Source Licenses'), findsOneWidget);
    expect(find.text('Source Code'), findsOneWidget);

    // Verify Privacy & Local Storage Note
    expect(find.text('100% Offline & Private'), findsOneWidget);
  });
}
