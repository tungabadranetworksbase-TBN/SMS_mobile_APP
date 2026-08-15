import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:video_player/video_player.dart' as vp;
import 'package:chewie/chewie.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/error_states/error_state_view.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String title;
  final String url;

  const VideoPlayerScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  // YouTube State
  YoutubePlayerController? _youtubeController;
  
  // Chewie State
  vp.VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  bool _isYoutube = false;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final videoId = YoutubePlayerController.convertUrlToId(widget.url);

      if (videoId != null) {
        // It's a YouTube video
        _isYoutube = true;
        _youtubeController = YoutubePlayerController.fromVideoId(
          videoId: videoId,
          autoPlay: true,
          params: const YoutubePlayerParams(
            mute: false,
            enableCaption: true,
            showFullscreenButton: true,
          ),
        );
        setState(() => _isLoading = false);
      } else {
        // Assume it's a direct mp4/m3u8 link (e.g. from MinIO)
        _isYoutube = false;
        _videoPlayerController = vp.VideoPlayerController.networkUrl(Uri.parse(widget.url));
        await _videoPlayerController!.initialize();
        
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController!,
          autoPlay: true,
          looping: false,
          allowFullScreen: true,
          aspectRatio: _videoPlayerController!.value.aspectRatio,
          errorBuilder: (context, errorMessage) {
            return Center(
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white),
              ),
            );
          },
        );
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load video. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    _youtubeController?.close();
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_error != null) {
      return ErrorStateView(
        message: _error!,
        onRetry: () {
          setState(() {
            _isLoading = true;
            _error = null;
          });
          _initializePlayer();
        },
      );
    }

    if (_isYoutube && _youtubeController != null) {
      // YoutubePlayer handles fullscreen internally via OverlayPortal, so no
      // scaffold wrapper or SystemChrome juggling is needed.
      return Center(
        child: YoutubePlayer(
          controller: _youtubeController!,
          aspectRatio: 16 / 9,
        ),
      );
    } else if (!_isYoutube && _chewieController != null) {
      return Center(
        child: Chewie(
          controller: _chewieController!,
        ),
      );
    }

    return const Center(child: Text('Unknown Player State', style: TextStyle(color: Colors.white)));
  }
}
