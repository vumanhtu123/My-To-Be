import 'dart:ui';

import 'package:get/get.dart';

class BottomBarController extends GetxController {
  var selectedIndex = 0.obs;

  void changeIndex(int index) {
    selectedIndex.value = index;
  }

  void switchLocale() {
    if (Get.locale == const Locale('en', 'US')) {
      Get.updateLocale(const Locale('vi', 'VN'));
    } else {
      Get.updateLocale(const Locale('en', 'US'));
    }
  }
}