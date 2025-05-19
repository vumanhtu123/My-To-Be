import 'package:get/get.dart';

class TrendingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TrendingController>(() => TrendingController());
  }
}

class TrendingController extends GetxController{

}