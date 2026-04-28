import 'dart:async';
import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../data/providers/api_provider.dart';

class HomeController extends GetxController {
  var isLoading = false.obs;
  var waterTemperature = 0.0.obs;
  var errorMessage = ''.obs;

  StreamSubscription? _accelerometerSubscription;
  DateTime _lastShakeTime = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    fetchWeatherData();
    _initShakeSensor();
  }

  Future<void> fetchWeatherData() async {
    isLoading.value = true;
    errorMessage.value = '';

    double lat = -8.023;
    double lng = 110.334;

    var data = await ApiProvider.getWeather(lat, lng);

    // PERBAIKAN: Membaca struktur JSON Standard Forecast (current_weather)
    if (data != null && data['current_weather'] != null) {
      // Pastikan konversi ke double aman
      waterTemperature.value = (data['current_weather']['temperature'] as num)
          .toDouble();
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
