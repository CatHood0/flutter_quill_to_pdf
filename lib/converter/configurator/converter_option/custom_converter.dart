import 'package:flutter_quill_to_pdf/utils/typedefs.dart';

enum TypeWidget {
  header, // attribute: header, scope: block
  alignedHeader, // attribute: header, align, scope: block
  paragraph, // attribute: bold, italic, underline, strike, color, background, etc. Scope: inline
  alignParagrah, // attribute: inline attrs,  align, scope: block
  list, // attribute: list, scope: block
  indentParagraph, // attribute: indent, scope: block
  blockquote, // attribute: blockquote, scope: block
  codeblock, // attribute: codeblock, scope: block
  lineHeight,
}

enum Scope {
  inline,
  block,
}

/// [CustomWidget] is used to match lines with a formatting and
///
/// Params:
///      [Scope] limite where must be on blockGenerator this class
///      [PDFInlineWidgetBuilder] callback to create our custom pdf widgets (limited to inlines)
///      [PDFBlockWidgetBuilder] callback to create ouw custom pdf widgets (limited to block)
///
/// The Scope limit where be usage [PDFInlineWidgetBuilder] or [PDFBlockWidgetBuilder]
///
class CustomWidget {
  final TypeWidget predicate;
  final Scope level;
  final PDFInlineWidgetBuilder? inlineWidgetCallback;
  final PDFBlockWidgetBuilder? blockWidgetCallback;
  CustomWidget({
    required this.predicate,
    required this.level,
    this.inlineWidgetCallback,
    this.blockWidgetCallback,
  }) : assert(
          inlineWidgetCallback != null || blockWidgetCallback != null,
          "Both PDFWidgetBuilders cannot be null. One of them must be defined",
        );

  @override
  bool operator ==(covariant CustomWidget other) {
    if (identical(this, other)) return true;

    return other.predicate == predicate && other.predicate == predicate && other.level == level;
  }

  @override
  int get hashCode => predicate.hashCode ^ predicate.hashCode ^ level.hashCode;

  @override
  String toString() => 'CustomDetector(detectorPattern: ${predicate.name}, Block-level: ${level.name})';
}

///CustomConverter is used to match lines with a formatting using custom regex and
///WidgetGenerator callback to create our custom pdf widgets implementation
@Deprecated('CustomConverter is no longer used. Replace with CustomPdfWidget instead')
class CustomConverter {
  final RegExp predicate;
  final PdfWidgetGenerator callback;
  CustomConverter({
    required this.predicate,
    required this.callback,
  });

  @override
  bool operator ==(covariant CustomConverter other) {
    if (identical(this, other)) return true;

    return other.predicate == predicate && other.predicate == predicate;
  }

  @override
  int get hashCode => predicate.hashCode ^ predicate.hashCode;

  @override
  String toString() => 'CustomDetector(detectorPattern: $predicate';
}
