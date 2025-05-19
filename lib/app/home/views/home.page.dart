import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_to_be/app/home/controllers/home.controller.dart';

import '../../../helper/theme.controller.dart';


class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        const Center(child: Text("Home")),
        IconButton(
          icon: Obx(() {
            final isDark = Get.find<ThemeController>().isDarkMode.value;
            return Icon(isDark ? Icons.light_mode : Icons.dark_mode);
          }),
          onPressed: () => Get.find<ThemeController>().toggleTheme(),
        ),

      ],)
    );
  }
}
