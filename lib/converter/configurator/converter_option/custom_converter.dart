import 'package:flutter_quill_to_pdf/utils/typedefs.dart';

class CustomConverter {
  final RegExp predicate;
  final WidgetGenerator callback;
  CustomConverter({
    required this.predicate,
    required this.callback,
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
