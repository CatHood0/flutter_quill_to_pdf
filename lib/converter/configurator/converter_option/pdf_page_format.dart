///PDFPageFormat is a default implementation to decide all the properties for the pdf document
///[width, height and margins]
class PDFPageFormat {
  final double marginTop;
  final double marginBottom;
  final double marginLeft;
  final double marginRight;
  final double height;
  final double width;
  const PDFPageFormat({
    required this.marginTop,
    required this.marginBottom,
    required this.marginLeft,
    required this.marginRight,
    required this.height,
    required this.width,
  });

  factory PDFPageFormat.all(
      {required double width, required double height, double margin = 0}) {
    return PDFPageFormat(
      marginTop: margin,
      marginBottom: margin,
      marginLeft: margin,
      marginRight: margin,
      height: height,
      width: width,
    );
  }

  static const double point = 1.0;
  static const double inch = 72.0;
  static const double cm = inch / 2.54;
  static const double mm = inch / 25.4;

  static final PDFPageFormat a5 = PDFPageFormat.all(
    width: 14.8 * cm,
    height: 21.0 * cm,
    margin: 2.0 * cm,
  );
  static final PDFPageFormat a6 = PDFPageFormat.all(
    width: 105 * mm,
    height: 148 * mm,
    margin: 1.0 * cm,
  );
  static final PDFPageFormat letter = PDFPageFormat.all(
    width: 8.5 * inch,
    height: 11.0 * inch,
    margin: inch,
  );
  static final PDFPageFormat legal = PDFPageFormat.all(
    width: 8.5 * inch,
    height: 14.0 * inch,
    margin: inch,
  );
  static final PDFPageFormat a4 = PDFPageFormat.all(
    width: 21.0 * cm,
    height: 29.7 * cm,
    margin: 2.0 * cm,
  );
  static final PDFPageFormat a3 = PDFPageFormat.all(
    height: 42 * cm,
    width: 29.7 * cm,
    margin: 2.0 * cm,
  );

  @override
  String toString() {
    return 'PDFPageFormat(marginTop: $marginTop, marginBottom: $marginBottom, marginLeft: $marginLeft, marginRight: $marginRight, height: $height, width: $width)';
  }

  @override
  bool operator ==(covariant PDFPageFormat other) {
    if (identical(this, other)) return true;

    return other.marginTop == marginTop &&
        other.marginBottom == marginBottom &&
        other.marginLeft == marginLeft &&
        other.marginRight == marginRight &&
        other.height == height &&
        other.width == width;
  }

  @override
  int get hashCode {
    return marginTop.hashCode ^
        marginBottom.hashCode ^
        marginLeft.hashCode ^
        marginRight.hashCode ^
        height.hashCode ^
        width.hashCode;
  }
}
