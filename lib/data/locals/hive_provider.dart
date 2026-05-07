import 'package:hive_flutter/hive_flutter.dart';

class HiveProvider {
  static const String userBoxName = 'userBox';
  static const String gameBoxName = 'gameBox';

  // Fungsi simpan data user
  static Future<void> saveUser(String email, Map<String, dynamic> userData) async {
    final box = Hive.box(userBoxName);
    await box.put(email, userData);
  }

  static Map<dynamic, dynamic>? getUser(String email) {
    return Hive.box(userBoxName).get(email);
  }

  // Fungsi high score game — hanya simpan jika skor baru lebih tinggi
  static void saveHighScore(String email, int score) {
    final box = Hive.box(gameBoxName);
    final key = 'highScore_$email';
    final current = box.get(key, defaultValue: 0) as int;
    if (score > current) box.put(key, score);
  }

  static int getHighScore(String email) {
    return Hive.box(gameBoxName).get('highScore_$email', defaultValue: 0);
  }

  // Fungsi status biometrik per user
  static void saveBiometricStatus(String email, bool isEnabled) {
    Hive.box(userBoxName).put('biometric_$email', isEnabled);
  }

  static bool getBiometricStatus(String email) {
    return Hive.box(userBoxName).get('biometric_$email', defaultValue: false);
  }

  // Fungsi testimoni user
  static void saveTestimonial(String email, String content, int rating) {
    final box = Hive.box(userBoxName);
    box.put('testimonial_content_$email', content);
    box.put('testimonial_rating_$email', rating);
  }

  static String getTestimonialContent(String email) {
    return Hive.box(userBoxName).get('testimonial_content_$email', defaultValue: '');
  }

  // Fungsi path foto profil user
  static void saveProfileImagePath(String email, String path) {
    Hive.box(userBoxName).put('profile_image_$email', path);
  }

  static String getProfileImagePath(String email) {
    return Hive.box(userBoxName).get('profile_image_$email', defaultValue: '');
  }
}
