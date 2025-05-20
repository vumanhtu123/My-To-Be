import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chewie/chewie.dart';
import '../controllers/video.play.controller.dart';

class VideoPlayerPage extends GetView<VideoController> {
  const VideoPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text('Phát media')),
        actions: [
          Obx(() => IconButton(
            icon: Icon(controller.isVideoMode.value ? Icons.music_note : Icons.ondemand_video),
            onPressed: controller.toggleMode,
          )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value));
        }

        return Column(
          children: [
            if (controller.isVideoMode.value)
              AspectRatio(
                aspectRatio: controller.videoController!.value.aspectRatio,
                child: Chewie(
                  controller: ChewieController(
                    videoPlayerController: controller.videoController!,
                    autoPlay: true,
                    looping: false,
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    const Icon(Icons.music_note, size: 80),
                    const SizedBox(height: 16),
                    Text(
                      controller.title.value,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      controller.author.value,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Phát / Tạm dừng'),
              onPressed: controller.playPause,
            ),
          ],
        );
      }),
    );
  }
}
