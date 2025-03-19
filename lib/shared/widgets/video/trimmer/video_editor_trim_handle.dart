import 'package:flutter/widgets.dart';

import '../video_editor_configurable.dart';

class VideoEditorTrimHandle extends StatelessWidget {
  const VideoEditorTrimHandle({super.key, required this.isLeft});

  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    var player = VideoEditorConfigurable.of(context);

    return SizedBox(
      width: player.style.trimBarHandlerWidth,
      child: Align(
        alignment: isLeft ? Alignment.centerLeft : Alignment.centerRight,
        child: MouseRegion(
          cursor: SystemMouseCursors.resizeLeftRight,
          child: Container(
            width: player.style.trimBarHandlerWidth,
            height: player.style.trimBarHeight,
            decoration: BoxDecoration(
              color: player.style.trimBarBackground,
              borderRadius: BorderRadius.horizontal(
                left: isLeft
                    ? Radius.circular(player.style.trimBarHandlerRadius)
                    : Radius.zero,
                right: isLeft
                    ? Radius.zero
                    : Radius.circular(player.style.trimBarHandlerRadius),
              ),
            ),
            child: Center(
              child: Icon(
                isLeft ? player.icons.trimLeft : player.icons.trimRight,
                color: player.style.trimBarColor,
                size: player.style.trimBarHandlerIconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
