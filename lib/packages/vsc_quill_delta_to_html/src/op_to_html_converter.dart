// ignore_for_file: avoid_dynamic_calls, always_specify_types

import 'package:flutter/foundation.dart';
import 'package:flutter_quill_to_pdf/packages/vsc_quill_delta_to_html/src/mentions/mention_sanitizer.dart';

import 'delta_insert_op.dart';
import 'funcs_html.dart';
import 'helpers/array.dart' as arr;
import 'helpers/js.dart';
import 'op_attribute_sanitizer.dart';
import 'value_types.dart';

class InlineStyleType {
  InlineStyleType({this.fn, this.map});

  final String? Function(String value, DeltaInsertOp op)? fn;
  final Map<String, String>? map;
}

class InlineStyles {
  InlineStyles(this.attrs);

  final Map<String, InlineStyleType> attrs;

  InlineStyleType? operator [](String key) => attrs[key];
}

const Map<String, String> defaultInlineFonts = <String, String>{
  'serif': 'font-family: Georgia, Times New Roman, serif',
  'monospace': 'font-family: Monaco, Courier New, monospace'
};

final InlineStyles defaultInlineStyles = InlineStyles(<String, InlineStyleType>{
  'font': InlineStyleType(fn: (String value, _) => defaultInlineFonts[value] ?? 'font-family:$value'),
  'size': InlineStyleType(map: <String, String>{
    'small': 'font-size: 0.75em',
    'large': 'font-size: 1.5em',
    'huge': 'font-size: 2.5em',
  }),
  'indent': InlineStyleType(fn: (String value, DeltaInsertOp op) {
    final double indentSize = (double.tryParse(value) ?? double.nan) * 3;
    final String side = op.attributes['direction'] == 'rtl' ? 'right' : 'left';
    return 'padding-$side:${indentSize}em';
  }),
  'direction': InlineStyleType(fn: (String value, DeltaInsertOp op) {
    if (value == 'rtl') {
      final String textAlign = isTruthy(op.attributes['align']) ? '' : '; text-align:inherit';
      return ('direction:rtl$textAlign');
    } else {
      return null;
    }
  }),
  'list': InlineStyleType(map: <String, String>{
    'checked': "list-style-type:'\\2611';padding-left: 0.5em;",
    'unchecked': "list-style-type:'\\2610';padding-left: 0.5em;",
  }),
});

class OpConverterOptions {
  OpConverterOptions({
    this.classPrefix = 'ql',
    this.inlineStylesFlag = false,
    this.inlineStyles,
    this.encodeHtml = true,
    this.listItemTag = 'li',
    this.paragraphTag = 'p',
    this.linkRel,
    this.linkTarget,
    this.allowBackgroundClasses = false,
    this.customTag,
    this.customTagAttributes,
    this.customCssClasses,
    this.customCssStyles,
  }) {
    if (inlineStyles == null && inlineStylesFlag == true) {
      inlineStyles = InlineStyles(<String, InlineStyleType>{});
    }
  }

  String classPrefix;
  bool? inlineStylesFlag;
  InlineStyles? inlineStyles;
  bool encodeHtml;
  String listItemTag;
  String paragraphTag;
  String? linkRel;
  String? linkTarget;
  bool? allowBackgroundClasses;
  String? Function(String format, DeltaInsertOp op)? customTag;
  Map<String, String>? Function(DeltaInsertOp op)? customTagAttributes;
  List<String>? Function(DeltaInsertOp op)? customCssClasses;
  List<String>? Function(DeltaInsertOp op)? customCssStyles;
}

class HtmlParts {
  HtmlParts({
    required this.openingTag,
    required this.content,
    required this.closingTag,
  });

  final String openingTag;
  final String content;
  final String closingTag;
}

/// Converts a single Delta op to HTML.
class OpToHtmlConverter {
  OpToHtmlConverter(this.op, [OpConverterOptions? options]) {
    this.options = options ?? OpConverterOptions();
  }

  late final OpConverterOptions options;
  final DeltaInsertOp op;

  @visibleForTesting
  String prefixClass(String className) {
    if (!isTruthy(options.classPrefix)) {
      return className;
    }
    return '${options.classPrefix}-$className';
  }

  String getHtml() {
    final HtmlParts parts = getHtmlParts();
    return parts.openingTag + parts.content + parts.closingTag;
  }

  HtmlParts getHtmlParts() {
    if (op.isJustNewline() && !op.isContainerBlock()) {
      return HtmlParts(openingTag: '', closingTag: '', content: newLine);
    }

    final List<String> tags = getTags();
    List<TagKeyValue> attrs = getTagAttributes();

    if (tags.isEmpty && attrs.isNotEmpty) {
      tags.add('span');
    }

    final List<String> beginTags = <String>[];
    final List<String> endTags = <String>[];
    const String imgTag = 'img';
    bool isImageLink(tag) => tag == imgTag && isTruthy(op.attributes.link);
    for (final String tag in tags) {
      if (isImageLink(tag)) {
        beginTags.add(makeStartTag('a', getLinkAttrs()));
      }
      beginTags.add(makeStartTag(tag, attrs));
      endTags.add(tag == imgTag ? '' : makeEndTag(tag));
      if (isImageLink(tag)) {
        endTags.add(makeEndTag('a'));
      }
      // consumed in first tag
      attrs = <TagKeyValue>[];
    }

    return HtmlParts(
      openingTag: beginTags.join(),
      content: getContent(),
      closingTag: endTags.reversed.join(),
    );
  }

  String getContent() {
    if (op.isContainerBlock()) {
      return '';
    }

    if (op.isMentions()) {
      return op.insert.value;
    }

    var content = op.isFormula() || op.isText() ? op.insert.value : '';

    return options.encodeHtml == true ? encodeHtml(content) : content;
  }

  bool _supportInlineStyles() => options.inlineStylesFlag == true || options.inlineStyles != null;

  List<String> getCssClasses() {
    OpAttributes attrs = op.attributes;

    if (_supportInlineStyles()) {
      return <String>[];
    }

    List<String> propsArr = <String>['indent', 'align', 'direction', 'font', 'size', 'line-height'];
    if (options.allowBackgroundClasses == true) {
      propsArr.add('background');
    }

    List<String> props = propsArr
        .where((String prop) => isTruthy(attrs[prop]) && (prop != 'background' || OpAttributeSanitizer.isValidColorLiteral(attrs[prop])))
        .map((String prop) => '$prop-${attrs[prop]}')
        .toList();
    if (op.isFormula()) props.add('formula');
    if (op.isVideo()) props.add('video');
    if (op.isImage()) props.add('image');
    props = props.map((String prop) => prefixClass(prop)).toList();

    final List<String>? customClasses = getCustomCssClasses();
    if (customClasses != null) props.insertAll(0, customClasses);

    return props;
  }

  List<String> getCssStyles() {
    final OpAttributes attrs = op.attributes;

    final List<List<String>> propsArr = <List<String>>[
      <String>['color']
    ];
    final bool inlineStyles = _supportInlineStyles();
    if (inlineStyles || options.allowBackgroundClasses != true) {
      propsArr.add(<String>['background', 'background-color']);
    }
    if (inlineStyles) {
      propsArr.addAll(<List<String>>[
        <String>['indent'],
        <String>['align', 'text-align'],
        <String>['direction'],
        <String>['line-height'],
        <String>['font', 'font-family'],
        <String>['size'],
        <String>['list'],
      ]);
    }

    final List<String> props = propsArr
        .where((List<String> item) => isTruthy(attrs[item[0]]))
        .map((List<String> item) {
          final String attribute = item[0];
          final attrValue = attrs[attribute];

          final InlineStyleType? attributeConverter =
              (_supportInlineStyles() ? (options.inlineStyles?[attribute]) : null) ?? defaultInlineStyles[attribute];

          if (attributeConverter?.map != null) {
            return attributeConverter!.map![attrValue];
          } else if (attributeConverter?.fn != null) {
            return attributeConverter!.fn!(attrValue.toString(), op);
          } else {
            return '${arr.preferSecond(item)}:$attrValue';
          }
        })
        .where((String? item) => item != null)
        .map((String? item) => item!)
        .toList();

    final List<String>? customCssStyles = getCustomCssStyles();
    if (customCssStyles != null) props.insertAll(0, customCssStyles);

    return props;
  }

  List<TagKeyValue> getTagAttributes() {
    if (op.attributes.code == true && !op.isLink()) {
      return <TagKeyValue>[];
    }

    final Map<String, String>? customTagAttributes = getCustomTagAttributes();
    final List<TagKeyValue> customAttr =
        customTagAttributes?.entries.map((MapEntry<String, String> entry) => makeAttr(entry.key, entry.value)).toList() ?? <TagKeyValue>[];
    final List<String> classes = getCssClasses();
    final List<TagKeyValue> tagAttrs = customAttr;
    if (classes.isNotEmpty) {
      tagAttrs.add(makeAttr('class', classes.join(' ')));
    }

    final List<String> styles = getCssStyles();
    if (styles.isNotEmpty) {
      tagAttrs.add(makeAttr('style', styles.join(';')));
    }

    if (op.isImage()) {
      if (isTruthy(op.attributes.width)) {
        tagAttrs.add(makeAttr('width', op.attributes.width!));
      }
      tagAttrs.add(makeAttr('src', op.insert.value));
      return tagAttrs;
    }

    if (op.isACheckList()) {
      tagAttrs.add(makeAttr('data-checked', op.isCheckedList() ? 'true' : 'false'));
      return tagAttrs;
    }

    if (op.isFormula()) {
      return tagAttrs;
    }

    if (op.isVideo()) {
      tagAttrs.addAll(<TagKeyValue>[
        makeAttr('frameborder', '0'),
        makeAttr('allowfullscreen', 'true'),
        makeAttr('src', op.insert.value),
      ]);
      return tagAttrs;
    }

    if (op.isMentions()) {
      final Mention mention = op.attributes.mention!;
      if (isTruthy(mention.class_)) {
        tagAttrs.add(makeAttr('class', mention.class_!));
      }
      if (isTruthy(mention.endPoint) && isTruthy(mention.slug)) {
        tagAttrs.add(makeAttr('href', '${mention.endPoint!}/${mention.slug!}'));
      } else {
        tagAttrs.add(makeAttr('href', 'about:blank'));
      }

      if (isTruthy(mention.target)) {
        tagAttrs.add(makeAttr('target', mention.target!));
      }
      return tagAttrs;
    }

    if (op.isCodeBlock() && op.attributes['code-block'] is String) {
      tagAttrs.add(makeAttr('data-language', op.attributes['code-block']));
      return tagAttrs;
    }

    if (op.isContainerBlock()) {
      return tagAttrs;
    }

    if (op.isLink()) {
      tagAttrs.addAll(getLinkAttrs());
    }

    return tagAttrs;
  }

  TagKeyValue makeAttr(String k, String v) => TagKeyValue(key: k, value: v);

  List<TagKeyValue> getLinkAttrs() {
    final String? targetForAll = OpAttributeSanitizer.isValidTarget(options.linkTarget ?? '') ? options.linkTarget : null;

    final String? relForAll = OpAttributeSanitizer.isValidRel(options.linkRel ?? '') ? options.linkRel : null;

    final String? target = op.attributes.target ?? targetForAll;
    final String? rel = op.attributes.rel ?? relForAll;

    final List<TagKeyValue> tagAttrs = <TagKeyValue>[makeAttr('href', op.attributes.link!)];
    if (isTruthy(target)) tagAttrs.add(makeAttr('target', target!));
    if (isTruthy(rel)) tagAttrs.add(makeAttr('rel', rel!));
    return tagAttrs;
  }

  String? getCustomTag(String format) => options.customTag?.call(format, op);

  Map<String, String>? getCustomTagAttributes() => options.customTagAttributes?.call(op);

  List<String>? getCustomCssClasses() => options.customCssClasses?.call(op);

  List<String>? getCustomCssStyles() => options.customCssStyles?.call(op);

  List<String> getTags() {
    final OpAttributes attrs = op.attributes;

    // embeds
    if (!op.isText()) {
      return <String>[
        op.isVideo()
            ? 'iframe'
            : op.isImage()
                ? 'img'
                : 'span', // formula
      ];
    }

    // blocks
    final String positionTag = options.paragraphTag;
    final List<List<String>> blocks = <List<String>>[
      <String>['blockquote'],
      <String>['code-block', 'pre'],
      <String>['list', options.listItemTag],
      <String>['header'],
      <String>['align', positionTag],
      <String>['direction', positionTag],
      <String>['indent', positionTag],
    ];
    for (final List<String> item in blocks) {
      String firstItem = item[0];
      if (isTruthy(attrs[firstItem])) {
        final String? customTag = getCustomTag(firstItem);
        return isTruthy(customTag)
            ? <String>[customTag!]
            : firstItem == 'header'
                ? <String>['h${attrs[firstItem]}']
                : <String>[arr.preferSecond(item)!];
      }
    }

    if (op.isCustomTextBlock()) {
      final String? customTag = getCustomTag('renderAsBlock');
      return isTruthy(customTag) ? <String>[customTag!] : <String>[positionTag];
    }

    // inlines
    final Map<String, String> customTagsMap = attrs.attrs.keys.fold(<String, String>{}, (Map<String, String> res, String it) {
      final String? customTag = getCustomTag(it);
      if (isTruthy(customTag)) {
        res[it] = customTag!;
      }
      return res;
    });

    const List<List<String>> inlineTags = <List<String>>[
      <String>['link', 'a'],
      <String>['mentions', 'a'],
      <String>['script'],
      <String>['bold', 'strong'],
      <String>['italic', 'em'],
      <String>['strike', 's'],
      <String>['underline', 'u'],
      <String>['code'],
    ];

    final List<List<String>> tl = <List<String>>[
      ...inlineTags.where((List<String> item) => isTruthy(attrs[item[0]])),
      ...customTagsMap.keys
          .where((String t) => !inlineTags.any((List<String> it) => it[0] == t))
          .map((String t) => <String>[t, customTagsMap[t]!]),
    ];
    return tl.map((List<String> item) {
      final String? v = customTagsMap[item[0]];
      return isTruthy(v)
          ? v!
          : item[0] == 'script'
              ? attrs[item[0]] == ScriptType.subscript.value
                  ? 'sub'
                  : 'sup'
              : arr.preferSecond(item)!;
    }).toList();
  }
}
