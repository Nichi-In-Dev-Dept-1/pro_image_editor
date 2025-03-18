import 'package:flutter/material.dart';

class VideoEditorIcons {
  const VideoEditorIcons({
    this.playIndicator = Icons.play_arrow_rounded,
    this.muteActive = Icons.volume_off_rounded,
    this.muteInActive = Icons.volume_up_rounded,
  });

  final IconData playIndicator;
  final IconData muteActive;
  final IconData muteInActive;
}
