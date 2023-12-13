import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/routes/app_pages.dart';
import './database_manager.dart';
import 'app/data/notif_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi database
  await DatabaseManager().database;

  // Inisialisasi dan konfigurasi NotifService
  NotifService notifService = NotifService();
  await notifService.init();
  notifService
      .startBackgroundTask(); // Memulai tugas latar belakang untuk notifikasi

  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
    ),
  );
}
