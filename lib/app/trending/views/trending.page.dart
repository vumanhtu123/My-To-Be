import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/trending.controller.dart';

class TrendingPage extends GetView<TrendingController> {
  const TrendingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text("Trending")),
    );
  }
}
