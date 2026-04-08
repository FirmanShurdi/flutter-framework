import 'package:flutter/material.dart';
import '../services/preference_service.dart';

class PreferenceProvider extends ChangeNotifier {
  final PreferenceService _service = PreferenceService();

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  String _userName = 'User';
  String get userName => _userName;

  PreferenceProvider() {
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    _isDarkMode = await _service.isDarkMode();
    _userName = await _service.getUserName();
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    await _service.setDarkMode(_isDarkMode);
    notifyListeners();
  }

  Future<void> updateUserName(String name) async {
    _userName = name;
    await _service.setUserName(name);
    notifyListeners();
  }
}
