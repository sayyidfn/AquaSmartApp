import 'package:get/get.dart';
import 'app_routes.dart';
import '../core/bindings/auth_binding.dart';
import '../core/bindings/dashboard_binding.dart';
import '../core/bindings/maps_binding.dart';
import '../features/auth/login_view.dart';
import '../features/auth/register_view.dart';
import '../features/dashboard/dashboard_view.dart';
import '../features/game/game_view.dart';
import '../features/maps/maps_view.dart';
import '../features/game/game_controller.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.AUTH,
      page: () => const LoginView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: Routes.GAME,
      page: () => const GameView(),
      // GameController didaftarkan inline karena belum memiliki file binding tersendiri
      binding: BindingsBuilder(() {
        Get.put(GameController());
      }),
    ),
    GetPage(
      name: Routes.MAPS,
      page: () => const MapsView(),
      binding: MapsBinding(),
    ),
  ];
}
