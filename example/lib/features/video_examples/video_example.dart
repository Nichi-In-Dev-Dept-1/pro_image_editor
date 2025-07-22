// Flutter imports:

import 'package:example/shared/widgets/paragraph_info_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/core/platform/io/io_helper.dart';

import '/core/mixin/example_helper.dart';
import 'pages/chewie_player_example.dart';
import 'pages/flick_video_player_example.dart';
import 'pages/video_media_kit_example.dart';
import 'pages/video_player_example.dart';

/// The video example widget
class VideoExample extends StatefulWidget {
  /// Creates a new [VideoExample] widget.
  const VideoExample({super.key});

  @override
  State<VideoExample> createState() => _VideoExampleState();
}

class _VideoExampleState extends State<VideoExample>
    with ExampleHelperState<VideoExample> {
  final _isWebEditingSupported = false;

  late final _videoPackages = [
    _Package(
      title: 'Package "video_player"',
      subTitle: 'Recommended for Android and iOS',
      enabled: (kIsWeb && _isWebEditingSupported) ||
          (!kIsWeb &&
              (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)),
      example: const VideoPlayerExample(),
    ),
    _Package(
      title: 'Package "media_kit"',
      enabled: !kIsWeb || _isWebEditingSupported,
      example: const VideoMediaKitExample(),
    ),
    _Package(
      title: 'Package "flick_video_player"',
      enabled: (kIsWeb && _isWebEditingSupported) ||
          (!kIsWeb &&
              (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)),
      example: const FlickVideoPlayerExample(),
    ),
    _Package(
      title: 'Package "chewie"',
      enabled: (kIsWeb && _isWebEditingSupported) ||
          (!kIsWeb &&
              (Platform.isAndroid || Platform.isIOS || Platform.isMacOS)),
      example: const ChewiePlayerExample(),
    ),
  ];

  void _openExample(Widget page) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video-Example'),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: <Widget>[
          const ParagraphInfoWidget(
            margin: EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Text(
              'For a reduced bundle size and fewer dependencies, no video '
              'player package is included. However, the image editor supports '
              'easy integration with an external video player, allowing video '
              'editing to be set up in just a few lines of code. Additional '
              'required native code implementations are provided by my new '
              'package, pro_video_editor.',
            ),
          ),
          if (kIsWeb || Platform.isWindows || Platform.isLinux)
            const ParagraphInfoWidget(
              margin: EdgeInsets.fromLTRB(16, 16, 16, 4),
              color: Colors.red,
              child: Text(
                'Video editing is currently only supported on Android, iOS and '
                'macOS. Support for other platforms will follow soon.',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          if (kDebugMode || (!kIsWeb && Platform.isAndroid))
            ..._videoPackages.map((pkg) {
              return ListTile(
                enabled: pkg.enabled,
                leading: const Icon(Icons.movie),
                title: Text(pkg.title),
                subtitle: pkg.enabled
                    ? (pkg.subTitle.isNotEmpty ? Text(pkg.subTitle) : null)
                    : _buildNotSupportedMsg(pkg.subTitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: pkg.enabled ? () => _openExample(pkg.example) : null,
              );
            }),
        ],
      ),
    );
  }

  Widget _buildNotSupportedMsg(String subTitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      spacing: 3,
      children: [
        Text(subTitle),
        const Text('This package is not supported on that platform.'),
      ],
    );
  }
}

class _Package {
  _Package({
    required this.title,
    this.subTitle = '',
    required this.enabled,
    required this.example,
  });
  final String title;
  final String subTitle;
  final bool enabled;
  final Widget example;
}
