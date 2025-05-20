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
  RxList<VideoItem> videos = <VideoItem>[].obs;
  RxBool loading = false.obs;

  @override
  void onInit() {
    initData();
    super.onInit();
  }

  void initData() async {
    loading.value = true;
    Future.delayed(const Duration(seconds: 4), () async {
      await repositories
          .fetchSearchVideos(
              query: 'video trend',
              type: 'video',
              sort: 'relevance',
              region: 'VN',
              page: 0)
          .then((value) => {
                if (value is List)
                  {
                    videos.value =
                        value.map((e) => VideoItem.fromJson(e)).toList()
                  }
                else
                  {print("check data $value")},
                loading.value = false,
              });
    });
  }

  void nextPlayVideo(String id) {
    Get.toNamed(Routes.playVideo, arguments: {'videoId': id});
    print("id: $id");
  }
}
