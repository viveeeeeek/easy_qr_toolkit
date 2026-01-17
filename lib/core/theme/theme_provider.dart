import 'package:easy_qr_toolkit/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  FutureOr<ThemeState> build() async {
    final prefs = await SharedPreferences.getInstance();
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
    final currentState = state.value;
    if (currentState == null) return;

    // Optimistically update
    state = AsyncValue.data(currentState.copyWith(isDynamic: value));

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppPrefsKeys.isDynamicColor, value);
    } catch (e, stack) {
      // Revert on error
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> setSeedColor(Color color) async {
    final currentState = state.value;
    if (currentState == null) return;

    // Update state directly without loading
    // Also disable dynamic color when a specific color is chosen
    state = AsyncValue.data(
        currentState.copyWith(seedColor: color, isDynamic: false));

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppPrefsKeys.seedColor, color.value);
      await prefs.setBool(AppPrefsKeys.isDynamicColor, false);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(themeMode: mode));

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(AppPrefsKeys.themeMode, mode.index);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
