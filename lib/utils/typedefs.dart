import 'package:pdf/widgets.dart' as pw;
import '../packages/vsc_quill_delta_to_html/src/delta_insert_op.dart';

typedef CustomRenderHtmlAttributes = String Function(DeltaInsertOp customOp, DeltaInsertOp? contextOp);
typedef CustomPDFWidget = Future<pw.Widget>
    Function(RegExp? regex, String matchedLine, [Object? extraAttribute]);
typedef PdfWidgetGenerator = pw.Widget Function(
    {required List<RegExpMatch> matches,
    required String input,
    required String lineWithoutFormatting});
typedef Predicate<T> = bool Function(T value);
//html converter
typedef CustomCssStylesFn = List<String>? Function(
    DeltaInsertOp op); //used just by HTMLConverterOptions
