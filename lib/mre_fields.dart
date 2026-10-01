/// Reusable Flutter form fields: bidirectional text, phone with country code,
/// and suggestions.
///
/// Fields read colors and typography from your `ThemeData` and add a few
/// tokens of their own through [MREFieldsTheme]. Any token can also be set on
/// a single field.
///
/// ## Topics
///
///  * **Theme**: [MREFieldsTheme], [MREFieldsStrings], [MREWindowSize].
///
/// ## Quick start
///
/// ```dart
/// MaterialApp(
///   theme: ThemeData(
///     extensions: const [MREFieldsTheme(fieldBorderRadius: 16)],
///   ),
///   home: const HomePage(),
/// );
/// ```
library;

export 'src/theme/mre_fields_strings.dart';
export 'src/theme/mre_fields_theme.dart';
