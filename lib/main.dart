import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:just_audio/just_audio.dart';
import 'package:http/http.dart' as http;

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
    text: 'https://www.youtube.com/watch?v=l8ToeCYczFs',
  );

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = false;
  String? _errorMessage;
  StreamManifest? _currentManifest;

  @override
  void dispose() {
    _yt.close();
    _audioPlayer.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  Future<(Uri?, Uri?)> _getBestStreams(VideoId videoId) async {
    try {
      _currentManifest = await _yt.videos.streamsClient.getManifest(videoId);
      _logStreamInfo();

      // Ưu tiên MP4 streams
      final videoStream = _currentManifest!.videoOnly
          .where((s) => s.container.name == 'mp4')
          .withHighestBitrate();

      final audioStream = _currentManifest!.audioOnly
          .where((s) => s.container.name == 'mp4')
          .withHighestBitrate();

      return (videoStream.url, audioStream.url);
    } catch (e) {
      log('Stream error: $e', name: 'YouTubeStream');
      rethrow;
    }
  }

  void _logStreamInfo() {
    log('''
    Available Streams:
    Video Only: ${_currentManifest!.videoOnly.length}
    Audio Only: ${_currentManifest!.audioOnly.length}
    Muxed: ${_currentManifest!.muxed.length}
    ''', name: 'YouTubeStream');
  }

  Future<void> _initVideoPlayer(Uri videoUrl) async {
    try {
      _videoController?.dispose();
      _videoController = VideoPlayerController.network(
        videoUrl.toString(),
        httpHeaders: _getHttpHeaders(),
      );

      await _videoController!.initialize();
      if (!mounted) return;

      _chewieController?.dispose();
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: false,
        looping: false,
        allowMuting: true,
        errorBuilder: (context, error) => Center(
          child: Text('Video Error: ${error.toString()}'),
        ),
      );
    } on PlatformException catch (e) {
      log('Video init error: ${e.message}', name: 'Player');
      throw Exception('Video initialization failed: ${e.message}');
    }
  }

  Future<void> _initAudioPlayer(Uri audioUrl) async {
    try {
      await _audioPlayer.setAudioSource(
        AudioSource.uri(  // Thay đổi từ ProgressiveAudioSource sang AudioSource.uri
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

      await Future.wait([
        _initVideoPlayer(videoUrl!),
        _initAudioPlayer(audioUrl!),
      ]);

      if (!mounted) return;
      setState(() {});
    } on VideoUnplayableException catch (e) {
      setState(() => _errorMessage = 'Video cannot be played: ${e.message}');
    } catch (e) {
      setState(() => _errorMessage = 'Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            _buildAudioControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioControls() {
    return StreamBuilder<PlayerState>(
      stream: _audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final state = snapshot.data;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: () => _audioPlayer.setVolume(1.0),
            ),
            IconButton(
              icon: Icon(state?.playing == true ? Icons.pause : Icons.play_arrow),
              onPressed: () => state?.playing == true
                  ? _audioPlayer.pause()
                  : _audioPlayer.play(),
            ),
            IconButton(
              icon: const Icon(Icons.volume_off),
              onPressed: () => _audioPlayer.setVolume(0.0),
            ),
          ],
        );
      },
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
                Text('Video: ${_currentManifest!.videoOnly.length}'),
                Text('Audio: ${_currentManifest!.audioOnly.length}'),
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