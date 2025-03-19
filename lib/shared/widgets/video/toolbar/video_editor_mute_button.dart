import 'package:flutter/material.dart';
import '/shared/widgets/video/video_editor_configurable.dart';

class VideoEditorMuteButton extends StatelessWidget {
  const VideoEditorMuteButton();

  @override
  Widget build(BuildContext context) {
    var player = VideoEditorConfigurable.of(context);
    return ValueListenableBuilder(
        valueListenable: player.isMutedNotifier,
        builder: (_, isMuted, __) {
          return player.widgets.muteButton?.call != null
              ? player.widgets.muteButton!(player.controller.setMuteState)
              : IconButtonTheme(
                  data: IconButtonThemeData(
                    style: IconButton.styleFrom(
                      backgroundColor: player.style.muteButtonBackground,
                    ),
                  ),
                  child: IconButton.filled(
                    onPressed: () {
                      player.controller.setMuteState(!isMuted);
                    },
                    color: player.style.muteButtonColor,
                    icon: Icon(isMuted
                        ? player.icons.muteActive
                        : player.icons.muteInActive),
                  ),
                );
        });
  }
}
