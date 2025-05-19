import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../main.controller.dart';

class FloatingBottomBar extends StatelessWidget {
  const FloatingBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black87 : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          BottomBarItem(icon: Icons.home, label: 'Home', index: 0),
          BottomBarItem(icon: Icons.search, label: 'Search', index: 1),
          BottomBarItem(icon: Icons.favorite, label: 'Likes', index: 2),
          BottomBarItem(icon: Icons.person, label: 'Profile', index: 3),
        ],
      ),
    );
  }
}

class BottomBarItem extends StatelessWidget {
  final IconData icon;
  final int index;
  final String label;

  const BottomBarItem({
    super.key,
    required this.icon,
    required this.index,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final navCtrl = Get.find<MainController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Obx(() {
      final isSelected = navCtrl.currentIndex.value == index;
      final backgroundColor = isSelected
          ? (isDark ? Colors.white : Colors.black)
          : Colors.transparent;
      final iconColor = isSelected
          ? (isDark ? Colors.black : Colors.white)
          : (isDark ? Colors.white70 : Colors.black87);

      return GestureDetector(
        onTap: () => navCtrl.changeTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor),
              // if (isSelected) const SizedBox(width: 6),
              // if (isSelected)
              //   Text(
              //     label,
              //     style: TextStyle(
              //       color: iconColor,
              //       fontWeight: FontWeight.w600,
              //     ),
              //   ),
            ],
          ),
        ),
      );
    });
  }
}
