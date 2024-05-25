import 'package:flutter/widgets.dart' show Alignment;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_quill_to_pdf/core/extensions/string_extension.dart';

extension PdfDoubleExtension on double {
  ///Calculate based on the the current value to return the more similar line height
  ///as should see on a PDF (and like Docx, libreoffice formatting too)
  double resolveLineHeight() {
    if (this <= 0) return 0;
    if (this == 2.0) return 23.5;
    if (this == 1.5) return 12.5;
    if (this == 1.15) return 6.5;
    return this;
  }

  ///Calculate based on the current value to return the padding
  ///at the last of the line since pdf package
  ///rich text, on param of lineSpacing
  ///doesn't have effect at the top or botton of the line
  double resolvePaddingByLineHeight() {
    if (this <= 0) return 0;
    if (this == 12.5) return 6.5;
    if (this == 6.5) return 3.5;
    if (this == 23.5) return 12.5;
    if (this == 1.0) return this;
    return 0;
  }
}

PdfColor? pdfColorString(String? colorString) {
  if (colorString == null || colorString.isTotallyEmpty) return null;
  if (colorString.startsWith('#')) {
    return PdfColor.fromHex(colorString);
  }
  if (colorString.startsWith('0x')) {
    return PdfColor.fromInt(int.parse(colorString));
  }
  final RegExp regex = RegExp(r'rgb\((\d+)\s*?,\s*?(\d+)\s*?,\s*?(\d+)\s*?(,?\s*?(\d+)\s*?)\)');
  final RegExpMatch? match = regex.firstMatch(colorString);
  if (match == null) {
    return null;
  }
  if (match.groupCount < 3) {
    return null;
  }

  final String? redColor = match.group(1);
  final String? greenColor = match.group(2);
  final String? blueColor = match.group(3);
  final String? alphaColor = match.group(5);

  final int? red = redColor != null ? int.tryParse(redColor) : null;
  final int? green = greenColor != null ? int.tryParse(greenColor) : null;
  final int? blue = blueColor != null ? int.tryParse(blueColor) : null;
  final int alpha = int.tryParse(alphaColor ?? 'null') ?? 1;

  if (red == null || green == null || blue == null) {
    return null;
  }

  return PdfColor.fromInt(
    rgbaToHex(red, green, blue, opacity: alpha.toDouble()),
  );
}

int rgbaToHex(int red, int green, int blue, {double opacity = 1}) {
  red = (red < 0) ? -red : red;
  green = (green < 0) ? -green : green;
  blue = (blue < 0) ? -blue : blue;
  opacity = (opacity < 0) ? -opacity : opacity;
  opacity = (opacity > 0) ? 255 : opacity * 255;
  red = (red > 255) ? 255 : red;
  green = (green > 255) ? 255 : green;
  blue = (blue > 255) ? 255 : blue;
  int alpha = opacity.toInt();
  final hex = '0x${alpha.toRadixString(16)}${red.toRadixString(16)}${green.toRadixString(16)}${blue.toRadixString(16)}';
  return int.parse(hex.replaceFirst('-', ''));
}

///A extesion to resolve more easily to decide the style of the spans
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

///A simple resolver to make more readable decide the align to a paragraph
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

///Pdf image resolve to boxfit images at a type
///Some conditions return different boxfit from the compare
///since that boxfit cam generate conflicts or crash the app
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
}
