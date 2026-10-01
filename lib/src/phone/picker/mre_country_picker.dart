import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/mre_fields_theme.dart';
import '../../theme/mre_window_size.dart';
import '../model/mre_country.dart';
import 'mre_country_picker_body.dart';

/// Widest the dialog gets on a wide window.
const double _dialogMaxWidth = 440;

/// Tallest the dialog gets, as a share of the window height.
const double _dialogHeightShare = 0.85;

/// Tallest the dialog gets, in logical pixels.
const double _dialogMaxHeight = 560;

/// Opens the country picker and returns the country the user chose, or null
/// when it is dismissed.
///
/// The picker adapts to the window: a bottom sheet you can drag on narrow
/// windows, a centered dialog with a maximum width on wide ones. The width is
/// classified with `MREFieldsTheme.windowSizeFor`.
///
/// {@example /doc/snippets/phone.dart#picker}
///
/// {@category Phone}
Future<MRECountry?> showMRECountryPicker(
  BuildContext context, {
  required List<MRECountry> countries,
  MRECountry? selected,
  List<MRECountry> favorites = const [],
  String? title,
  String? searchHint,
  String? emptyText,
  String Function(MRECountry country)? nameBuilder,
  bool showFlags = true,
}) {
  final size = MREFieldsTheme.of(
    context,
  ).windowSizeFor(MediaQuery.sizeOf(context).width);

  MRECountryPickerBody body(
    BuildContext context, {
    ScrollController? controller,
  }) {
    return MRECountryPickerBody(
      countries: countries,
      selected: selected,
      favorites: favorites,
      title: title,
      searchHint: searchHint,
      emptyText: emptyText,
      nameBuilder: nameBuilder,
      showFlags: showFlags,
      scrollController: controller,
      autofocusSearch: size == MREWindowSize.expanded,
      onSelected: (country) => Navigator.of(context).pop(country),
    );
  }

  if (size == MREWindowSize.expanded) {
    return showDialog<MRECountry>(
      context: context,
      builder: (context) => Dialog(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _dialogMaxWidth,
            maxHeight: math.min(
              _dialogMaxHeight,
              MediaQuery.sizeOf(context).height * _dialogHeightShare,
            ),
          ),
          child: body(context),
        ),
      ),
    );
  }

  return showModalBottomSheet<MRECountry>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, controller) => body(context, controller: controller),
      ),
    ),
  );
}
