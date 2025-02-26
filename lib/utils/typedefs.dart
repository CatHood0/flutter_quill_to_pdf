import 'package:pdf/pdf.dart' show PdfPageFormat;
import 'package:pdf/widgets.dart' as pw;

typedef PDFWidgetBuilder<T, W> = W Function(T spansToWrap, Map<String, dynamic>? blockAttributes);

typedef PDFWidgetErrorBuilder<T, W, R> = W Function(T data, R alternativeData);

typedef PageBuilder = pw.Page Function(List<pw.Widget>, pw.ThemeData theme, PdfPageFormat pageFormat);
