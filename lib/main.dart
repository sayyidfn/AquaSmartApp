import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/utils/storage_util.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Hive.openBox('userBox');
  await Hive.openBox('gameBox');

  bool isLogin = await StorageUtil.isLoggedIn();

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
