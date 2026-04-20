import 'dart:async';
import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';

class GameController extends GetxController {
  // status game
  var isPlaying = false.obs;
  var isGameOver = false.obs;
  var score = 0.obs;
  var lives = 3.obs;

  // posisi ikan (sumbu x: -1.0 kiri mentok, 1.0 kanan mentok, 0.0 tengah)
  var fishPositionX = 0.0.obs;

  StreamSubscription? _gyroscopeSubscription;

  @override
  void onInit() {
    super.onInit();
    _initGyroscopeSensor();
  }

  // - Fungsi sensor gyro (kemiringan hp)
  void _initGyroscopeSensor() {
    // menggunakan gyroscopeEventStream untuk membaca rotasi sumbu Y (kiri/kanan)
    _gyroscopeSubscription = gyroscopeEventStream().listen((
      GyroscopeEvent event,
    ) {
      if (!isPlaying.value || isGameOver.value) return;

      // E=event.y membaca kemiringan HP ke kiri/kanan.
      // kalikan pengali kecepatan (misal 0.05) agar geraknya mulus.
      double movement = event.y * 0.05;

      // update posisi ikan
      double newPosition = fishPositionX.value + movement;

      // batasi agar ikan tidak keluar layar (-1.0 sampai 1.0)
      if (newPosition < -1.0) newPosition = -1.0;
      if (newPosition > 1.0) newPosition = 1.0;

      fishPositionX.value = newPosition;
    });
  }

  // - Logika memulai game -
  void startGame() {
    score.value = 0;
    lives.value = 3;
    isGameOver.value = false;
    isPlaying.value = true;
    fishPositionX.value = 0.0; // ikan ada ditengah layar

    print("Game Dimulai! Miringkan HP ke Kiri/Kanan");
  }

  void hitItem(bool isFood) {
    if (isFood) {
      score.value += 10; // tambah score jika makan pelet
    } else {
      lives.value -= 1; // kurangi nyawa jika kena sampah
      if (lives.value <= 0) {
        gameOver();
      }
    }
  }

  void gameOver() {
    isPlaying.value = false;
    isGameOver.value = true;
    print("Game Over! Skor Akhir: ${score.value}");
    // Tampilkan pesan edukasi di UI nanti
  }

  @override
  void onClose() {
    // Matikan sensor saat keluar dari halaman game
    _gyroscopeSubscription?.cancel();
    super.onClose();
  }
}
