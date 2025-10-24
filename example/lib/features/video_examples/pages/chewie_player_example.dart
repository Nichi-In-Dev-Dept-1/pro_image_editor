import 'package:chewie/chewie.dart';
import 'package:example/shared/widgets/video_progress_alert.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';
import 'package:video_player/video_player.dart';

import '/core/constants/example_constants.dart';
import '../mixins/video_editor_mixin.dart';
import '../widgets/video_initializing_widget.dart';

/// A widget that demonstrates video playback using the Chewie player.
///
/// This serves as an example implementation of a video player with Chewie.
class ChewiePlayerExample extends StatefulWidget {
  /// Creates a [ChewiePlayerExample] widget.
  const ChewiePlayerExample({super.key});

  @override
  State<ChewiePlayerExample> createState() => _ChewiePlayerExampleState();
}

class _ChewiePlayerExampleState extends State<ChewiePlayerExample>
    with VideoEditorMixin {
  late ChewieController _chewieController;
  late VideoPlayerController _videoPlayerController;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _chewieController.dispose();
    _videoPlayerController.dispose();
    super.dispose();
  }

  void _initializePlayer() async {
    generateThumbnails();
    video = EditorVideo.asset(kVideoEditorExampleAssetPath);

    if (!mounted) return;

    _videoPlayerController =
        VideoPlayerController.asset(kVideoEditorExampleAssetPath);

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: videoConfigs.initialPlay,
      looping: false,
      showControls: false,
      showOptions: false,
      showControlsOnInitialize: false,
      showSubtitles: false,
    );
    await Future.wait([
      setMetadata(),
      _videoPlayerController.initialize(),
      _chewieController.setVolume(videoConfigs.initialMuted ? 0 : 100),
    ]);

    proVideoController = ProVideoController(
      videoPlayer: _buildVideoPlayer(),
      initialResolution: videoMetadata.resolution,
      videoDuration: videoMetadata.duration,
      fileSize: videoMetadata.fileSize,
      bitrate: videoMetadata.bitrate,
      thumbnails: thumbnails,
    );

    _chewieController.videoPlayerController.addListener(_onDurationChange);

    setState(() {});
  }

  void _onDurationChange() {
    var totalVideoDuration = videoMetadata.duration;
    var duration = _chewieController.videoPlayerController.value.position;
    proVideoController!.setPlayTime(duration);
    if (durationSpan != null && duration > durationSpan!.end) {
      _seekToPosition(durationSpan!);
    } else if (duration >= totalVideoDuration) {
      _seekToPosition(
        TrimDurationSpan(start: Duration.zero, end: totalVideoDuration),
      );
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

    await _chewieController.videoPlayerController.pause();
    await _chewieController.videoPlayerController.seekTo(span.start);

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
      child: proVideoController == null
          ? const VideoInitializingWidget()
          : ProImageEditor.video(
              proVideoController!,
              callbacks: ProImageEditorCallbacks(
                onCompleteWithParameters: generateVideo,
                onCloseEditor: onCloseEditor,
                videoEditorCallbacks: VideoEditorCallbacks(
                  onPause: _chewieController.pause,
                  onPlay: _chewieController.play,
                  onMuteToggle: (isMuted) {
                    _chewieController.setVolume(isMuted ? 0 : 100);
                  },
                  onTrimSpanUpdate: (durationSpan) {
                    if (_chewieController.isPlaying) {
                      proVideoController!.pause();
                    }
                  },
                  onTrimSpanEnd: _seekToPosition,
                ),
              ),
              configs: ProImageEditorConfigs(
                dialogConfigs: DialogConfigs(
                  widgets: DialogWidgets(
                    loadingDialog: (message, configs) =>
                        VideoProgressAlert(taskId: taskId),
                  ),
                ),
                mainEditor: MainEditorConfigs(
                  widgets: MainEditorWidgets(
                    removeLayerArea: (
                      removeAreaKey,
                      editor,
                      rebuildStream,
                      isLayerBeingTransformed,
                    ) =>
                        VideoEditorRemoveArea(
                      removeAreaKey: removeAreaKey,
                      editor: editor,
                      rebuildStream: rebuildStream,
                      isLayerBeingTransformed: isLayerBeingTransformed,
                    ),
                  ),
                ),
                paintEditor: const PaintEditorConfigs(
                  tools: [
                    PaintMode.freeStyle,
                    PaintMode.arrow,
                    PaintMode.line,
                    PaintMode.rect,
                    PaintMode.circle,
                    PaintMode.dashLine,
                    PaintMode.dashDotLine,
                    PaintMode.polygon,
                    // Blur and pixelate are not supported.
                    // PaintMode.pixelate,
                    // PaintMode.blur,
                    PaintMode.eraser,
                  ],
                ),
                videoEditor: videoConfigs.copyWith(
                  playTimeSmoothingDuration: const Duration(milliseconds: 600),
                ),
              ),
            ),
    );
  }

  Widget _buildVideoPlayer() {
    return Chewie(
      key: const ValueKey('video-player'),
      controller: _chewieController,
    );
  }
}
