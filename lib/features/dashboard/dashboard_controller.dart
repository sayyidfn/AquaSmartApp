import 'package:get/get.dart';

class DashboardController extends GetxController {
  // variabel reaktif untuk menyimpan index tab yang sedang aktif
  // 0 = Home, 1 = Encyclopedia, 2 = Tools, 3 = Profile
  var tabIndex = 0.obs;

  // fungsi untuk mengubah tab saat ikon di Bottom Navigation Bar ditekan
  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}
