import 'package:pdf/pdf.dart' show PdfPageFormat;
import 'package:pdf/widgets.dart' as pw;

typedef PDFWidgetBuilder<T, W> = W Function(T data, Map<String, dynamic>? blockAttributes, [Object? extraArgs]);
typedef PDFLeadingWidget<W> = W Function(
  String type,
  int indentLevel,
  Object? extraArgs,
);

typedef PDFWidgetErrorBuilder<T, W, R> = W Function(T data, R alternativeData, [Object? extraArgs]);

typedef PageBuilder = pw.Page Function(List<pw.Widget>, pw.ThemeData theme, PdfPageFormat pageFormat);
