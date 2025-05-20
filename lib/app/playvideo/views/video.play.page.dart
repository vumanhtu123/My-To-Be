import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:chewie/chewie.dart';
import 'package:video_player/video_player.dart';
import '../controllers/video.play.controller.dart';

class VideoPlayerPage extends GetView<VideoController> {
  const VideoPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(

      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return Center(child: Text(controller.errorMessage.value, style: const TextStyle(color: Colors.white)));
        }

        return Column(
          children: [
            // Video player
            AspectRatio(
              aspectRatio: controller.videoController!.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  VideoPlayer(controller.videoController!),
                  _VideoOverlay(controller: controller),
                  VideoProgressIndicator(
                    controller.videoController!,
                    allowScrubbing: true,
                    padding: const EdgeInsets.all(8),
                  ),
                ],
              ),
            ),

            // Title
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                controller.title.value,
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                maxLines: 2,
              ),
            ),

            // Channel info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Colors.grey,
                    radius: 18,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      controller.author.value,
                      style: TextStyle(color: Colors.grey[300], fontSize: 14),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('SUBSCRIBE', style: TextStyle(color: Colors.redAccent)),
                  )
                ],
              ),
            ),

            const Divider(color: Colors.white24),

            // Controls
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  // IconButton(
                  //   icon: Icon(
                  //     controller.isVideoMode.value
                  //         ? (controller.videoController!.value.isPlaying ? Icons.pause : Icons.play_arrow)
                  //         : (controller.audioPlayer.playing ? Icons.pause : Icons.play_arrow),
                  //     color: Colors.white,
                  //   ),
                  //   onPressed: controller.playPause,
                  // ),
                  IconButton(
                    icon: Icon(Icons.swap_vert, color: Colors.white),
                    onPressed: controller.toggleMode,
                    tooltip: 'Chuyển chế độ Video / Audio',
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white24),

            // Suggested videos (dummy layout)
            Expanded(
              child: ListView.builder(
                itemCount: 8,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Container(
                      width: 100,
                      height: 56,
                      color: Colors.grey[700],
                      child: const Center(child: Icon(Icons.play_arrow, color: Colors.white)),
                    ),
                    title: Text("Video liên quan #$index", style: TextStyle(color: Colors.white)),
                    subtitle: Text("Channel name • 1M views • 2 weeks ago", style: TextStyle(color: Colors.grey[400])),
                    onTap: () {
                      // Điều hướng đến video khác nếu có tích hợp
                    },
                  );
                },
              ),
            )
          ],
        );
      }),
    );
  }
}

class _VideoOverlay extends StatelessWidget {
  final VideoController controller;

  const _VideoOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // onTap: controller.playPause,
      child: AnimatedOpacity(
        opacity: controller.videoController!.value.isPlaying ? 0 : 1,
        duration: const Duration(milliseconds: 300),
        child: Container(
          color: Colors.black45,
          child: const Center(
            child: Icon(Icons.play_arrow, size: 60, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
