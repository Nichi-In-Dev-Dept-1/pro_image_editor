import 'package:flutter/material.dart';
import 'package:pro_image_editor/shared/widgets/video/video_editor_mute_button.dart';
import '/shared/widgets/video/video_editor_state_widget.dart';
import 'video_editor_configurable.dart';
import 'video_editor_info_banner.dart';

class VideoEditorControlsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var player = VideoEditorConfigurable.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Stack(
        children: [
          player.widgets.headerToolbar ??
              Column(
                spacing: 10,
                children: [
                  Container(
                    color: Colors.red,
                    width: double.infinity,
                    height: 50,
                  ),
                  const Row(
                    spacing: 12,
                    children: [
                      VideoEditorMuteButton(),
                      VideoEditorInfoBanner(),
                    ],
                  ),
                ],
              ),
          VideoEditorStateWidget(),
        ],
      ),
    );
  }
}
