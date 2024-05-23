import 'package:quill_to_pdf/core/constant/constants.dart';

final StringBuffer _buffer = StringBuffer();

extension StringNullableExt on String? {
  String get withBrackets {
    return '[$this]';
  }

  String? replaceAllNewLinesWith(Object object) => this?.replaceAll('\n', '$object');

  bool equals(String other, {bool caseSensitive = true, Pattern? pattern}) {
    if (this == null) return false;
    if (!caseSensitive) return this?.toLowerCase() == other.toLowerCase();
    return pattern != null
        ? pattern is RegExp
            ? pattern.hasMatch(other)
            : pattern.allMatches(other).isNotEmpty
        : this == other;
  }
}

extension StringExtension on String {
  String get withBrackets {
    return '[$this]';
  }

  String capitalize() => isEmpty || length < 2 ? this : "${this[0].toUpperCase()}${substring(1)}";

  (String, int) capitalizeByIndex({int? startIndex, required int endIndex}) {
    _buffer.clear();
    int lastIndex = 0;
    int end = endIndex;
    for (int i = 0; i < endIndex; i++) {
      if (startIndex != null && i < startIndex) {
        _buffer.write(this[i]);
      }
      if (i < length || i >= endIndex) {
        _buffer.write(this[i].toUpperCase());
        lastIndex = i + 1;
        end--;
      }
    }
    return ('${_buffer..write(substring(lastIndex))}', end);
  }

  bool get isTotallyEmpty => replaceAll(RegExp(r'\s+'), '').replaceAll(RegExp('\\n|\n'), '').isEmpty;

  List<String> get splitBasedNewLine => split('\n');

  String get replaceAllNewLines => replaceAll('\n', '');
  String get rawnewLines => replaceAll('\n', r'\n');

  String replaceAllNewLinesWith(Object object) => replaceAll('\n', '$object');

  String get replaceAllSpaces => replaceAll(RegExp(r'\s*'), '');

  String get replaceHtmlBrToManyNewLines => replaceAll('<br>', '\n');

  String get replaceWhitespacesWithHyphen => replaceAll(r'\s+', '-');

  bool equals(String other, {bool caseSensitive = true, Pattern? pattern, bool useThisInstead = false}) {
    if (!caseSensitive) return toLowerCase() == other.toLowerCase();
    return pattern != null
        ? pattern is RegExp
            ? pattern.hasMatch(useThisInstead ? this : other)
            : pattern.allMatches(useThisInstead ? this : other).isNotEmpty
        : this == other;
  }

  String get convertWrongInlineStylesToSpans {
    return replaceAllMapped(RegExp(r'(<em\s*(style=".*?")>(.+?)<\/em>)'), (Match match) {
      final String? styles = match.group(2);
      final String? content = match.group(3);
      return '<span $styles><em>$content</em></span>';
    }).replaceAllMapped(RegExp(r'(<strong\s*(style=".*?")>(.+?)<\/strong>)'), (Match match) {
      final String? styles = match.group(2);
      final String? content = match.group(3);
      return '<span $styles><strong>$content</strong></span>';
    }).replaceAllMapped(RegExp(r'(<u\s*(style=".*?")>(.+?)<\/u>)'), (Match match) {
      final String? styles = match.group(2);
      final String? content = match.group(3);
      return '<span $styles><u>$content</u></span>';
    });
  }

  ///Encode the markdown inline styles (**,*,_) to another tags types, to avoid detection by the compiler
  //(is need, because if the user put _ in a word, it will be detected as underline instead of just a symbol)
  String get encodeSymbols {
    return replaceAll('#', Constant.ENCODED_MD_HEADER_SYMBOL)
        .replaceAll('"', Constant.ENCODED_QUOTE_SYMBOL)
        .replaceAll('}', Constant.ENCODED_KEY_SYMBOL_LEFT)
        .replaceAll('{', Constant.ENCODED_KEY_SYMBOL_RIGHT)
        .replaceAll(']', Constant.ENCODED_BRACKETS_SYMBOL_LEFT)
        .replaceAll('[', Constant.ENCODED_BRACKETS_SYMBOL_RIGHT)
        .replaceAll('***_', Constant.ENCODED_MD_ALL_SYMBOL_LEFT)
        .replaceAll('_***', Constant.ENCODED_MD_ALL_SYMBOL_RIGHT)
        .replaceAll('**_', Constant.ENCODED_MD_UNDERLINE_BOLD_SYMBOL_LEFT)
        .replaceAll('_**', Constant.ENCODED_MD_UNDERLINE_BOLD_SYMBOL_RIGHT)
        .replaceAll('*_', Constant.ENCODED_MD_UNDERLINE_ITALIC_LEFT)
        .replaceAll('_*', Constant.ENCODED_MD_UNDERLINE_ITALIC_RIGHT)
        .replaceAll('***', Constant.ENCODED_MD_BOLDITALIC_SYMBOL)
        .replaceAll('_', Constant.ENCODED_MD_UNDERLINE_SYMBOL)
        .replaceAll('**', Constant.ENCODED_MD_BOLD_SYMBOL)
        .replaceAll('*', Constant.ENCODED_MD_ITALIC_SYMBOL);
  }

  String get decodeSymbols {
    return replaceAll(Constant.ENCODED_MD_HEADER_SYMBOL, '#')
        .replaceAll(Constant.ENCODED_KEY_SYMBOL_LEFT, '}')
        .replaceAll(Constant.ENCODED_QUOTE_SYMBOL, '"')
        .replaceAll(Constant.ENCODED_KEY_SYMBOL_RIGHT, '{')
        .replaceAll(Constant.ENCODED_BRACKETS_SYMBOL_LEFT, ']')
        .replaceAll(Constant.ENCODED_BRACKETS_SYMBOL_RIGHT, '[')
        .replaceAll(Constant.ENCODED_MD_ALL_SYMBOL_LEFT, '***_')
        .replaceAll(Constant.ENCODED_MD_ALL_SYMBOL_RIGHT, '_***')
        .replaceAll(Constant.ENCODED_MD_UNDERLINE_BOLD_SYMBOL_LEFT, '**_')
        .replaceAll(Constant.ENCODED_MD_UNDERLINE_BOLD_SYMBOL_RIGHT, '_**')
        .replaceAll(Constant.ENCODED_MD_UNDERLINE_ITALIC_LEFT, '*_')
        .replaceAll(Constant.ENCODED_MD_UNDERLINE_ITALIC_RIGHT, '_*')
        .replaceAll(Constant.ENCODED_MD_BOLDITALIC_SYMBOL, '***')
        .replaceAll(Constant.ENCODED_MD_UNDERLINE_SYMBOL, '_')
        .replaceAll(Constant.ENCODED_MD_BOLD_SYMBOL, '**')
        .replaceAll(Constant.ENCODED_MD_ITALIC_SYMBOL, '*');
  }

  String get convertHTMLToMarkdown =>
      replaceAllMapped(RegExp(r'<strong>(?<bold>(?:(?!(<strong>|<\/strong>)).)+)<\/strong>'), (Match match) {
        return '**${match.group(1)!}**';
      }).replaceAllMapped(RegExp(r'<em>(?<italic>(?:(?!(<em>|<\/em>)).)+)<\/em>'), (Match match) {
        return '*${match.group(1)!}*';
      }).replaceAllMapped(RegExp(r'<u>(?<underline>(?:(?!(<u>|<\/u>)).)+)<\/u>'), (Match match) {
        return '_${match.group(1)!}_';
      }).replaceAllMapped(RegExp(r'<em><u>(?<italicunderline>(?:(?!(<em><u>|<\/u><\/em>)).)+)<\/u><\/em>'), (Match match) {
        return '*_${match.group(1)!}_*';
      }).replaceAllMapped(RegExp(r'<strong><u>(?<boldunderline>(?:(?!(<strong><u>|<\/u><\/strong>)).)+)<\/u><\/strong>'), (Match match) {
        return '**_${match.group(1)!}_**';
      }).replaceAllMapped(RegExp(r'<strong><em>(?<italicbold>(?:(?!(<strong><em>|<\/strong><\/em>)).)+)<\/em><\/strong>'), (Match match) {
        return '***${match.group(1)!}***';
      }).replaceAllMapped(
          RegExp(r'<strong><em><u>(?<bolditalicunderline>(?:(?!(<strong><em><u>|<\/u><\/em><\/strong>)).)+)<\/u><\/em><\/strong>'),
          (Match match) {
        return '***_${match.group(1)!}_***';
      }).replaceAllMapped(Constant.WRONG_IMAGE_MATCHING, (Match match) {
        final String styles = match.group(1)!;
        final String src = match.group(12)!;
        return '![$styles]($src)';
      });

  String get convertUTF8QuotesToValidString => replaceAll('&lt;', '<').replaceAll('&gt;', '>');
  String get recovertUTF8QuotesToHumanStringChars => replaceAll('<', '&lt;').replaceAll('>', '&gt;');

  String get fixCommonErrorInsertsInRawDelta => replaceAll('"}]{"', '"},{"')
      .replaceAll(RegExp(r'\}(,+)\{'), '},{')
      .replaceAll('}{', '},{')
      .replaceAll('},},{', '}},{')
      .replaceAll('}},]', '}}')
      .replaceAll(RegExp(r'\{"insert":"\\n"\}\}'), r'{"insert":"\n"}')
      .replaceAll(RegExp(r',"attributes":\{\}'), r'') //removes empty attributes
      .replaceAll(RegExp(r'\{"insert":""(,"attributes":\{\S+\}\})?(,)?'), '')
      .replaceAll(RegExp(r'"\}{1,2}\],\[\{{1,2}"insert"'), '"},{"insert"') //removes }],[{
      //deletes more from ( -> {"insert":"words"}}} <-)
      .replaceAll(RegExp(r'\}(\}+)$'), '}}')
      .replaceAll(RegExp(r'\}(\}+)(,+)$'), '}},')
      //deletes start and end issues with close []
      .replaceFirst(RegExp(r'\}(,+)\]$'), '}]')
      .replaceFirstMapped(
          RegExp(r'^\[(.+?)\]$', multiLine: true),
          (Match match) =>
              //removes []
              '${match.group(1)}')
      //deletes unnessary brackets in start and end
      .replaceFirst(RegExp('^(,+){'), '{') //deletes the first one like: ',{"insert":"word 1"}' -> '{"insert":"word 1"}'
      .replaceFirst(
          RegExp(
              r'\}(,+)$'), //deletes the last one like: '{"insert":"word 1"},{"insert":"final"},' -> {"insert":"word 1"},{"insert":"final"}'
          '}')
      .replaceFirst(RegExp(r'},$'), '}');
}
