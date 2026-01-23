import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_provider.g.dart';

@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(Ref ref) {
  // This provider is overridden in main.dart using ProviderScope.
  // It allows us to load SharedPreferences synchronously in the rest of the app.
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main.dart');
}
