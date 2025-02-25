import 'dart:convert';
import 'package:dart_quill_delta/dart_quill_delta.dart' as fq;
import 'package:flutter_quill_to_pdf/converter/delta_processor/delta_attributes_options.dart';
import 'package:flutter_quill_to_pdf/core/extensions/map_extension.dart';
import 'package:flutter_quill_to_pdf/core/extensions/string_extension.dart';
import 'package:flutter_quill_to_pdf/core/internal/delta_denormalizer.dart';
import 'package:flutter_quill_to_pdf/utils/utils.dart';
import '../../core/constant/constants.dart';

int _index = 0;
final StringBuffer _buffer = StringBuffer();

//TODO: add support for custom attributes detection and implementation to block, and inline
String applyAttributesIfNeeded({
  required String json,
  required DeltaAttributesOptions attr,
  required bool overrideAttributes,
}) {
  _index = 0;
  _buffer.clear();
  if (json.isEmpty) return json;
  fq.Delta delta = fq.Delta.fromJson(jsonDecode(json)).denormalize();
  while (_index < delta.length) {
    final int nextIndex = _index + 1;
    final fq.Operation operation = delta.elementAt(_index);
    if (operation.data is! String) {
      _buffer.write(',${jsonEncode(operation.toJson())},');
      _index++;
      continue;
    }
    fq.Operation? nextOp = null;
    if (nextIndex < delta.length) nextOp = delta.elementAt(nextIndex);
    if (operation.data is String &&
        !Constant.newLinesInsertions.hasMatch(
            (operation.data as String).replaceAll(RegExp('\n|\\n'), '¶'))) {
      //inlines
      final String? overridedHexColor = overrideAttributes
          ? attr.hexColor == null
              ? null
              : '${attr.hexColor}'
          : null;
      final String? overridedBackgroundHexColor = overrideAttributes
          ? attr.hexBackgroundColor == null
              ? null
              : '${attr.hexBackgroundColor}'
          : null;
      final bool overridedBoldAttr = overrideAttributes ? attr.bold : false;
      final bool overridedItalicAttr = overrideAttributes ? attr.italic : false;
      final bool overridedStrikeAttr =
          overrideAttributes ? attr.strikethrough : false;
      final String? overridedLinkAttr = overrideAttributes ? attr.link : null;
      final bool overridedUnderlineAttr =
          overrideAttributes ? attr.underline : false;
      final bool boldAttr = operation.attributes?['bold'] ?? overridedBoldAttr;
      final bool? italicHelperAttr = operation.attributes?['italic'] is String
          ? stringToSafeBool(operation.attributes?['italic'])
          : operation.attributes?['italic'];
      final bool italicAttr = italicHelperAttr ?? overridedItalicAttr;
      final bool? underlineHelperAttr =
          operation.attributes?['underline'] is String
              ? stringToSafeBool(operation.attributes?['underline'])
              : operation.attributes?['underline'];
      final bool underlineAttr = underlineHelperAttr ?? overridedUnderlineAttr;
      final bool strikeAttr =
          operation.attributes?['strike'] ?? overridedStrikeAttr;
      final String? color = operation.attributes?['color'] ?? overridedHexColor;
      final String? background =
          operation.attributes?['background'] ?? overridedBackgroundHexColor;
      final String decidedFontFamily =
          overrideAttributes ? attr.fontFamily : 'Arial';
      final String fontFamilyAttr =
          operation.attributes?['font'] as String? ?? decidedFontFamily;
      final String? linkAttrHelper =
          operation.attributes?['link'] ?? operation.attributes?['href'];
      final String? linkAttr = linkAttrHelper ?? overridedLinkAttr;
      final fontSizeHelper = operation.attributes?['size'];
      final String fontSizeAttr = fontSizeHelper != null
          ? fontSizeHelper is String
              ? fontSizeHelper
              : (fontSizeHelper as num).toInt().toString()
          : overrideAttributes
              ? '${attr.fontSize.toInt()}'
              : Constant.DEFAULT_FONT_SIZE.toString();
      final String insertionData =
          '{"insert":${jsonEncode(operation.data.toString())}';
      final double? lineSpacingHelper = overrideAttributes
          ? attr.lineSpacing ?? Constant.DEFAULT_LINE_HEIGHT
          : null;
      final double? spacing = lineSpacingHelper;
      final Map<String, dynamic> mapAttrs = <String, dynamic>{
        "line-height": lineSpacingHelper == null
            ? null
            : nextOp?.attributes != null &&
                    nextOp!.attributes!.containsKey('code-block')
                ? null
                : "$spacing",
        "size": nextOp?.attributes != null &&
                nextOp!.attributes!.containsKey('code-block')
            ? null
            : fontSizeAttr,
        "font": nextOp?.attributes != null &&
                nextOp!.attributes!.containsKey('code-block')
            ? null
            : fontFamilyAttr,
        "bold": boldAttr,
        "italic": italicAttr,
        "underline": underlineAttr,
        "strike": strikeAttr,
        "link": linkAttr,
        "color": nextOp?.attributes != null &&
                nextOp!.attributes!.containsKey('code-block')
            ? null
            : color,
        "background": nextOp?.attributes != null &&
                nextOp!.attributes!.containsKey('code-block')
            ? null
            : background,
      };
      final Map<String, dynamic>? attributesJson =
          mapAttrs.ignoreIf(predicate: (String key, dynamic value) {
        if (value is bool && !value) {
          return false;
        }
        if (value == null) return false;
        return true;
      });
      _buffer.write(
          insertionData); //Avoid error if the content has '"' into itself
      _buffer.write(attributesJson == null
          ? '},'
          : ',"attributes":${jsonEncode(attributesJson)}},');
      _index++;
      continue;
    } else if (operation.data is String &&
        Constant.newLinesInsertions.hasMatch(
            (operation.data as String).replaceAll(RegExp('\n|\\n'), '¶')) &&
        operation.attributes != null) {
      final String? listAttr = operation.attributes?['list'];
      final String? decidedAlign = overrideAttributes
          ? validateAlign(attr.align)
              ? attr.align
              : null
          : null;
      final String? alignAttr = operation.attributes?['align'] ?? decidedAlign;
      final String? indentHelper = overrideAttributes
          ? attr.indent > 0
              ? '${attr.indent}'
              : null
          : null;
      int? indentAttr = operation.attributes?['indent'] ?? indentHelper;
      final bool quote = operation.attributes?['blockquote'] ?? false;
      final bool codeBlock = operation.attributes?['code-block'] ?? false;
      final int? headerAttr = operation.attributes?['header'];
      final Map<String, dynamic> mapAttrs = <String, dynamic>{
        "align": quote || listAttr != null || codeBlock ? null : alignAttr,
        "list": headerAttr != null || quote || codeBlock ? null : listAttr,
        "header": quote || codeBlock || listAttr != null ? null : headerAttr,
        "blockquote":
            codeBlock || listAttr != null || alignAttr != null ? null : quote,
        "code-block": !quote ||
                headerAttr != null ||
                listAttr != null ||
                alignAttr != null
            ? codeBlock
            : null,
        "indent": quote || codeBlock ? null : indentAttr,
      };
      final Map<String, dynamic>? attributesJson =
          mapAttrs.ignoreIf(predicate: (String key, value) {
        if (value is bool && !value) {
          return false;
        }
        if (value is int && value < 1 && value > 4) {
          return false;
        }
        if (value == null) return false;
        return true;
      });
      _buffer.write(
          ',{"insert":"${(operation.data as String).replaceAll('\n', r'\n')}"${attributesJson == null ? '},' : ',"attributes":${jsonEncode(attributesJson)}}'}');
    } else {
      final double? lineSpacingHelper = overrideAttributes
          ? attr.lineSpacing ?? Constant.DEFAULT_LINE_HEIGHT
          : null;
      double? spacing =
          operation.attributes?['line-height'] ?? lineSpacingHelper;
      final Map<String, dynamic> map = <String, dynamic>{
        if (spacing != null) "line-height": "$spacing",
        ...(operation.attributes ?? <String, dynamic>{})
      };
      final String attributes = jsonEncode(map);
      _buffer.write(
          ',{"insert":"${(operation.data as String).replaceAll('\n', r'\n')}","attributes":$attributes},');
    }
    _index++;
  }
  return '$_buffer'.fixCommonErrorInsertsInRawDelta;
}

bool validateAlign(String? align) {
  if (align.equals('left')) return true;
  if (align.equals('justify')) return true;
  if (align.equals('center')) return true;
  if (align.equals('right')) return true;
  return false;
}
