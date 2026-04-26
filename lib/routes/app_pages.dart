import 'package:get/get.dart';

// import rute
import 'app_routes.dart';

// import views (ui)
import '../features/auth/login_view.dart';
import '../features/dashboard/dashboard_view.dart';
import '../features/game/game_view.dart';

// import controllers (logic)
import '../features/auth/auth_controller.dart';
import '../features/auth/register_view.dart';
import '../features/dashboard/dashboard_controller.dart';
import '../features/game/game_controller.dart';
import '../features/home/home_controller.dart'; // HomeController dinyalakan dari Dashboard

class AppPages {
  // rute pertama yang dibuka saat aplikasi menyala
  static const INITIAL = Routes.AUTH;

  // daftar rute
  static final routes = [
    GetPage(
      name: Routes.AUTH,
      page: () => const LoginView(),
      binding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
    ),
    GetPage(
      name: Routes.REGISTER,
      page: () => const RegisterView(),
      binding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
    ),
    GetPage(
      name: Routes.DASHBOARD,
      page: () => const DashboardView(),
      binding: BindingsBuilder(() {
        Get.put(DashboardController());
        Get.put(HomeController());
      }),
    ),
    GetPage(
      name: Routes.GAME,
      page: () => const GameView(),
      binding: BindingsBuilder(() {
        Get.put(GameController());
      }),
    ),
  ];
}
