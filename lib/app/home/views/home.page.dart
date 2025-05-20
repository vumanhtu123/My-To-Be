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
          backgroundColor: Colors.blueGrey,
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Center(child: Text("Home")),
              Expanded(
                  child: ListView.builder(
                itemCount: controller.videos.length,
                itemBuilder: (context, index) {
                  final feedItem = controller.videos[index];
                  return GestureDetector(
                    onTap: () {
                      controller.nextPlayVideo(feedItem.videoId);
                    },
                    child: YouTubeVideoItem(
                      thumbnailUrl: feedItem.videoThumbnails[0].url,
                      duration: feedItem.lengthSeconds,
                      title: feedItem.title,
                      channelName: feedItem.author,
                      views: feedItem.viewCountText.toString(),
                      publishedTime: feedItem.publishedText,
                      channelAvatarUrl: feedItem.authorThumbnails[0].url,
                    ),
                  );
                },
              )),
            ],
          ));
    });
  }
}
