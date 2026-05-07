import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_auth/local_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/snackbar_helper.dart';
import '../../core/utils/storage_util.dart';
import '../../data/locals/hive_provider.dart';

class ProfileController extends GetxController {

  // Data User
  var currentName = 'Loading...'.obs;
  var currentNim = '...'.obs;
  String? currentUserEmail;

  // Foto profil
  var currentProfileImagePath = ''.obs;
  final ImagePicker _picker = ImagePicker();

  // Testimoni
  var isEditingTestimonial = false.obs;
  var testimonialText = ''.obs;
  final TextEditingController testimonialController = TextEditingController();

  // Biometrik
  var isBiometricEnabled = false.obs;
  final LocalAuthentication auth = LocalAuthentication();

  @override
  void onInit() {
    super.onInit();
    // Pasang listener sekali di sini, bukan di dalam _loadUserData
    testimonialController.addListener(() {
      testimonialText.value = testimonialController.text;
    });
    _loadUserData();
  }

  // Fungsi untuk load user dari local storage
  Future<void> _loadUserData() async {
    currentUserEmail = await StorageUtil.getLoggedInEmail();

    final prefs = await SharedPreferences.getInstance();
    currentName.value = prefs.getString(StorageUtil.keyUserName) ?? 'User Unknown';
    currentNim.value = prefs.getString(StorageUtil.keyUserNim) ?? '000000';

    if (currentUserEmail != null) {
      isBiometricEnabled.value = HiveProvider.getBiometricStatus(currentUserEmail!);
      currentProfileImagePath.value = HiveProvider.getProfileImagePath(currentUserEmail!);
      testimonialController.text = HiveProvider.getTestimonialContent(currentUserEmail!);
      testimonialText.value = testimonialController.text;
    }
  }

  // Fungsi untuk ambil foto profil dari galeri
  Future<void> pickProfileImage() async {
    if (currentUserEmail == null) {
      SnackbarHelper.showError('Error', 'Sesi tidak valid.');
      return;
    }
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 800,
      );
      if (image != null) {
        currentProfileImagePath.value = image.path;
        HiveProvider.saveProfileImagePath(currentUserEmail!, image.path);
      }
    } catch (e) {
      SnackbarHelper.showError('Error', 'Gagal memuat gambar galeri.');
    }
  }

  // Fungsi untuk toggle edit testimoni
  void toggleEditTestimonial() {
    isEditingTestimonial.value = !isEditingTestimonial.value;

    if (!isEditingTestimonial.value && currentUserEmail != null) {
      HiveProvider.saveTestimonial(currentUserEmail!, testimonialController.text, 5);
      SnackbarHelper.showSuccess('Berhasil', 'Testimoni Anda telah disimpan!');
    }
  }

  // Hapus testimoni dengan dialog konfirmasi sebelum menghapus
  void deleteTestimonial() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.pureWhite,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.dangerRed.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.dangerRed,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Hapus Testimoni?',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Testimoni yang sudah dihapus tidak dapat dikembalikan.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.tfPlaceholder,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.tfBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        testimonialController.clear();
                        testimonialText.value = '';
                        if (currentUserEmail != null) {
                          HiveProvider.saveTestimonial(currentUserEmail!, '', 0);
                        }
                        isEditingTestimonial.value = false;
                        Get.back();
                        SnackbarHelper.showSuccess('Berhasil', 'Testimoni berhasil dihapus.');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dangerRed,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Hapus',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Fungsi untuk toggle biometrik
  Future<void> toggleBiometric(bool value) async {
    if (currentUserEmail == null) return;

    if (value) {
      try {
        final canCheck = await auth.canCheckBiometrics;
        final isSupported = await auth.isDeviceSupported();

        if (canCheck && isSupported) {
          final didAuthenticate = await auth.authenticate(
            localizedReason: 'Pindai biometrik Anda untuk mengaktifkan login cepat',
            biometricOnly: true,
          );

          if (didAuthenticate) {
            isBiometricEnabled.value = true;
            HiveProvider.saveBiometricStatus(currentUserEmail!, true);
          } else {
            isBiometricEnabled.value = false;
          }
        } else {
          SnackbarHelper.showInfo('Info', 'Perangkat tidak mendukung biometrik.');
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

  // Fungsi untuk logout dengan dialog konfirmasi
  Future<void> logout() async {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.pureWhite,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.dangerRed.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.dangerRed,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Keluar dari Akun?',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Anda perlu login kembali setelah keluar.',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.tfPlaceholder,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.tfBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Batal',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Get.back();
                        await StorageUtil.clearSession();
                        Get.offAllNamed('/auth');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.dangerRed,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: GoogleFonts.inter(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onClose() {
    testimonialController.dispose();
    super.onClose();
  }
}
