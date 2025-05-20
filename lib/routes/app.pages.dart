import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:my_to_be/app/favorite/controllers/favorite.controller.dart';
import 'package:my_to_be/app/home/views/home.page.dart';
import 'package:my_to_be/app/playvideo/controllers/video.play.controller.dart';
import 'package:my_to_be/app/playvideo/views/video.play.page.dart';
import 'package:my_to_be/app/setting/controllers/setting.controller.dart';
import 'package:my_to_be/app/setting/views/setting.page.dart';
import 'package:my_to_be/app/trending/views/trending.page.dart';
import 'package:my_to_be/main.dart';

import '../app/favorite/views/favorite.page.dart';
import '../app/home/controllers/home.controller.dart';
import '../app/splash/views/splash.page.dart';
import '../app/trending/controllers/trending.controller.dart';
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
    ),
    GetPage(
      name: Routes.splash,
      page: () => const SplashPage(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.trending,
      page: () => const TrendingPage(),
      binding: TrendingBinding(),
    ),
    GetPage(
      name: Routes.favorite,
      page: () => const FavoritePage(),
      binding: FavoriteBinding(),
    ),
    GetPage(
      name: Routes.setting,
      page: () => const SettingPage(),
      binding: SettingBinding(),
    ),
    GetPage(
      name: Routes.playVideo,
      page: () => const VideoPlayerPage(),
      binding: VideoPlayBinding(),
    ),
  ];
}
