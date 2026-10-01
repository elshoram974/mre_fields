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
///  * **Text**: [detectTextDirection], [detectStrongTextDirection],
///    [MREAutoText], [MREAutoDirectionText], [MRETextDirection],
///    [MREDirectionalWidget], [safeDisplayText].
///  * **Fields**: [MRETextField], [MRESuggestionBar], [MREFieldClearButton],
///    [MRESafeTextEditingController], [mreFilterSuggestions].
///  * **Attachments**: [MREImagePasteBehavior] with [MRENoImagePaste],
///    [MREImageCallbackPaste] and [MREImageAttachmentPaste]; [MREPastedImage],
///    [MREAttachmentsController], [MREAttachmentStrip], [MREImageViewer],
///    [MREImagePasteScope], [MREClipboardImageReader].
library;

export 'src/attachments/ui/mre_attachment_strip.dart';
export 'src/attachments/model/mre_attachments_controller.dart';
export 'src/attachments/paste/mre_clipboard_image_reader.dart';
export 'src/attachments/paste/mre_image_paste_behavior.dart';
export 'src/attachments/paste/mre_image_paste_scope.dart';
export 'src/attachments/ui/mre_image_viewer.dart';
export 'src/attachments/model/mre_pasted_image.dart';
export 'src/text/direction/mre_auto_text.dart';
export 'src/text/field/mre_field_clear_button.dart';
export 'src/text/field/mre_safe_text_editing_controller.dart';
export 'src/text/field/mre_suggestion_bar.dart';
export 'src/text/field/mre_text_field.dart';
export 'src/text/direction/mre_text_extensions.dart';
export 'src/text/direction/mre_directional_widget.dart';
export 'src/text/direction/safe_display_text.dart';
export 'src/text/direction/text_direction.dart';
export 'src/theme/mre_fields_strings.dart';
export 'src/theme/mre_fields_theme.dart';
export 'src/theme/mre_window_size.dart';
