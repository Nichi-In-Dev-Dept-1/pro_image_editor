import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '/core/models/editor_configs/pro_image_editor_configs.dart';
import 'rounded_background_text.dart';

/// A customizable text field widget that displays editable text over a
/// rounded background.
class RoundedBackgroundTextField extends StatefulWidget {
  /// Creates a customizable text field with rounded background support.
  ///
  /// This widget displays editable text with a background and allows
  /// customization of cursor behavior, hint styling, focus management,
  /// and more.
  const RoundedBackgroundTextField({
    super.key,
    required this.controller,
    required this.configs,
    required this.style,
    required this.backgroundColor,
    required this.textAlign,
    required this.focusNode,
    this.cursorWidth = 2.0,
    this.cursorHeight,
    this.cursorRadius,
    this.hint,
    this.hintStyle,
    this.autofocus = false,
    this.showSelectionHandles = false,
    this.onSelectionChanged,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
  });

  /// Controls the text being edited in the text editor.
  final TextEditingController controller;

  /// Manages the focus state of the text editor.
  final FocusNode focusNode;

  /// Configuration settings for customizing text editor behavior and
  /// appearance.
  final TextEditorConfigs configs;

  /// The text style applied to the editable text.
  final TextStyle style;

  /// How the text should be aligned within the editor.
  final TextAlign textAlign;

  /// Optional placeholder text displayed when the editor is empty.
  final String? hint;

  /// Optional style to apply to the hint text.
  final TextStyle? hintStyle;

  /// {@macro rounded_background_text.background_color}
  final Color backgroundColor;

  /// {@macro flutter.widgets.editableText.autofocus}
  final bool autofocus;

  /// Whether to show selection handles.
  final bool showSelectionHandles;

  /// {@macro flutter.widgets.editableText.cursorWidth}
  final double cursorWidth;

  /// {@macro flutter.widgets.editableText.cursorHeight}
  final double? cursorHeight;

  /// {@macro flutter.widgets.editableText.cursorRadius}
  final Radius? cursorRadius;

  /// {@macro flutter.widgets.editableText.onChanged}
  final ValueChanged<String>? onChanged;

  /// {@macro flutter.widgets.editableText.onEditingComplete}
  final VoidCallback? onEditingComplete;

  /// {@macro flutter.widgets.editableText.onSubmitted}
  final ValueChanged<String>? onSubmitted;

  /// {@macro flutter.widgets.editableText.onSelectionChanged}
  final SelectionChangedCallback? onSelectionChanged;

  @override
  State<RoundedBackgroundTextField> createState() =>
      _RoundedBackgroundTextFieldState();
}

class _RoundedBackgroundTextFieldState
    extends State<RoundedBackgroundTextField> {
  late final _textController = widget.controller;
  final _scrollCtrl = ScrollController();

  final _padding = const EdgeInsets.all(6.0);

  @override
  void initState() {
    super.initState();
    _textController.addListener(_handleTextChange);
    _scrollCtrl.addListener(_handleScrollChange);
  }

  void _handleTextChange() {
    if (mounted) setState(() {});
  }

  void _handleScrollChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _textController.removeListener(_handleTextChange);
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context);

    final fontSize =
        (widget.style.fontSize ?? defaultTextStyle.style.fontSize ?? 16);

    return Stack(
      clipBehavior: Clip.none,
      alignment: switch (widget.textAlign) {
        TextAlign.end => AlignmentDirectional.centerEnd,
        TextAlign.start => AlignmentDirectional.centerStart,
        TextAlign.left => Alignment.centerLeft,
        TextAlign.right => Alignment.centerRight,
        TextAlign.center || _ => Alignment.topCenter,
      },
      children: [
        if (_textController.text.isNotEmpty)
          _buildBackgroundText()
        else if (widget.hint != null)
          _buildHint(fontSize: fontSize),
        _buildEditableText(fontSize: fontSize),
      ],
    );
  }

  Widget _buildBackgroundText() {
    final style = widget.style.copyWith(
      color: Colors.transparent,
      leadingDistribution: TextLeadingDistribution.proportional,
    );

    return Positioned(
      top: _scrollCtrl.hasClients ? -_scrollCtrl.position.pixels : null,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Padding(
          padding: _padding,
          child: RoundedBackgroundText.rich(
            text: _textController.buildTextSpan(
              context: context,
              withComposing: true,
              style: style,
            ),
            cursorWidth: widget.cursorWidth,
            textAlign: widget.textAlign,
            backgroundColor: widget.backgroundColor,
          ),
        ),
      ),
    );
  }

  Widget _buildEditableText({required double fontSize}) {
    final theme = Theme.of(context);
    final selectionTheme = TextSelectionTheme.of(context);
    TextSelectionControls? textSelectionControls;
    final bool paintCursorAboveText;
    final bool cursorOpacityAnimates;
    Offset? cursorOffset;
    final Color selectionColor;
    Color? autocorrectionTextRectColor;
    Radius? cursorRadius = widget.cursorRadius;

    switch (theme.platform) {
      case TargetPlatform.iOS:
        final cupertinoTheme = CupertinoTheme.of(context);
        textSelectionControls ??= cupertinoTextSelectionControls;
        paintCursorAboveText = true;
        cursorOpacityAnimates = true;
        selectionColor = selectionTheme.selectionColor ??
            cupertinoTheme.primaryColor.withValues(alpha: 0.40);
        cursorRadius ??= const Radius.circular(2.0);
        cursorOffset = Offset(
            iOSHorizontalOffset / MediaQuery.devicePixelRatioOf(context), 0);
        autocorrectionTextRectColor = selectionColor;
        break;

      case TargetPlatform.macOS:
        final cupertinoTheme = CupertinoTheme.of(context);
        textSelectionControls ??= cupertinoDesktopTextSelectionControls;
        paintCursorAboveText = true;
        cursorOpacityAnimates = true;
        selectionColor = selectionTheme.selectionColor ??
            cupertinoTheme.primaryColor.withValues(alpha: 0.40);
        cursorRadius ??= const Radius.circular(2.0);
        cursorOffset = Offset(
            iOSHorizontalOffset / MediaQuery.devicePixelRatioOf(context), 0);
        break;

      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        textSelectionControls ??= materialTextSelectionControls;
        paintCursorAboveText = false;
        cursorOpacityAnimates = false;
        selectionColor = selectionTheme.selectionColor ??
            theme.colorScheme.primary.withValues(alpha: 0.40);
        break;

      case TargetPlatform.linux:
      case TargetPlatform.windows:
        textSelectionControls ??= desktopTextSelectionControls;
        paintCursorAboveText = false;
        cursorOpacityAnimates = false;
        selectionColor = selectionTheme.selectionColor ??
            theme.colorScheme.primary.withValues(alpha: 0.40);
        break;
    }

    return Padding(
      padding: _padding,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: _textController.text.isEmpty
            ? (_) {
                if (View.of(context).viewInsets.bottom <= 0) {
                  FocusManager.instance.primaryFocus?.unfocus();
                  widget.focusNode.requestFocus();
                }
              }
            : null,
        child: EditableText(
          autofocus: widget.autofocus,
          controller: _textController,
          focusNode: widget.focusNode,
          scrollPhysics: const NeverScrollableScrollPhysics(),
          scrollController: _scrollCtrl,
          scrollPadding: EdgeInsets.zero,
          style: widget.style.copyWith(
            fontSize: fontSize,
            leadingDistribution: TextLeadingDistribution.proportional,
          ),
          textAlign: widget.textAlign,
          maxLines: null,
          keyboardType: TextInputType.multiline,
          backgroundCursorColor: CupertinoColors.inactiveGray,
          cursorColor: widget.configs.style.inputCursorColor,
          cursorWidth: widget.cursorWidth,
          cursorHeight: widget.cursorHeight,
          cursorRadius: widget.cursorRadius,
          paintCursorAboveText: paintCursorAboveText,
          cursorOpacityAnimates: cursorOpacityAnimates,
          cursorOffset: cursorOffset,
          autocorrectionTextRectColor: autocorrectionTextRectColor,
          textCapitalization: TextCapitalization.sentences,
          enableInteractiveSelection: true,
          selectionColor: selectionColor,
          selectionControls: textSelectionControls,
          showSelectionHandles: widget.showSelectionHandles,
          showCursor: true,
          autocorrect: widget.configs.enableAutocorrect,
          smartDashesType: SmartDashesType.enabled,
          smartQuotesType: SmartQuotesType.enabled,
          enableSuggestions: widget.configs.enableSuggestions,
          clipBehavior: Clip.hardEdge,
          textInputAction: TextInputAction.newline,
          onSelectionChanged: widget.onSelectionChanged,
          magnifierConfiguration: const TextMagnifierConfiguration(),
          onChanged: widget.onChanged,
          onEditingComplete: widget.onEditingComplete,
          onSubmitted: widget.onSubmitted,
        ),
      ),
    );
  }

  Widget _buildHint({required double fontSize}) {
    final style =
        (widget.hintStyle ?? TextStyle(color: Theme.of(context).hintColor))
            .copyWith(fontSize: fontSize);

    return Positioned(
      child: Padding(
        padding: _padding,
        child: Text(
          widget.hint!,
          style: style,
          textAlign: widget.textAlign,
        ),
      ),
    );
  }
}
