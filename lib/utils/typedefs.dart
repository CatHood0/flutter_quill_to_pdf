//general actions
import 'package:pdf/widgets.dart' as pw;

import '../packages/vsc_quill_delta_to_html/src/delta_insert_op.dart';

typedef OptionalAction<R, T> = R Function(T obj);
typedef Path = String;
typedef CustomPDFWidget = Future<pw.Widget> Function(RegExp? regex, String matchedLine, [Object? extraAttribute]);
typedef WidgetGenerator = pw.Widget Function(
    {required List<RegExpMatch> matches, required String input, required String lineWithoutFormatting});
typedef Predicate<T> = bool Function(T value);
typedef MapEntryPredicate<K, V> = bool Function(K key, V? value);
//manager
//compiler definitions
typedef DocxStyles = Map<String, dynamic>;
typedef ReplacementsValues = Map<String, dynamic>;
//html converter
typedef CustomCssStylesFn = List<String>? Function(DeltaInsertOp op); //used just by HTMLConverterOptions
typedef Close<T extends Object?> = void Function(T object);
