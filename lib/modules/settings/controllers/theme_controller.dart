import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  ThemeController(this._preferences);

  final SharedPreferences _preferences;
  final mode = ThemeMode.light.obs;

  @override
  void onInit() {
    final stored = _preferences.getString('theme_mode');
    mode.value = ThemeMode.values.firstWhere(
      (item) => item.name == stored,
      orElse: () => ThemeMode.light,
    );
    super.onInit();
  }

  Future<void> setMode(ThemeMode value) async {
    mode.value = value;
    await _preferences.setString('theme_mode', value.name);
  }
}
