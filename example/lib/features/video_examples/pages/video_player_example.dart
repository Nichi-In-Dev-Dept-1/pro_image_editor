import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:video_player/video_player.dart';

import '/core/constants/example_constants.dart';
import '/features/video_examples/mixins/thumbnail_generator_mixin.dart';
import '/features/video_examples/widgets/video_initializing_widget.dart';

/// A widget that demonstrates video playback functionality.
///
/// This serves as an example implementation of a video player.
class VideoPlayerExample extends StatefulWidget {
  /// Creates a [VideoPlayerExample] widget.
  const VideoPlayerExample({super.key});

  @override
  State<VideoPlayerExample> createState() => _VideoPlayerExampleState();
}

class _VideoPlayerExampleState extends State<VideoPlayerExample>
    with ThumbnailGeneratorMixin {
  late VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  void _initializePlayer() async {
    _videoController =
        VideoPlayerController.asset(kVideoEditorExampleAssetPath);

    var bytes = await loadAssetImageAsUint8List(kVideoEditorExampleAssetPath);

    await _videoController.initialize();
    await _videoController.setLooping(false);
    await _videoController.setVolume(videoConfigs.initialMuted ? 0 : 100);
    if (videoConfigs.initialPlay) {
      await _videoController.play();
    } else {
      await _videoController.pause();
    }

    Duration duration = _videoController.value.duration;

    if (!mounted) return;
    await generateThumbnails(
      bytes: bytes,
      duration: duration,
      editorWidth: MediaQuery.sizeOf(context).width,
      pixelRatio: MediaQuery.devicePixelRatioOf(context),
    );

    proVideoController = ProVideoController(
      videoPlayer: _buildVideoPlayer(),
      initialResolution: _videoController.value.size,
      videoDuration: duration,
      fileSize: bytes.lengthInBytes,
      thumbnails: thumbnails,
    );

    _videoController.addListener(_onDurationChange);

    setState(() {});
  }

  void _onDurationChange() {
    var duration = _videoController.value.position;
    proVideoController!.setPlayTime(duration);

    if (durationSpan != null && duration > durationSpan!.end) {
      _seekToPosition(durationSpan!);
    }
  }

  Future<void> _seekToPosition(TrimDurationSpan span) async {
    durationSpan = span;

    if (isSeeking) {
      tempDurationSpan = span; // Store the latest seek request
      return;
    }
    isSeeking = true;

    proVideoController!.pause();
    proVideoController!.setPlayTime(durationSpan!.start);

    await _videoController.pause();
    await _videoController.seekTo(span.start);

    isSeeking = false;

    // Check if there's a pending seek request
    if (tempDurationSpan != null) {
      TrimDurationSpan nextSeek = tempDurationSpan!;
      tempDurationSpan = null; // Clear the pending seek
      await _seekToPosition(nextSeek); // Process the latest request
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: proVideoController == null || !_videoController.value.isInitialized
          ? const VideoInitializingWidget()
          : ProImageEditor.video(
              proVideoController!,
              callbacks: ProImageEditorCallbacks(
                videoEditorCallbacks: VideoEditorCallbacks(
                  onPause: _videoController.pause,
                  onPlay: _videoController.play,
                  onMuteToggle: (isMuted) {
                    _videoController.setVolume(isMuted ? 0 : 100);
                  },
                  onTrimSpanUpdate: (durationSpan) {
                    if (_videoController.value.isPlaying) {
                      proVideoController!.pause();
                    }
                  },
                  onTrimSpanEnd: _seekToPosition,
                ),
              ),
              configs: ProImageEditorConfigs(
                mainEditor: MainEditorConfigs(
                  widgets: MainEditorWidgets(
                    removeLayerArea: (removeAreaKey, editor, rebuildStream) =>
                        VideoEditorRemoveArea(
                      removeAreaKey: removeAreaKey,
                      editor: editor,
                      rebuildStream: rebuildStream,
                    ),
                  ),
                ),
                videoEditor: videoConfigs.copyWith(
                  playTimeSmoothingDuration: const Duration(milliseconds: 600),
                ),
              ),
            ),
    );
  }

  Widget _buildVideoPlayer() {
    return AspectRatio(
      aspectRatio: _videoController.value.size.aspectRatio,
      child: VideoPlayer(
        _videoController,
      ),
    );
  }
}
