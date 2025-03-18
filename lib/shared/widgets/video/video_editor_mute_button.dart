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
              ? player.widgets.muteButton!(player.videoManager.setMuteState)
              : Container(
                  decoration: ShapeDecoration(
                    shape: const CircleBorder(),
                    color: player.style.muteButtonBackground,
                  ),
                  child: IconButton(
                    onPressed: () {
                      player.videoManager.setMuteState(!isMuted);
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
