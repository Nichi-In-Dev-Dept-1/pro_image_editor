import 'package:flutter/material.dart';

import '/core/models/editor_configs/video_editor_configs.dart';
import '/shared/widgets/video/toolbar/video_editor_trim_info_widget.dart';
import '/shared/widgets/video/video_editor_state_widget.dart';
import 'toolbar/video_editor_info_banner.dart';
import 'toolbar/video_editor_mute_button.dart';
import 'trimmer/video_editor_trim_bar.dart';
import 'video_editor_configurable.dart';

/// A widget that manages the video editor's control elements.
///
/// This includes the trim bar, mute button, info banner, and state indicator.
class VideoEditorControlsWidget extends StatelessWidget {
  /// Creates a [VideoEditorControlsWidget] widget.
  const VideoEditorControlsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    var player = VideoEditorConfigurable.of(context);

    bool isAudioSupported = player.configs.isAudioSupported;
    bool alignTop =
        player.configs.controlsPosition == VideoEditorControlPosition.top;

    return Stack(
      children: [
        player.widgets.headerToolbar ??
            Column(
              spacing: 10,
              verticalDirection:
                  alignTop ? VerticalDirection.down : VerticalDirection.up,
              children: [
                const VideoEditorTrimBar(),
                Padding(
                  padding: player.contentPadding,
                  child: LayoutBuilder(
                    builder: (_, constraints) {
                      if (constraints.maxWidth +
                              player.contentPadding.horizontal >=
                          330) {
                        return Row(
                          children: [
                            if (isAudioSupported) ...[
                              const VideoEditorMuteButton(),
                              const SizedBox(width: 12),
                            ],
                            const VideoEditorInfoBanner(),
                            const Spacer(),
                            const VideoEditorTrimInfoWidget()
                          ],
                        );
                      } else {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isAudioSupported) const VideoEditorMuteButton(),
                            const Spacer(),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              spacing: 6,
                              children: [
                                VideoEditorInfoBanner(),
                                VideoEditorTrimInfoWidget()
                              ],
                            )
                          ],
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
        const VideoEditorStateWidget(),
      ],
    );
  }
}
