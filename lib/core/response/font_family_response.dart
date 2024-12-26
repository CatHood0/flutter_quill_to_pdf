import 'package:pdf/widgets.dart' as pw;

class FontFamilyResponse {
  final pw.Font? boldFontV;
  final pw.Font fontNormalV;
  final pw.Font? italicFontV;
  final pw.Font? boldItalicFontV;
  final List<pw.Font> fallbacks;

  FontFamilyResponse({
    required this.fontNormalV,
    this.boldFontV,
    this.italicFontV,
    this.boldItalicFontV,
    this.fallbacks = const <pw.Font>[],
  });

  factory FontFamilyResponse.helvetica() {
    return FontFamilyResponse(
      fontNormalV: pw.Font.helvetica(),
      boldFontV: null,
      italicFontV: null,
      boldItalicFontV: null,
      fallbacks: const <pw.Font>[],
    );
  }
}
