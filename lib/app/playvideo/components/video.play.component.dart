import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/video.play.controller.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 64),
            const SizedBox(height: 20),
            const Text(
              'Không thể phát video',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoOverlay extends StatelessWidget {
  final VideoController controller;

  const VideoOverlay({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      // Nhấn toàn bộ màn hình để play/pause
      onTap: controller.togglePlayPause,
      child: Obx(() {
        final isPlaying = controller.isPlaying.value;
        final isVideoMode = controller.isVideoMode.value;

        return Stack(
          children: [
            // Nền bán trong suốt hiện khi video tạm dừng
            AnimatedOpacity(
              opacity: isPlaying ? 0 : 1,
              duration: const Duration(milliseconds: 300),
              child: Container(
                color: Colors.black45,
                child: Center(
                  child: Icon(
                    isPlaying ? null : Icons.play_arrow,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            // Thanh điều khiển ở dưới cùng
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Nút tua lùi 15 giây
                  IconButton(
                    icon: const Icon(Icons.replay_10, color: Colors.white, size: 30),
                    onPressed: () async {
                      final currentPos = controller.isVideoMode.value
                          ? controller.videoController?.value.position ?? Duration.zero
                          : controller.audioPlayer.position;

                      final newPos = currentPos - const Duration(seconds: 15);
                      await controller.seekTo(newPos >= Duration.zero ? newPos : Duration.zero);
                    },
                  ),

                  // Nút play/pause chính giữa
                  IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      color: Colors.white,
                      size: 50,
                    ),
                    onPressed: controller.togglePlayPause,
                  ),

                  // Nút tua nhanh 15 giây
                  IconButton(
                    icon: const Icon(Icons.forward_10, color: Colors.white, size: 30),
                    onPressed: () async {
                      final currentPos = controller.isVideoMode.value
                          ? controller.videoController?.value.position ?? Duration.zero
                          : controller.audioPlayer.position;

                      final totalDuration = controller.videoController?.value.duration ??
                          (controller.audioPlayer.duration ?? Duration.zero);

                      final newPos = currentPos + const Duration(seconds: 15);
                      await controller.seekTo(newPos <= totalDuration ? newPos : totalDuration);
                    },
                  ),

                  // Nút chuyển đổi chế độ Video/Audio
                  IconButton(
                    icon: Icon(
                      isVideoMode ? Icons.video_library : Icons.audiotrack,
                      color: Colors.white,
                      size: 30,
                    ),
                    onPressed: controller.toggleMode,
                    tooltip: isVideoMode ? 'Chuyển sang chế độ nghe nhạc' : 'Chuyển sang chế độ xem video',
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

