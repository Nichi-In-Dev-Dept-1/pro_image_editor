// ignore_for_file: deprecated_member_use_from_same_package
// TODO: Remove deprecated
import 'package:flutter/material.dart';

import '/core/mixins/converted_configs.dart';
import '/core/mixins/editor_configs_mixin.dart';
import '/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/layers/layer.dart';
import '/shared/widgets/extended/extended_pop_scope.dart';

/// The `StickerEditor` class is responsible for creating a widget that allows
/// users to select stickers
class StickerEditor extends StatefulWidget with SimpleConfigsAccess {
  /// Creates an `StickerEditor` widget.
  const StickerEditor({
    super.key,
    required this.configs,
    this.callbacks = const ProImageEditorCallbacks(),
    required this.scrollController,
  });
  @override
  final ProImageEditorConfigs configs;

  @override
  final ProImageEditorCallbacks callbacks;

  /// Controller for managing scroll actions.
  final ScrollController scrollController;

  @override
  createState() => StickerEditorState();
}

/// The state class for the `StickerEditor` widget.
class StickerEditorState extends State<StickerEditor>
    with ImageEditorConvertedConfigs, SimpleConfigsAccessState {
  /// Closes the editor without applying changes.
  void close() {
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    callbacks.stickerEditorCallbacks?.onInit?.call();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      callbacks.stickerEditorCallbacks?.onAfterViewInit?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    assert(
      stickerEditorConfigs.builder != null ||
          stickerEditorConfigs.buildStickers != null,
      '`builder` is required',
    );

    return ExtendedPopScope(
      child: stickerEditorConfigs.builder?.call(
            setLayer,
            widget.scrollController,
          ) ??
          stickerEditorConfigs.buildStickers!(
            setLayerOld,
            widget.scrollController,
          ),
    );
  }

  /// Close the editor with the selected widget-layer.
  void setLayer(WidgetLayer widgetLayer) {
    Navigator.of(context).pop(widgetLayer);
  }

  /// Sets the current layer with a sticker and closes the navigation.
  ///
  /// [widget] is the widget to be set as the layer.
  @Deprecated('Use [setLayer] instead')
  void setLayerOld(
    Widget widget, {
    WidgetLayerExportConfigs? exportConfigs,
  }) {
    Navigator.of(context).pop(
      WidgetLayer(
        widget: widget,
        exportConfigs: exportConfigs ?? const WidgetLayerExportConfigs(),
      ),
    );
  }
}
