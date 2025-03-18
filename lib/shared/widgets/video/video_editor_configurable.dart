import 'package:flutter/material.dart';

import '/core/models/editor_callbacks/video_editor_callbacks.dart';
import '/core/models/editor_configs/video_editor_configs.dart';
import '/features/main_editor/services/video_manager.dart';

class VideoEditorConfigurable extends InheritedWidget {
  const VideoEditorConfigurable({
    super.key,
    required super.child,
    required this.videoManager,
  });

  final VideoManager videoManager;

  VideoEditorConfigs get configs => videoManager.configs;
  VideoEditorCallbacks get callbacks => videoManager.callbacks;

  ValueNotifier<bool> get isPlayingNotifier => videoManager.isPlayingNotifier;
  ValueNotifier<bool> get isMutedNotifier => videoManager.isMutedNotifier;

  VideoEditorIcons get icons => videoManager.icons;
  VideoEditorStyle get style => videoManager.style;
  VideoEditorWidgets get widgets => videoManager.widgets;

  static VideoEditorConfigurable of(BuildContext context) {
    final config = maybeOf(context);
    assert(config != null, 'No VideoEditorConfigurable found in context');
    return config!;
  }

  static VideoEditorConfigurable? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<VideoEditorConfigurable>();
  }

  @override
  bool updateShouldNotify(covariant VideoEditorConfigurable oldWidget) {
    return true;
  }
}
