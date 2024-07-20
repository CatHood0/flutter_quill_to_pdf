import 'package:flutter_quill_delta_easy_parser/flutter_quill_delta_easy_parser.dart';
import 'package:pdf/widgets.dart' as pw;

@Deprecated('CustomPDFWidget typedef is no longer used. Replace with PDFBlockWidgetBuilder')
typedef CustomPDFWidget = Future<pw.Widget> Function(RegExp? regex, String matchedLine, [Object? extraAttribute]);
@Deprecated('PdfWidgetGenerator is no longer used. Replace with PDFWidgetBuilder instead')
typedef PdfWidgetGenerator = pw.Widget Function({
  required List<RegExpMatch> matches,
  required String input,
  required String lineWithoutFormatting,
});
typedef PDFInlineWidgetBuilder = pw.Widget Function(Line line, Map<String, dynamic>? blockAttributes);
typedef PDFBlockWidgetBuilder = pw.Widget Function(
    List<pw.InlineSpan> spansToWrap, Map<String, dynamic>? blockAttributes);
