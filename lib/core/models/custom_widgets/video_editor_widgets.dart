import 'package:flutter/widgets.dart';

class VideoEditorWidgets {
  const VideoEditorWidgets({
    this.playIndicator,
    this.pauseIndicator,
    this.muteButton,
    this.infoBanner,
    this.headerToolbar,
  });

  final Widget? playIndicator;
  final Widget? pauseIndicator;
  final Widget Function(Function(bool isMuted) setMute)? muteButton;
  final Widget? infoBanner;

  final Widget? headerToolbar;
}
