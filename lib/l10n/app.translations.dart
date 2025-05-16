
import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'home': 'Home',
      'search': 'Search',
      'profile': 'Profile',
      'change_language': 'Change Language',
    },
    'vi_VN': {
      'home': 'Trang Chủ',
      'search': 'Tìm Kiếm',
      'profile': 'Hồ Sơ',
      'change_language': 'Đổi Ngôn Ngữ',
    },
  };
}