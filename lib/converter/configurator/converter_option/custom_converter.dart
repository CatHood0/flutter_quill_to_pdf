import 'package:flutter_quill_to_pdf/utils/typedefs.dart';

enum Scope {
  block,
  inline,
}

/// [CustomWidget] is used to match lines with a formatting and
class CustomWidget<T, B> {
  final bool Function(T t) predicate;
  final Scope scope;
  final PDFWidgetBuilder<B>? widgetCallback;
  CustomWidget({
    required this.predicate,
    required this.scope,
    required this.widgetCallback,
  }); 
}

///CustomConverter is used to match lines with a formatting using custom regex and
///WidgetGenerator callback to create our custom pdf widgets implementation
@Deprecated('CustomConverter is no longer used. Replace with CustomPdfWidget instead')
class CustomConverter {
  final RegExp predicate;
  final PdfWidgetGenerator callback;
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
