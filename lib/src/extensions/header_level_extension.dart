extension HeaderLevelResolverExtension on num {
  double resolveHeaderLevel({
    required List<double> headingSizes,
  }) {
    final int index = toInt() - 1;
    if(index >= headingSizes.length) {
      throw StateError('Heading of level $this is not supported into the passed list: $headingSizes');
    }
    return headingSizes[index];
  }
}
