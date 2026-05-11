import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

const _themeBoxName = 'fasalx_theme';
const _darkThemeKey = 'dark_theme';

class ThemeController extends ChangeNotifier {
  ThemeController._();

  static final ThemeController instance = ThemeController._();

  Box<dynamic>? _box;
  bool _isDark = false;
  bool _isChanging = false;

  bool get isDark => _isDark;
  bool get isChanging => _isChanging;
  ThemeMode get themeMode => _isDark ? ThemeMode.dark : ThemeMode.light;

  Future<void> load() async {
    _box = await Hive.openBox<dynamic>(_themeBoxName);
    _isDark = _box?.get(_darkThemeKey, defaultValue: false) as bool;
    notifyListeners();
  }

  Future<void> setDarkTheme(bool value) async {
    if (_isChanging || _isDark == value) return;
    _isChanging = true;
    notifyListeners();

    await Future<void>.delayed(const Duration(milliseconds: 260));
    _isDark = value;
    await _box?.put(_darkThemeKey, value);
    _isChanging = false;
    notifyListeners();
  }

  Future<void> toggle() => setDarkTheme(!_isDark);
}
