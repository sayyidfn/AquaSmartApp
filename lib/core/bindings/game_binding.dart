import 'package:get/get.dart';
import '../../features/game/game_controller.dart';

class GameBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<GameController>(GameController());
  }
}
