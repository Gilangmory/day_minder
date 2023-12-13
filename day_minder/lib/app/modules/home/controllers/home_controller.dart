import 'package:get/get.dart';
import 'dart:async';

class HomeController extends GetxController {
  // Observable untuk waktu saat ini
  var currentTime = ''.obs;

  @override
  void onInit() {
    super.onInit();
    Timer.periodic(Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    final now = DateTime.now();
    currentTime.value = '${now.hour}:${now.minute}:${now.second}';
  }

  @override
  void onClose() {
    super.onClose();
  }
}
