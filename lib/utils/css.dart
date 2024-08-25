/// Parses a CSS `<img>` style attribute string into Delta attributes.
///
/// Converts CSS styles (like 'width', 'height', 'margin') from [style]
/// into Quill Delta attributes suitable for image rich text formatting.
///
/// Parameters:
/// - [style]: The CSS style attribute string to parse.
///
/// Returns:
/// A map of Delta attributes derived from the CSS styles.
///
/// Example:
/// ```dart
/// final style = 'width: 50px; height: 250px;';
/// print(parseStyleAttribute(style)); // Output: {'width': '50px', 'height': '250px'}
/// ```
Map<String, dynamic> parseCssStyles(String? style, String align) {
  Map<String, dynamic> attributes = <String, dynamic>{};
  if (style == null || style.isEmpty) return attributes;

  final List<String> styles = style.split(';');
  for (String style in styles) {
    final List<String> parts = style.split(':');
    if (parts.length == 2) {
      final String key = parts[0].trim();
      final String value = parts[1].trim();

      switch (key) {
        case 'width':
          attributes['width'] = double.tryParse(value);
          break;
        case 'height':
          attributes['height'] = double.tryParse(value);
          break;
        case 'margin':
          attributes['margin'] = double.tryParse(value);
          break;
        default:
          // Ignore other styles
          break;
      }
    }
  }

  if (align.isNotEmpty) attributes['alignment'] = align;
  return attributes;
}
