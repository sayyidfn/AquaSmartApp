import 'dart:async';
import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../data/providers/api_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/snackbar_helper.dart';
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
      final prefs = await SharedPreferences.getInstance();
      final String? savedName = prefs.getString(StorageUtil.keyUserName);
      if (savedName != null && savedName.isNotEmpty) {
        userName.value = savedName.split(' ')[0];
      }
    } catch (e) {
      // Gagal load nama tidak perlu ditampilkan ke user
    }
  }

  Future<void> fetchWeatherData() async {
    isLoading.value = true;
    errorMessage.value = '';

    const double lat = -8.023;
    const double lng = 110.334;

    final data = await ApiProvider.getWeather(lat, lng);

    if (data != null && data['current_weather'] != null) {
      final double temp = (data['current_weather']['temperature'] as num).toDouble();
      waterTemperature.value = temp;

      if (temp > 27.0) {
        NotificationHelper.showNotification(
          id: 1,
          title: '🚨 Peringatan Suhu Panas!',
          body: 'Suhu air mencapai $temp°C. Segera nyalakan pendingin atau periksa sirkulasi air akuarium Anda.',
        );
      } else if (temp < 26.0) {
        NotificationHelper.showNotification(
          id: 2,
          title: '❄️ Peringatan Suhu Dingin!',
          body: 'Suhu air turun ke $temp°C. Ikan tropis Anda butuh kehangatan, nyalakan Heater sekarang.',
        );
      } else {
        NotificationHelper.showNotification(
          id: 3,
          title: '✅ Akuarium Aman',
          body: 'Suhu air stabil di $temp°C. Kondisi ideal untuk ikan kesayangan Anda.',
        );
      }
    } else {
      errorMessage.value = 'Gagal mengambil data cuaca';
    }

    isLoading.value = false;
  }

  // Sensor accelerometer untuk shake-to-refresh
  void _initShakeSensor() {
    try {
      _accelerometerSubscription = accelerometerEventStream().listen(
        (AccelerometerEvent event) {
          final double gX = event.x / 9.80665;
          final double gY = event.y / 9.80665;
          final double gZ = event.z / 9.80665;
          final double gForce = (gX * gX + gY * gY + gZ * gZ);

          if (gForce > 2.5) {
            final now = DateTime.now();
            if (now.difference(_lastShakeTime).inSeconds > 5) {
              _lastShakeTime = now;
              SnackbarHelper.showInfo(
                'Memperbarui Data',
                'Guncangan terdeteksi, mengambil data suhu terbaru...',
              );
              fetchWeatherData();
            }
          }
        },
        onError: (error) {
          // Error sensor tidak perlu ditampilkan ke user
        },
      );
    } catch (e) {
      // Sensor tidak tersedia di emulator/perangkat tanpa akselerometer
    }
  }

  @override
  void onClose() {
    _accelerometerSubscription?.cancel();
    super.onClose();
  }
}
