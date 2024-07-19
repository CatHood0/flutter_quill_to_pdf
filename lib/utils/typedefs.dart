import 'package:flutter_quill_delta_easy_parser/flutter_quill_delta_easy_parser.dart';
import 'package:pdf/widgets.dart' as pw;

typedef CustomPDFWidget = Future<pw.Widget> Function(Line matchedLine,
    [Map<String, dynamic>? blockAttributes]);
typedef PdfWidgetGenerator = pw.Widget Function(
    {required List<RegExpMatch> matches,
    required String input,
    required String lineWithoutFormatting});
typedef Predicate<T> = bool Function(T value);
