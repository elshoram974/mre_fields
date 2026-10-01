`MREPhoneField` is a phone number field with a country picker. It checks the
number for **every country**, finds the country from a pasted number, and
accepts only the countries you choose.

## A field

The country button shows the flag and the dial code. Tap it to pick another
country. `number.e164` is the number to save or send.

<!-- snippet: basic -->
```dart
final field = MREPhoneField(
  labelText: 'Phone number',
  onChanged: (number) {
    if (number.isValid) {
      saveNumber(number.e164!); // '+201012345678'
    }
  },
);
```

## What it does for the user

| The user... | The field... |
|---|---|
| Types `1012345678` or `01012345678` | Reads it as a number of the chosen country |
| Pastes `+20 (10) 1234-5678` | Switches to Egypt and fills `1012345678` |
| Pastes `0020 101 234 5678` | The same: `00` is read as `+` |
| Types digits in Arabic (`٠١٠١٢٣٤٥٦٧٨`) | Converts them to ASCII digits |
| Pastes a `+1 204…` number | Finds Canada, not the United States: the whole number decides |
| Pastes a number from an excluded country | Keeps it and says the country is not accepted |
| Taps the country button | Opens a searchable list: a sheet on narrow windows, a dialog on wide ones |

## Choose the countries

One selection feeds the picker, the paste detection and the validation, so an
excluded country cannot get in by any path.

<!-- snippet: selection -->
```dart
const selection = MRECountrySelection(
  include: {'SA', 'AE', 'KW', 'QA', 'BH', 'OM'},
  favorites: ['SA', 'AE'],
  initial: 'SA',
);

final field = MREPhoneField(selection: selection);
```

Or exclude some:

<!-- snippet: exclude -->
```dart
final field = MREPhoneField(
  selection: const MRECountrySelection(exclude: {'IL'}),
);
```

Give either `include` or `exclude`, not both. `favorites` are pinned at the
top of the picker. `initial` is the country a new field starts with; without
it the field uses the device country when it is accepted, then the first
favorite, then the first accepted country.

## Read the number

`MREPhoneNumber` splits what was typed. It works without any widget.

<!-- snippet: parse -->
```dart
final number = MREPhoneNumber.parse('+20 101 234 5678');

final country = number.country!.name; // 'Egypt'
final e164 = number.e164; // '+201012345678'
final nice = number.international; // '+20 10 12345678'
final valid = number.isValid; // true
```

Numbers without a dial code need a country:

<!-- snippet: national -->
```dart
final egypt = MRECountries.byIsoCode('EG')!;
final number = MREPhoneNumber.parse('010 1234 5678', defaultCountry: egypt);

final e164 = number.e164; // '+201012345678'
```

## Why a number is not valid

When `isValid` is false, `error` says why. The field shows the message and you
can show your own.

| `MREPhoneError` | Meaning |
|---|---|
| `empty` | Nothing was entered |
| `tooShort` | Fewer digits than any number of the country has |
| `tooLong` | More digits than any number of the country has |
| `invalid` | The length fits but the number matches no pattern |
| `unknownCountry` | The dial code after the plus belongs to no country |
| `countryNotAllowed` | The number is from a country the selection does not accept |
| `missingCountry` | A national number and no country to read it in |

<!-- snippet: error -->
```dart
final number = MREPhoneNumber.parse(
  typed,
  defaultCountry: MRECountries.byIsoCode('EG'),
);

final error = number.error; // null, or tooShort, tooLong, invalid, ...
```

## Translate it

Country names, the picker texts and every error message can be in your
language. Names come from `countryNameBuilder` (English is the fallback). Error
messages come from `MREFieldsStrings`, registered once on your theme.

<!-- snippet: translate -->
```dart
final field = MREPhoneField(
  labelText: 'رقم الهاتف',
  countryNameBuilder: (country) =>
      arabicNames[country.isoCode] ?? country.name,
  pickerTitle: 'اختر الدولة',
  pickerSearchHint: 'ابحث عن دولة أو رمز',
);

// The error messages come from MREFieldsStrings, registered once in the theme:
const strings = MREFieldsStrings(
  phoneEmpty: 'اكتب رقم الهاتف',
  phoneTooShort: 'الرقم قصير',
  phoneInvalid: 'رقم غير صحيح',
);
```

Get the message for an error yourself:

<!-- snippet: messages -->
```dart
const strings = MREFieldsStrings();
final message = strings.phoneError(error); // 'The phone number is too short'
```

## Use it in a form

<!-- snippet: form -->
```dart
final form = Form(
  key: formKey,
  child: const MREPhoneField(labelText: 'Phone number', required: true),
);
```

Without a parent `Form`, pass `fieldKey` and call
`fieldKey.currentState!.validate()`.

## Validate any field

The same validation works in a plain `TextFormField`:

<!-- snippet: validator -->
```dart
final field = TextFormField(
  keyboardType: TextInputType.phone,
  validator: MREPhoneValidators.valid(
    country: MRECountries.byIsoCode('EG'),
    selection: const MRECountrySelection(include: {'EG', 'SA'}),
  ),
);
```

## Read and set the number from code

<!-- snippet: controller -->
```dart
// Create the controller in initState and dispose it in dispose.
final field = MREPhoneField(controller: controller, labelText: 'Phone');

controller.setNumber('+966 50 123 4567'); // sets the country and the digits
final number = controller.number(); // an MREPhoneNumber
```

The controller notifies when the **country** changes. Listen to
`controller.text` for typing.

## Countries

<!-- snippet: countries -->
```dart
final egypt = MRECountries.byIsoCode('EG')!;
final dial = egypt.dialCodeWithPlus; // '+20'
final flag = egypt.flag; // 🇪🇬
final sharing = MRECountries.byDialCode('+1'); // United States, Canada, ...
```

A dial code can belong to several countries, so the ISO code is the key: two
countries are equal when their ISO codes are.

## The picker on its own

<!-- snippet: picker -->
```dart
final country = showMRECountryPicker(
  context,
  countries: MRECountries.all,
  favorites: [MRECountries.byIsoCode('EG')!],
);
```

`MRECountryPickerBody` is the list without the sheet or dialog, if you want to
put it in your own page.

## How the numbers are checked

The rules come from the libphonenumber data through the
[phone_numbers_parser](https://pub.dev/packages/phone_numbers_parser) package:
length and pattern for 245 countries and regions. The package hides it behind
`MREPhoneNumber`, so your code does not depend on it.
