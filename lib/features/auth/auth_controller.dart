import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:local_auth/local_auth.dart';
import '../../core/utils/storage_util.dart';
import '../../data/locals/hive_provider.dart';

class AuthController extends GetxController {
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;

  final String userBoxName = 'userBox';

  final LocalAuthentication auth = LocalAuthentication();

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  Future<bool> register(
    String name,
    String nim,
    String email,
    String password,
  ) async {
    if (name.isEmpty || nim.isEmpty || email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Semua kolom harus diisi';
      return false;
    }

    isLoading.value = true;
    try {
      var box = Hive.box(userBoxName);

      if (box.containsKey(email)) {
        errorMessage.value = 'Email sudah terdaftar!';
        return false;
      }

      await box.put(email, {
        'name': name,
        'nim': nim,
        'email': email,
        'password': password,
      });

      errorMessage.value = '';
      return true;
    } catch (e) {
      errorMessage.value = 'Gagal mendaftar: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // - Fungsi Login Standar -
  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Email dan Password harus diisi!';
      return false;
    }

    isLoading.value = true;
    try {
      var box = Hive.box(userBoxName);
      var userData = box.get(email);

      if (userData != null && userData['password'] == password) {
        await StorageUtil.saveLoginSession(
          email,
          userData['nim'],
          userData['name'],
        );

        box.put('last_logged_in_email', email);

        errorMessage.value = '';
        return true;
      } else {
        errorMessage.value = 'Email atau Password salah!';
        return false;
      }
    } catch (e) {
      errorMessage.value = 'Terjadi kesalahan sistem: $e';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  bool isBiometricEnabled() {
    var box = Hive.box(userBoxName);
    return box.get('use_biometric', defaultValue: false);
  }
  // - Fungsi Login Biometrik -
  Future<bool> loginWithBiometric() async {
    try {
      var box = Hive.box(userBoxName);
      String? lastEmail = box.get('last_logged_in_email');

      // 1. Cek apakah ada histori login
      if (lastEmail == null || lastEmail.isEmpty) {
        errorMessage.value =
            'Data login sebelumnya tidak ditemukan. Silakan login manual dengan email.';
        return false;
      }

      // 2. Cek apakah user ini menyalakan sakelar biometrik di halaman Profil
      bool isEnabled = HiveProvider.getBiometricStatus(lastEmail);
      if (!isEnabled) {
        errorMessage.value =
            'Fitur biometrik belum diaktifkan untuk akun ini. Silakan login manual dan aktifkan di menu Profil.';
        return false;
      }

      // 3. Cek dukungan hardware HP
      bool canCheckBiometrics = await auth.canCheckBiometrics;
      bool isDeviceSupported = await auth.isDeviceSupported();

      if (!canCheckBiometrics || !isDeviceSupported) {
        errorMessage.value = 'Perangkat Anda tidak mendukung fitur biometrik.';
        return false;
      }

      // 4. Munculkan pop-up sensor sidik jari (Sesuai dengan sintaks tooltip Anda)
      bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Pindai sidik jari Anda untuk masuk ke AquaSmart',
        biometricOnly: true,
      );

      // 5. Jika sidik jari cocok, langsung buatkan sesi login!
      if (didAuthenticate) {
        var userData = box.get(lastEmail);
        if (userData != null) {
          await StorageUtil.saveLoginSession(
            lastEmail,
            userData['nim'],
            userData['name'],
          );
          return true;
        }
      }
      return false; // Jika batal memindai
    } catch (e) {
      errorMessage.value = 'Sensor dibatalkan atau terjadi kesalahan.';
      return false;
    }
  }
}
