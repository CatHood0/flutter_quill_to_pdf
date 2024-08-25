import 'package:flutter_quill_delta_easy_parser/flutter_quill_delta_easy_parser.dart';
import 'package:flutter_quill_to_pdf/utils/typedefs.dart';
import 'package:pdf/widgets.dart' as pw;

/// [CustomWidget] is used to match lines with a formatting and
class CustomWidget {
  final bool Function(Paragraph paragraph) predicate;
  final PDFWidgetBuilder<Paragraph, pw.Widget> widgetCallback;
  CustomWidget({
    required this.predicate,
    required this.widgetCallback,
  });
}
