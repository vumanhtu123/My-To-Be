import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app.routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  onGoToMain() {
    Future.delayed(const Duration(seconds: 3), () {
      Get.offAllNamed(Routes.main);
    });
  }

  @override
  void initState() {
    onGoToMain();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(color: Colors.black),
      ),
    );
  }
}
