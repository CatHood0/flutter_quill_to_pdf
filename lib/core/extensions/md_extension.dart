import '../constant/constants.dart';

final RegExp STRONG_PATTERN = RegExp(r'\*\*(?<bold>(?:(?!\*\*).)+)\*\*'); // more precise bold detecting pattern
final RegExp ITALIC_PATTERN = RegExp(r'^(\*(?<italic>[^*]+)\*)$');
final RegExp ITALIC_AND_STRONG_PATTERN = RegExp(r'^(\*\*\*(?<boldItalic>(?:(?!\*\*\*).)+)\*\*\*)$');
final RegExp ITALIC_AND_STRONG_AND_UNDERLINE_AND_STRIKE_PATTERN =
    RegExp(r'^(\*\*\*~~\_(?<boldItalicStrikeUnderline>(?:(?!\_~~\*\*\*).)+)\_~~\*\*\*)$');
final RegExp ITALIC_AND_STRONG_AND_UNDERLINE_PATTERN = RegExp(r'^(\*\*\*\_(?<boldItalicUnderline>(?:(?!\_\*\*\*).)+)\_\*\*\*)$');
final RegExp UNDERLINE_WITH_OPTIONAL_STYLES_PATTERN = RegExp(r'^(\*\*)?(\*)?(\_)((?:(?!\_\*\*\*).)+)(\3)(\2)?(\1)?$');
final RegExp SRIKE_WITH_OPTIONAL_STYLES_PATTERN = RegExp(r'^(\*\*)?(\*)?(~~)(\_)?(.+)(\4)(~~)(\2)?(\1)?$');

///an extension used to detect inline markdown styles in plain text
extension MdInlineStringExtension on String {
  bool get isJustItalic {
    return ITALIC_PATTERN.hasMatch(this);
  }

  bool get isBold {
    return STRONG_PATTERN.hasMatch(this);
  }

  bool get isItalic {
    return ITALIC_PATTERN.hasMatch(this) || ITALIC_AND_STRONG_PATTERN.hasMatch(this);
  }

  bool get isItalicAndBoldInlineStylesCombined {
    return ITALIC_AND_STRONG_PATTERN.hasMatch(this);
  }

  bool get isUnderline {
    return UNDERLINE_WITH_OPTIONAL_STYLES_PATTERN.hasMatch(this);
  }

  bool get isStrike {
    return  SRIKE_WITH_OPTIONAL_STYLES_PATTERN.hasMatch(this);
  }

  bool get isUnderlineWithOtherStyles {
    return UNDERLINE_WITH_OPTIONAL_STYLES_PATTERN.hasMatch(this);
  }

  bool get isAllStylesCombined {
    return ITALIC_AND_STRONG_AND_UNDERLINE_PATTERN.hasMatch(this) || ITALIC_AND_STRONG_AND_UNDERLINE_AND_STRIKE_PATTERN.hasMatch(this);
  }

  ///Remove markdown inlines styles. Like: **bold** -> bold
  String get replaceMd {
    return replaceAllMapped(STRONG_PATTERN, (Match match) {
      final String contentWithoutStrong = match.group(1)!;
      return contentWithoutStrong;
    }).replaceAllMapped(ITALIC_PATTERN, (Match match) {
      final String contentWithoutItalic = match.group(1)!;
      return contentWithoutItalic;
    }).replaceAllMapped(UNDERLINE_WITH_OPTIONAL_STYLES_PATTERN, (Match match) {
      final String contentWithoutUnderline = match.group(4)!;
      return contentWithoutUnderline;
    }).replaceAllMapped(SRIKE_WITH_OPTIONAL_STYLES_PATTERN, (Match match) {
      final String contentWithoutStrike = match.group(5)!;
      return contentWithoutStrike;
    });
  }
}

extension MdHeaderLevelExtension on String {
  double resolveHeaderLevel({List<double> headingSizes = Constant.default_heading_size}) {
    return this == '#' || this == '1'
        ? headingSizes[0]
        : this == '##' || this == '2'
            ? headingSizes[1]
            : this == '###' || this == '3'
                ? headingSizes[2]
                : this == '####' || this == '4'
                    ? headingSizes[3]
                    : headingSizes[4];
  }
}
