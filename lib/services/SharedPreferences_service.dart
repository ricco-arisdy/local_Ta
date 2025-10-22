import 'package:shared_preferences/shared_preferences.dart';
import 'package:ta_project/models/app_constants.dart';

class SharedPreferencesService {
  // Update keys untuk konsistensi dengan app_constants.dart
  static Future<void> saveAuthData({
    required String token,
    required bool rememberMe,
    String? userId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.tokenKey, token);
    await prefs.setBool(AppConstants.rememberMeKey, rememberMe);
    await prefs.setBool(AppConstants.isLoggedInKey, true);
    if (userId != null) {
      await prefs.setString(AppConstants.userDataKey, userId);
    }
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.tokenKey);
  }

  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.rememberMeKey) ?? false;
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.userDataKey);
  }

  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool(AppConstants.isLoggedInKey) ?? false;
      final rememberMe = prefs.getBool(AppConstants.rememberMeKey) ?? false;
      final token = prefs.getString(AppConstants.tokenKey);

      // User dianggap logged in jika:
      // 1. Flag isLoggedIn = true
      // 2. Remember me = true
      // 3. Token tersedia
      return isLoggedIn && rememberMe && (token != null && token.isNotEmpty);
    } catch (e) {
      print('💥 [SHARED_PREFS] Error checking login status: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString(AppConstants.savedEmailKey) ?? '',
      'password': prefs.getString(AppConstants.savedPasswordKey) ?? '',
      'rememberMe': prefs.getBool(AppConstants.rememberMeKey) ?? false,
    };
  }

  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.tokenKey);
    await prefs.remove(AppConstants.userDataKey);
    await prefs.setBool(AppConstants.isLoggedInKey, false);
    // Keep saved credentials if remember me was enabled
  }

  static Future<void> clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.savedEmailKey);
    await prefs.remove(AppConstants.savedPasswordKey);
    await prefs.setBool(AppConstants.rememberMeKey, false);
  }

  static Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
