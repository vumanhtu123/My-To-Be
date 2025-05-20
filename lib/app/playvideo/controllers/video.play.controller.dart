import 'dart:async';

import 'package:get/get.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';

class VideoPlayBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VideoController>(() => VideoController());
  }
}

class VideoController extends GetxController {
  final YoutubeExplode yt = YoutubeExplode();
  final AudioPlayer audioPlayer = AudioPlayer();
  final String videoId = Get.arguments['videoId'];

  VideoPlayerController? videoController;

  var isLoading = true.obs;
  var errorMessage = ''.obs;
  var isVideoMode = true.obs;

  var title = ''.obs;
  var author = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMedia();
  }

  Future<void> _loadMedia() async {
    try {
      print("check id ${videoId}");
      final video = await yt.videos.get(videoId);
      final manifest = await yt.videos.streamsClient.getManifest(videoId);

      // Audio
      final audioStream = manifest.audioOnly.withHighestBitrate();
      await audioPlayer.setUrl(audioStream.url.toString());

      // Video
      final videoStream = manifest.muxed.withHighestBitrate();
      videoController = VideoPlayerController.networkUrl(videoStream.url);
      await videoController!.initialize();

      title.value = video.title;
      author.value = video.author;
    } catch (e) {
      errorMessage.value = 'Lỗi phát media: $e';
    } finally {
      isLoading.value = false;
    }
  }

  void toggleMode() {
    isVideoMode.value = !isVideoMode.value;
    if (isVideoMode.value) {
      audioPlayer.pause();
      videoController?.play();
    } else {
      videoController?.pause();
      audioPlayer.play();
    }
  }

  void playPause() {
    if (isVideoMode.value) {
      if (videoController!.value.isPlaying) {
        videoController?.pause();
      } else {
        videoController?.play();
      }
    } else {
      if (audioPlayer.playing) {
        audioPlayer.pause();
      } else {
        audioPlayer.play();
      }
    }
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    videoController?.dispose();
    yt.close();
    super.onClose();
  }
}
