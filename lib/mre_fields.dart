/// Reusable Flutter form fields: bidirectional text, phone with country code,
/// and suggestions.
///
/// Fields use the colors and fonts of your `ThemeData`. Add the field-only
/// values with [MREFieldsTheme]:
///
/// {@example /doc/snippets/theme.dart#global}
///
/// ## Topics
///
///  * **Theme**: [MREFieldsTheme], [MREFieldsStrings], [MREWindowSize].
///  * **Text**: [detectTextDirection], [MREAutoText], [MRETextDirection],
///    [MREDirectionalWidget], [safeDisplayText].
library;

export 'src/text/mre_auto_text.dart';
export 'src/text/text_direction.dart';
export 'src/theme/mre_fields_strings.dart';
export 'src/theme/mre_fields_theme.dart';
