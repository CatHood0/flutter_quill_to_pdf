extension StringNullableExt on String? {
  ///Equals is a similar function that use Java or Kotlin
  ///classes to see the equality from two objects
  bool equals(
    String other, {
    bool caseSensitive = true,
    Pattern? pattern,
  }) {
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
  @Deprecated(
      'isTotallyEmpty is no longer supported and will be removed in future releases')
  bool get isTotallyEmpty => false;

  ///Equals is a similar function that use Java or Kotlin
  ///classes to see the equality from two objects
  bool equals(
    String other, {
    bool caseSensitive = true,
    Pattern? pattern,
    bool useThisInstead = false,
  }) {
    if (!caseSensitive) return toLowerCase() == other.toLowerCase();
    return pattern != null
        ? pattern is RegExp
            ? pattern.hasMatch(useThisInstead ? this : other)
            : pattern.allMatches(useThisInstead ? this : other).isNotEmpty
        : this == other;
  }

  @Deprecated(
      'fixCommonErrorInsertsInRawDelta is no longer supported and will be removed in future releases')
  String fixCommonErrorInsertsInRawDelta() {
    return this;
  }
}
