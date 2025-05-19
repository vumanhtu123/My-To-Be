import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/favorite.controller.dart';

class FavoritePage extends GetView<FavoriteController> {
  const FavoritePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Favorite")),
    );
  }
}
