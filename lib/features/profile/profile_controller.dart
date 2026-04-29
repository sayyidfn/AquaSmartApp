import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_auth/local_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/storage_util.dart';
import '../../data/locals/hive_provider.dart';

class ProfileController extends GetxController {
  // ==========================================
  // 1. VARIABEL STATE (Disamakan persis dengan ProfileView)
  // ==========================================

  // Data User
  var currentName = 'Loading...'.obs;
  var currentNim = '...'.obs;
  String? currentUserEmail;

  // Foto Profil
  var currentProfileImagePath = ''.obs;
  final ImagePicker _picker = ImagePicker();

  // Testimoni
  var isEditingTestimonial = false.obs;
  final TextEditingController testimonialController = TextEditingController();

  // Biometrik
  var isBiometricEnabled = false.obs;
  final LocalAuthentication auth = LocalAuthentication();

  // ==========================================
  // 2. INISIALISASI AWAL (Load Data)
  // ==========================================
  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    currentUserEmail = await StorageUtil.getLoggedInEmail();

    // Ambil Nama dan NIM dari SharedPreferences (karena disave saat login)
    final prefs = await SharedPreferences.getInstance();
    currentName.value =
        prefs.getString(StorageUtil.keyUserName) ?? 'User Unknown';
    currentNim.value = prefs.getString(StorageUtil.keyUserNim) ?? '000000';

    if (currentUserEmail != null) {
      // Load semua data dari brankas Hive sesuai email
      isBiometricEnabled.value = HiveProvider.getBiometricStatus(
        currentUserEmail!,
      );
      currentProfileImagePath.value = HiveProvider.getProfileImagePath(
        currentUserEmail!,
      );
      testimonialController.text = HiveProvider.getTestimonialContent(
        currentUserEmail!,
      );
    }
  }

  // ==========================================
  // 3. FUNGSI FOTO PROFIL (ANTI-LAG)
  // ==========================================
  Future<void> pickProfileImage() async {
    if (currentUserEmail == null) {
      Get.snackbar('Error', 'Sesi tidak valid.');
      return;
    }
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50, // Kompresi agar tidak lag
        maxWidth: 800,
      );

      if (image != null) {
        currentProfileImagePath.value = image.path; // Update UI
        HiveProvider.saveProfileImagePath(
          currentUserEmail!,
          image.path,
        ); // Simpan permanen
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat gambar galeri.');
    }
  }

  // ==========================================
  // 4. FUNGSI TESTIMONI
  // ==========================================
  void toggleEditTestimonial() {
    // Balikkan status (dari baca ke edit, atau edit ke baca)
    isEditingTestimonial.value = !isEditingTestimonial.value;

    // Jika user selesai mengedit (menekan tombol centang)
    if (!isEditingTestimonial.value && currentUserEmail != null) {
      // Simpan teks testimoni ke brankas Hive (default bintang 5 untuk saat ini)
      HiveProvider.saveTestimonial(
        currentUserEmail!,
        testimonialController.text,
        5,
      );
      Get.snackbar(
        'Berhasil',
        'Testimoni Anda telah disimpan!',
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    }
  }

  // ==========================================
  // 5. FUNGSI BIOMETRIK
  // ==========================================
  Future<void> toggleBiometric(bool value) async {
    if (currentUserEmail == null) return;

    if (value == true) {
      try {
        bool canCheck = await auth.canCheckBiometrics;
        bool isSupported = await auth.isDeviceSupported();

        if (canCheck && isSupported) {
          bool didAuthenticate = await auth.authenticate(
            localizedReason:
                'Pindai biometrik Anda untuk mengaktifkan login cepat',
            biometricOnly: true,
          );

          if (didAuthenticate) {
            isBiometricEnabled.value = true;
            HiveProvider.saveBiometricStatus(currentUserEmail!, true);
          } else {
            isBiometricEnabled.value = false;
          }
        } else {
          Get.snackbar('Info', 'Perangkat tidak mendukung biometrik');
          isBiometricEnabled.value = false;
        }
      } catch (e) {
        isBiometricEnabled.value = false;
      }
    } else {
      isBiometricEnabled.value = false;
      HiveProvider.saveBiometricStatus(currentUserEmail!, false);
    }
  }

  // ==========================================
  // 6. FUNGSI LOGOUT
  // ==========================================
  Future<void> logout() async {
    // Bersihkan sesi di StorageUtil
    await StorageUtil.clearSession();

    // Arahkan kembali ke halaman Login (sesuaikan dengan nama rute Anda, misal '/login')
    Get.offAllNamed('/auth');
  }
}
