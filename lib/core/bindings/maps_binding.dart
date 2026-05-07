import 'package:get/get.dart';
import '../../features/maps/maps_controller.dart';

class MapsBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MapsController>(() => MapsController());
  }
}
