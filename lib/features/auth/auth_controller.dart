import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../core/utils/storage_util.dart';

class AuthController extends GetxController {
  // state untuk memantau loading dan pesan error
  var isLoading = false.obs;
  var errorMessage = ''.obs;

  var isPasswordHidden = true.obs;
  var isConfirmPasswordHidden = true.obs;

  // fungsi untuk toggle ikon mata
  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  final String userBoxName = 'userBox';

  // - Fungsi Register -
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

      //cek apakah email sudah terdaftar
      if (box.containsKey(email)) {
        errorMessage.value = 'Email sudah terdaftar!';
        return false;
      }

      // simpan data pendaftaran ke Hive (Email sebagai Primary key)
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

  // - Fungsi Login -
  Future<bool> login(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Email dan Password harus diisi!';
      return false;
    }

    isLoading.value = true;
    try {
      var box = Hive.box(userBoxName);

      // ambil data dari Hive berdasarkan email
      var userData = box.get(email);

      // cocokan password
      if (userData != null && userData['password'] == password) {
        // jika cocok, panggil fungsi shared preferences untuk menyimpan sesi
        await StorageUtil.saveLoginSession(userData['nim'], userData['name']);
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
}
