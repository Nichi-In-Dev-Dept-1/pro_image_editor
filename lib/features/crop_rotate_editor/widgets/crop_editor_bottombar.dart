import 'dart:math';

import 'package:flutter/material.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/shared/widgets/flat_icon_text_button.dart';

/// A widget representing the bottom bar for the crop editor, providing
/// options like rotate, flip, aspect ratio, and reset.
class CropEditorBottombar extends StatelessWidget {
  /// Creates a `CropEditorBottombar` with the provided configurations and
  /// callbacks.
  ///
  /// - [bottomBarScrollCtrl]: Controls the scroll behavior of the bottom bar.
  /// - [i18n]: Provides localized strings for tooltips and labels.
  /// - [configs]: Contains configurations for the crop and rotate editor.
  /// - [theme]: Defines the theme to style the bottom bar.
  /// - [onRotate]: Callback invoked when the rotate option is selected.
  /// - [onFlip]: Callback invoked when the flip option is selected.
  /// - [onOpenAspectRatioOptions]: Callback invoked when the aspect ratio
  /// options are opened.
  /// - [onReset]: Callback invoked when the reset option is selected.
  const CropEditorBottombar({
    super.key,
    required this.bottomBarScrollCtrl,
    required this.i18n,
    required this.configs,
    required this.theme,
    required this.onRotate,
    required this.onFlip,
    required this.onOpenAspectRatioOptions,
    required this.onReset,
  });

  /// Controls the scroll behavior of the bottom bar.
  final ScrollController bottomBarScrollCtrl;

  /// Provides localized strings for tooltips and labels.
  final I18nCropRotateEditor i18n;

  /// Configurations for the crop and rotate editor.
  final CropRotateEditorConfigs configs;

  /// Theme data for styling the bottom bar.
  final ThemeData theme;

  /// Callback for the rotate option.
  final Function() onRotate;

  /// Callback for the flip option.
  final Function() onFlip;

  /// Callback for opening the aspect ratio options.
  final Function() onOpenAspectRatioOptions;

  /// Callback for resetting the editor.
  final Function() onReset;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme,
      child: Scrollbar(
        controller: bottomBarScrollCtrl,
        scrollbarOrientation: ScrollbarOrientation.top,
        thickness: isDesktop ? null : 0,
        child: BottomAppBar(
          height: kToolbarHeight,
          color: configs.style.bottomBarBackground,
          padding: EdgeInsets.zero,
          child: Center(
            child: SingleChildScrollView(
              controller: bottomBarScrollCtrl,
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: min(MediaQuery.sizeOf(context).width, 500),
                  maxWidth: 500,
                ),
                child: Builder(builder: (context) {
                  Color foregroundColor = configs.style.appBarColor;
                  return Wrap(
                    direction: Axis.horizontal,
                    alignment: WrapAlignment.spaceAround,
                    children: <Widget>[
                      if (configs.showRotateButton)
                        FlatIconTextButton(
                          key: const ValueKey('crop-rotate-editor-rotate-btn'),
                          label: Text(
                            i18n.rotate,
                            style: TextStyle(
                                fontSize: 10.0, color: foregroundColor),
                          ),
                          icon: Icon(configs.icons.rotate,
                              color: foregroundColor),
                          onPressed: onRotate,
                        ),
                      if (configs.showFlipButton)
                        FlatIconTextButton(
                          key: const ValueKey('crop-rotate-editor-flip-btn'),
                          label: Text(
                            i18n.flip,
                            style: TextStyle(
                                fontSize: 10.0, color: foregroundColor),
                          ),
                          icon:
                              Icon(configs.icons.flip, color: foregroundColor),
                          onPressed: onFlip,
                        ),
                      if (configs.showAspectRatioButton)
                        FlatIconTextButton(
                          key: const ValueKey('crop-rotate-editor-ratio-btn'),
                          label: Text(
                            i18n.ratio,
                            style: TextStyle(
                                fontSize: 10.0, color: foregroundColor),
                          ),
                          icon: Icon(configs.icons.aspectRatio,
                              color: foregroundColor),
                          onPressed: onOpenAspectRatioOptions,
                        ),
                      if (configs.showResetButton)
                        FlatIconTextButton(
                          key: const ValueKey('crop-rotate-editor-reset-btn'),
                          label: Text(
                            i18n.reset,
                            style: TextStyle(
                                fontSize: 10.0, color: foregroundColor),
                          ),
                          icon:
                              Icon(configs.icons.reset, color: foregroundColor),
                          onPressed: onReset,
                        ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
