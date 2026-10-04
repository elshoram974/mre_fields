/// Flutter ordinary and form fields with Unicode-wide direction, checking phone
/// numbers for every country, and accept pasted images.
///
/// Fields use the colors and fonts of your `ThemeData`. Add the field-only
/// values with [MREFieldsTheme]:
///
/// {@example /doc/snippets/theme.dart#global}
///
/// Every rule is also a plain function or class, so you can use it without any
/// widget on screen: see the functions guide in the repository (`doc/functions.md`).
///
/// ## Guides
///
/// Each guide has runnable examples:
///
///  * [Theme](https://github.com/elshoram974/mre_fields/blob/main/doc/theme.md):
///    one place to set radius, padding and texts, dark mode, translation.
///  * [Text direction](https://github.com/elshoram974/mre_fields/blob/main/doc/text.md):
///    how the direction is chosen, `MREAutoText`, extensions.
///  * [Text field](https://github.com/elshoram974/mre_fields/blob/main/doc/text_field.md):
///    `MRETextField`, validation, suggestions, controllers.
///  * [Image paste](https://github.com/elshoram974/mre_fields/blob/main/doc/attachments.md):
///    behaviours, limits, where images come from.
///  * [Phone](https://github.com/elshoram974/mre_fields/blob/main/doc/phone.md):
///    `MREPhoneField`, country selection, validation for every country.
///  * [Functions](https://github.com/elshoram974/mre_fields/blob/main/doc/functions.md):
///    every rule without a widget.
///
/// ## Topics
///
///  * **Theme**: [MREFieldsTheme], [MREFieldsStrings], [MREWindowSize].
///  * **Text**: [detectTextDirection], [detectStrongTextDirection],
///    [MREAutoText], [MREAutoDirectionText], [MRETextDirection],
///    [MREDirectionalWidget], [safeDisplayText].
///  * **Fields**: [MRETextField], [MRETextFormField], [MRESuggestionBar], [MREFieldClearButton],
///    [MRESafeTextEditingController], [mreFilterSuggestions].
///  * **Phone**: [MREPhoneField], [MREPhoneFormField], [MREPhoneController], [MREPhoneNumber],
///    [MREPhoneError], [MREPhoneValidators], [MRECountrySelection],
///    [MRECountry], [MRECountries], [showMRECountryPicker],
///    [MRECountryPickerBody], [MREPhoneInputFormatter].
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
export 'src/phone/field/mre_phone_controller.dart';
export 'src/phone/field/mre_phone_field.dart';
export 'src/phone/model/mre_country.dart';
export 'src/phone/model/mre_country_selection.dart';
export 'src/phone/model/mre_phone_digits.dart';
export 'src/phone/model/mre_phone_number.dart';
export 'src/phone/picker/mre_country_picker.dart';
export 'src/phone/picker/mre_country_picker_body.dart';
export 'src/phone/validation/mre_phone_validators.dart';
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

export 'src/text/field/mre_text_form_field.dart';
export 'src/phone/field/mre_phone_form_field.dart';
