import 'package:flutter_quill_to_pdf/core/extensions/string_extension.dart';

const String newLine = r'\n';
const String quillDeltaNewLine = '{"insert":"$newLine"}';

bool? stringToSafeBool(String? str) {
  if (str == null) return null;
  if (str.isEmpty) return null;
  if (str.equals('true')) return true;
  if (str.equals('false')) return false;
  return null;
}

bool isHTML(String str) {
  final RegExp htmlRegExp = RegExp('<[^>]*>', multiLine: true, caseSensitive: false);
  return htmlRegExp.hasMatch(str);
}

bool isEmptyDeltaJson(String content) {
  return content.equals('[{"insert":"$newLine"}]');
}
