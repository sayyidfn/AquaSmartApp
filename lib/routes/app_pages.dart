import 'package:get/get.dart';

// import rute
import 'app_routes.dart';

// import bindings (Injeksi Controller yang rapi)
import '../core/bindings/auth_binding.dart';
import '../core/bindings/dashboard_binding.dart';

// import views (ui)
import '../features/auth/login_view.dart';
import '../features/auth/register_view.dart'; // Sudah dipindah ke kelompok UI
import '../features/dashboard/dashboard_view.dart';
import '../features/game/game_view.dart';
import '../features/maps/maps_view.dart';

// import controllers (logic) - Hanya untuk yang masih pakai BindingsBuilder langsung
import '../features/game/game_controller.dart';
import '../features/maps/maps_controller.dart';

class AppPages {

  // daftar rute
  static final routes = [
    GetPage(
      name: Routes.AUTH,
      page: () => const LoginView(),
      // PERBAIKAN 2: Menggunakan class Binding terpisah yang lebih bersih
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
      // Karena kita belum membuat file game_binding.dart,
      // yang ini biarkan menggunakan cara lama (inline) sementara waktu
      binding: BindingsBuilder(() {
        Get.put(GameController());
      }),
    ),
    GetPage(
      name: Routes.MAPS,
      page: () => const MapsView(),
      binding: BindingsBuilder(() {
        Get.put(MapsController());
      }),
    ),
  ];
}
