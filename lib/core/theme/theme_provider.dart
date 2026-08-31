import 'package:easy_qr_toolkit/core/constants/app_constants.dart';
import 'package:easy_qr_toolkit/core/providers/shared_preferences_provider.dart';
import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'theme_provider.g.dart';

class ThemeState {
  final bool isDynamic;
  final Color seedColor;
  final ThemeMode themeMode;

  const ThemeState({
    this.isDynamic = true,
    this.seedColor = Colors.blue,
    this.themeMode = ThemeMode.system,
  });

  ThemeState copyWith({
    bool? isDynamic,
    Color? seedColor,
    ThemeMode? themeMode,
  }) {
    return ThemeState(
      isDynamic: isDynamic ?? this.isDynamic,
      seedColor: seedColor ?? this.seedColor,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

@riverpod
class ThemeController extends _$ThemeController {
  @override
  ThemeState build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final isDynamic = prefs.getBool(AppPrefsKeys.isDynamicColor) ?? true;
    final seedColorValue = prefs.getInt(AppPrefsKeys.seedColor);
    final themeModeIndex =
        prefs.getInt(AppPrefsKeys.themeMode) ?? ThemeMode.system.index;

    return ThemeState(
      isDynamic: isDynamic,
      seedColor: seedColorValue != null ? Color(seedColorValue) : Colors.blue,
      themeMode: ThemeMode.values[themeModeIndex],
    );
  }

  Future<void> toggleDynamicColor(bool value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    
    // Optimistically update
    state = state.copyWith(isDynamic: value);

    await prefs.setBool(AppPrefsKeys.isDynamicColor, value);
  }

  Future<void> setSeedColor(Color color) async {
    final prefs = ref.read(sharedPreferencesProvider);

    // Update state directly
    state = state.copyWith(seedColor: color, isDynamic: false);

    await prefs.setInt(AppPrefsKeys.seedColor, color.toARGB32());
    await prefs.setBool(AppPrefsKeys.isDynamicColor, false);
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = ref.read(sharedPreferencesProvider);

    state = state.copyWith(themeMode: mode);

    await prefs.setInt(AppPrefsKeys.themeMode, mode.index);
  }
}
