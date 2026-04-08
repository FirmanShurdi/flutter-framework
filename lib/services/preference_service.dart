import 'package:shared_preferences/shared_preferences.dart';

class PreferenceService {
  static const String _themeKey = 'theme_mode';
  static const String _nameKey = 'user_name';
  static const String _isLoggedInKey = 'is_logged_in';
  static const String _tokenKey = 'auth_token';
  static const String _cachedDataKey = 'cached_parking_data';

  // Theme
  Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, value);
  }

  // Name
  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey) ?? 'User';
  }

  Future<void> setUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, name);
  }

  // Auth Status
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<void> setLoggedIn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, value);
  }

  // Token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Cache
  Future<String?> getCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cachedDataKey);
  }

  Future<void> saveCacheData(String data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cachedDataKey, data);
  }

  // Clear all for Logout
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    // We clear token, isLoggedIn, but maybe keep theme?
    // Requirement says "menghapus login status lokal"
    await prefs.remove(_tokenKey);
    await prefs.remove(_isLoggedInKey);
    // User requested "benar-benar clear status yang disimpan" 
    // but usually theme is kept. I will clear login stuff.
  }
}
