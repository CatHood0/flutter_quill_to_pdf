import 'package:flutter_quill_to_pdf/core/extensions/string_extension.dart';

///Contains all custom properties that we want in our delta
///Use this with together delta processor to add properties more easily without format all delta
class DeltaAttributesOptions {
  //inline
  double fontSize;
  bool bold;
  bool italic;
  bool underline;
  double lineSpacing;
  String fontFamily;
  //block
  String? align;
  ///[Not supported yet]
  bool strikethrough;
  String? link; //url
  String? rgbColor;
  int indent;
  String? image; //bytes or url
  int? levelHeader;

  DeltaAttributesOptions({
    required this.fontSize,
    required this.bold,
    required this.italic,
    required this.underline,
    required this.lineSpacing,
    required this.strikethrough,
    required this.align,
    required this.levelHeader,
    this.fontFamily = "Arial",
    this.rgbColor,
    this.link,
    this.indent = -1,
    this.image,
  })  : assert(lineSpacing <= 2.0 && lineSpacing >= 1.0),
        assert(indent == -1 || (indent > 0 && indent <= 4)),
        assert(align == null || (align.equals('left') || align.equals('right') || align.equals('center') || align.equals('justify')));

  factory DeltaAttributesOptions.common({
    bool? bold,
    bool? italic,
    bool? underline,
    bool? automaticIndent,
    int? levelHeader,
    String? rgbColor,
    String? rgbBackground,
    String? fontFamily,
    String? align,
    String? image,
    double? lineSpacing,
    double? fontSize,
  }) {
    return DeltaAttributesOptions(
      align: align ?? "left",
      bold: bold ?? false,
      italic: italic ?? false,
      strikethrough: false,
      indent: -1,
      link: null,
      levelHeader: levelHeader ?? 0,
      image: image,
      lineSpacing: lineSpacing ?? 1.0,
      fontFamily: fontFamily ?? 'Arial',
      fontSize: fontSize ?? 12,
      rgbColor: rgbColor,
      underline: underline ?? false,
    );
  }

  DeltaAttributesOptions copyWith({
    double? fontSize,
    bool? bold,
    bool? italic,
    bool? underline,
    bool? automaticIndent,
    String? fontFamily,
    String? rgbColor,
    String? image,
    double? lineSpacing,
    bool? strikethrough,
    String? link,
    String? align,
    int? indent,
    int? levelHeader,
  }) {
    return DeltaAttributesOptions(
      fontSize: fontSize ?? this.fontSize,
      strikethrough: strikethrough ?? this.strikethrough,
      indent: indent ?? this.indent,
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      underline: underline ?? this.underline,
      fontFamily: fontFamily ?? this.fontFamily,
      rgbColor: rgbColor ?? this.rgbColor,
      image: image ?? this.image,
      align: align ?? this.align,
      levelHeader: levelHeader ?? this.levelHeader,
    );
  }

  @override
  String toString() {
    return 'DeltaAttributesOptions(line_spacing: $lineSpacing, fontSize: $fontSize, bold: $bold, italic: $italic, underline: $underline, fontFamily: $fontFamily, rgbColor: $rgbColor, image: $image, align: $align, levelHeader: $levelHeader)';
  }
}
