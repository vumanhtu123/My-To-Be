import 'dart:ui';

import 'package:get/get.dart';

class MainController extends GetxController {
  final currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  void switchLocale() {
    if (Get.locale == const Locale('en', 'US')) {
      Get.updateLocale(const Locale('vi', 'VN'));
    } else {
      Get.updateLocale(const Locale('en', 'US'));
    }
  }
}