import 'package:get/get.dart';

class DashboardController extends GetxController {
  // Index tab yang sedang aktif (0=Home, 1=Encyclopedia, 2=Tools, 3=Profile)
  var tabIndex = 0.obs;

  void changeTabIndex(int index) {
    tabIndex.value = index;
  }
}
