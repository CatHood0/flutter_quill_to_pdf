import 'package:flutter_quill_to_pdf/utils/typedefs.dart';

enum TypeWidget {
  header, // attribute: header, scope: block
  alignedHeader, // attribute: header, align, scope: block
  paragraph, // attribute: bold, italic, underline, strike, color, background, etc. Scope: block
  alignParagrah, // attribute: inline attrs,  align, scope: block
  list, // attribute: list, scope: block
  indentParagraph, // attribute: indent, scope: block
  blockquote, // attribute: blockquote, scope: block
  codeblock, // attribute: codeblock, scope: block
}

enum Scope {
  inline,
  block,
}

///CustomConverter is used to match lines with a formatting and
///WidgetGenerator callback to create our custom pdf widgets implementation
class CustomConverter {
  final TypeWidget predicate;
  final Scope level;
  final PdfWidgetGenerator widgetCallback;
  CustomConverter({
    required this.predicate,
    required this.level,
    required this.widgetCallback,
  });

  @override
  bool operator ==(covariant CustomConverter other) {
    if (identical(this, other)) return true;

    return other.predicate == predicate && other.predicate == predicate && other.level == level;
  }

  @override
  int get hashCode => predicate.hashCode ^ predicate.hashCode ^ level.hashCode;

  @override
  String toString() => 'CustomDetector(detectorPattern: ${predicate.name}, Block-level: ${level.name})';
}
