import 'package:flutter_quill_to_pdf/core/extensions/string_extension.dart';

import '../constant/constants.dart';

final RegExp STRONG_PATTERN = RegExp(r'\*\*(?<bold>(?:(?!\*\*).)+)\*\*'); // more precise bold detecting pattern
final RegExp ITALIC_PATTERN = RegExp(r'^(\*(?<italic>[^*]+)\*)$');
final RegExp ITALIC_AND_STRONG_PATTERN = RegExp(r'^(\*\*\*(?<boldItalic>(?:(?!\*\*\*).)+)\*\*\*)$');
final RegExp ITALIC_AND_STRONG_AND_UNDERLINE_PATTERN = RegExp(r'^(\*\*\*\_(?<boldItalicUnderline>(?:(?!\_\*\*\*).)+)\_\*\*\*)$');
final RegExp UNDERLINE_WITH_OPTIONAL_STYLES_PATTERN = RegExp(r'^(\*\*)?(\*)?\_((?:(?!\_\*\*\*).)+)\_(\2)?(\1)?$');

// for commit
// [Fix] issues related with matches about abstract and non absolute patterns
// [Feat] patterns with better matches instead of .startWith or .endWith functions
// [Fix] improvements in replaceMarkdownTags (before removes unnecessary tags from the editor)
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

  bool get isBothInlineStylesCombined {
    return ITALIC_AND_STRONG_PATTERN.hasMatch(this);
  }

  bool get isUnderline {
    return UNDERLINE_WITH_OPTIONAL_STYLES_PATTERN.hasMatch(this);
  }

  bool get isUnderlineWithOtherStyles {
    return UNDERLINE_WITH_OPTIONAL_STYLES_PATTERN.hasMatch(this);
  }

  bool get isAllStylesCombined {
    return ITALIC_AND_STRONG_AND_UNDERLINE_PATTERN.hasMatch(this);
  }

  String get replaceMd {
    return replaceAllMapped(STRONG_PATTERN, (Match match) {
      final String contentWithoutStrong = match.group(1)!;
      return contentWithoutStrong;
    }).replaceAllMapped(ITALIC_PATTERN, (Match match) {
      final String contentWithoutItalic = match.group(1)!;
      return contentWithoutItalic;
    }).replaceAllMapped(UNDERLINE_WITH_OPTIONAL_STYLES_PATTERN, (Match match) {
      final String contentWithoutUnderline = match.group(3)!;
      return contentWithoutUnderline;
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

  double? resolveSize() {
    return equals('small')
        ? 12
        : equals('large')
            ? 19.5
            : equals('huge')
                ? 22.5
                : equals('subtitle')
                    ? 24.5
                    : equals('title')
                        ? 26
                        : double.tryParse(this);
  }
}
