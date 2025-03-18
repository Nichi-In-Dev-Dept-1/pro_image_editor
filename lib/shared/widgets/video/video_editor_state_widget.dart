import 'package:flutter/material.dart';
import 'video_editor_configurable.dart';

class VideoEditorStateWidget extends StatelessWidget {
  const VideoEditorStateWidget();

  @override
  Widget build(BuildContext context) {
    var player = VideoEditorConfigurable.of(context);

    return Center(
      child: ValueListenableBuilder(
        valueListenable: player.isPlayingNotifier,
        builder: (_, isPlaying, __) {
          return AnimatedSwitcher(
            duration: player.configs.animatedIndicatorDuration,
            switchInCurve: player.configs.animatedIndicatorSwitchInCurve,
            switchOutCurve: player.configs.animatedIndicatorSwitchOutCurve,
            child: isPlaying
                ? player.widgets.pauseIndicator ?? const SizedBox.shrink()
                : player.widgets.playIndicator ??
                    IgnorePointer(
                      child: Container(
                        decoration: ShapeDecoration(
                          shape: const CircleBorder(),
                          color: player.style.playIndicatorBackground,
                        ),
                        width: 64,
                        height: 64,
                        child: Icon(
                          player.icons.playIndicator,
                          color: player.style.playIndicatorColor,
                          size: 44,
                        ),
                      ),
                    ),
          );
        },
      ),
    );
  }
}
