import 'package:hive_flutter/hive_flutter.dart';

class HiveProvider {
  static const String userBoxName = 'userBox';
  static const String gameBoxName = 'gameBox';

  // Menyimpan data registrasi user
  static Future<void> saveUser(
    String email,
    Map<String, dynamic> userData,
  ) async {
    var box = Hive.box(userBoxName);
    await box.put(email, userData);
  }

  // Mengambil data user berdasarkan email
  static Map<dynamic, dynamic>? getUser(String email) {
    var box = Hive.box(userBoxName);
    return box.get(email);
  }

  // Menyimpan high score game Aqua Catch
  static Future<void> saveHighScore(int score) async {
    var box = await Hive.openBox(gameBoxName);
    int currentHighScore = box.get('highScore', defaultValue: 0);
    if (score > currentHighScore) {
      await box.put('highScore', score);
    }
  }

  // Mengambil high score
  static Future<int> getHighScore() async {
    var box = await Hive.openBox(gameBoxName);
    return box.get('highScore', defaultValue: 0);
  }
}
