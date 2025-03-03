class FontFamilyRequest {
  final String family;
  final bool isBold;
  final bool isItalic;
  final bool isUnderline;
  final bool isStrike;

  FontFamilyRequest({
    required this.family,
    this.isBold = false,
    this.isItalic = false,
    this.isUnderline = false,
    this.isStrike = false,
  });
}
