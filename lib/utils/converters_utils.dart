import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart';
import 'package:flutter_quill_to_pdf/packages/html2md/lib/html2md.dart' as hm2;

bool? stringToSafeBool(String? str) {
  if (str == null) return null;
  if (str.isEmpty) return null;
  if (str.equals('true')) return true;
  if (str.equals('false')) return false;
  return null;
}

String convertDeltaToHtml(Delta delta,
    [ConverterOptions? options,
    CustomRenderHtmlAttributes? customRenderCallback]) {
  final QuillDeltaToHtmlConverter converterDeltaToHTML =
      QuillDeltaToHtmlConverter(
    delta.toJson(),
    options ?? ConverterOptions.forEmail(),
  );
  converterDeltaToHTML.renderCustomWith = customRenderCallback;
  return converterDeltaToHTML.convert();
}

String convertHtmlToMarkdown(
    String htmlText, List<hm2.Rule>? rules, List<String> ignoreRules,
    {bool removeLeadingWhitespaces = false, bool escape = true}) {
  if (!ignoreRules.contains('underline')) ignoreRules.add('underline');
  return hm2.convert(
    styleOptions: <String, String>{'emDelimiter': '*'},
    htmlText,
    escape: escape,
    rules: rules,
    removeLeadingWhitespaces: removeLeadingWhitespaces,
    ignore: ignoreRules,
  );
}
