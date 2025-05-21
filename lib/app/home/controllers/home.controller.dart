import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../base/repository/repositories.dart';
import '../../../models/trending.model.dart';
import '../../../routes/app.routes.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
  }
}

class HomeController extends GetxController {
  Repositories repositories = Repositories();
  final ScrollController scrollController = ScrollController();
  final videos = <VideoItem>[].obs;
  final loading = false.obs;
  int currentPage = 0;
  bool hasMore = true;

  @override
  void onInit() {
    super.onInit();
    fetchNextPage();
    scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      if (!loading.value && hasMore) {
        fetchNextPage();
      }
    }
  }

  Future<void> fetchNextPage() async {
    if (loading.value || !hasMore) return;

    loading.value = true;

    const int minValidItems = 10;
    const int maxAttempts = 5;
    int attempt = 0;
    final List<VideoItem> tempList = [];

    while (tempList.length < minValidItems && attempt < maxAttempts) {
      final result = await repositories.fetchSearchVideos(
        query: 'abc',
        type: 'video',
        sort: 'relevance',
        region: 'VN',
        page: currentPage,
      );

      attempt++;

      if (result is List && result.isNotEmpty) {
        final parsed = result.map((e) => VideoItem.fromJson(e)).toList();

        // Lọc bỏ shorts, live, video quá ngắn
        final valid = parsed.where((v) =>
        v.type == 'video' &&
            v.lengthSeconds >= 100 &&
            !v.liveNow &&
            v.lengthSeconds < 3600);

        if (valid.isEmpty) {
          currentPage++; // vẫn tăng để tránh lặp
          continue;
        }

        tempList.addAll(valid);
        currentPage++; // chỉ tăng khi có dữ liệu
      } else {
        hasMore = false;
        break;
      }
    }

    if (tempList.isNotEmpty) {
      videos.addAll(tempList);
    } else {
      hasMore = false;
    }

    loading.value = false;
  }

  void nextPlayVideo(String videoId) {
    Get.toNamed(Routes.playVideo, arguments: {'videoId': videoId});
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
