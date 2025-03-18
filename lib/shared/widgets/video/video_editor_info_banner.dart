import 'package:flutter/material.dart';
import '/shared/widgets/video/video_editor_configurable.dart';

class VideoEditorInfoBanner extends StatelessWidget {
  const VideoEditorInfoBanner({super.key});

  @override
  Widget build(BuildContext context) {
    var player = VideoEditorConfigurable.of(context);

    return player.widgets.infoBanner ??
        (player.configs.infoBannerText != null
            ? IgnorePointer(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: player.style.infoBannerBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    player.configs.infoBannerText!,
                    style: player.style.infoBannerTextStyle ??
                        TextStyle(
                          fontSize: 14,
                          color: player.style.infoBannerTextColor,
                        ),
                  ),
                ),
              )
            : const SizedBox.shrink());
  }
}
