import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../attachments/paste/mre_image_paste_behavior.dart';
import '../../internal/mre_owned.dart';
import 'mre_text_field.dart';
import 'mre_safe_text_editing_controller.dart';

/// A text form field with Unicode direction, suggestions and image paste.
///
/// Supports [FormState.validate], [FormState.save] and [FormState.reset].
/// Use [MRETextField] when no form lifecycle is needed. Appearance and input
/// parameters have the same meaning as on [MRETextField].
///
/// {@category Fields}
class MRETextFormField extends FormField<String> {
  /// Creates a form field. [controller] takes precedence over [initialValue].
  MRETextFormField({
    Key? key,
    GlobalKey<FormFieldState<String>>? fieldKey,
    this.controller,
    String? initialValue,
    FocusNode? focusNode,
    String? hintText,
    String? labelText,
    Widget? label,
    String? helperText,
    String? errorText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    Widget? prefix,
    Widget? suffix,
    InputDecoration? decoration,
    TextStyle? style,
    TextAlign? textAlign,
    TextDirection? textDirection,
    int? maxLines = 1,
    int? minLines,
    int? maxLength,
    bool expands = false,
    ValueChanged<String>? onChanged,
    VoidCallback? onEditingComplete,
    ValueChanged<String>? onFieldSubmitted,
    GestureTapCallback? onTap,
    TapRegionCallback? onTapOutside,
    TextInputAction? textInputAction,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    Iterable<String>? autofillHints,
    bool autocorrect = true,
    bool enableSuggestions = true,
    bool obscureText = false,
    bool autofocus = false,
    super.enabled = true,
    bool readOnly = false,
    Color? cursorColor,
    MouseCursor? mouseCursor,
    double? borderRadius,
    EdgeInsetsGeometry? contentPadding,
    bool showClearButton = false,
    String? clearTooltip,
    bool selectTextOnFocus = false,
    List<String>? suggestions,
    int maxSuggestions = 20,
    ValueChanged<String>? onSuggestionSelected,
    MREImagePasteBehavior imagePaste = const MRENoImagePaste(),
    super.validator,
    super.onSaved,
    super.onReset,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
  }) : super(
         key: fieldKey ?? key,
         initialValue: controller?.text ?? initialValue ?? '',
         autovalidateMode: autovalidateMode,
         builder: (field) {
           final state = field as _MRETextFormFieldState;
           return MRETextField(
             controller: state._text,
             focusNode: focusNode,
             hintText: hintText,
             labelText: labelText,
             label: label,
             helperText: helperText,
             errorText: errorText ?? state.errorText,
             prefixIcon: prefixIcon,
             suffixIcon: suffixIcon,
             prefix: prefix,
             suffix: suffix,
             decoration: decoration,
             style: style,
             textAlign: textAlign,
             textDirection: textDirection,
             maxLines: maxLines,
             minLines: minLines,
             maxLength: maxLength,
             expands: expands,
             onChanged: (value) {
               state.didChange(value);
               onChanged?.call(value);
             },
             onEditingComplete: onEditingComplete,
             onFieldSubmitted: onFieldSubmitted,
             onTap: onTap,
             onTapOutside: onTapOutside,
             textInputAction: textInputAction,
             keyboardType: keyboardType,
             inputFormatters: inputFormatters,
             textCapitalization: textCapitalization,
             autofillHints: autofillHints,
             autocorrect: autocorrect,
             enableSuggestions: enableSuggestions,
             obscureText: obscureText,
             autofocus: autofocus,
             enabled: enabled,
             readOnly: readOnly,
             cursorColor: cursorColor,
             mouseCursor: mouseCursor,
             borderRadius: borderRadius,
             contentPadding: contentPadding,
             showClearButton: showClearButton,
             clearTooltip: clearTooltip,
             selectTextOnFocus: selectTextOnFocus,
             suggestions: suggestions,
             maxSuggestions: maxSuggestions,
             onSuggestionSelected: onSuggestionSelected,
             imagePaste: imagePaste,
           );
         },
       );

  /// The host's controller, which remains owned by the host.
  final TextEditingController? controller;

  @override
  FormFieldState<String> createState() => _MRETextFormFieldState();
}

class _MRETextFormFieldState extends FormFieldState<String> {
  late MREOwned<TextEditingController> _controller;
  TextEditingController get _text => _controller.value;
  MRETextFormField get _field => widget as MRETextFormField;

  @override
  void initState() {
    super.initState();
    _controller = _adopt();
    _text.addListener(_sync);
  }

  MREOwned<TextEditingController> _adopt() => MREOwned(
    _field.controller,
    () => MRESafeTextEditingController(text: widget.initialValue),
  );

  void _sync() {
    if (_text.text != value) didChange(_text.text);
  }

  @override
  void didUpdateWidget(covariant MRETextFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != _field.controller) {
      _text.removeListener(_sync);
      final old = _controller;
      _controller = _adopt();
      _text.addListener(_sync);
      setValue(_text.text);
      old.disposeAfterFrame();
    } else if (_controller.isCreated &&
        oldWidget.initialValue != widget.initialValue) {
      final expected = widget.initialValue ?? '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && (widget.initialValue ?? '') == expected) {
          _text.text = expected;
        }
      });
    }
  }

  @override
  void reset() {
    _text.text = widget.initialValue ?? '';
    super.reset();
  }

  @override
  void dispose() {
    _text.removeListener(_sync);
    _controller.dispose();
    super.dispose();
  }
}
