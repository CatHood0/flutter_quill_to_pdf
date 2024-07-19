extension StringNullableExt on String? {
  String get withBrackets {
    return '[$this]';
  }

  ///Equals is a similar function that use Java or Kotlin
  ///classes to see the equality from two objects
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

  bool get isTotallyEmpty =>
      replaceAll(RegExp(r'\s+'), '').replaceAll(RegExp('\\n|\n'), '').isEmpty;

  bool equals(String other,
      {bool caseSensitive = true,
      Pattern? pattern,
      bool useThisInstead = false}) {
    if (!caseSensitive) return toLowerCase() == other.toLowerCase();
    return pattern != null
        ? pattern is RegExp
            ? pattern.hasMatch(useThisInstead ? this : other)
            : pattern.allMatches(useThisInstead ? this : other).isNotEmpty
        : this == other;
  }

  ///Used to solved common errors in raw delta strings, since we don't used delta literals
  String get fixCommonErrorInsertsInRawDelta => replaceAll('"}]{"', '"},{"')
      .replaceAll(RegExp(r'\}(,+)\{'), '},{')
      .replaceAll('}{', '},{')
      .replaceAll('},},{', '}},{')
      .replaceAll('}},]', '}}')
      .replaceAll(RegExp(r'\{"insert":"\\n"\}\}'), r'{"insert":"\n"}')
      .replaceAll(RegExp(r',"attributes":\{\}'), r'') //removes empty attributes
      .replaceAll(RegExp(r'\{"insert":""(,"attributes":\{\S+\}\})?(,)?'), '')
      .replaceAll(RegExp(r'"\}{1,2}\],\[\{{1,2}"insert"'),
          '"},{"insert"') //removes }],[{
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
      .replaceFirst(RegExp('^(,+){'),
          '{') //deletes the first one like: ',{"insert":"word 1"}' -> '{"insert":"word 1"}'
      .replaceFirst(
          RegExp(
              r'\}(,+)$'), //deletes the last one like: '{"insert":"word 1"},{"insert":"final"},' -> {"insert":"word 1"},{"insert":"final"}'
          '}')
      .replaceFirst(RegExp(r'},$'), '}');
}
