import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/mre_fields_theme.dart';
import 'mre_field_clear_button.dart';
import 'mre_safe_text_editing_controller.dart';
import 'mre_suggestion_bar.dart';
import 'mre_text_field_decoration.dart';
import 'text_direction.dart';

/// Space between the field and its suggestions.
const double _suggestionGap = 6;

/// What the field shows that depends on its text. The field rebuilds only when
/// this changes, not on every keystroke.
@immutable
class _FieldFlags {
  const _FieldFlags({required this.direction, required this.hasText});

  /// Direction of the first strong letter, or null when there is none.
  final TextDirection? direction;

  /// Whether the text is not empty.
  final bool hasText;

  @override
  bool operator ==(Object other) {
    return other is _FieldFlags &&
        other.direction == direction &&
        other.hasText == hasText;
  }

  @override
  int get hashCode => Object.hash(direction, hasText);
}

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

  @override
  State<MRETextField> createState() => _MRETextFieldState();
}

class _MRETextFieldState extends State<MRETextField> {
  late TextEditingController _controller;
  late bool _ownsController;
  late FocusNode _focusNode;
  late bool _ownsFocusNode;
  late final ValueNotifier<_FieldFlags> _flags;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        MRESafeTextEditingController(text: widget.initialValue);
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _flags = ValueNotifier(_flagsFor(_controller.text));
    _controller.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(MRETextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.controller != oldWidget.controller) {
      _controller.removeListener(_onTextChanged);
      _disposeLater(_ownsController ? _controller : null);
      _ownsController = widget.controller == null;
      _controller =
          widget.controller ??
          MRESafeTextEditingController(text: widget.initialValue);
      _controller.addListener(_onTextChanged);
      _onTextChanged();
    } else if (_ownsController &&
        widget.initialValue != oldWidget.initialValue) {
      _setInitialValueAfterBuild(widget.initialValue ?? '');
    }

    if (widget.focusNode != oldWidget.focusNode) {
      _focusNode.removeListener(_onFocusChanged);
      _disposeLater(_ownsFocusNode ? _focusNode : null);
      _ownsFocusNode = widget.focusNode == null;
      _focusNode = widget.focusNode ?? FocusNode();
      _focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _flags.dispose();
    if (_ownsController) {
      _controller.dispose();
    }
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  _FieldFlags _flagsFor(String text) {
    return _FieldFlags(
      direction: detectStrongTextDirection(text),
      hasText: text.isNotEmpty,
    );
  }

  /// Runs on every text or selection change. Updating the notifier is a no-op
  /// while the flags stay equal, so the field rebuilds only when the direction
  /// or the empty state changes.
  void _onTextChanged() {
    _flags.value = _flagsFor(_controller.text);
  }

  void _onFocusChanged() {
    if (!widget.selectTextOnFocus || !_focusNode.hasFocus) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _focusNode.hasFocus) {
        _controller.selection = TextSelection(
          baseOffset: 0,
          extentOffset: _controller.text.length,
        );
      }
    });
  }

  /// Disposes a replaced object after the frame, once the [TextFormField] has
  /// stopped listening to it.
  void _disposeLater(ChangeNotifier? notifier) {
    if (notifier == null) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => notifier.dispose());
  }

  void _setInitialValueAfterBuild(String text) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _controller.text != text) {
        _controller.value = TextEditingValue(
          text: text,
          selection: TextSelection.collapsed(offset: text.length),
        );
      }
    });
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  void _pick(String suggestion) {
    _controller.value = TextEditingValue(
      text: suggestion,
      selection: TextSelection.collapsed(offset: suggestion.length),
    );
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
        final field = ValueListenableBuilder<_FieldFlags>(
          valueListenable: _flags,
          builder: (context, flags, _) =>
              _buildField(theme, tokens, size, flags),
        );

        if (widget.suggestions == null) {
          return field;
        }
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [field, _buildSuggestions()],
        );
      },
    );
  }

  Widget _buildField(
    ThemeData theme,
    MREFieldsTheme tokens,
    MREWindowSize size,
    _FieldFlags flags,
  ) {
    final multiline = widget.maxLines == null || widget.maxLines! > 1;

    return TextFormField(
      key: widget.fieldKey,
      controller: _controller,
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
    );
  }

  InputDecoration _decoration(
    ThemeData theme,
    MREFieldsTheme tokens,
    MREWindowSize size,
    _FieldFlags flags,
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

  Widget? _suffixIcon(MREFieldsTheme tokens, _FieldFlags flags) {
    final showClear =
        widget.showClearButton &&
        flags.hasText &&
        widget.enabled &&
        !widget.readOnly;
    if (!showClear) {
      return widget.suffixIcon;
    }

    final clear = MREFieldClearButton(
      onPressed: _clear,
      tooltip: widget.clearTooltip ?? tokens.strings.clearTooltip,
    );
    final suffix = widget.suffixIcon;
    if (suffix == null) {
      return clear;
    }
    return Row(mainAxisSize: MainAxisSize.min, children: [clear, suffix]);
  }

  /// The suggestions rebuild on text and focus changes only, and only when the
  /// field has suggestions.
  Widget _buildSuggestions() {
    return ListenableBuilder(
      listenable: Listenable.merge([_controller, _focusNode]),
      builder: (context, _) {
        if (!_focusNode.hasFocus) {
          return const SizedBox.shrink();
        }
        final matches = mreFilterSuggestions(
          widget.suggestions!,
          _controller.text,
          limit: widget.maxSuggestions,
        );
        if (matches.isEmpty) {
          return const SizedBox.shrink();
        }
        // A tap on a suggestion is a tap inside the field. Without the tap
        // region it would count as a tap outside, unfocus the field, and hide
        // the suggestion before the tap ends.
        return TextFieldTapRegion(
          child: Padding(
            padding: const EdgeInsets.only(top: _suggestionGap),
            child: MRESuggestionBar(suggestions: matches, onSelected: _pick),
          ),
        );
      },
    );
  }
}
