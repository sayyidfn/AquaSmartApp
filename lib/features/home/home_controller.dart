import 'dart:async';
import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../data/providers/api_provider.dart';

class HomeController extends GetxController {
  // variabel yang akan dipantau oleh ui
  var isLoading = false.obs;
  var waterTemperature = 0.0.obs;
  var errorMessage = ''.obs;

  StreamSubscription? _accelerometerSubscription;
  DateTime _lastShakeTime = DateTime.now();

  @override
  void onInit() {
    super.onInit();
    fetchWeatherData(); // ambil data saat aplikasi pertama kali dibuka
    _initShakeSensor(); // aktifkan sensor guncang
  }

  // - Fungsi mengambil data api -
  Future<void> fetchWeatherData() async {
    isLoading.value = true;
    errorMessage.value = '';

    // koordinat dummy (misal: pantai parangtritis, yogyakarta)
    double lat = -8.023;
    double lng = 110.334;

    var data = await ApiProvider.getWeather(lat, lng);

    if (data != null && data['hours'] != null) {
      // mengambil suhu air dari jam pertama data json
      waterTemperature.value = data['hours'][0]['waterTemperature']['sg'];
    } else {
      errorMessage.value = 'Gagal mengambil data cuaca';
    }

    isLoading.value = false;
  }

  // - Fungsi sensor accelerometer (shake to refresh) -
  void _initShakeSensor() {
    _accelerometerSubscription = accelerometerEventStream().listen((
      AccelerometerEvent event,
    ) {
      // menghitung kekuatan guncangan (treshold)
      double gX = event.x / 9.80665;
      double gY = event.y / 9.80665;
      double gZ = event.z / 9.80665;
      double gForce = (gX * gX + gY * gY + gZ * gZ);

      // jika guncangan cukup kuat (> 2.5G)
      if (gForce > 2.5) {
        final now = DateTime.now();
        // jeda 5 detik antar gunacangan agar api tidak dipanggil trus
        if (now.difference(_lastShakeTime).inSeconds > 5) {
          _lastShakeTime = now;
          print("Guncangan terdeteksi! Memperbarui data cuaca...");

          // notif kecil (snackbar) lalu panggil ulang api
          GetSnackBar(
            title: 'Memperbarui Data',
            message: 'Guncangan terdeteksi, mengambil data terbaru...',
            snackPosition: SnackPosition.BOTTOM,
          );
          fetchWeatherData();
        }
      }
    });
  }

  @override
  void onClose() {
    // mematikan sensor agar tidak boros baterai
    _accelerometerSubscription?.cancel();
    super.onClose();
  }
}
