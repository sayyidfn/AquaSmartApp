import 'package:shared_preferences/shared_preferences.dart';

class StorageUtil {
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUserNim = 'userNim';
  static const String keyUserName = 'userName';

  static const String keyUserEmail = 'userEmail';

  static Future<void> saveLoginSession(
    String email,
    String nim,
    String name,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, true);
    await prefs.setString(keyUserEmail, email);
    await prefs.setString(keyUserNim, nim);
    await prefs.setString(keyUserName, name);
  }

  static Future<String?> getLoggedInEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyUserEmail);
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
