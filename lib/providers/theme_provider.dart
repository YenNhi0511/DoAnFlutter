import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/services/local_storage_service.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(_getInitialTheme());

  static ThemeMode _getInitialTheme() {
    return LocalStorageService.isDarkMode ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() {
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
      LocalStorageService.isDarkMode = true;
    } else {
      state = ThemeMode.light;
      LocalStorageService.isDarkMode = false;
    }
  }

  void setTheme(ThemeMode mode) {
    state = mode;
    LocalStorageService.isDarkMode = mode == ThemeMode.dark;
  }

  bool get isDarkMode => state == ThemeMode.dark;
}

