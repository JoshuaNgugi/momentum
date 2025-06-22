import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class PostCard extends StatefulWidget {
  final String mediaUrl;
  final String mediaType;
  final String userName;
  final String status;

  const PostCard({
    Key? key,
    required this.mediaUrl,
    required this.mediaType,
    required this.userName,
    required this.status,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late VideoPlayerController _videoController;
  Future<void>? _initializeVideoPlayerFuture;
  bool _videoInitializationAttempted = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoMedia();
  }

  // Helper method to initialize video, called when widget mounts or status changes to ready
  void _initializeVideoMedia() {
    if (widget.mediaType == 'video' &&
        widget.status == 'ready' &&
        !_videoInitializationAttempted) {
      _videoInitializationAttempted = true; // Mark as attempted
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.mediaUrl),
      );
      _initializeVideoPlayerFuture = _videoController
          .initialize()
          .then((_) {
            setState(() {
              _videoController.setLooping(true);
              _videoController.setVolume(0.0);
            });
          })
          .catchError((error) {
            print("Error initializing video player: $error");
            setState(() {
              _initializeVideoPlayerFuture = Future.error(error);
            });
          });
    }
  }

  @override
  void didUpdateWidget(covariant PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If a video's status changes from 'processing' to 'ready', initialize it
    if (widget.mediaType == 'video' &&
        oldWidget.status == 'processing' &&
        widget.status == 'ready') {
      _videoInitializationAttempted = false; // Allow re-initialization
      _initializeVideoMedia();
    }
    // Handle cases where mediaUrl changes (unlikely for a post card, but good practice)
    if (widget.mediaType == 'video' && widget.mediaUrl != oldWidget.mediaUrl) {
      _videoController.dispose();
      _videoInitializationAttempted = false;
      _initializeVideoMedia();
    }
  }

  @override
  void dispose() {
    if (widget.mediaType == 'video' && _videoInitializationAttempted) {
      // Only dispose if controller was initialized
      _videoController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              widget.userName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.0,
              ),
            ),
          ),
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(10.0),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: widget.mediaType == 'image'
                  ? Image.network(
                      widget.mediaUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                            child: Icon(Icons.broken_image, size: 50),
                          ),
                    )
                  : widget.status ==
                        'processing' // --- NEW: Check status for video ---
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 10),
                          Text(
                            'Video is processing...',
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            'Please wait a moment.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : FutureBuilder(
                      future: _initializeVideoPlayerFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.done &&
                            !snapshot.hasError) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _videoController.value.isPlaying
                                    ? _videoController.pause()
                                    : _videoController.play();
                              });
                            },
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                VideoPlayer(_videoController),
                                if (!_videoController.value.isPlaying)
                                  Icon(
                                    _videoController.value.isPlaying
                                        ? Icons.pause_circle_filled
                                        : Icons.play_circle_fill,
                                    size: 70.0,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: VideoProgressIndicator(
                                    _videoController,
                                    allowScrubbing: true,
                                    colors: const VideoProgressColors(
                                      playedColor: Colors.blue,
                                      bufferedColor: Colors.lightBlueAccent,
                                      backgroundColor: Colors.white54,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  size: 50,
                                  color: Colors.red,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Error loading video: ${snapshot.error}',
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                      },
                    ),
            ),
          ),
          const SizedBox(height: 8.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              '${widget.mediaType == 'image' ? 'Image' : 'Video'} posted.${widget.status == 'processing' ? ' (Processing)' : ''}',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8.0),
        ],
      ),
    );
  }
}
