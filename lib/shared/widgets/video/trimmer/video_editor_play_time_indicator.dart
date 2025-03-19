import 'package:flutter/material.dart';

import '../video_editor_configurable.dart';

class VideoEditorPlayTimeIndicator extends StatelessWidget {
  const VideoEditorPlayTimeIndicator({super.key, required this.trimBarWidth});

  final double trimBarWidth;

  @override
  Widget build(BuildContext context) {
    var player = VideoEditorConfigurable.of(context);

    int videoDuration = player.controller.videoDuration.inMicroseconds;
    double barWidth = trimBarWidth;

    return ValueListenableBuilder(
        valueListenable: player.controller.trimDurationSpanNotifier,
        builder: (_, durationSpan, __) {
          double minX =
              barWidth / videoDuration * durationSpan.start.inMicroseconds;

          double maxX =
              barWidth / videoDuration * durationSpan.end.inMicroseconds - 1;

          return ValueListenableBuilder(
              valueListenable: player.controller.playTimeNotifier,
              builder: (_, playTime, __) {
                double startX =
                    barWidth / videoDuration * playTime.inMicroseconds;

                return Positioned(
                  left: startX.clamp(minX, maxX.floorToDouble()),
                  top: player.style.trimBarBorderWidth,
                  bottom: player.style.trimBarBorderWidth,
                  width: player.style.trimBarPlayTimeIndicatorWidth,
                  child: Container(
                    color: player.style.trimBarPlayTimeIndicatorColor,
                  ),
                );
              });
        });
  }
}
