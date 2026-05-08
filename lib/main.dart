import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/utils/storage_util.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  // Menginisialisasi Flutter Binding agar dapat menggunakan widget.
  WidgetsFlutterBinding.ensureInitialized();
  
  // Menginisialisasi Hive agar dapat menggunakan Hive.
  await Hive.initFlutter();

  // Membuka box untuk menyimpan data.
  await Hive.openBox('userBox');
  await Hive.openBox('gameBox');

  // Mengecek apakah user sudah login.
  bool isLogin = await StorageUtil.isLoggedIn();

  // Menjalankan aplikasi jika user sudah login maka akan masuk ke dashboard, jika tidak maka akan masuk ke auth.
  runApp(AquaSmartApp(isLoggedIn: isLogin));
}

class AquaSmartApp extends StatelessWidget {
  final bool isLoggedIn;

  const AquaSmartApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AquaSmart',
      debugShowCheckedModeBanner: false,
      initialRoute: isLoggedIn ? Routes.DASHBOARD : Routes.AUTH,
      getPages: AppPages.routes,
    );
  }
}
