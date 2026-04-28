import 'package:get/get.dart';
import '../../features/dashboard/dashboard_controller.dart';
import '../../features/home/home_controller.dart';

class DashboardBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
