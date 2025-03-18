// Flutter imports:
import 'package:flutter/material.dart';

import '/core/mixin/example_helper.dart';
import '/features/video_examples/video_media_kit_example.dart';

/// The video example widget
class VideoExample extends StatefulWidget {
  /// Creates a new [VideoExample] widget.
  const VideoExample({super.key});

  @override
  State<VideoExample> createState() => _VideoExampleState();
}

class _VideoExampleState extends State<VideoExample>
    with ExampleHelperState<VideoExample> {
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
          ListTile(
            leading: const Icon(Icons.movie),
            title: const Text('MediaKit'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const VideoMediaKitExample(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
