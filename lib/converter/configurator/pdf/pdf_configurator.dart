import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:dio/dio.dart';
import 'package:flutter_quill_delta_easy_parser/flutter_quill_delta_easy_parser.dart';
import 'package:flutter_quill_to_pdf/converter/configurator/utils/hightlight_themes.dart';
import 'package:flutter_quill_to_pdf/core/constant/constants.dart';
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart';
import 'package:highlight/highlight.dart';
import 'package:meta/meta.dart';
import 'package:numerus/roman/roman.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' show PdfColor, PdfColors, PdfPageFormat;
import 'package:pdf/widgets.dart' as pw;

import '../../../utils/css.dart';
import 'document_functions.dart';
import 'package:http/http.dart' as http;

abstract class PdfConfigurator<T, D> extends ConverterConfigurator<T, D>
    implements DocumentFunctions<Delta, Document, List<pw.Widget>> {
  late final pw.ThemeData defaultTheme;
  late final PdfColor defaultLinkColor;
  //show default this on ordered list
  @protected
  int lastListIndent = 0;
  @protected
  int numberList = 0;
  @protected
  int numberIndent1List = 0;
  @protected
  int numberIndent2List = 0;
  @protected
  int numberIndent3List = 0;
  @protected
  int numberIndent4List = 0;
  @protected
  int numberIndent5List = 0;
  @protected
  int numCodeLine = 0;
  @protected
  String? lastListType;
  final Delta? frontM;
  final Delta? backM;
  final List<double>? customHeadingSizes;
  final List<CustomWidget> customBuilders;
  final FontFamilyResponse Function(FontFamilyRequest familyRequest)? onRequestFontFamily;
  final PDFWidgetBuilder<TextFragment, pw.Widget>? onDetectImageBlock;
  final PDFWidgetErrorBuilder<String, pw.Widget, TextFragment>? onDetectErrorInImage;
  final PDFWidgetBuilder<TextFragment, pw.InlineSpan>? onDetectInlineRichTextStyles;
  final PDFWidgetBuilder<Line, pw.Widget>? onDetectHeaderBlock;
  final PDFWidgetBuilder<Line, pw.Widget>? onDetectAlignedParagraph;
  final PDFWidgetBuilder<TextFragment, pw.InlineSpan>? onDetectCommonText;
  final PDFLeadingWidget<pw.Widget?>? listLeadingBuilder;

  /// manages the directionality of the common text,
  final pw.TextDirection directionality;

  final PDFWidgetBuilder<TextFragment, pw.InlineSpan>? onDetectLink;
  final PDFWidgetBuilder<Paragraph, pw.Widget>? onDetectList;
  final PDFWidgetBuilder<Paragraph, pw.Widget>? onDetectCodeBlock;
  final PDFWidgetBuilder<Paragraph, pw.Widget>? onDetectBlockquote;
  final bool enableCodeBlockHighlighting;

  /// isLightCodeBlockTheme is used when enableCodeBlockHighlighting is true
  /// to decide the correct style for the spans
  final bool isLightCodeBlockTheme;
  final Map<String, pw.TextStyle>? customCodeHighlightTheme;
  final pw.Font? codeBlockFont;
  final pw.TextStyle? codeBlockTextStyle;
  final PdfColor? codeBlockBackgroundColor;
  final pw.TextStyle? codeBlockNumLinesTextStyle;
  final pw.TextStyle? blockQuoteTextStyle;
  final PdfColor? blockQuoteBackgroundColor;
  final PdfColor? blockQuoteDividerColor;
  final double? blockQuotethicknessDividerColor;
  final double? blockQuotePaddingLeft;
  final double? blockQuotePaddingRight;
  final int defaultFontSize =
      Constant.DEFAULT_FONT_SIZE; //avoid spans without font sizes not appears in the document
  late final double pageWidth, pageHeight;
  final bool isWeb;
  PdfConfigurator({
    required this.customBuilders,
    required super.document,
    this.customHeadingSizes,
    this.enableCodeBlockHighlighting = true,
    this.isLightCodeBlockTheme = true,
    this.customCodeHighlightTheme,
    this.onRequestFontFamily,
    this.isWeb = false,
    this.directionality = pw.TextDirection.ltr,
    this.blockQuotePaddingLeft,
    this.blockQuotePaddingRight,
    this.blockQuotethicknessDividerColor,
    this.blockQuoteBackgroundColor,
    this.codeBlockBackgroundColor,
    this.listLeadingBuilder,
    this.codeBlockNumLinesTextStyle,
    this.codeBlockTextStyle,
    this.blockQuoteDividerColor,
    this.blockQuoteTextStyle,
    this.codeBlockFont,
    this.onDetectBlockquote,
    this.onDetectCodeBlock,
    this.onDetectAlignedParagraph,
    this.onDetectCommonText,
    this.onDetectHeaderBlock,
    this.onDetectLink,
    this.onDetectList,
    this.onDetectInlineRichTextStyles,
    this.onDetectImageBlock,
    this.onDetectErrorInImage,
    this.backM,
    this.frontM,
  }) {
    defaultLinkColor = const PdfColor.fromInt(0x2AAB);
  }

  Future<pw.Widget> getImageBlock(
    TextFragment line, [
    pw.AlignmentDirectional? alignment,
    pw.TextDirection? textDirection,
  ]) async {
    double? width = null;
    double? height = null;
    final String data = (line.data as Map<String, dynamic>)['image'];
    final Map<String, dynamic> attributes = parseCssStyles(line.attributes?['style'] ?? '', 'left');
    if (attributes.isNotEmpty) {
      width = attributes['width'] ?? pageWidth;
      height = attributes['height'];
    }

    File? file;
    Uint8List? imageBytes;

    // if the data is a content uri we ignore it, since we have no support for them
    if (!Constant.contentUriFileDetector.hasMatch(data)) {
      if (isWeb) {
        imageBytes = await _fetchBlobAsBytes(data);
      } else if (Constant.IMAGE_FROM_NETWORK_URL.hasMatch(data)) {
        final String pathStorage =
            '${(await getApplicationCacheDirectory()).path}/image_${Random.secure().nextInt(99999) + 50}';
        try {
          file = File(pathStorage);
          await Dio().download(data, pathStorage);
        } on DioException {
          final pw.Widget? errorWidget = onDetectErrorInImage?.call(data, line, alignment);
          return errorWidget ?? pw.SizedBox.shrink();
        }
      } else if (Constant.isFromLocalStorage(data)) {
        file = File(data);
      } else {
        final Uint8List bytes = base64Decode(data);
        final String pathStorage =
            '${(await getApplicationCacheDirectory()).path}/image_${Random.secure().nextInt(99999) + 50}';
        try {
          file = File(pathStorage);
          await file.writeAsBytes(bytes);
        } on DioException {
          final pw.Widget? errorWidget = onDetectErrorInImage?.call(data, line, alignment);
          return errorWidget ?? pw.SizedBox.shrink();
        }
      }
    }

    if (isWeb ? (imageBytes == null || imageBytes.isEmpty) : (file == null || !(await file.exists()))) {
      final pw.Widget? errorWidget = onDetectErrorInImage?.call(data, line, alignment);
      return errorWidget ?? pw.SizedBox.shrink();
    }

    // verify if exceded height using page format params
    if (height != null && height >= pageHeight) height = pageHeight;
    // verify if exceded width using page format params
    if (width != null && width >= pageWidth) width = pageWidth;
    return pw.Container(
      child: pw.RichText(
        softWrap: true,
        overflow: pw.TextOverflow.span,
        textDirection: textDirection ?? directionality,
        text: pw.WidgetSpan(
          child: pw.Container(
            width: pageWidth,
            alignment: alignment,
            constraints: height == null ? const pw.BoxConstraints(maxHeight: 450) : null,
            child: pw.Image(
              pw.MemoryImage(isWeb ? imageBytes! : (await file!.readAsBytes())),
              dpi: 230,
              height: height,
              width: width,
            ),
          ),
        ),
      ),
    );
  }

  Future<pw.InlineSpan> getRichTextInlineStyles({
    required TextFragment line,
    required bool isCodeBlock,
    required bool isBlockquote,
    required int? headerLevel,
    pw.TextStyle? style,
    bool returnContentIfNeedIt = false,
    bool addFontSize = true,
  }) async {
    if (isCodeBlock && enableCodeBlockHighlighting) {
      final pw.TextStyle codeBlockStyle = getCodeBlockStyle();
      return _getHighlight(
        line.data as String,
        style: codeBlockStyle.copyWith(lineSpacing: 0.5),
      );
    }
    final PdfColor? textColor = pdfColorString(line.attributes?['color']);
    final PdfColor? backgroundTextColor = pdfColorString(line.attributes?['background']);
    final double? spacing = line.attributes?['line-height'];
    final String? fontFamily = line.attributes?['font'];
    final Object? fontSizeMatch = line.attributes?['size'];
    final String href = line.attributes?['link'] as String? ?? '';
    double? fontSizeHelper = defaultTheme.defaultTextStyle.fontSize ?? defaultTheme.defaultTextStyle.fontSize;
    if (fontSizeMatch != null) {
      if (fontSizeMatch == 'large') fontSizeHelper = 15.5;
      if (fontSizeMatch == 'huge') fontSizeHelper = 18.5;
      if (fontSizeMatch != 'huge' && fontSizeMatch != 'large' && fontSizeMatch != 'small') {
        if (fontSizeMatch is String) {
          fontSizeHelper = double.tryParse(fontSizeMatch) ?? fontSizeHelper;
        }
        if (fontSizeMatch is num) {
          fontSizeHelper = fontSizeMatch.toDouble();
        }
      }
    }
    final bool bold = line.attributes?['bold'] ?? false;
    final bool italic = line.attributes?['italic'] ?? false;
    final bool strike = line.attributes?['strike'] ?? false;
    final bool underline = line.attributes?['underline'] ?? false;
    final double? fontSize = !addFontSize ? null : fontSizeHelper;
    final String content = line.data as String;
    final double? lineSpacing = spacing?.resolveLineHeight();
    final FontFamilyResponse? fontResponse = onRequestFontFamily?.call(FontFamilyRequest(
      family: fontFamily ?? Constant.DEFAULT_FONT_FAMILY,
      isBold: bold,
      isItalic: italic,
      isUnderline: underline,
      isStrike: strike,
    ));
    // Give just the necessary fallbacks for the founded fontFamily
    final pw.TextStyle finalStyle = (style ?? defaultTheme.defaultTextStyle).copyWith(
      font: fontResponse?.fontNormalV,
      fontStyle: italic ? pw.FontStyle.italic : null,
      fontWeight: bold ? pw.FontWeight.bold : null,
      decoration: pw.TextDecoration.combine(<pw.TextDecoration>[
        if (strike) pw.TextDecoration.lineThrough,
        if (underline) pw.TextDecoration.underline,
      ]),
      decorationStyle: pw.TextDecorationStyle.solid,
      decorationColor: href.isNotEmpty ? textColor ?? defaultLinkColor : textColor ?? backgroundTextColor,
      color: textColor ?? (href.isNotEmpty ? defaultLinkColor : null),
      fontBold: fontResponse?.boldFontV,
      fontItalic: fontResponse?.italicFontV,
      fontBoldItalic: fontResponse?.boldItalicFontV,
      fontFallback: fontResponse?.fallbacks,
      fontSize: !addFontSize ? null : fontSize,
      lineSpacing: lineSpacing,
      background: backgroundTextColor == null ? null : pw.BoxDecoration(color: backgroundTextColor),
    );
    if (returnContentIfNeedIt) {
      return pw.TextSpan(
        annotation: href.isNotEmpty ? pw.AnnotationLink(href) : null,
        text: line.data as String,
        style: style ?? finalStyle,
      );
    }
    if (headerLevel != null && headerLevel > 0) {
      final double headerFontSize =
          headerLevel.resolveHeaderLevel(headingSizes: customHeadingSizes ?? Constant.kDefaultHeadingSizes);
      final pw.TextStyle headerStyle = finalStyle.copyWith(fontSize: headerFontSize);
      return pw.TextSpan(
        text: content,
        style: headerStyle,
      );
    }

    if (isBlockquote) {
      final pw.TextStyle blockquoteStyle = blockQuoteTextStyle ??
          pw.TextStyle(
            color: PdfColor.fromHex("#808080"),
            lineSpacing: 1.5,
          ).merge(finalStyle);
      return pw.TextSpan(
        annotation: href.isNotEmpty ? pw.AnnotationLink(href) : null,
        text: content,
        style: blockquoteStyle,
      );
    }

    return pw.TextSpan(
      text: content,
      style: finalStyle,
    );
  }

  Future<pw.Widget> getBlockQuote(
    List<pw.Widget> spansToWrap, [
    pw.TextStyle? style,
    String? align,
    int? indentLevel,
    pw.TextDirection? textDirection,
  ]) async {
    align ??= 'left';
    indentLevel ??= 0;
    final pw.Widget widget = pw.Directionality(
      textDirection: textDirection ?? directionality,
      child: pw.Container(
        padding: pw.EdgeInsetsDirectional.only(
          start: blockQuotePaddingLeft ?? (indentLevel > 0 ? indentLevel * 12.5 : 10),
          end: blockQuotePaddingRight ?? 10,
        ),
        decoration: pw.BoxDecoration(
          color: this.blockQuoteBackgroundColor ?? PdfColor.fromHex('#fbfbf9'),
          border: pw.Border(
            left: (textDirection ?? directionality) == pw.TextDirection.rtl
                ? pw.BorderSide.none
                : pw.BorderSide(
                    color: blockQuoteDividerColor ?? PdfColors.blue,
                    width: blockQuotethicknessDividerColor ?? 2.5,
                  ),
            right: (textDirection ?? directionality) != pw.TextDirection.rtl
                ? pw.BorderSide.none
                : pw.BorderSide(
                    color: blockQuoteDividerColor ?? PdfColors.blue,
                    width: blockQuotethicknessDividerColor ?? 2.5,
                  ),
          ),
        ),
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisSize: pw.MainAxisSize.min,
          children: spansToWrap,
        ),
      ),
    );
    return widget;
  }

  Future<pw.Widget> getCodeBlock(
    List<pw.Widget> spansToWrap, [
    pw.TextStyle? style,
    pw.TextDirection? textDirection,
    bool isFirstBlockLine = false,
    bool isLastBlockLine = false,
  ]) async {
    final pw.Widget widget = pw.Container(
      width: pageWidth,
      decoration: pw.BoxDecoration(
        color: this.codeBlockBackgroundColor ?? PdfColor.fromHex('#e1e1e166'),
      ),
      child: pw.Container(
        padding: pw.EdgeInsetsDirectional.only(
          start: 10,
          end: 10,
          top: isFirstBlockLine ? 10 : 2,
          bottom: isLastBlockLine ? 10 : 2,
        ),
        margin: !isFirstBlockLine && !isLastBlockLine ? const pw.EdgeInsetsDirectional.only(top: -1) : null,
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.start,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          mainAxisSize: pw.MainAxisSize.min,
          children: <pw.Widget>[
            ...spansToWrap,
          ],
        ),
      ),
    );
    return widget;
  }

  @protected
  pw.TextStyle getCodeBlockStyle() {
    final pw.TextStyle defaultCodeBlockStyle = pw.TextStyle(
      fontSize: 10,
      font: codeBlockFont ?? pw.Font.courier(),
      fontFallback: <pw.Font>[
        pw.Font.courierBold(),
        pw.Font.courierBoldOblique(),
        pw.Font.courierOblique(),
        pw.Font.symbol()
      ],
      letterSpacing: 1.17,
      lineSpacing: 1.0,
      wordSpacing: 1.0,
      color: PdfColor.fromHex("#808080"),
    );
    return codeBlockTextStyle ??
        defaultCodeBlockStyle.merge(defaultTheme.defaultTextStyle.copyWith(lineSpacing: 1.0));
  }

  pw.Widget lineBuilder({
    required List<pw.InlineSpan> spans,
    String align = 'left',
    pw.TextDirection? textDirection,
  }) {
    return pw.RichText(
      textAlign: (textDirection ?? directionality) == pw.TextDirection.rtl
          ? align.resolvePdfTextAlign.reversed
          : align.resolvePdfTextAlign,
      softWrap: true,
      overflow: pw.TextOverflow.span,
      textDirection: textDirection ?? directionality,
      text: pw.TextSpan(
        children: <pw.InlineSpan>[...spans],
      ),
    );
  }

  @protected
  pw.Widget codeBlockLineBuilder({
    required List<pw.InlineSpan> spans,
    required pw.TextStyle codeBlockStyle,
    pw.TextDirection? textDirection,
  }) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisSize: pw.MainAxisSize.min,
      children: <pw.Widget>[
        pw.Padding(
          padding: const pw.EdgeInsetsDirectional.only(
            end: 10,
          ),
          child: pw.Text(
            numCodeLine.toString(),
            style: codeBlockNumLinesTextStyle?.merge(
                  defaultTheme.defaultTextStyle,
                ) ??
                codeBlockStyle.merge(defaultTheme.defaultTextStyle),
            overflow: pw.TextOverflow.span,
            textDirection: textDirection ?? directionality,
          ),
        ),
        pw.Expanded(
          child: pw.RichText(
            softWrap: true,
            overflow: pw.TextOverflow.span,
            textDirection: textDirection ?? directionality,
            text: pw.TextSpan(
              children: <pw.InlineSpan>[...spans],
            ),
          ),
        )
      ],
    );
  }

  Future<pw.Widget> getHeaderBlock({
    required pw.Widget child,
    required int headerLevel,
    required int indentLevel,
    pw.TextStyle? style,
    pw.TextDirection? textDirection,
  }) async {
    return pw.Directionality(
      textDirection: textDirection ?? directionality,
      child: pw.Container(
        alignment: pw.AlignmentDirectional.centerStart,
        padding: pw.EdgeInsets.only(
          left: indentLevel.toDouble() * 7,
          top: 3.5,
          bottom: 2.5,
        ),
        child: child,
      ),
    );
  }

  Future<pw.Widget> getAlignedHeaderBlock({
    required pw.Widget child,
    required int headerLevel,
    required String align,
    required int indentLevel,
    pw.TextStyle? firstSpanStyle,
    pw.TextStyle? style,
    pw.TextDirection? textDirection,
  }) async {
    final String alignment = align;
    final pw.AlignmentDirectional al = alignment.resolvePdfBlockAlign;
    final double spacing = (firstSpanStyle?.lineSpacing ?? Constant.kDefaultLineHeight);
    return pw.Directionality(
      textDirection: textDirection ?? directionality,
      child: pw.Container(
        padding: pw.EdgeInsetsDirectional.only(
          start: indentLevel * 12.5,
          top: spacing.resolvePaddingByLineHeight(),
          bottom: spacing.resolvePaddingByLineHeight(),
        ),
        alignment: al,
        child: child,
      ),
    );
  }

  Future<pw.Widget> getAlignedParagraphBlock({
    required pw.Widget child,
    required String align,
    required int indentLevel,
    required pw.TextStyle? firstSpanStyle,
    pw.TextStyle? style,
    pw.TextDirection? textDirection,
  }) async {
    final double spacing =
        (firstSpanStyle?.lineSpacing ?? defaultTheme.defaultTextStyle.lineSpacing ?? Constant.kDefaultLineHeight);
    return pw.Directionality(
      textDirection: textDirection ?? directionality,
      child: pw.Container(
        alignment: align.resolvePdfBlockAlign,
        padding: pw.EdgeInsetsDirectional.only(
          start: indentLevel * 12.5,
          top: 1.5,
          bottom: spacing.resolvePaddingByLineHeight(),
        ),
        child: child,
      ),
    );
  }

  Future<pw.Widget> getListBlock(
    List<pw.InlineSpan> spansToWrap,
    String listType,
    String align,
    int indentLevel, [
    pw.TextStyle? style,
    pw.TextDirection? textDirection,
  ]) async {
    pw.Widget? leadingWidget;

    // Get the style from the first span to wrap
    //
    // with this we ensure to have the styles of the spans and apply the
    // size of that span to the leading
    final pw.TextStyle? firstSpanStyle = spansToWrap.isNotEmpty ? spansToWrap.first.style : null;
    final double? spacing = firstSpanStyle?.lineSpacing;
    if (listLeadingBuilder != null) {
      final pw.Widget? leading = listLeadingBuilder!(listType, indentLevel, <String, dynamic>{
        'currentStyle': style,
        'firstWordStyle': firstSpanStyle,
        'lineSpacing': spacing,
        if (listType == 'ordered') 'lineNumber': _getListIdentifier(indentLevel),
      });
      if (leading != null) leadingWidget = leading;
    }
    // use default leading builders
    if (leadingWidget == null) {
      if (listType == 'bullet') {
        final double? circleSize = firstSpanStyle?.fontSize == null ? null : firstSpanStyle!.fontSize! * 0.3;
        // we need to compute the margin size to position
        // the bullet where we expect
        final double? effectiveCircleMargin = circleSize != null ? (circleSize / 2) * 1.11 : null;
        leadingWidget = pw.Container(
          width: circleSize ?? 0.85 * PdfPageFormat.mm,
          height: circleSize ?? 0.85 * PdfPageFormat.mm,
          margin: pw.EdgeInsetsDirectional.only(bottom: effectiveCircleMargin ?? 0.85 * PdfPageFormat.mm),
          decoration: const pw.BoxDecoration(
            color: PdfColors.black,
            shape: pw.BoxShape.circle,
          ),
        );
      }
      if (listType == 'checked' || listType == 'unchecked') {
        leadingWidget = pw.Checkbox(
          activeColor: PdfColors.blue400,
          name: 'check ${Random.secure().nextInt(9999999) + 50}',
          value: listType == 'checked' ? true : false,
        );
      }
    }

    return pw.Directionality(
      textDirection: textDirection ?? directionality,
      child: pw.Container(
        width: pageWidth,
        padding: pw.EdgeInsetsDirectional.only(
          start: indentLevel > 0 ? indentLevel * 12.5 : 15,
          bottom: spacing?.resolvePaddingByLineHeight() ?? 1.5,
        ),
        child: pw.RichText(
          textAlign: (textDirection ?? directionality) == pw.TextDirection.rtl
              ? align.resolvePdfTextAlign.reversed
              : align.resolvePdfTextAlign,
          softWrap: true,
          overflow: pw.TextOverflow.span,
          textDirection: textDirection ?? directionality,
          text: pw.TextSpan(
            style: defaultTheme.defaultTextStyle,
            children: <pw.InlineSpan>[
              if (listType != 'ordered' || leadingWidget != null)
                pw.WidgetSpan(
                  child: leadingWidget!,
                  style: firstSpanStyle?.merge(defaultTheme.defaultTextStyle) ?? defaultTheme.defaultTextStyle,
                ),
              if (listType == 'ordered' && leadingWidget == null)
                pw.TextSpan(
                  text: _getListIdentifier(indentLevel),
                  style: firstSpanStyle ?? defaultTheme.defaultTextStyle,
                ),
              pw.TextSpan(
                text: '  ',
                style: firstSpanStyle?.merge(defaultTheme.defaultTextStyle) ?? defaultTheme.defaultTextStyle,
              ),
              ...spansToWrap
            ],
          ),
        ),
      ),
    );
  }

  String _getListIdentifier(int indentLevel) {
    if (indentLevel > 0) indentLevel--;
    // we verify if is alphabetic type
    // (when indent is 1 or 4, by default Flutter Quill takes them as a alphabetic list)
    if (indentLevel == 1 || indentLevel == 4) {
      return '${_getLetterIdentifier(indentLevel == 1 ? numberIndent1List : numberIndent4List)}.';
    }
    // we verify if is roman type
    // (when indent is 2 or 5, by default Flutter Quill takes them as a roman list)
    if (indentLevel == 2 || indentLevel == 5) {
      return '${(indentLevel == 2 ? numberIndent2List : numberIndent5List).toRomanNumeralString()}.';
    }
    // return common numbered list
    return '${indentLevel == 0 ? numberList : numberIndent3List}.';
  }

  String _getLetterIdentifier(int number) {
    const String letters = 'abcdefghijklmnopqrstuvwxyz';
    const int base = letters.length - 1;
    // set number to zero to let access to "a" index instead directly
    // to "b" if item number is "1"
    number--;
    if (number < 0) number = 0;
    String result = '';

    while (number >= 0) {
      result = letters[number % base] + result;
      number = (number ~/ base) - 1;
    }

    return result;
  }

  pw.TextSpan _getHighlight(
    String source, {
    String? language,
    required pw.TextStyle style,
  }) {
    final Result result = highlight.parse(
      source,
      language: language,
      autoDetection: language == null,
    );

    final List<Node>? codeNodes = result.nodes;
    if (codeNodes == null) {
      throw Exception('Code block parse error.');
    }
    return _convertResultToSpans(codeNodes, style: style);
  }

  // Copy from flutter.highlight package.
  // https://github.com/git-touch/highlight.dart/blob/master/flutter_highlight/lib/flutter_highlight.dart
  pw.TextSpan _convertResultToSpans(
    List<Node> nodes, {
    required pw.TextStyle style,
  }) {
    final List<pw.TextSpan> spans = <pw.TextSpan>[];
    final List<List<pw.TextSpan>> stack = <List<pw.TextSpan>>[<pw.TextSpan>[]];
    List<pw.TextSpan> currentSpans = spans;

    final Map<String, pw.TextStyle> cbTheme =
        customCodeHighlightTheme ?? (isLightCodeBlockTheme ? lightThemeInCodeblock : darkThemeInCodeBlock);

    void traverse(Node node) {
      if (node.value != null) {
        currentSpans.add(
          node.className == null
              ? pw.TextSpan(text: node.value)
              : pw.TextSpan(
                  text: node.value,
                  style: cbTheme[node.className] ??
                      style.merge(
                        defaultTheme.defaultTextStyle,
                      ),
                ),
        );
      } else if (node.children != null) {
        final List<pw.TextSpan> tmp = <pw.TextSpan>[];
        currentSpans.add(
          pw.TextSpan(children: tmp, style: cbTheme[node.className!]),
        );
        stack.add(currentSpans);
        currentSpans = tmp;

        for (final Node n in node.children!) {
          traverse(n);
          if (n == node.children!.last) {
            currentSpans = stack.isEmpty ? spans : stack.removeLast();
          }
        }
      }
    }

    for (final Node node in nodes) {
      traverse(node);
    }

    return pw.TextSpan(children: spans);
  }

  Future<Uint8List> _fetchBlobAsBytes(String blobUrl) async {
    final http.Response response = await http.get(Uri.parse(blobUrl));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Failed to load blob image');
    }
  }
}
