import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Hive.openBox('userBox');

  runApp(const AquaSmartApp());
}

class AquaSmartApp extends StatelessWidget {
  const AquaSmartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AquaSmart',
      debugShowCheckedModeBanner: false,
      initialRoute: AppPages.initial, // rute awal
      getPages: AppPages.routes, // daftar rute
    );
  }
}
