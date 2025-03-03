import 'dart:ui';
import 'package:pdf/widgets.dart' as pw;

extension MaterialDirectionToPdfDirection on TextDirection {
  pw.TextDirection toPdf() {
    return this == TextDirection.rtl
        ? pw.TextDirection.rtl
        : pw.TextDirection.ltr;
  }
}
