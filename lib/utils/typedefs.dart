import 'package:pdf/widgets.dart' as pw;

@Deprecated('CustomPDFWidget typedef is no longer used. Replace with PDFBlockWidgetBuilder')
typedef CustomPDFWidget = Future<pw.Widget> Function(RegExp? regex, String matchedLine, [Object? extraAttribute]);
@Deprecated('PdfWidgetGenerator is no longer used. Replace with PDFWidgetBuilder instead')
typedef PdfWidgetGenerator = pw.Widget Function({
  required List<RegExpMatch> matches,
  required String input,
  required String lineWithoutFormatting,
});
typedef PDFWidgetBuilder<T> = pw.Widget Function(T spansToWrap, Map<String, dynamic>? blockAttributes);
