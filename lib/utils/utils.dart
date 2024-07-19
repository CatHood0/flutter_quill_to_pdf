import 'package:flutter_quill_to_pdf/core/extensions/string_extension.dart';

const String quillDeltaNewLine = '{"insert":"\\n"}';

bool? stringToSafeBool(String? str) {
  if (str == null) return null;
  if (str.isEmpty) return null;
  if (str.equals('true')) return true;
  if (str.equals('false')) return false;
  return null;
}
