import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart'; 
import '../../core/utils/storage_util.dart';

class ProfileController extends GetxController {
  var testimonialController = TextEditingController();

  var isEditingTestimonial = false.obs;
  var isBiometricEnabled = false.obs;

  var currentUserEmail = ''.obs;
  
  var currentName = ''.obs;
  var currentNim = ''.obs;
  var currentProfileImagePath = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  void loadUserData() async {
    currentUserEmail.value = await StorageUtil.getLoggedInEmail() ?? '';

    var box = Hive.box('userBox');
    isBiometricEnabled.value = box.get('use_biometric', defaultValue: false);

    if (currentUserEmail.value.isNotEmpty) {
      var userData = box.get(currentUserEmail.value);
      if (userData != null) {
        // Langsung isi ke variabel reaktif, tanpa perlu TextEditingController
        currentName.value = userData['name'] ?? 'Sayyid Fakhri Nurjundi';
        currentNim.value = userData['nim'] ?? '123230172';
        currentProfileImagePath.value = userData['profile_image'] ?? '';
        
        testimonialController.text = userData['testimonial'] ?? '';
      }
    }
  }

  Future<void> pickProfileImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        currentProfileImagePath.value = image.path;
        
        var box = Hive.box('userBox');
        var userData = box.get(currentUserEmail.value) ?? {};
        userData['profile_image'] = image.path;
        box.put(currentUserEmail.value, userData);
        
        Get.snackbar('Sukses', 'Foto profil berhasil diperbarui', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih foto: $e', snackPosition: SnackPosition.BOTTOM);
    }
  }

  void toggleBiometric(bool value) {
    isBiometricEnabled.value = value;
    var box = Hive.box('userBox');
    box.put('use_biometric', value);

    if (value) {
      Get.snackbar(
        'Biometrik Aktif',
        'Login dengan sidik jari/Face ID diaktifkan',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void toggleEditTestimonial() {
    isEditingTestimonial.value = !isEditingTestimonial.value;
    if (!isEditingTestimonial.value) {
      _saveTestimonial();
    }
  }

  void _saveTestimonial() {
    var box = Hive.box('userBox');
    var userData = box.get(currentUserEmail.value) ?? {};

    userData['testimonial'] = testimonialController.text;
    box.put(currentUserEmail.value, userData);

    Get.snackbar(
      'Berhasil',
      'Testimoni mata kuliah berhasil disimpan',
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void logout() {
    StorageUtil.clearSession();
    Get.offAllNamed('/auth');
  }

  @override
  void onClose() {
    // Sekarang kita hanya perlu membuang 1 controller saja
    testimonialController.dispose();
    super.onClose();
  }
}