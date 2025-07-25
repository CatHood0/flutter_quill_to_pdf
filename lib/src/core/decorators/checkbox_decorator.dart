import 'package:meta/meta.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

import '../../extensions/pdf_extension.dart';

/// This class determines how will look the leading
/// appearance
@immutable
class CheckboxDecorator {
  final BoxDecoration? decoration;
  final double width;
  final double height;
  final bool tristate;

  /// Determines the hex color of the checkbox
  final String color;

  /// Determines the color (in hex format) of the text and the strikethrough
  /// decoration of the element
  final String? strikethroughColor;

  /// Determines if the elements that are
  /// checked, will be forcely applying
  /// italic style
  final bool italicOnStrikethrough;

  static const String white = '#FFFFFF';

  const CheckboxDecorator({
    required this.width,
    required this.height,
    required this.decoration,
    required this.tristate,
    required this.color,
    this.strikethroughColor,
    this.italicOnStrikethrough = true,
  });

  const CheckboxDecorator.base({
    this.width = 13,
    this.height = 13,
    this.decoration,
    this.tristate = false,
    this.color = white,
    this.strikethroughColor,
    this.italicOnStrikethrough = true,
  });

  PdfColor get checkcolor => hexToColor(
        color,
      );

  PdfColor? get strikeColor => strikethroughColor == null
      ? null
      : hexToColor(
          strikethroughColor!,
        );
}
