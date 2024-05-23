import 'package:flutter/foundation.dart';
import 'package:quill_to_pdf/core/extensions/string_extension.dart';
import 'package:quill_to_pdf/packages/html2md/lib/src/options.dart';

import 'package:quill_to_pdf/packages/html2md/lib/html2md.dart' as hm2;
import 'package:quill_to_pdf/packages/html2md/lib/src/utils.dart' as util;

import '../core/constant/constants.dart';

abstract interface class MarkdownRules {
  //getters
  static hm2.Rule get paragraph => _PARAGRAPH_RULE;
  static hm2.Rule get headers => _HEADER_RULE;
  static hm2.Rule get common => _DEFAULT_RULE;
  static hm2.Rule get image => _IMAGE_RULE;
  static hm2.Rule get underline => _UNDERLINE_RULE;
  static hm2.Rule get code => _CODE_RULE;
  static List<hm2.Rule> get list => <hm2.Rule>[_LIST_ITEM_RULE, _LIST_RULE];
  static List<hm2.Rule> get allRules => <hm2.Rule>[paragraph, headers, common, image, underline, code, ...list];

  static final hm2.Rule _UNDERLINE_RULE =
      hm2.Rule('underline', filters: <String>['u', 'ins'], replacement: (String content, hm2.Node node) {
    return '_${content}_';
  });

  static final hm2.Rule _PARAGRAPH_RULE = hm2.Rule('paragraph', filters: <String>['p'], replacement: (String content, hm2.Node node) {
    final String? style = node.getAttribute('style');
    String copyOuterHTML = node.outerHTML.convertWrongInlineStylesToSpans;
    if (RegExp(r'"^<p>[<br>]{1,}<\/p>$"').hasMatch(copyOuterHTML)) {
      return (copyOuterHTML).replaceAll(RegExp(r'<p>|<\/p>'), '').replaceHtmlBrToManyNewLines;
    } else if (RegExp(r'^<p\s+.+?>[<br>]{1,}<\/p>$').hasMatch(copyOuterHTML)) {
      return (copyOuterHTML).replaceAll(RegExp(r'<p.*?>|<\/p>'), '').replaceHtmlBrToManyNewLines;
    } else if (style != null) {
      return '\n${(copyOuterHTML).convertHTMLToMarkdown}\n';
    } else {
      final hm2.Node? child = node.firstChild;
      if (child != null && child.nodeName == 'span') {
        return '\n${copyOuterHTML.replaceAll(RegExp(r'<p.*?>|<\/p>'), '')}\n';
      }
      return "\n$content\n";
    }
  });

  static final hm2.Rule _IMAGE_RULE = hm2.Rule('image', filters: <String>['img'], replacement: (String content, hm2.Node node) {
    String src = node.getAttribute('src') ?? '';
    String style = node.getAttribute('style')?.replaceFirst(';;', ';') ?? 'max-width: 100%;object-fit: fill';
    return src.isNotEmpty ? '\n![$style]($src)\n' : '';
  });

  static final hm2.Rule _DEFAULT_RULE = hm2.Rule('default', filters: <String>['default'], replacement: (String content, hm2.Node node) {
    return content.isEmpty
        ? node.isBlock
            ? '\n'
            : ''
        : node.isBlock
            ? '\n$content\n'
            : content;
  });

  static final hm2.Rule _HEADER_RULE =
      hm2.Rule('heading', filters: <String>['h1', 'h2', 'h3', 'h4', 'h5', 'h6'], replacement: (String content, hm2.Node node) {
    final String? style = node.getAttribute('style');
    final hm2.Node? child = node.firstChild;
    int hLevel = int.parse(node.nodeName.substring(1, 2));
    if (RegExp(r'"^<h([1-6])>[<br>]+<\/h\1>$"').hasMatch(node.outerHTML)) {
      return node.outerHTML.replaceAll(r'<h([1-6])>|<\/h\1>', '').replaceHtmlBrToManyNewLines;
    } else if (RegExp(r'<h([1-6])\s?style=".*?">[<br>]+<\/h\1>').hasMatch(node.outerHTML)) {
      return (node.outerHTML).replaceAll(RegExp(r'<h.*?>|<\/h.*?>'), '').replaceHtmlBrToManyNewLines;
    } else if (style != null) {
      return '\n${node.outerHTML.convertHTMLToMarkdown}\n';
    } else if (child != null && child.nodeName == 'span') {
      final String headerLevel = util.repeat("#", hLevel);
      String content = node.outerHTML.replaceAllMapped(RegExp(r'(<h.*?>)(.*?)(<\/h.*?>)'), (Match match) {
        return '$headerLevel ${match.group(2)!}';
      });
      content = content.replaceAllMapped('<br>', (Match match) {
        final String remainingText = content.substring(match.end);
        return '\n$headerLevel $remainingText';
      });
      return '\n$content\n';
    } else if (getStyleOption('headingStyle') == 'setext' && hLevel < 3) {
      String header = util.repeat(
          hLevel == 1 ? '#' : '#',
          hLevel == 1
              ? 1
              : hLevel == 2
                  ? 2
                  : 3);
      return '\n$header $content';
    } else {
      return '\n${util.repeat("#", hLevel)} $content';
    }
  });

  static final hm2.Rule _CODE_RULE = hm2.Rule('code', filterFn: (hm2.Node node) {
    bool isCodeBlock = node.nodeName == 'pre';
    return isCodeBlock;
  }, replacement: (String content, hm2.Node node) {
    return "\n${node.outerHTML.replaceAll('\n', '<br>')}";
  });

  static final hm2.Rule _LIST_RULE = hm2.Rule('list', filters: <String>['ul', 'ol'], replacement: (String content, hm2.Node node) {
    if (node.parentElName == 'li' && node.isParentLastChild) {
      return '$content\n';
    } else {
      return '$content\n';
    }
  });

  static final hm2.Rule _LIST_ITEM_RULE = hm2.Rule('listItem', filters: <String>['li'], replacement: (String content, hm2.Node node) {
    if (Constant.LIST_CHECK_PATTERN.hasMatch(node.outerHTML)) {
      final RegExpMatch match = Constant.LIST_CHECK_PATTERN.firstMatch(node.outerHTML)!;
      // final listType = match.group(6); //specific type list
      // final padding = match.group(8); //left amount padding
      final String? align = match.group(4);
      final bool isCheck = bool.parse(match.group(10)!); //check
      final String content = match.group(11) ?? ' ';
      final String prefix = '- [${isCheck ? 'x' : ' '}]${align != null ? '[$align]' : ''} ';
      final String suffix = ' ${content.convertHTMLToMarkdown}';
      return '\n$prefix$suffix';
    } else {
      String convertContent =
          content.replaceAll(RegExp(r'^\n+'), '\n').replaceAll(RegExp(r'\n+$'), '').replaceAll(RegExp('\n', multiLine: true), '\n    ');
      String prefix = '${getStyleOption('bulletListMarker')}   ';
      if (node.parentElName == 'ol') {
        //Is numered list
        int start = -1;
        String? startAttr = node.getParentAttribute('start');
        if (startAttr != null && startAttr.isNotEmpty) {
          try {
            start = int.parse(startAttr);
          } catch (e) {
            debugPrint('listItem parse start error $e');
            rethrow;
          }
        }

        int index = (start > -1) ? start + node.parentChildIndex : node.parentChildIndex + 1;
        prefix = '$index.  ';
      }
      String postfix = ((node.nextSibling != null) && !RegExp(r'\n$').hasMatch(convertContent)) ? '\n' : '';
      return '\n$prefix$convertContent$postfix';
    }
  });
}
