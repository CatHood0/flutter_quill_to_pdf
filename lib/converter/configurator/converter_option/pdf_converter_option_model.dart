class PDFConverterParams {
  final double marginTop;
  final double marginBottom;
  final double marginLeft;
  final double marginRight;
  final double marginAllPositions;
  final bool marginAll;
  final double height;
  final double width;
  const PDFConverterParams({
    this.marginTop = 0,
    this.marginBottom = 0,
    this.marginLeft = 0,
    this.marginRight = 0,
    this.marginAllPositions = 0,
    this.marginAll = false,
    required this.height,
    required this.width,
  });

  static const double point = 1.0;
  static const double inch = 72.0;
  static const double cm = inch / 2.54;
  static const double mm = inch / 25.4;

  static const PDFConverterParams a5 = PDFConverterParams(
    width: 14.8 * cm,
    height: 21.0 * cm,
    marginAll: true,
    marginAllPositions: 2.0 * cm,
  );
  static const PDFConverterParams a6 = PDFConverterParams(
    width: 105 * mm,
    height: 148 * mm,
    marginAll: true,
    marginAllPositions: 1.0 * cm,
  );
  static const PDFConverterParams letter = PDFConverterParams(
    width: 8.5 * inch,
    height: 11.0 * inch,
    marginAll: true,
    marginAllPositions: inch,
  );
  static const PDFConverterParams legal = PDFConverterParams(
    width: 8.5 * inch,
    height: 14.0 * inch,
    marginAll: true,
    marginAllPositions: inch,
  );
  static const PDFConverterParams a4 = PDFConverterParams(
    width: 21.0 * cm,
    height: 29.7 * cm,
    marginAll: true,
    marginAllPositions: 2.0 * cm,
  );
  static const PDFConverterParams a3 = PDFConverterParams(
    height: 42 * cm,
    width: 29.7 * cm,
    marginAll: true,
    marginAllPositions: 2.0 * cm,
  );

  @override
  String toString() {
    return 'PDFConverterParams(marginTop: $marginTop, marginBottom: $marginBottom, marginLeft: $marginLeft, marginRight: $marginRight, marginAllPositions: $marginAllPositions, marginAll: $marginAll, height: $height, width: $width)';
  }

  @override
  bool operator ==(covariant PDFConverterParams other) {
    if (identical(this, other)) return true;

    return other.marginTop == marginTop &&
        other.marginBottom == marginBottom &&
        other.marginLeft == marginLeft &&
        other.marginRight == marginRight &&
        other.marginAllPositions == marginAllPositions &&
        other.marginAll == marginAll &&
        other.height == height &&
        other.width == width;
  }

  @override
  int get hashCode {
    return marginTop.hashCode ^
        marginBottom.hashCode ^
        marginLeft.hashCode ^
        marginRight.hashCode ^
        marginAllPositions.hashCode ^
        marginAll.hashCode ^
        height.hashCode ^
        width.hashCode;
  }
}
