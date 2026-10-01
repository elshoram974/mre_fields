import 'package:flutter/material.dart';
import 'package:mre_fields/mre_fields.dart';

/// What the demo lets the user change: theme, language and field radius.
class ExampleSettings extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');
  double _radius = 12;

  /// Light, dark or system.
  ThemeMode get themeMode => _themeMode;

  /// The app language, English or Arabic.
  Locale get locale => _locale;

  /// The field corner radius, set through [MREFieldsTheme].
  double get radius => _radius;

  /// Whether the app is in Arabic.
  bool get isArabic => _locale.languageCode == 'ar';

  /// The field texts for the current language.
  MREFieldsStrings get strings => isArabic ? _arabic : const MREFieldsStrings();

  /// Switches between light and dark.
  void toggleDark(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    _themeMode = dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  /// Switches between English and Arabic.
  void toggleLanguage() {
    _locale = isArabic ? const Locale('en') : const Locale('ar');
    notifyListeners();
  }

  /// Sets the field corner radius.
  set radius(double value) {
    _radius = value;
    notifyListeners();
  }
}

const _arabic = MREFieldsStrings(
  clearTooltip: 'مسح',
  countryPickerTitle: 'اختر الدولة',
  countrySearchHint: 'ابحث عن دولة أو رمز',
  noCountriesFound: 'لا توجد دول',
  removeImageTooltip: 'إزالة الصورة',
  replaceImageTooltip: 'استبدال الصورة',
  closeViewerTooltip: 'إغلاق',
  pasteImageLabel: 'لصق صورة',
  attachedImageLabel: 'صورة مرفقة',
);
