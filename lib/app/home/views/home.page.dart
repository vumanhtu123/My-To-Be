import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:my_to_be/app/home/controllers/home.controller.dart';

import '../component/item.home.component.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Center(child: Text("Home")),
            Expanded(
                child: ListView.builder(
                  itemCount: controller.videos.length + (controller.loading.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.videos.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    // Đảm bảo chỉ gọi fetchNextPage sau khi frame hiện tại hoàn tất
                    if (index >= controller.videos.length - 2 &&
                        controller.hasMore &&
                        !controller.loading.value) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        controller.fetchNextPage();
                      });
                    }

                    final video = controller.videos[index];
                    return GestureDetector(
                      onTap: () => controller.nextPlayVideo(video.videoId),
                      child: YouTubeVideoItem(
                        thumbnailUrl: video.videoThumbnails[0].url,
                        duration: video.lengthSeconds,
                        title: video.title,
                        channelName: video.author,
                        views: video.viewCountText,
                        publishedTime: video.publishedText,
                        channelAvatarUrl: video.authorThumbnails[0].url,
                      ),
                    );
                  },
                )),
          ],
        ),
      );
    });
  }
}
