import 'package:flutter/widgets.dart';

class VideoEditorStyle {
  const VideoEditorStyle({
    this.playIndicatorColor = const Color(0xFFFFFFFF),
    this.playIndicatorBackground = const Color.fromARGB(128, 0, 0, 0),
    this.muteButtonColor = const Color(0xFFFFFFFF),
    this.muteButtonBackground = const Color.fromARGB(60, 0, 0, 0),
    this.infoBannerTextStyle,
    this.infoBannerTextColor = const Color(0xFFFFFFFF),
    this.infoBannerBackground = const Color.fromARGB(60, 0, 0, 0),
  });

  final Color playIndicatorColor;
  final Color playIndicatorBackground;

  final Color muteButtonColor;
  final Color muteButtonBackground;

  final TextStyle? infoBannerTextStyle;
  final Color infoBannerTextColor;
  final Color infoBannerBackground;
}
