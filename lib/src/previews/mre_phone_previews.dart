import 'package:flutter/material.dart';

import '../phone/field/mre_phone_form_field.dart';
import '../phone/model/mre_country.dart';
import '../phone/model/mre_country_selection.dart';
import '../phone/picker/mre_country_picker_body.dart';
import 'preview_harness.dart';

/// A phone field with a valid Egyptian number.
@MREPreview()
Widget previewPhoneField() {
  return MREPhoneFormField(
    labelText: 'Phone number',
    initialValue: '+201012345678',
  );
}

/// A number that is too short, with its error showing.
@MREPreview()
Widget previewPhoneFieldError() {
  return MREPhoneFormField(
    labelText: 'Phone number',
    initialCountry: MRECountries.byIsoCode('EG'),
    initialValue: '0101',
    autovalidateMode: AutovalidateMode.always,
  );
}

/// A field that accepts the Gulf countries only.
@MREPreview()
Widget previewPhoneFieldGulf() {
  return MREPhoneFormField(
    labelText: 'Phone number',
    helperText: 'Gulf numbers only',
    selection: MRECountrySelection(
      include: {'SA', 'AE', 'KW', 'QA', 'BH', 'OM'},
      favorites: ['SA', 'AE'],
      initial: 'SA',
    ),
  );
}

/// The country list with favorites pinned on top.
@MREPreview()
Widget previewCountryPicker() {
  return SizedBox(
    height: 480,
    child: MRECountryPickerBody(
      countries: MRECountries.all,
      favorites: [MRECountries.byIsoCode('EG')!, MRECountries.byIsoCode('SA')!],
      selected: MRECountries.byIsoCode('EG'),
      onSelected: (_) {},
    ),
  );
}
