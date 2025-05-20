import 'package:get/get.dart';
import 'package:my_to_be/app/home/controllers/home.controller.dart';

import '../main.controller.dart';

class BottomBarBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
