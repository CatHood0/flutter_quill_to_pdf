import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_quill_to_pdf/src/extensions/string_extension.dart';

extension PdfDoubleExtension on double {
  /// Calculate based on the the current value to return the more similar line height
  /// as should see on a PDF (and like Docx, libreoffice formatting too)
  ///
  /// _This is the default implementation and should not be used outside_
  double resolveLineHeight() {
    if (this <= 0) return 0;
    if (this == 2.0) return 23.5;
    if (this == 1.5) return 12.5;
    if (this == 1.15) return 6.5;
    if (this == 1.0) return 3.5;
    return this;
  }

  /// Calculate based on the current value to return the padding
  /// at the last of the line since pdf package
  /// rich text, on param of lineSpacing
  /// doesn't have effect at the top or botton of the line
  ///
  /// _This is the default implementation and should not be used outside_
  double resolvePaddingByLineHeight() {
    if (this <= 0) return 0;
    if (this == 12.5) return 6.5;
    if (this == 6.5) return 3.5;
    if (this == 23.5) return 12.5;
    if (this == 3.5) return 1.5;
    return 0;
  }
}

PdfColor hexToColor(String hexString) {
  final String hex = hexString.replaceAll('#', '');

  // Parse the hex string to an integer and add alpha if missing
  final int color = int.parse(
    hex,
    radix: 16,
  );

  return PdfColor.fromInt(color);
}

final RegExp _kDefaultRGBRegex = RegExp(
  r'rgb\((\d+)\s*?,\s*?(\d+)\s*?,\s*?(\d+)\s*?(,?\s*?(\d+)\s*?)\)',
);

PdfColor? pdfColorString(String? colorString) {
  if (colorString == null ||
      colorString
          .replaceAll(RegExp(r'\s+'), '')
          .replaceAll(
            RegExp('\\n|\n'),
            '',
          )
          .isEmpty) {
    return null;
  }
  if (colorString.startsWith('#')) {
    return hexToColor(colorString);
  }
  if (colorString.startsWith('0x')) {
    return PdfColor.fromInt(int.parse(colorString));
  }
  final RegExpMatch? match = _kDefaultRGBRegex.firstMatch(colorString);
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
  final String hex =
      '0x${alpha.toRadixString(16)}${red.toRadixString(16)}${green.toRadixString(16)}${blue.toRadixString(16)}';
  return int.parse(hex.replaceFirst('-', ''));
}

///A extesion to resolve more easily to decide the style of the spans
extension TextStyleInlineExtension on pw.TextStyle {
  pw.TextStyle resolveInline(
      bool bold, bool italic, bool under, bool strike, bool isAllInOne) {
    pw.TextDecoration? decoration = null;
    if (under && strike) {
      decoration = pw.TextDecoration.combine(
        <pw.TextDecoration>[
          pw.TextDecoration.lineThrough,
          pw.TextDecoration.underline,
        ],
      );
    } else if (strike) {
      decoration = pw.TextDecoration.lineThrough;
    } else if (under) {
      decoration = pw.TextDecoration.underline;
    }

    return !isAllInOne
        ? copyWith(
            fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            fontStyle: italic ? pw.FontStyle.italic : pw.FontStyle.normal,
            decoration: decoration,
          )
        : copyWith(
            fontWeight: pw.FontWeight.bold,
            fontStyle: pw.FontStyle.italic,
            decoration: decoration,
          );
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
  pw.AlignmentDirectional get resolvePdfBlockAlign {
    return this == 'center'
        ? pw.AlignmentDirectional.center
        : this == 'right'
            ? pw.AlignmentDirectional.centerEnd
            : pw.AlignmentDirectional.centerStart;
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

extension TextAlignmentExtensionReverse on pw.TextAlign? {
  pw.TextAlign get reversed {
    return this == pw.TextAlign.center
        ? pw.TextAlign.center
        : this == pw.TextAlign.right
            ? pw.TextAlign.left
            : this == pw.TextAlign.justify
                ? pw.TextAlign.justify
                : pw.TextAlign.right;
  }
}
