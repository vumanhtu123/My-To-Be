import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:my_to_be/main.dart';

import '../common/bindings.dart';
import 'app.routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.splash;

  static final routes = [
    GetPage(
      name: Routes.main,
      page: () => const MainScreen(),
      binding: BottomBarBinding(),
    )
  ];
}