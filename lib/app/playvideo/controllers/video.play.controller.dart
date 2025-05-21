import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:video_player/video_player.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;

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
  late StreamManifest _manifest;
  var isPlaying = false.obs;

  VideoPlayerController? videoController;

  var isLoading = true.obs;
  var isError = false.obs;
  var errorMessage = ''.obs;

  var isVideoReady = false.obs; // báo hiệu video player đã init

  var isVideoMode = true.obs;

  // Metadata
  var title = ''.obs;
  var author = ''.obs;
  var thumbnailUrl = ''.obs;
  var duration = ''.obs;

  @override
  void onInit() {
    super.onInit();
    videoId = Get.arguments['videoId'];
    loadMedia();
  }

  Future<void> loadMedia() async {
    try {
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';
      isVideoReady.value = false;

      final video = await yt.videos.get(videoId);
      try {
        _manifest = await yt.videos.streamsClient.getManifest(videoId);
      } catch (e) {
        log('[YouTubeExplode] getManifest lỗi: $e');

        final fallbackUrl = await getInvidiousFallbackStreamUrl(videoId);
        if (fallbackUrl == null) {
          throw Exception('Không thể tải manifest hoặc fallback stream');
        }

        await _initVideoPlayer(Uri.parse(fallbackUrl));
        return;
      }

      title.value = video.title;
      author.value = video.author;
      thumbnailUrl.value = video.thumbnails.highResUrl;
      duration.value = video.duration?.inMinutes.toString() ?? '';

      final videoUrl = _getLowestVideoUrl();
      final audioUrl = _getLowestAudioUrl();

      await Future.wait([
        _initVideoPlayer(videoUrl),
        _initAudioPlayer(audioUrl),
      ]);

      videoController!.addListener(_syncPosition);

      audioPlayer.playerStateStream.listen((state) {
        isPlaying.value = isVideoMode.value
            ? videoController?.value.isPlaying ?? false
            : state.playing;
      });

    } catch (e) {
      isError.value = true;
      errorMessage.value = e.toString();
      log('Load media error: $e', name: 'VideoController');
    } finally {
      isLoading.value = false;
    }
  }


  final List<String> invidiousInstances = [
    'https://vid.puffyan.us',
    'https://yewtu.be',
    'https://invidious.f5.si',
  ];

  Future<String?> getInvidiousFallbackStreamUrl(String videoId, {bool audioOnly = false}) async {
      try {
        final uri = Uri.parse('https://vid.puffyan.us/api/v1/videos/$videoId');
        final response = await http.get(uri);
        if (response.statusCode != 200);

        final data = jsonDecode(response.body);
        final formats = data['adaptiveFormats'] as List?;

        final selected = formats?.firstWhere(
              (f) {
            final type = f['type'] ?? '';
            return audioOnly ? type.startsWith('audio/') : type.startsWith('video/');
          },
          orElse: () => null,
        );

        if (selected != null) return selected['url'];
      } catch (e) {
        print('[Fallback] Lỗi từ: $e');
      }
      return null;
    }


  Uri _getLowestVideoUrl() {
    final videoStream = _manifest.hls
        .where((s) => s.container.name == 'mp4')
        .reduce((a, b) =>
    (a.size.totalBytes) < (b.size.totalBytes) ? a : b);
    return videoStream.url;
  }


  Uri _getLowestAudioUrl() {
    final audioStream = _manifest.audioOnly
        .where((s) => s.container.name == 'mp4')
        .reduce((a, b) =>
    (a.size.totalBytes) < (b.size.totalBytes) ? a : b);
    return audioStream.url;
  }


  Future<void> _initVideoPlayer(Uri url) async {
    videoController?.dispose();
    videoController = VideoPlayerController.networkUrl(url);
    await videoController!.initialize();
    isVideoReady.value = true;
  }

  Future<void> _initAudioPlayer(Uri url) async {
    await audioPlayer.setUrl(url.toString());
  }

  /// Đồng bộ tua video và audio
  Future<void> seekTo(Duration position) async {
    if (videoController == null) return;
    await videoController!.seekTo(position);
    await audioPlayer.seek(position);
  }

  /// Đồng bộ trạng thái vị trí audio khi video thay đổi
  void _syncPosition() {
    if (videoController == null) return;
    final videoPos = videoController!.value.position;
    final audioPos = audioPlayer.position;

    // Nếu lệch quá 500ms thì đồng bộ audio theo video
    if ((videoPos - audioPos).inMilliseconds.abs() > 500) {
      audioPlayer.seek(videoPos);
    }
  }

  void togglePlayPause() {
    if (isVideoMode.value) {
      if (videoController?.value.isPlaying ?? false) {
        videoController?.pause();
        audioPlayer.pause();
        isPlaying.value = false;
      } else {
        videoController?.play();
        audioPlayer.play();
        isPlaying.value = true;
      }
    } else {
      // Chế độ audio only
      if (audioPlayer.playing) {
        audioPlayer.pause();
        isPlaying.value = false;
      } else {
        audioPlayer.play();
        isPlaying.value = true;
      }
    }
  }

  void toggleMode() {
    isVideoMode.value = !isVideoMode.value;

    if (isVideoMode.value) {
      // Chuyển sang xem video: phát cả video và audio
      videoController?.play();
      audioPlayer.play();
    } else {
      // Chuyển sang nghe audio: dừng video, chỉ chạy audio
      videoController?.pause();
      audioPlayer.play();
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
