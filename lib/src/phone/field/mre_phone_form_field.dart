import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../internal/mre_owned.dart';
import '../../theme/mre_fields_theme.dart';
import '../model/mre_country.dart';
import '../model/mre_country_selection.dart';
import '../model/mre_phone_number.dart';
import '../model/mre_phone_initial_country.dart';
import '../validation/mre_phone_validators.dart';
import '../../theme/mre_fields_strings.dart';
import 'mre_phone_controller.dart';
import 'mre_phone_field.dart';

/// A phone form field with a structured [MREPhoneNumber] value.
///
/// Validates, saves and resets both the country and number. Use [MREPhoneField]
/// for an ordinary input without form registration. Appearance parameters
/// have the same meaning as on [MREPhoneField].
///
/// {@category Phone}
class MREPhoneFormField extends FormField<MREPhoneNumber> {
  /// Creates a phone form field with built-in, localizable validation.
  factory MREPhoneFormField({
    Key? key,
    GlobalKey<FormFieldState<MREPhoneNumber>>? fieldKey,
    MREPhoneController? controller,
    String? initialValue,
    MRECountry? initialCountry,
    MRECountrySelection selection = const MRECountrySelection(),
    String? labelText,
    String? hintText,
    String? helperText,
    String? errorText,
    InputDecoration? decoration,
    ValueChanged<MREPhoneNumber>? onChanged,
    ValueChanged<MRECountry>? onCountryChanged,
    bool enabled = true,
    bool readOnly = false,
    bool autofocus = false,
    FocusNode? focusNode,
    TextInputAction? textInputAction,
    ValueChanged<MREPhoneNumber>? onFieldSubmitted,
    TextStyle? style,
    double? borderRadius,
    EdgeInsetsGeometry? contentPadding,
    bool showClearButton = false,
    bool showFlags = true,
    String Function(MRECountry country)? countryNameBuilder,
    String? pickerTitle,
    String? pickerSearchHint,
    String? pickerEmptyText,
    Iterable<String> autofillHints = const [
      AutofillHints.telephoneNumberNational,
    ],
    bool required = true,
    String? Function(MREPhoneNumber number)? validator,
    FormFieldSetter<MREPhoneNumber>? onSaved,
    VoidCallback? onReset,
    AutovalidateMode autovalidateMode = AutovalidateMode.onUserInteraction,
  }) {
    var strings = const MREFieldsStrings();
    return MREPhoneFormField._(
      controller: controller,
      initialCountry: initialCountry,
      selection: selection,
      onChanged: onChanged,
      initialText: initialValue,
      updateStrings: (value) => strings = value,
      key: fieldKey ?? key,
      enabled: enabled,
      validator: (number) {
        if (number == null) return null;
        if (validator != null) return validator(number);
        final error = number.error;
        if (error == null || (!required && error == MREPhoneError.empty)) {
          return null;
        }
        return strings.phoneError(error);
      },
      onSaved: onSaved,
      onReset: onReset,
      autovalidateMode: autovalidateMode,
      builder: (field) {
        final state = field as _MREPhoneFormFieldState;
        return MREPhoneField(
          controller: state._phone,
          initialCountry: initialCountry,
          selection: selection,
          labelText: labelText,
          hintText: hintText,
          helperText: helperText,
          errorText: errorText ?? state.errorText,
          decoration: decoration,
          onChanged: (number) {
            if (state._resetting) return;
            state.didChange(number);
            onChanged?.call(number);
          },
          onCountryChanged: onCountryChanged,
          enabled: enabled,
          readOnly: readOnly,
          autofocus: autofocus,
          focusNode: focusNode,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted,
          style: style,
          borderRadius: borderRadius,
          contentPadding: contentPadding,
          showClearButton: showClearButton,
          showFlags: showFlags,
          countryNameBuilder: countryNameBuilder,
          pickerTitle: pickerTitle,
          pickerSearchHint: pickerSearchHint,
          pickerEmptyText: pickerEmptyText,
          autofillHints: autofillHints,
        );
      },
    );
  }

  const MREPhoneFormField._({
    super.key,
    required this.controller,
    required this.initialCountry,
    required this.selection,
    required this.onChanged,
    required String? initialText,
    required void Function(MREFieldsStrings) updateStrings,
    required super.enabled,
    required super.validator,
    required super.onSaved,
    required super.onReset,
    required super.autovalidateMode,
    required super.builder,
  }) : _initialText = initialText,
       _updateStrings = updateStrings;

  /// The host's controller, never disposed by the field.
  final MREPhoneController? controller;

  /// The preferred country at initialization.
  final MRECountry? initialCountry;

  /// Allowed countries and fallback country.
  final MRECountrySelection selection;

  /// Called when the user changes the number or country.
  final ValueChanged<MREPhoneNumber>? onChanged;

  final void Function(MREFieldsStrings) _updateStrings;
  final String? _initialText;

  @override
  FormFieldState<MREPhoneNumber> createState() => _MREPhoneFormFieldState();
}

class _MREPhoneFormFieldState extends FormFieldState<MREPhoneNumber> {
  late MREOwned<MREPhoneController> _controller;
  MREPhoneController get _phone => _controller.value;
  MREPhoneFormField get _field => widget as MREPhoneFormField;
  late MRECountry? _startCountry;
  late String _startText;
  bool _resetting = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _field._updateStrings(MREFieldsTheme.of(context).strings);
  }

  @override
  void initState() {
    super.initState();
    _adopt();
  }

  void _adopt() {
    _controller = MREOwned(_field.controller, MREPhoneController.new);
    final selection = _field.selection;
    if (_phone.country == null || !selection.allows(_phone.country!)) {
      final locale =
          WidgetsBinding.instance.platformDispatcher.locale.countryCode;
      _phone.country = mreInitialPhoneCountry(
        selection: selection,
        preferred: _field.initialCountry,
        deviceCountryCode: locale,
      );
    }
    if (_controller.isCreated && _field._initialText != null) {
      _phone.setNumber(_field._initialText!, selection: selection);
    }
    _startCountry = _phone.country;
    _startText = _phone.text.text;
    setValue(_phone.number(selection));
    _phone.addListener(_sync);
    _phone.text.addListener(_sync);
  }

  void _sync() {
    if (_resetting) return;
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_resetting) _sync();
      });
      return;
    }
    final number = _phone.number(_field.selection);
    if (number != value) didChange(number);
  }

  void _detach() {
    _phone.removeListener(_sync);
    _phone.text.removeListener(_sync);
  }

  @override
  void didUpdateWidget(covariant MREPhoneFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    _field._updateStrings(MREFieldsTheme.of(context).strings);
    if (oldWidget.controller != _field.controller) {
      _detach();
      final old = _controller;
      _adopt();
      old.disposeAfterFrame();
    }
  }

  @override
  void reset() {
    _resetting = true;
    _phone.country = _startCountry;
    _phone.text.text = _startText;
    super.reset();
    setValue(_phone.number(_field.selection));
    _resetting = false;
  }

  @override
  void dispose() {
    _detach();
    _controller.dispose();
    super.dispose();
  }
}
