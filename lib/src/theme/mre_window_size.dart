/// Width class of the space a field has available.
///
/// Fields choose layout and density from this value, never from the platform.
/// See [MREFieldsTheme.windowSizeFor].
///
/// {@category Theme}
enum MREWindowSize {
  /// Narrow space, such as a phone in portrait.
  compact,

  /// Mid-width space, such as a large phone or a small tablet.
  medium,

  /// Wide space, such as a tablet in landscape or a desktop window.
  expanded,
}
