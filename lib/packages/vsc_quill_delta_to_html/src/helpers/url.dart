String sanitize(String str) {
  final String val = str.replaceAll(RegExp(r'^\s*', multiLine: true), '');
  final RegExp whiteList =
      RegExp(r'^((https?|s?ftp|file|blob|mailto|tel):|#|/|data:image/)');
  if (whiteList.hasMatch(val)) {
    return val;
  }
  return 'unsafe:$val';
}
