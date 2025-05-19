import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../main.controller.dart';

class FloatingBottomBar extends StatelessWidget {
  const FloatingBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(40),
        // boxShadow: const [
        //   BoxShadow(
        //     color: Colors.black38,
        //     blurRadius: 8,
        //     offset: Offset(0, 4),
        //   ),
        // ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          BottomBarItem(icon: Icons.home, label: 'Home', index: 0),
          BottomBarItem(icon: Icons.trending_up, label: 'Search', index: 1),
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

    return Obx(() {
      final isSelected = navCtrl.currentIndex.value == index;
      return GestureDetector(
        onTap: () => navCtrl.changeTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: isSelected
              ? BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          )
              : null,
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.redAccent : Colors.black,
              ),
              // if (isSelected)
              //   const SizedBox(width: 6),
              // if (isSelected)
              //   Text(
              //     label,
              //     style: const TextStyle(color: Colors.black),
              //   ),
            ],
          ),
        ),
      );
    });
  }
}

