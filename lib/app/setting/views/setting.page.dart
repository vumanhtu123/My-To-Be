import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/theme.controller.dart';
import '../controllers/setting.controller.dart';

class SettingPage extends GetView<SettingController> {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Center(child: Text("Setting")),
          IconButton(
            icon: Obx(() {
              final isDark = Get.find<ThemeController>().isDarkMode.value;
              return Icon(isDark ? Icons.light_mode : Icons.dark_mode);
            }),
            onPressed: () => Get.find<ThemeController>().toggleTheme(),
          ),
        ],
      ),
    );
  }
}
