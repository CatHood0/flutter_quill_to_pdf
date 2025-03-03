
import 'package:flutter_quill_to_pdf/src/extensions/string_extension.dart';

///Contains all custom properties that we want in our delta
///Use this with together delta processor to add properties more easily without format all delta
@Deprecated('DeltaAttributesOptions is no longer used, and will be removed in future releases.')
class DeltaAttributesOptions {
  //inline
  double fontSize;
  bool bold;
  bool italic;
  bool underline;
  double? lineSpacing;
  String fontFamily;
  //block
  String? align;
  bool strikethrough;
  String? link; //url
  int? hexColor;
  int? hexBackgroundColor;
  int indent;

  DeltaAttributesOptions({
    required this.fontSize,
    required this.bold,
    required this.italic,
    required this.underline,
    required this.lineSpacing,
    required this.strikethrough,
    required this.align,
    this.fontFamily = "Arial",
    this.hexColor,
    this.hexBackgroundColor,
    this.link,
    this.indent = -1,
  })  : assert(indent == -1 || (indent > 0 && indent <= 4)),
        assert(align == null ||
            (align.equals('left') ||
                align.equals('right') ||
                align.equals('center') ||
                align.equals('justify')));

  factory DeltaAttributesOptions.common({
    bool? bold,
    bool? italic,
    bool? underline,
    bool? automaticIndent,
    int? hexColor,
    int? hexBackgroundColor,
    String? rgbBackground,
    String? fontFamily,
    String? align,
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
      lineSpacing: lineSpacing,
      fontFamily: fontFamily ?? 'Arial',
      fontSize: fontSize ?? 12,
      hexColor: hexColor,
      hexBackgroundColor: hexBackgroundColor,
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
    int? hexColor,
    int? hexBackgroundColor,
    double? lineSpacing,
    bool? strikethrough,
    String? link,
    String? align,
    int? indent,
  }) {
    return DeltaAttributesOptions(
      fontSize: fontSize ?? this.fontSize,
      strikethrough: strikethrough ?? this.strikethrough,
      indent: indent ?? this.indent,
      bold: bold ?? this.bold,
      italic: italic ?? this.italic,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      hexBackgroundColor: hexBackgroundColor ?? this.hexBackgroundColor,
      underline: underline ?? this.underline,
      fontFamily: fontFamily ?? this.fontFamily,
      hexColor: hexColor ?? this.hexColor,
      align: align ?? this.align,
    );
  }
}
