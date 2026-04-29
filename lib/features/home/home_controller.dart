import 'dart:async';
import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../data/providers/api_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/storage_util.dart';
import '../../core/utils/notification_helper.dart';

class HomeController extends GetxController {
  var isLoading = false.obs;
  var waterTemperature = 0.0.obs;
  var errorMessage = ''.obs;

  var userName = 'User'.obs;

  StreamSubscription? _accelerometerSubscription;
  DateTime _lastShakeTime = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    NotificationHelper.requestPermission();
    fetchWeatherData();
    loadUserName();
    _initShakeSensor();
  }

  Future<void> loadUserName() async {
    try {
      // OPSI A: Jika menggunakan SharedPreferences
      final prefs = await SharedPreferences.getInstance();

      // GUNAKAN CARA YANG SAMA DENGAN PROFILE CONTROLLER
      String? savedName = prefs.getString(StorageUtil.keyUserName);

      print("===== CEK NAMA DARI STORAGE: $savedName =====");

      if (savedName != null && savedName.isNotEmpty) {
        // Jika namanya panjang (misal "Sayyid Fakhri Nurjundi"),
        // Anda bisa mengambil kata pertamanya saja agar UI Home tidak kepanjangan
        userName.value = savedName.split(' ')[0];
      }

      // OPSI B: Jika menggunakan Firebase Auth (Hapus komentar jika pakai ini)
      // final user = FirebaseAuth.instance.currentUser;
      // if (user != null && user.displayName != null) {
      //   userName.value = user.displayName!;
      // }
    } catch (e) {
      print("Error memuat nama user: $e");
    }
  }

  Future<void> fetchWeatherData() async {
    isLoading.value = true;
    errorMessage.value = '';

    double lat = -8.023;
    double lng = 110.334;

    var data = await ApiProvider.getWeather(lat, lng);

    if (data != null && data['current_weather'] != null) {
      double temp = (data['current_weather']['temperature'] as num).toDouble();
      waterTemperature.value = temp;

      // LOGIKA NOTIFIKASI PINTAR!
      if (temp > 28.0) {
        NotificationHelper.showNotification(
          id: 1,
          title: '🚨 Peringatan Suhu Panas!',
          body:
              'Suhu air mencapai $temp°C. Segera nyalakan pendingin atau periksa sirkulasi air akuarium Anda.',
        );
      } else if (temp < 26.0) {
        NotificationHelper.showNotification(
          id: 2,
          title: '❄️ Peringatan Suhu Dingin!',
          body:
              'Suhu air turun ke $temp°C. Ikan tropis Anda butuh kehangatan, nyalakan Heater sekarang.',
        );
      } else {
        // Opsional: Notifikasi jika aman (Bisa dihapus jika dirasa mengganggu)
        NotificationHelper.showNotification(
          id: 3,
          title: '✅ Akuarium Aman',
          body:
              'Suhu air stabil di $temp°C. Kondisi ideal untuk ikan kesayangan Anda.',
        );
      }
    } else {
      errorMessage.value = 'Gagal mengambil data cuaca';
    }

    isLoading.value = false;
  }

  // - Fungsi sensor accelerometer (shake to refresh) -
  void _initShakeSensor() {
    try {
      _accelerometerSubscription = accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          // menghitung kekuatan guncangan (treshold)
          double gX = event.x / 9.80665;
          double gY = event.y / 9.80665;
          double gZ = event.z / 9.80665;
          double gForce = (gX * gX + gY * gY + gZ * gZ);

          // jika guncangan cukup kuat (> 2.5G)
          if (gForce > 2.5) {
            final now = DateTime.now();
            if (now.difference(_lastShakeTime).inSeconds > 5) {
              _lastShakeTime = now;
              print("Guncangan terdeteksi! Memperbarui data cuaca...");

              Get.snackbar(
                'Memperbarui Data',
                'Guncangan terdeteksi, mengambil data suhu terbaru...',
                snackPosition: SnackPosition.BOTTOM,
                duration: const Duration(seconds: 2),
              );

              fetchWeatherData();
            }
          }
        },
        onError: (error) {
          // Menangkap error jika sensor terputus di tengah jalan
          print("Sensor accelerometer bermasalah/tidak didukung: $error");
        },
      );
    } catch (e) {
      // Menangkap error MissingPluginException saat dijalankan di Windows/Emulator yang tidak punya sensor
      print(
        "INFO: Sensor Accelerometer tidak ditemukan pada perangkat ini. Fitur Shake to Refresh dimatikan.",
      );
    }
  }

  @override
  void onClose() {
    _accelerometerSubscription?.cancel();
    super.onClose();
  }
}
