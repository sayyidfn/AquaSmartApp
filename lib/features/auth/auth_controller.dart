import 'dart:convert';
import 'package:get/get.dart';
import 'package:crypto/crypto.dart';
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

  // Hash password dengan SHA-256 sebelum disimpan ke Hive
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  // Register akun baru
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

    if (!GetUtils.isEmail(email)) {
      errorMessage.value = 'Format email tidak valid, pastikan mengandung @';
      return false;
    }

    if (password.length < 6) {
      errorMessage.value = 'Password minimal 6 karakter';
      return false;
    }

    isLoading.value = true;
    try {
      final box = Hive.box(userBoxName);

      if (box.containsKey(email)) {
        errorMessage.value = 'Email sudah terdaftar!';
        return false;
      }

      await box.put(email, {
        'name': name,
        'nim': nim,
        'email': email,
        'password': _hashPassword(password),
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

  // Login dengan email dan password
  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Email dan Password harus diisi!';
      return false;
    }

    if (!GetUtils.isEmail(email)) {
      errorMessage.value = 'Format email tidak valid, pastikan mengandung @';
      return false;
    }

    isLoading.value = true;
    try {
      final box = Hive.box(userBoxName);
      final userData = box.get(email);
      final hashedInput = _hashPassword(password);

      if (userData != null && userData['password'] == hashedInput) {
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
    final box = Hive.box(userBoxName);
    return box.get('use_biometric', defaultValue: false);
  }

  // Login menggunakan sidik jari / biometrik
  Future<bool> loginWithBiometric() async {
    try {
      final box = Hive.box(userBoxName);
      final String? lastEmail = box.get('last_logged_in_email');

      if (lastEmail == null || lastEmail.isEmpty) {
        errorMessage.value =
            'Data login sebelumnya tidak ditemukan. Silakan login manual dengan email.';
        return false;
      }

      final isEnabled = HiveProvider.getBiometricStatus(lastEmail);
      if (!isEnabled) {
        errorMessage.value =
            'Fitur biometrik belum diaktifkan. Silakan login manual dan aktifkan di menu Profil.';
        return false;
      }

      final canCheck = await auth.canCheckBiometrics;
      final isSupported = await auth.isDeviceSupported();

      if (!canCheck || !isSupported) {
        errorMessage.value = 'Perangkat Anda tidak mendukung fitur biometrik.';
        return false;
      }

      final didAuthenticate = await auth.authenticate(
        localizedReason: 'Pindai sidik jari Anda untuk masuk ke AquaSmart',
        biometricOnly: true,
      );

      if (didAuthenticate) {
        final userData = box.get(lastEmail);
        if (userData != null) {
          await StorageUtil.saveLoginSession(
            lastEmail,
            userData['nim'],
            userData['name'],
          );
          return true;
        }
      }

      return false;
    } catch (e) {
      errorMessage.value = 'Sensor dibatalkan atau terjadi kesalahan.';
      return false;
    }
  }
}
