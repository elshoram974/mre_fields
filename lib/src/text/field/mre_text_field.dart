import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../attachments/paste/mre_image_paste_behavior.dart';
import '../../attachments/paste/mre_image_paste_scope.dart';
import '../../theme/mre_fields_theme.dart';
import '../../theme/mre_window_size.dart';
import '../../internal/mre_owned.dart';
import 'mre_safe_text_editing_controller.dart';
import 'mre_text_field_decoration.dart';
import 'mre_text_field_flags.dart';
import 'mre_text_field_suggestions.dart';

/// A text field that follows the language of what the user types.
///
/// The text direction changes while the user types: Arabic reads right to
/// left, English left to right. Set [textDirection] to lock it. The field also
/// offers a clear button, select-all on focus, and suggestions.
///
/// It sits inside a [Form] like a [TextFormField], and takes the colors, fonts
/// and borders of your `ThemeData`.
///
/// {@example /doc/snippets/text_field.dart#basic}
///
/// Change one field without touching the theme:
///
/// {@example /doc/snippets/text_field.dart#override_one_field}
///
/// Order of priority for [borderRadius] and [contentPadding]: the parameter,
/// then [MREFieldsTheme], then your `InputDecorationTheme`, then the default.
///
/// Paste images with [imagePaste]:
///
/// {@example /doc/snippets/attachments.dart#attachments}
///
/// See also:
///
///  * [MREFieldsTheme], the tokens every field shares.
///  * [MRESuggestionBar] and [MREFieldClearButton], the pieces this field uses.
///  * [MRESafeTextEditingController], the controller used when you pass none.
///
/// {@category Fields}
class MRETextField extends StatefulWidget {
  /// Creates a text field.
  const MRETextField({
    super.key,
    this.fieldKey,
    this.controller,
    this.initialValue,
    this.focusNode,
    this.hintText,
    this.labelText,
    this.label,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.prefix,
    this.suffix,
    this.decoration,
    this.style,
    this.textAlign,
    this.textDirection,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.expands = false,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.onChanged,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.onTap,
    this.onTapOutside,
    this.textInputAction,
    this.keyboardType,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
    this.autofillHints,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.obscureText = false,
    this.autofocus = false,
    this.enabled = true,
    this.readOnly = false,
    this.cursorColor,
    this.mouseCursor,
    this.borderRadius,
    this.contentPadding,
    this.showClearButton = false,
    this.clearTooltip,
    this.selectTextOnFocus = false,
    this.suggestions,
    this.maxSuggestions = 20,
    this.onSuggestionSelected,
    this.imagePaste = const MRENoImagePaste(),
  });

  /// Key of the inner [FormField], to validate without a parent [Form].
  final GlobalKey<FormFieldState<String>>? fieldKey;

  /// The text controller. The field creates and disposes its own when null.
  final TextEditingController? controller;

  /// Text to start with when [controller] is null. A new value replaces the
  /// text, but only when the field owns its controller.
  final String? initialValue;

  /// The focus node. The field creates and disposes its own when null.
  final FocusNode? focusNode;

  /// Hint shown while the field is empty.
  final String? hintText;

  /// Label that floats above the field.
  final String? labelText;

  /// A widget label. Wins over [labelText].
  final Widget? label;

  /// Text shown under the field.
  final String? helperText;

  /// Error shown under the field. Wins over [validator] messages.
  final String? errorText;

  /// Widget before the input, inside the border.
  final Widget? prefixIcon;

  /// Widget after the input. Shown after the clear button when both are on.
  final Widget? suffixIcon;

  /// Widget directly before the text, such as a currency symbol.
  final Widget? prefix;

  /// Widget directly after the text, such as a unit.
  final Widget? suffix;

  /// Start from this decoration. The parameters above and the theme values are
  /// applied on top of it.
  final InputDecoration? decoration;

  /// Style of the typed text.
  final TextStyle? style;

  /// Alignment of the text. Follows the detected direction when null.
  final TextAlign? textAlign;

  /// Locks the direction and turns detection off. Use
  /// [TextDirection.ltr] for emails, links and numbers.
  final TextDirection? textDirection;

  /// See [TextField.maxLines].
  final int? maxLines;

  /// See [TextField.minLines].
  final int? minLines;

  /// See [TextField.maxLength].
  final int? maxLength;

  /// See [TextField.expands].
  final bool expands;

  /// Checks the text. Return an error message, or null when it is valid.
  final FormFieldValidator<String>? validator;

  /// When [validator] runs. Defaults to after the user interacts.
  final AutovalidateMode autovalidateMode;

  /// Called on every change, also when the clear button or a suggestion
  /// changes the text.
  final ValueChanged<String>? onChanged;

  /// See [TextField.onEditingComplete].
  final VoidCallback? onEditingComplete;

  /// Called when the user submits the field.
  final ValueChanged<String>? onFieldSubmitted;

  /// See [FormField.onSaved].
  final FormFieldSetter<String>? onSaved;

  /// See [TextField.onTap].
  final GestureTapCallback? onTap;

  /// See [TextField.onTapOutside].
  final TapRegionCallback? onTapOutside;

  /// The keyboard action button. Defaults to newline for multiline fields and
  /// to the platform default otherwise.
  final TextInputAction? textInputAction;

  /// The keyboard type.
  final TextInputType? keyboardType;

  /// Filters or formats what the user types.
  final List<TextInputFormatter>? inputFormatters;

  /// How the keyboard capitalizes. Defaults to none.
  final TextCapitalization textCapitalization;

  /// Hints for the platform autofill service.
  final Iterable<String>? autofillHints;

  /// See [TextField.autocorrect].
  final bool autocorrect;

  /// See [TextField.enableSuggestions].
  final bool enableSuggestions;

  /// Whether to hide the text, for passwords.
  final bool obscureText;

  /// Whether to take focus when first built.
  final bool autofocus;

  /// Whether the user can interact with the field.
  final bool enabled;

  /// Whether the text can be read and copied but not changed.
  final bool readOnly;

  /// Color of the cursor. Defaults to the theme.
  final Color? cursorColor;

  /// Mouse cursor over the field.
  final MouseCursor? mouseCursor;

  /// Corner radius of the border. Defaults to [MREFieldsTheme.fieldBorderRadius]
  /// when the theme is registered; otherwise the border stays as your theme
  /// defines it. Only outline borders have a radius.
  final double? borderRadius;

  /// Padding inside the border. Defaults to [MREFieldsTheme.contentPadding] on
  /// compact and medium widths and [MREFieldsTheme.expandedContentPadding] on
  /// expanded widths.
  final EdgeInsetsGeometry? contentPadding;

  /// Whether to show a clear button while the field has text.
  final bool showClearButton;

  /// Tooltip of the clear button. Defaults to [MREFieldsStrings.clearTooltip].
  final String? clearTooltip;

  /// Whether to select all text when the field gets focus.
  final bool selectTextOnFocus;

  /// Suggestions shown under the field while it has focus.
  final List<String>? suggestions;

  /// The most suggestions to show at once.
  final int maxSuggestions;

  /// Called after the user picks a suggestion. [onChanged] is called too.
  final ValueChanged<String>? onSuggestionSelected;

  /// What to do when the user pastes an image. Defaults to nothing: the field
  /// pastes text only. See [MREImagePasteBehavior].
  final MREImagePasteBehavior imagePaste;

  @override
  State<MRETextField> createState() => _MRETextFieldState();
}

class _MRETextFieldState extends State<MRETextField> {
  late MREOwned<TextEditingController> _controller;
  late MREOwned<FocusNode> _focus;
  late final MRETextFieldFlagsTracker _flags;

  TextEditingController get _text => _controller.value;

  FocusNode get _focusNode => _focus.value;

  @override
  void initState() {
    super.initState();
    _controller = _adoptController();
    _focus = MREOwned(widget.focusNode, FocusNode.new);
    _flags = MRETextFieldFlagsTracker(_text);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(MRETextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      final old = _controller;
      _controller = _adoptController();
      _flags.follow(_text);
      old.disposeAfterFrame();
    } else if (_controller.isCreated &&
        widget.initialValue != oldWidget.initialValue) {
      _setTextAfterBuild(widget.initialValue ?? '');
    }

    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_onFocusChanged);
      final old = _focus;
      _focus = MREOwned(widget.focusNode, FocusNode.new);
      _focusNode.addListener(_onFocusChanged);
      old.disposeAfterFrame();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _flags.dispose();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  MREOwned<TextEditingController> _adoptController() {
    return MREOwned(
      widget.controller,
      () => MRESafeTextEditingController(text: widget.initialValue),
    );
  }

  void _onFocusChanged() {
    if (!widget.selectTextOnFocus || !_focusNode.hasFocus) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _focusNode.hasFocus) {
        _text.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _text.text.length,
        );
      }
    });
  }

  /// Sets the text once the frame is built, because the controller notifies
  /// listeners and the field may be building right now.
  void _setTextAfterBuild(String text) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _text.text != text) {
        _setText(text);
      }
    });
  }

  /// Replaces the text and puts the cursor at its end.
  void _setText(String text) {
    _text.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  void _clear() {
    _text.clear();
    widget.onChanged?.call('');
  }

  void _pick(String suggestion) {
    _setText(suggestion);
    widget.onChanged?.call(suggestion);
    widget.onSuggestionSelected?.call(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = MREFieldsTheme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = tokens.windowSizeFor(constraints.maxWidth);
        final field = MREImagePasteScope(
          behavior: widget.imagePaste,
          builder: (context, hooks) =>
              ValueListenableBuilder<MRETextFieldFlags>(
                valueListenable: _flags,
                builder: (context, flags, _) =>
                    _buildField(theme, tokens, size, flags, hooks),
              ),
        );

        final suggestions = widget.suggestions;
        if (suggestions == null) {
          return field;
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            field,
            MRETextFieldSuggestions(
              controller: _text,
              focusNode: _focusNode,
              suggestions: suggestions,
              limit: widget.maxSuggestions,
              onSelected: _pick,
            ),
          ],
        );
      },
    );
  }

  Widget _buildField(
    ThemeData theme,
    MREFieldsTheme tokens,
    MREWindowSize size,
    MRETextFieldFlags flags,
    MREImagePasteHooks hooks,
  ) {
    final multiline = widget.maxLines == null || widget.maxLines! > 1;

    return TextFormField(
      key: widget.fieldKey,
      controller: _text,
      focusNode: _focusNode,
      decoration: _decoration(theme, tokens, size, flags),
      style: widget.style,
      textAlign: widget.textAlign ?? TextAlign.start,
      textDirection: widget.textDirection ?? flags.direction,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      expands: widget.expands,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      onChanged: widget.onChanged,
      onEditingComplete: widget.onEditingComplete,
      onFieldSubmitted: widget.onFieldSubmitted,
      onSaved: widget.onSaved,
      onTap: widget.onTap,
      onTapOutside: widget.onTapOutside,
      textInputAction:
          widget.textInputAction ??
          (multiline ? TextInputAction.newline : null),
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      textCapitalization: widget.textCapitalization,
      autofillHints: widget.autofillHints,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.enableSuggestions,
      obscureText: widget.obscureText,
      autofocus: widget.autofocus,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      cursorColor: widget.cursorColor,
      mouseCursor: widget.mouseCursor,
      contentInsertionConfiguration: hooks.contentInsertionConfiguration,
      contextMenuBuilder: hooks.contextMenuBuilder,
    );
  }

  InputDecoration _decoration(
    ThemeData theme,
    MREFieldsTheme tokens,
    MREWindowSize size,
    MRETextFieldFlags flags,
  ) {
    final base = widget.decoration ?? const InputDecoration();
    final decoration = base.copyWith(
      hintText: widget.hintText,
      labelText: widget.labelText,
      label: widget.label,
      helperText: widget.helperText,
      errorText: widget.errorText,
      prefixIcon: widget.prefixIcon,
      prefix: widget.prefix,
      suffix: widget.suffix,
      suffixIcon: _suffixIcon(tokens, flags),
    );

    return resolveMRETextFieldDecoration(
      base: decoration,
      theme: theme,
      size: size,
      borderRadius: widget.borderRadius,
      contentPadding: widget.contentPadding,
    );
  }

  Widget? _suffixIcon(MREFieldsTheme tokens, MRETextFieldFlags flags) {
    return composeMRETextFieldSuffix(
      suffixIcon: widget.suffixIcon,
      showClear:
          widget.showClearButton &&
          flags.hasText &&
          widget.enabled &&
          !widget.readOnly,
      onClear: _clear,
      clearTooltip: widget.clearTooltip ?? tokens.strings.clearTooltip,
    );
  }
}
