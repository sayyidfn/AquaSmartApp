import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:light/light.dart';
import '../../core/utils/storage_util.dart';
import '../../data/locals/hive_provider.dart';

class GameController extends GetxController {
  var score = 0.obs;
  var highScore = 0.obs;
  var hearts = 3.obs;
  var isGameOver = false.obs;

  // Streak & Multiplier
  var streak = 0.obs;
  var multiplier = 1.obs;

  var luxValue = 0.obs;
  late Light _light;
  StreamSubscription? _subscription;

  // Email pemain yang sedang aktif
  String? currentUserEmail;

  // Callback untuk reset Flame game (dipasang oleh GameView)
  VoidCallback? _onResetFlameGame;

  void attachFlameGameReset(VoidCallback callback) {
    _onResetFlameGame = callback;
  }

  @override
  void onInit() {
    super.onInit();
    _startLightSensor();
    _loadUserAndHighScore();
  }

  // Fungsi ambil data user dari Hive saat login
  Future<void> _loadUserAndHighScore() async {
    currentUserEmail = await StorageUtil.getLoggedInEmail();
    if (currentUserEmail != null) {
      highScore.value = HiveProvider.getHighScore(currentUserEmail!);
    }
  }

  // Fungsi start sensor cahaya
  void _startLightSensor() {
    _light = Light();
    try {
      _subscription = _light.lightSensorStream.listen((lux) {
        luxValue.value = lux;
      });
    } catch (e) {
      // Sensor cahaya tidak tersedia di perangkat ini
      print('Error: $e');
    }
  }

  // Fungsi untuk mendapatkan opacity overlay gelap berdasarkan nilai lux
  double get nightOverlayOpacity {
    if (luxValue.value > 50) return 0.0;
    if (luxValue.value <= 5) return 0.6;
    return (50 - luxValue.value) / 100;
  }

  // Fungsi untuk menambah skor
  void increaseScore() {
    if (isGameOver.value) return;

    streak.value++;
    // Multiplier naik di streak 3 dan 5
    if (streak.value >= 5) {
      multiplier.value = 3;
    } else if (streak.value >= 3) {
      multiplier.value = 2;
    }

    score.value += 10 * multiplier.value;

    if (score.value > highScore.value) {
      highScore.value = score.value;
      if (currentUserEmail != null) {
        HiveProvider.saveHighScore(currentUserEmail!, score.value);
      }
    }
  }

  // Fungsi saat makanan terlewat (melewati layar tanpa ditangkap)
  void onFoodMissed() {
    if (isGameOver.value) return;
    streak.value = 0;
    multiplier.value = 1;
  }

  // Fungsi untuk mengurangi nyawa
  void decreaseHeart() {
    if (isGameOver.value || hearts.value <= 0) return;
    hearts.value--;
    if (hearts.value == 0) isGameOver.value = true;
  }

  void resetGame() {
    score.value = 0;
    hearts.value = 3;
    streak.value = 0;
    multiplier.value = 1;
    isGameOver.value = false;
    // Reset semua komponen di Flame game
    _onResetFlameGame?.call();
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
