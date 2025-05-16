import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:just_audio/just_audio.dart';

void main() => runApp(const YouTubeMediaApp());

class YouTubeMediaApp extends StatelessWidget {
  const YouTubeMediaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YouTube Media Player',
      theme: ThemeData.dark(),
      home: const MediaPlayerScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MediaPlayerScreen extends StatefulWidget {
  const MediaPlayerScreen({super.key});

  @override
  State<MediaPlayerScreen> createState() => _MediaPlayerScreenState();
}

class _MediaPlayerScreenState extends State<MediaPlayerScreen> {
  final _yt = YoutubeExplode();
  final _audioPlayer = AudioPlayer();
  final _urlController = TextEditingController(
    text: 'https://www.youtube.com/watch?v=UjxhrD_Rm5M&ab_channel=MILLY',
  );

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  bool _isLoading = false;
  String? _errorMessage;
  StreamManifest? _currentManifest;

  // Đồng bộ trạng thái play/pause
  late StreamSubscription<PlayerState> _audioStateSub;

  @override
  void initState() {
    super.initState();

    // Khi audio thay đổi trạng thái, đồng bộ với video
    _audioStateSub = _audioPlayer.playerStateStream.listen((state) {
      final playing = state.playing;
      if (_videoController == null || !_videoController!.value.isInitialized) {
        return;
      }
      if (playing && !_videoController!.value.isPlaying) {
        _videoController!.play();
      } else if (!playing && _videoController!.value.isPlaying) {
        _videoController!.pause();
      }
    });
  }

  @override
  void dispose() {
    _audioStateSub.cancel();
    _yt.close();
    _audioPlayer.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<(Uri?, Uri?)> _getBestStreams(VideoId videoId) async {
    try {
      _currentManifest = await _yt.videos.streamsClient.getManifest(videoId);

      final manifest = _currentManifest;
      if (manifest == null) {
        log('Manifest is null', name: 'YouTubeStream');
        return (null, null);
      }

      _logStreamInfo();

      final videoStreams = manifest.videoOnly
          .where((s) => s.container.name == 'mp4')
          .toList();
      final audioStreams = manifest.audioOnly
          .where((s) => s.container.name == 'mp4')
          .toList();

      if (videoStreams.isEmpty || audioStreams.isEmpty) {
        log('Video or audio streams empty', name: 'YouTubeStream');
        return (null, null);
      }

      final bestVideo = videoStreams.reduce((a, b) {
        final aSize = a.size.totalBytes ?? 0;
        final bSize = b.size.totalBytes ?? 0;
        return aSize > bSize ? a : b;
      });

      final bestAudio = audioStreams.reduce((a, b) {
        final aSize = a.size.totalBytes ?? 0;
        final bSize = b.size.totalBytes ?? 0;
        return aSize > bSize ? a : b;
      });

      return (bestVideo.url, bestAudio.url);
    } catch (e) {
      log('Stream error: $e', name: 'YouTubeStream');
      return (null, null);
    }
  }

  void _logStreamInfo() {
    if (_currentManifest == null) return;

    log('''
Available Streams:
Video Only: ${_currentManifest!.videoOnly.length}
Audio Only: ${_currentManifest!.audioOnly.length}
Muxed: ${_currentManifest!.muxed.length}
''', name: 'YouTubeStream');
  }

  Future<void> _initVideoPlayer(Uri videoUrl) async {
    try {
      if (_videoController != null) {
        await _videoController!.dispose();
        _videoController = null;
      }
      _videoController = VideoPlayerController.network(
        videoUrl.toString(),
        httpHeaders: _getHttpHeaders(),
      );

      await _videoController!.initialize();
      if (!mounted) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        allowMuting: true,
        errorBuilder: (context, error) => Center(
          child: Text('Video Error: ${error.toString()}'),
        ),
      );
    } catch (e) {
      log('Video init error: $e', name: 'Player');
      rethrow;
    }
  }

  Future<void> _initAudioPlayer(Uri audioUrl) async {
    try {
      await _audioPlayer.setAudioSource(
        AudioSource.uri(
          audioUrl,
          headers: _getHttpHeaders(),
        ),
      );
    } catch (e) {
      log('Audio init error: $e', name: 'Player');
      throw Exception('Audio initialization failed: $e');
    }
  }

  Map<String, String> _getHttpHeaders() {
    return {
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
      'Referer': 'https://www.youtube.com/',
      'Origin': 'https://www.youtube.com',
    };
  }

  Future<void> _loadMedia() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final videoId = VideoId(_urlController.text.trim());
      final (videoUrl, audioUrl) = await _getBestStreams(videoId);

      if (videoUrl == null || audioUrl == null) {
        setState(() {
          _errorMessage = 'Không tìm thấy stream video hoặc audio phù hợp.';
          _isLoading = false;
        });
        return;
      }

      await Future.wait([
        _initVideoPlayer(videoUrl),
        _initAudioPlayer(audioUrl),
      ]);

      if (!mounted) return;

      setState(() {});
    } catch (e) {
      setState(() => _errorMessage = 'Lỗi: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = _audioPlayer.playing;
    return Scaffold(
      appBar: AppBar(
        title: const Text('YouTube Media Player'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showVideoInfo,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                labelText: 'YouTube URL',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _loadMedia,
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const CircularProgressIndicator()
            else if (_errorMessage != null)
              Text(_errorMessage!, style: TextStyle(color: Colors.red[400])),
            if (_chewieController != null)
              Expanded(
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Chewie(controller: _chewieController!),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                  onPressed: () {
                    if (isPlaying) {
                      _audioPlayer.pause();
                      _videoController?.pause();
                    } else {
                      _audioPlayer.play();
                      _videoController?.play();
                    }
                    setState(() {});
                  },
                ),
                IconButton(
                  icon: Icon(Icons.stop),
                  onPressed: () {
                    _audioPlayer.stop();
                    _videoController?.pause();
                    _videoController?.seekTo(Duration.zero);
                    setState(() {});
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: () => _audioPlayer.setVolume(1.0),
                ),
                IconButton(
                  icon: const Icon(Icons.volume_off),
                  onPressed: () => _audioPlayer.setVolume(0.0),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Future<void> _showVideoInfo() async {
    if (_urlController.text.isEmpty || _currentManifest == null) return;

    try {
      final videoId = VideoId(_urlController.text.trim());
      final video = await _yt.videos.get(videoId);

      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(video.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Channel: ${video.author}'),
                Text('Duration: ${video.duration}'),
                Text('Views: ${video.engagement.viewCount}'),
                const SizedBox(height: 16),
                const Text('Available Streams:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Video Only: ${_currentManifest!.videoOnly.length}'),
                Text('Audio Only: ${_currentManifest!.audioOnly.length}'),
                Text('Muxed: ${_currentManifest!.muxed.length}'),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get video info: ${e.toString()}')),
      );
    }
  }
}