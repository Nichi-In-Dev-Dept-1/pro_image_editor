import 'package:example/core/constants/example_constants.dart';
import 'package:example/core/mixin/example_helper.dart';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:pro_image_editor/core/models/editor_callbacks/video_editor_callbacks.dart';
import 'package:pro_image_editor/core/models/editor_configs/video_editor_configs.dart';
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

  late final _player = Player();
  late final _controller = VideoController(_player);

  final _fileSize = '1.5MB';

  late VideoEditorConfigs _configs = VideoEditorConfigs(
    infoBannerText: '00:00 | $_fileSize',
    initialMuted: false,
    initialPlay: false,
  );

  @override
  void initState() {
    super.initState();
    _player
      ..open(Media(kVideoEditorExampleAssetPath))
      ..setPlaylistMode(PlaylistMode.loop)
      ..pause()
      ..stream.duration.listen((event) {
        if (!mounted) return;

        _configs = _configs.copyWith(
          infoBannerText: '${_formatDuration(event)} | $_fileSize',
        );

        setState(() {});
      });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');

    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));

    return '$hours:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    return ProImageEditor.video(
      Video(
        controller: _controller,
        controls: null,
      ),
      callbacks: ProImageEditorCallbacks(
        onImageEditingComplete: (bytes) async {
          print(bytes.length);
        },
        videoEditorCallbacks: VideoEditorCallbacks(
          onPause: _player.pause,
          onPlay: _player.play,
          onMuteToggle: (isMuted) {
            _player.setVolume(isMuted ? 0 : 100);
          },
        ),
      ),
      configs: ProImageEditorConfigs(
        videoEditor: _configs,
      ),
    );
  }
}
