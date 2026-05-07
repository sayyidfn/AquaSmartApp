import 'package:get/get.dart';
import '../../features/dashboard/dashboard_controller.dart';
import '../../features/encyclopedia/ai_assistant_controller.dart';
import '../../features/encyclopedia/encyclopedia_controller.dart';
import '../../features/game/game_controller.dart';
import '../../features/home/home_controller.dart';
import '../../features/profile/profile_controller.dart';
import '../../features/tools/tools_controller.dart';

class DashboardBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<EncyclopediaController>(() => EncyclopediaController());
    Get.lazyPut<AiAssistantController>(() => AiAssistantController());
    Get.lazyPut<GameController>(() => GameController());
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<ToolsController>(() => ToolsController());
  }
}
