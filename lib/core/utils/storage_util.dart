import 'package:shared_preferences/shared_preferences.dart';

class StorageUtil {
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUserNim = 'userNim';
  static const String keyUserName = 'userName';

  // simpan sesi seteah login berhasil
  static Future<void> saveLoginSession(String nim, String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, true);
    await prefs.setString(keyUserNim, nim);
    await prefs.setString(keyUserName, name);
  }

  // cek apakah user sedang login saat aplikasi pertama kali dibuka
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  // hapus sesi saat tombol logout ditekan
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
