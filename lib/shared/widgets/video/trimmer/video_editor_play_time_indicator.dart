import 'package:flutter/material.dart';

import '../video_editor_configurable.dart';

class VideoEditorPlayTimeIndicator extends StatelessWidget {
  const VideoEditorPlayTimeIndicator({super.key, required this.areaWidth});

  final double areaWidth;

  @override
  Widget build(BuildContext context) {
    var player = VideoEditorConfigurable.of(context);

    double handlerWidth = player.configs.style.trimBarHandlerWidth;
    double barWidth = areaWidth - 2 * handlerWidth;

    return ValueListenableBuilder(
        valueListenable: player.controller.trimDurationSpanNotifier,
        builder: (_, durationSpan, __) {
          Duration startDuration = durationSpan.start;
          int areaDuration = durationSpan.duration.inMicroseconds;

          return ValueListenableBuilder(
              valueListenable: player.controller.playTimeNotifier,
              builder: (_, playTime, __) {
                int convertedPlay = (playTime - startDuration).inMicroseconds;

                double startX = barWidth / areaDuration * convertedPlay;

                return Positioned(
                  left: handlerWidth + startX,
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
