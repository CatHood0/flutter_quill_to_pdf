import 'package:flutter_quill_delta_easy_parser/flutter_quill_delta_easy_parser.dart';
import 'package:pdf/widgets.dart' as pw;

typedef CustomPDFWidget = Future<pw.Widget> Function(
  List<pw.InlineSpan> spansToWrap, [
  Map<String, dynamic>? blockAttributes,
]);
typedef PdfWidgetGenerator = pw.Widget Function(Line line, Map<String,dynamic>? blockAttributes);
typedef Predicate<T> = bool Function(T value);
