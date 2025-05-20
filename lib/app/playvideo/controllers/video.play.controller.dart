import 'dart:async';
import 'dart:developer';

import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
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
  final yt = YoutubeExplode();
  final audioPlayer = AudioPlayer();

  late final String videoId;
  late final StreamManifest _manifest;

  VideoPlayerController? videoController;
  ChewieController? chewieController;

  var isLoading = true.obs;
  var isError = false.obs;
  var errorMessage = ''.obs;

  var isVideoMode = true.obs;

  // Metadata
  var title = ''.obs;
  var author = ''.obs;
  var thumbnailUrl = ''.obs;
  var duration = ''.obs;

  @override
  void onInit() {
    videoId = Get.arguments['videoId'];
    _loadMedia();
    super.onInit();
  }

  Future<void> _loadMedia() async {
    isLoading.value = true;
    isError.value = false;
    errorMessage.value = '';
    try {
      final video = await yt.videos.get(videoId);
      _manifest = await yt.videos.streamsClient.getManifest(videoId);

      // Metadata
      title.value = video.title;
      author.value = video.author;
      thumbnailUrl.value = video.thumbnails.highResUrl;
      duration.value = video.duration?.inMinutes.toString() ?? '';

      final videoUrl = _getBestVideoUrl();
      final audioUrl = _getBestAudioUrl();

      await Future.wait([
        _initVideoPlayer(videoUrl),
        _initAudioPlayer(audioUrl),
      ]);
    } catch (e) {
      isError.value = true;
      errorMessage.value = 'Không thể tải video: $e';
      log('Load media error: $e', name: 'VideoController');
    } finally {
      isLoading.value = false;
    }
  }

  Uri _getBestVideoUrl() {
    final videoStream = _manifest.videoOnly
        .where((s) => s.container.name == 'mp4')
        .reduce((a, b) =>
    (a.size.totalBytes ?? 0) > (b.size.totalBytes ?? 0) ? a : b);
    return videoStream.url;
  }

  Uri _getBestAudioUrl() {
    final audioStream = _manifest.audioOnly
        .where((s) => s.container.name == 'mp4')
        .reduce((a, b) =>
    (a.size.totalBytes ?? 0) > (b.size.totalBytes ?? 0) ? a : b);
    return audioStream.url;
  }

  Future<void> _initVideoPlayer(Uri url) async {
    videoController?.dispose();
    videoController = VideoPlayerController.networkUrl(url);
    await videoController!.initialize();

    chewieController = ChewieController(
      videoPlayerController: videoController!,
      autoPlay: true,
      looping: false,
      allowMuting: true,
      showControls: true,
    );
  }

  Future<void> _initAudioPlayer(Uri url) async {
    await audioPlayer.setUrl(url.toString());
  }

  void togglePlayPause() {
    if (isVideoMode.value) {
      if (videoController?.value.isPlaying ?? false) {
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

  @override
  void onClose() {
    audioPlayer.dispose();
    videoController?.dispose();
    chewieController?.dispose();
    yt.close();
    super.onClose();
  }
}
