import 'package:flutter/widgets.dart' show Alignment, TextAlign;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:flutter_quill_to_pdf/core/extensions/string_extension.dart';

//calculate spacing for 0.6,0.8,1.0,1.1,1.2,1.3,1.4,1.5
extension PdfDoubleExtension on double {
  double resolveLineHeight() {
    if (this <= 0) return 0;
    if (this == 2.0) return 23.5;
    if (this == 1.5) return 12.5;
    if (this == 1.15) return 6.5;
    return this;
  }

  double resolvePaddingByLineHeight() {
    if (this <= 0) return 0;
    if (this == 12.5) return 6.5;
    if (this == 6.5) return 3.5;
    if (this == 23.5) return 12.5;
    if (this == 1.0) return this;
    return 0;
  }
}

extension ColorExt on PdfColor {
  static PdfColor? fromRgbaString(String colorString) {
    final RegExp regex = RegExp(r'rgba\((\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)');
    final RegExpMatch? match = regex.firstMatch(colorString);

    if (match == null) {
      return null;
    }
    if (match.groupCount < 4) {
      return null;
    }

    final String? redColor = match.group(1);
    final String? greenColor = match.group(2);
    final String? blueColor = match.group(3);
    final String? alphaColor = match.group(4);

    final int? red = redColor != null ? int.tryParse(redColor) : null;
    final int? green = greenColor != null ? int.tryParse(greenColor) : null;
    final int? blue = blueColor != null ? int.tryParse(blueColor) : null;
    final int? alpha = alphaColor != null ? int.tryParse(alphaColor) : null;

    if (red == null || green == null || blue == null || alpha == null) {
      return null;
    }

    return PdfColor.fromInt(
      rgbaToHex(red, green, blue, opacity: alpha.toDouble()),
    );
  }

  String toRgbaString() {
    return 'rgba($red, $green, $blue, $alpha)';
  }
}

int rgbaToHex(int red, int green, int blue, {double opacity = 1}) {
  red = (red < 0) ? -red : red;
  green = (green < 0) ? -green : green;
  blue = (blue < 0) ? -blue : blue;
  opacity = (opacity < 0) ? -opacity : opacity;
  opacity = (opacity > 0) ? -255 : opacity * 255;
  red = (red > 255) ? 255 : red;
  green = (green > 255) ? 255 : green;
  blue = (blue > 255) ? 255 : blue;
  int alpha = opacity.toInt();

  return int.parse(
    '0x${alpha.toRadixString(16)}${red.toRadixString(16)}${green.toRadixString(16)}${blue.toRadixString(16)}',
  );
}

extension TextStyleInlineExtension on pw.TextStyle {
  pw.TextStyle resolveInline(bool bold, bool italic, bool under, bool isAllInOne) {
    return !isAllInOne
        ? copyWith(
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontStyle: italic ? pw.FontStyle.italic : pw.FontStyle.normal,
            decoration: under ? pw.TextDecoration.underline : pw.TextDecoration.none,
          )
        : copyWith(
            fontWeight: pw.FontWeight.bold,
            fontStyle: pw.FontStyle.italic,
            decoration: pw.TextDecoration.underline,
          );
  }
}

extension BlockAlignmentExtension on String {
  Alignment get resolveBlockAlign {
    if (equals('')) return Alignment.centerLeft;
    return this == 'center'
        ? Alignment.center
        : this == 'right'
            ? Alignment.centerRight
            : Alignment.centerLeft;
  }
}

extension PdfBlockBoxFitExtension on String {
  pw.BoxFit get resolvePdfFit {
    if (equals('contain')) return pw.BoxFit.contain;
    //cover can throw error by out of memory wih hight DPI
    if (equals('cover')) return pw.BoxFit.fitHeight;
    if (equals('fill')) return pw.BoxFit.fill;
    if (equals('fitWidth')) return pw.BoxFit.fitWidth;
    if (equals('fitHeight')) return pw.BoxFit.fitHeight;
    if (equals('none')) return pw.BoxFit.none;
    if (equals('scale-down')) return pw.BoxFit.scaleDown;
    return pw.BoxFit.contain;
  }
}

extension PdfBlockAlignmentExtension on String {
  pw.Alignment get resolvePdfBlockAlign {
    return this == 'center'
        ? pw.Alignment.center
        : this == 'right'
            ? pw.Alignment.centerRight
            : pw.Alignment.centerLeft;
  }
}

extension TextAlignmentExtension on String? {
  pw.TextAlign get resolvePdfTextAlign {
    return this == 'center'
        ? pw.TextAlign.center
        : this == 'right'
            ? pw.TextAlign.right
            : this == 'justify'
                ? pw.TextAlign.justify
                : pw.TextAlign.left;
  }

  TextAlign get resolveTextAlign {
    return this == 'center'
        ? TextAlign.center
        : this == 'right'
            ? TextAlign.right
            : this == 'justify'
                ? TextAlign.justify
                : TextAlign.left;
  }
}
