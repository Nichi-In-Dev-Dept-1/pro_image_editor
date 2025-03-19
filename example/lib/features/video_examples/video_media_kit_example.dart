import 'dart:async';

import 'package:example/core/constants/example_constants.dart';
import 'package:example/core/mixin/example_helper.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

class VideoMediaKitExample extends StatefulWidget {
  const VideoMediaKitExample({super.key});

  @override
  State<VideoMediaKitExample> createState() => _VideoMediaKitExampleState();
}

class _VideoMediaKitExampleState extends State<VideoMediaKitExample>
    with ExampleHelperState<VideoMediaKitExample> {
  /// Ensure that you have called `MediaKit.ensureInitialized();` in the
  /// main method.

  bool _isSeeking = false;
  TrimDurationSpan? _durationSpan;
  TrimDurationSpan? _tempDurationSpan;

  late final _player = Player();
  late final _controller = VideoController(_player);

  final VideoEditorConfigs _configs = const VideoEditorConfigs(
    initialMuted: true,
    initialPlay: false,
    minTrimDuration: Duration(seconds: 7),
  );
  ProVideoController? _proVideoController;

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
    var bytes = await loadAssetImageAsUint8List(kVideoEditorExampleAssetPath);

    await _player.open(
      await Media.memory(bytes),
      play: _configs.initialPlay,
    );
    await _player.setPlaylistMode(PlaylistMode.none);
    await _player.setVolume(_configs.initialMuted ? 0 : 100);

    Completer<void> durationCompleter = Completer();
    Completer<void> resolutionCompleter = Completer();
    Size initialSize = Size.zero;
    Duration videoDuration = Duration.zero;

    /// Read duration
    _player.stream.duration.listen((event) {
      if (!mounted) return;

      videoDuration = event;

      if (!durationCompleter.isCompleted) {
        durationCompleter.complete();
      }
      setState(() {});
    });

    /// Read resolution
    _player.stream.width.listen((event) {
      if (!mounted) return;

      initialSize = Size(
        _player.state.width?.toDouble() ?? 0,
        _player.state.height?.toDouble() ?? 0,
      );

      if (!resolutionCompleter.isCompleted) {
        resolutionCompleter.complete();
      }
      setState(() {});
    });

    /// Listen to play time
    _player.stream.position.listen((position) {
      if (!mounted) return;
      _proVideoController!.setPlayTime(position);

      if (_isSeeking ||
          _durationSpan == null ||
          position < _durationSpan!.end) {
        return;
      }

      _seekToPosition(_durationSpan!);
    });

    /// Listen video end
    _player.stream.completed.listen((isEnded) {
      if (!mounted || !isEnded || _isSeeking || _durationSpan == null) {
        return;
      }

      _seekToPosition(_durationSpan!);
    });

    await durationCompleter.future;
    await resolutionCompleter.future;

    _proVideoController = ProVideoController(
      videoPlayer: _buildVideoPlayer(),
      initialResolution: initialSize,
      videoDuration: videoDuration,
      fileSize: bytes.lengthInBytes,
    );
  }

  Future<void> _seekToPosition(TrimDurationSpan span) async {
    _durationSpan = span;

    if (_isSeeking) {
      _tempDurationSpan = span; // Store the latest seek request
      return;
    }
    _isSeeking = true;

    _proVideoController!.pause();
    _proVideoController!.setPlayTime(_durationSpan!.start);

    await _player.pause();
    await _player.seek(span.start);

    _isSeeking = false;

    // Check if there's a pending seek request
    if (_tempDurationSpan != null) {
      TrimDurationSpan nextSeek = _tempDurationSpan!;
      _tempDurationSpan = null; // Clear the pending seek
      await _seekToPosition(nextSeek); // Process the latest request
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: _proVideoController == null
          ? _buildProcessing()
          : ProImageEditor.video(
              _proVideoController!,
              callbacks: ProImageEditorCallbacks(
                videoEditorCallbacks: VideoEditorCallbacks(
                  onPause: _player.pause,
                  onPlay: _player.play,
                  onMuteToggle: (isMuted) {
                    _player.setVolume(isMuted ? 0 : 100);
                  },
                  onTrimSpanUpdate: (durationSpan) {
                    if (_player.state.playing) {
                      _proVideoController!.pause();
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
                videoEditor: _configs,
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

  Widget _buildProcessing() {
    return Scaffold(
      body: Stack(
        children: [
          Offstage(child: _buildVideoPlayer()),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blueGrey.shade900,
                  Colors.black87,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                spacing: 30,
                children: [
                  Icon(
                    Icons.video_camera_back_rounded,
                    size: 80,
                    color: Colors.white70,
                  ),
                  Text(
                    'Initializing Video-Editor...',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: CircularProgressIndicator(
                      color: Colors.white70,
                      strokeWidth: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
