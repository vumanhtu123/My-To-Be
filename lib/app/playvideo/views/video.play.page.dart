import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_to_be/app/playvideo/controllers/video.play.controller.dart';
import 'package:video_player/video_player.dart';

import '../components/video.play.component.dart';


class VideoPlayerPage extends GetView<VideoController> {
  const VideoPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Play", maxLines: 1),
        backgroundColor: Colors.black87,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          // Hiển thị thumbnail + loading spinner
          return Stack(
            alignment: Alignment.center,
            children: [
              Image.network(
                controller.thumbnailUrl.value,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 250,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey,
                  width: double.infinity,
                  height: 250,
                  child: const Icon(Icons.error, color: Colors.white),
                ),
              ),
              const CircularProgressIndicator(),
            ],
          );
        }

        if (controller.isError.value) {
          return ErrorView(
            message: controller.errorMessage.value,
            onRetry: controller.loadMedia, // Hoặc gọi lại hàm load media phù hợp
          );
        }
        if (!controller.isVideoReady.value) {
          // Nếu video chưa init, chỉ hiển thị thumbnail
          return Image.network(
            controller.thumbnailUrl.value,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 250,
          );
        }

        // Video player chính thức
        return Column(
          children: [
            AspectRatio(
              aspectRatio: controller.videoController!.value.aspectRatio,
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  VideoPlayer(controller.videoController!),
                  VideoOverlay(controller: controller),
                  VideoProgressIndicator(
                    controller.videoController!,
                    allowScrubbing: true,
                    padding: const EdgeInsets.all(8),
                  ),
                ],
              ),
            ),

            // Thông tin video
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                controller.title.value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),

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
                    child: const Text(
                      'SUBSCRIBE',
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  )
                ],
              ),
            ),

            const Divider(color: Colors.white24),

            // Controls: Play/Pause + Toggle mode
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: Obx(() {
                      final isPlaying = controller.isVideoMode.value
                          ? (controller.videoController?.value.isPlaying ?? false)
                          : controller.audioPlayer.playing;
                      return Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.white,
                      );
                    }),
                    onPressed: controller.togglePlayPause,
                  ),
                  IconButton(
                    icon: const Icon(Icons.swap_vert, color: Colors.white),
                    onPressed: controller.toggleMode,
                    tooltip: 'Chuyển chế độ Video / Audio',
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white24),

            // Placeholder danh sách video liên quan
            Expanded(
              child: ListView.builder(
                itemCount: 8,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Container(
                      width: 100,
                      height: 56,
                      color: Colors.grey[700],
                      child: const Center(
                        child: Icon(Icons.play_arrow, color: Colors.white),
                      ),
                    ),
                    title: Text(
                      "Video liên quan #$index",
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      "Channel name • 1M views • 2 weeks ago",
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    onTap: () {
                      // Xử lý chuyển video nếu cần
                    },
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}