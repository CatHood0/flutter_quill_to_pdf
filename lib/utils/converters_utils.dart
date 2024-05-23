import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:quill_to_pdf/core/extensions/string_extension.dart';
import 'package:quill_to_pdf/core/options/html_converter_options.dart';
import 'package:quill_to_pdf/packages/html2md/lib/html2md.dart' as hm2;
import '../packages/vsc_quill_delta_to_html/src/quill_delta_to_html_converter.dart';

bool? stringToSafeBool(String? str) {
  if (str == null) return null;
  if (str.isEmpty) return null;
  if (str.equals('true')) return true;
  if (str.equals('false')) return false;
  return null;
}

String convertDeltaToHtml(Delta delta, [ConverterOptions? options]) {
  return QuillDeltaToHtmlConverter(
    delta.toJson(),
    options ?? HTMLConverterOptions.options(),
  ).convert();
}

String convertHtmlToMarkdown(String htmlText, List<hm2.Rule>? rules, List<String> ignoreRules,
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
