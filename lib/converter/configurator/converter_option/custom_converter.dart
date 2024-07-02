import 'package:flutter_quill_to_pdf/utils/typedefs.dart';

///CustomConverter is used to match lines with a formatting using custom regex and
///WidgetGenerator callback to create our custom pdf widgets implementation
class CustomConverter {
  final RegExp predicate;
  final PdfWidgetGenerator widgetCallback;
  CustomConverter({
    required this.predicate,
    required this.widgetCallback,
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
