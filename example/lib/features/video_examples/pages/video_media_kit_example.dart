import 'dart:async';

import 'package:example/shared/widgets/video_progress_alert.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';

import '/core/constants/example_constants.dart';
import '../mixins/video_editor_mixin.dart';
import '../widgets/video_initializing_widget.dart';

/// A widget that demonstrates video editing using MediaKit and ProImageEditor.
class VideoMediaKitExample extends StatefulWidget {
  /// Creates a [VideoMediaKitExample] widget.
  const VideoMediaKitExample({super.key});

  @override
  State<VideoMediaKitExample> createState() => _VideoMediaKitExampleState();
}

class _VideoMediaKitExampleState extends State<VideoMediaKitExample>
    with VideoEditorMixin {
  /// IMPORTANT: Ensure that you have called `MediaKit.ensureInitialized();`
  /// in the main method.

  final _player = Player();
  late final _controller = VideoController(_player);

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _initializePlayer() async {
    generateThumbnails();
    video = EditorVideo.asset(kVideoEditorExampleAssetPath);

    await Future.wait([
      setMetadata(),
      _player.open(
        Media('asset:///$kVideoEditorExampleAssetPath'),
        play: videoConfigs.initialPlay,
      ),
      _player.setPlaylistMode(PlaylistMode.none),
      _player.setVolume(videoConfigs.initialMuted ? 0 : 100),
    ]);

    /// Listen to play time
    _player.stream.position.listen((position) {
      if (!mounted || proVideoController == null) return;
      proVideoController!.setPlayTime(position);

      if (isSeeking) return;

      if (durationSpan != null &&
          position.inSeconds >= durationSpan!.end.inSeconds) {
        _seekToPosition(durationSpan!);
      } else if (position.inSeconds >= videoMetadata.duration.inSeconds) {
        _seekToPosition(
          TrimDurationSpan(
            start: Duration.zero,
            end: videoMetadata.duration,
          ),
        );
      }
    });

    /// Listen video end
    _player.stream.completed.listen((isEnded) {
      if (!mounted || !isEnded || isSeeking || durationSpan == null) {
        return;
      }

      _seekToPosition(durationSpan!);
    });

    proVideoController = ProVideoController(
      videoPlayer: _buildVideoPlayer(),
      initialResolution: videoMetadata.resolution,
      videoDuration: videoMetadata.duration,
      fileSize: videoMetadata.fileSize,
      bitrate: videoMetadata.bitrate,
      thumbnails: thumbnails,
    );

    setState(() {});
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

    await _player.pause();
    await _player.seek(span.start);

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
                  onPause: _player.pause,
                  onPlay: _player.play,
                  onMuteToggle: (isMuted) {
                    _player.setVolume(isMuted ? 0 : 100);
                  },
                  onTrimSpanUpdate: (durationSpan) {
                    if (_player.state.playing) {
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
                videoEditor: videoConfigs,
              ),
            ),
    );
  }

  Widget _buildVideoPlayer() {
    return Video(
      key: const ValueKey('Video-Player'),
      controller: _controller,
      controls: null,
    );
  }
}
