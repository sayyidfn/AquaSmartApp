import 'dart:async';
import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';

class GameController extends GetxController {
  var score = 0.obs;
  var highScore = 0.obs;

  // Posisi karakter jaring di layar (Sumbu X)
  var netPositionX = 0.0.obs;

  StreamSubscription? _gyroscopeSubscription;

  @override
  void onInit() {
    super.onInit();
    loadHighScore();
    _initGyroscope();
  }

  void _initGyroscope() {
    // Menggunakan gyroscope untuk rotasi HP, atau accelerometer untuk kemiringan
    _gyroscopeSubscription = gyroscopeEventStream().listen((
      GyroscopeEvent event,
    ) {
      // event.y mengukur rotasi kiri/kanan perangkat
      // Kita tambahkan nilai sensitivitas ke netPositionX
      netPositionX.value += (event.y * 10);

      // Beri batas agar jaring tidak keluar layar (nanti disesuaikan dengan lebar layar)
      if (netPositionX.value > 150) netPositionX.value = 150;
      if (netPositionX.value < -150) netPositionX.value = -150;
    });
  }

  void addScore() {
    score.value += 10;
    if (score.value > highScore.value) {
      highScore.value = score.value;
    }
  }

  void loadHighScore() {
    // Load dari Hive
  }

  @override
  void onClose() {
    _gyroscopeSubscription?.cancel(); // Sangat penting agar HP tidak panas
    super.onClose();
  }
}
