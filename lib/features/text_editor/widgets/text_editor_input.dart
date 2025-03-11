import 'package:flutter/material.dart';

import '/core/models/editor_callbacks/text_editor_callbacks.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/layers/layer.dart';
import '/plugins/rounded_background_text/src/rounded_background_text_field.dart';

/// A widget for managing the text input in the text editor, providing a
/// customizable input area with styling and configuration options.
class TextEditorInput extends StatelessWidget {
  /// Creates a `TextEditorInput` widget with the required configurations,
  /// callbacks, and styling for text input management.
  ///
  /// - [callbacks]: Optional callbacks for text editor interactions.
  /// - [configs]: Configuration settings for the text editor.
  /// - [i18n]: Localization strings for tooltips and labels.
  /// - [heroTag]: Optional tag for hero animations during transitions.
  /// - [selectedTextStyle]: The text style applied to the input text.
  /// - [align]: The alignment of the text in the input field.
  /// - [textFontSize]: The font size of the input text.
  /// - [textColor]: The color of the input text.
  /// - [backgroundColor]: The background color of the text input field.
  /// - [layer]: The text layer being edited, if applicable.
  /// - [focusNode]: The focus node for managing input focus.
  /// - [textCtrl]: The text editing controller for managing input content.
  const TextEditorInput({
    super.key,
    required this.callbacks,
    required this.configs,
    required this.heroTag,
    required this.focusNode,
    required this.i18n,
    required this.selectedTextStyle,
    required this.align,
    required this.textFontSize,
    required this.scaleFactor,
    required this.textColor,
    required this.backgroundColor,
    required this.layer,
    required this.textCtrl,
  });

  /// Optional callbacks for text editor interactions.
  final TextEditorCallbacks? callbacks;

  /// Configuration settings for the text editor.
  final TextEditorConfigs configs;

  /// Localization strings for tooltips and labels.
  final I18nTextEditor i18n;

  /// Optional tag for hero animations during transitions.
  final String? heroTag;

  /// The text style applied to the input text.
  final TextStyle selectedTextStyle;

  /// The alignment of the text in the input field.
  final TextAlign align;

  /// The font size of the input text.
  final double textFontSize;

  /// The scale factor to transform the textfield
  final double scaleFactor;

  /// The color of the input text.
  final Color textColor;

  /// The background color of the text input field.
  final Color backgroundColor;

  /// The text layer being edited, if applicable.
  final TextLayer? layer;

  /// The focus node for managing input focus.
  final FocusNode focusNode;

  /// The text editing controller for managing input content.
  final TextEditingController textCtrl;

  Widget _flightShuttleBuilder(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    if (flightDirection == HeroFlightDirection.pop) {
      return fromHeroContext.widget;
    }

    void animationStatusListener(AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          focusNode.requestFocus();
        });
        animation.removeStatusListener(animationStatusListener);
      }
    }

    animation.addStatusListener(animationStatusListener);

    return toHeroContext.widget;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      ///  TODO: remove `IntrinsicWidth` after improve
      /// `RoundedBackgroundTextField` code
      child: IntrinsicWidth(
        child: Padding(
          padding: configs.style.textFieldMargin,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Hero(
                flightShuttleBuilder: _flightShuttleBuilder,
                tag: heroTag ?? 'Text-Image-Editor-Empty-Hero',
                createRectTween: (begin, end) =>
                    RectTween(begin: begin, end: end),
                child: _buildInputField(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Transform.scale(
      scale: scaleFactor,
      child: RoundedBackgroundTextField(
        key: const ValueKey('rounded-background-text-editor-field'),
        controller: textCtrl,
        focusNode: focusNode,
        onChanged: callbacks?.handleChanged,
        onEditingComplete: callbacks?.handleEditingComplete,
        onSubmitted: callbacks?.handleSubmitted,
        autocorrect: configs.enableAutocorrect,
        enableSuggestions: configs.enableSuggestions,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        textCapitalization: TextCapitalization.sentences,
        textAlign: textCtrl.text.isEmpty ? TextAlign.center : align,
        maxLines: null,
        cursorColor: configs.style.inputCursorColor,
        cursorHeight: textFontSize * 1.2,
        scrollPhysics: const NeverScrollableScrollPhysics(),
        hint: textCtrl.text.isEmpty ? i18n.inputHintText : '',
        hintStyle: selectedTextStyle.copyWith(
          color: configs.style.inputHintColor,
          fontSize: textFontSize,
          height: 1.35,
          shadows: [],
        ),
        backgroundColor: backgroundColor,
        style: selectedTextStyle.copyWith(
          color: textColor,
          fontSize: textFontSize,
          height: 1.35,
          letterSpacing: 0,
          decoration: TextDecoration.none,
          shadows: [],
        ),

        /// If we edit an layer we focus to the textfield after the
        /// hero animation is done
        autofocus: layer == null,
      ),
    );
  }
}
