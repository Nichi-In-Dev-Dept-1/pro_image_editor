import 'package:flutter/widgets.dart';

import '/core/models/editor_callbacks/video_editor_callbacks.dart';
import '/core/models/editor_configs/video_editor_configs.dart';

class VideoManager {
  VideoManager({
    required this.callbacksFunction,
    required this.configsFunction,
  });

  final VideoEditorCallbacks? Function() callbacksFunction;
  final VideoEditorConfigs? Function() configsFunction;

  VideoEditorCallbacks get callbacks =>
      callbacksFunction() ?? VideoEditorCallbacks();
  VideoEditorConfigs get configs =>
      configsFunction() ?? const VideoEditorConfigs();

  late final VideoEditorIcons icons = configs.icons;
  late final VideoEditorStyle style = configs.style;
  late final VideoEditorWidgets widgets = configs.widgets;

  late final isPlayingNotifier = ValueNotifier<bool>(configs.initialPlay);
  late final isMutedNotifier = ValueNotifier<bool>(configs.initialMuted);

  void onPlayerTap() {
    isPlayingNotifier.value = !isPlayingNotifier.value;

    if (isPlayingNotifier.value) {
      callbacks.onPlay?.call();
    } else {
      callbacks.onPause?.call();
    }
  }

  void setMuteState(bool isMuted) {
    isMutedNotifier.value = isMuted;

    callbacks.onMuteToggle?.call(isMuted);
  }
}
