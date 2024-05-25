import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_quill_to_pdf/core/constant/constants.dart';
import 'package:flutter_quill_to_pdf/core/extensions/list_extension.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' show PdfColor, PdfColors;
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart';
import 'attribute_functions.dart';
import 'document_functions.dart';
import '../abstract_converter.dart';

abstract class PdfConfigurator<T, D> extends ConverterConfigurator<T, D>
    implements
        AttrInlineFunctions<List<pw.InlineSpan>, pw.TextStyle?>,
        AttrBlockFunctions<pw.Widget, pw.TextStyle?>,
        DocumentFunctions<Delta, List<String>, List<pw.Widget>> {
  late final PdfColor defaultLinkColor;
  late final pw.TextStyle defaultTextStyle;
  final Delta? frontM;
  final Delta? backM;
  final List<CustomConverter> customConverters;
  final Future<pw.Font> Function(String fontFamily) onRequestFont;
  final Future<pw.Font> Function(String fontFamily) onRequestBoldFont;
  final Future<pw.Font> Function(String fontFamily) onRequestItalicFont;
  final Future<pw.Font> Function(String fontFamily) onRequestBothFont;
  final CustomPDFWidget? onDetectImageBlock;
  final CustomPDFWidget? onDetectInlineRichTextStyles;
  final CustomPDFWidget? onDetectHeaderBlock;
  final CustomPDFWidget? onDetectHeaderAlignedBlock;
  final CustomPDFWidget? onDetectAlignedParagraph;
  final CustomPDFWidget? onDetectCommonText;
  final CustomPDFWidget? onDetectInlinesMarkdown;
  final CustomPDFWidget? onDetectLink;
  final CustomPDFWidget? onDetectList;
  final CustomPDFWidget? onDetectCodeBlock;
  final CustomPDFWidget? onDetectBlockquote;
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
  final Future<List<pw.Font>?> Function(String fontFamily)? onRequestFallbacks;
  final int defaultFontSize = Constant.DEFAULT_FONT_SIZE; //avoid spans without font sizes not appears in the document
  late final double pageWidth, pageHeight;
  int _numCodeLine = 0;
  PdfConfigurator({
    required this.onRequestBoldFont,
    required this.onRequestBothFont,
    required this.onRequestFallbacks,
    required this.onRequestFont,
    required this.onRequestItalicFont,
    required this.customConverters,
    required super.document,
    this.blockQuotePaddingLeft,
    this.blockQuotePaddingRight,
    this.blockQuotethicknessDividerColor,
    this.blockQuoteBackgroundColor,
    this.codeBlockBackgroundColor,
    this.codeBlockNumLinesTextStyle,
    this.codeBlockTextStyle,
    this.blockQuoteDividerColor,
    this.blockQuoteTextStyle,
    this.codeBlockFont,
    this.onDetectBlockquote,
    this.onDetectCodeBlock,
    this.onDetectAlignedParagraph,
    this.onDetectCommonText,
    this.onDetectHeaderAlignedBlock,
    this.onDetectHeaderBlock,
    this.onDetectInlinesMarkdown,
    this.onDetectLink,
    this.onDetectList,
    this.onDetectInlineRichTextStyles,
    this.onDetectImageBlock,
    this.backM,
    this.frontM,
  }) {
    defaultLinkColor = const PdfColor.fromInt(0x2AAB);
  }

  //Network image is not supported yet
  @override
  Future<pw.Widget?> getImageBlock(String line, [pw.Alignment? alignment]) async {
    final RegExpMatch? match = Constant.IMAGE_PATTERN.firstMatch(line);
    double? width = null;
    double? height = null;
    if (match != null) {
      final String objectFit = match.group(2)!;
      if (match.group(6) != null) width = double.tryParse(match.group(7)!);
      if (match.group(8) != null) width = double.tryParse(match.group(9)!);
      final String path = match.group(10)!;
      late final File? file;
      if (Constant.IMAGE_FROM_NETWORK_URL.hasMatch(path)) {
        final String url = path;
        final String pathStorage = '${(await getApplicationCacheDirectory()).path}/image (${Random.secure().nextInt(99999) + 50})';
        try {
          file = File(pathStorage);
          await Dio().download(url, pathStorage);
        } on DioException catch (e) {
          final Map<String, dynamic> mapError = <String, dynamic>{
            'error': e.error,
            'message': e.message,
            'request_options': e.requestOptions,
            'response': e.response,
            'stacktrace': e.stackTrace,
            'type': e.type.name,
          };
          debugPrint('${e.message}\n\n${jsonEncode(mapError)}');
          return null;
        }
      }
      file = File(path);
      if (!(await file.exists())) {
        //if not exist the image will create a warning
        return null;
      }
      //calculate exceded height using page format params
      if (height != null && height >= pageHeight) height = pageHeight;
      //calculate exceded width using page format params
      if (width != null && width >= pageWidth) width = pageWidth;
      //calculating object fit type instead use object fit literal enum (it causes out of memory errors)
      if (objectFit.equals('cover') || objectFit.equals('fill')) {
        return pw.Wrap(
          children: <pw.Widget>[
            pw.Container(
              alignment: alignment,
              child: pw.Image(
                pw.MemoryImage((await file.readAsBytes())),
                dpi: 230,
                fit: pw.BoxFit.fitWidth,
                height: pageHeight,
                width: pageWidth,
              ),
            ),
          ],
        );
      }
      if (objectFit.equals('fill-all')) {
        return pw.RichText(
          softWrap: true,
          overflow: pw.TextOverflow.span,
          text: pw.WidgetSpan(
            child: pw.Container(
              alignment: alignment,
              child: pw.Image(
                pw.MemoryImage((await file.readAsBytes())),
                dpi: 230,
                fit: pw.BoxFit.contain,
                height: pageWidth,
                width: pageWidth,
              ),
            ),
          ),
        );
      }
      if (objectFit.equals('fitWidth')) {
        return pw.RichText(
          softWrap: true,
          overflow: pw.TextOverflow.span,
          text: pw.WidgetSpan(
            child: pw.Container(
              alignment: alignment,
              child: pw.Image(
                pw.MemoryImage((await file.readAsBytes())),
                dpi: 230,
                fit: pw.BoxFit.fitWidth,
                height: height,
              ),
            ),
          ),
        );
      }
      if (objectFit.equals('fitHeight')) {
        return pw.RichText(
          softWrap: true,
          overflow: pw.TextOverflow.span,
          text: pw.WidgetSpan(
            child: pw.Container(
              alignment: alignment,
              child: pw.Image(
                pw.MemoryImage((await file.readAsBytes())),
                dpi: 230,
                fit: pw.BoxFit.fitHeight,
                width: width,
              ),
            ),
          ),
        );
      }
      return pw.RichText(
        softWrap: true,
        overflow: pw.TextOverflow.span,
        text: pw.WidgetSpan(
          child: pw.Container(
            alignment: alignment,
            child: pw.Image(
              pw.MemoryImage((await file.readAsBytes())),
              dpi: 230,
              fit: objectFit.resolvePdfFit,
              height: height,
              width: width,
            ),
          ),
        ),
      );
    }
    return null;
  }

  @override
  Future<List<pw.InlineSpan>> getRichTextInlineStyles(String line,
      [pw.TextStyle? style, bool returnContentIfNeedIt = false, bool addFontSize = true]) async {
    final List<pw.InlineSpan> spans = <pw.InlineSpan>[];
    final Iterable<RegExpMatch> matches = Constant.RICH_TEXT_INLINE_STYLES_PATTERN.allMatches(line);
    int i = 0;
    int currentIndex = 0;
    while (i < matches.length) {
      final RegExpMatch match = matches.elementAt(i);
      final String plainText = line.substring(currentIndex, match.start);
      if (plainText.isNotEmpty) {
        if (Constant.INLINE_MATCHER.hasMatch(plainText)) {
          spans.add(pw.TextSpan(
              children: await applyInlineStyles(plainText, style, addFontSize),
              style: style ?? defaultTextStyle)); // Apply currentinheritedStyle
        } else {
          spans.add(pw.TextSpan(text: plainText.decodeSymbols, style: style ?? defaultTextStyle)); // Apply currentinheritedStyle
        }
      }

      final PdfColor? textColor = pdfColorString(match.group(4) ?? match.group(5));
      final PdfColor? backgroundTextColor = pdfColorString(match.group(11) ?? match.group(12));
      final double? spacing = double.tryParse(match.group(21) ?? '');
      final String? fontFamily = match.group(23);
      final double? fontSizeMatch = double.tryParse(match.group(26) ?? '');
      final double? fontSize = !addFontSize ? null : fontSizeMatch;
      final String content = match.group(28) ?? '';
      final double? lineSpacing = spacing?.resolveLineHeight();
      final pw.Font font = await onRequestFont.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY);
      final List<pw.Font> fonts = await onRequestFallbacks?.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY) ?? <pw.Font>[];
      // Give just the necessary fallbacks for the founded fontFamily
      final pw.TextStyle decided_style = style?.copyWith(
            font: font,
            fontBold: await onRequestBoldFont.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY),
            fontItalic: await onRequestItalicFont.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY),
            fontBoldItalic: await onRequestBothFont.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY),
            fontFallback: fonts,
            fontSize: !addFontSize ? null : fontSize ?? defaultFontSize.toDouble(),
            lineSpacing: lineSpacing,
            color: textColor,
            background: pw.BoxDecoration(color: backgroundTextColor),
            decorationColor: textColor ?? backgroundTextColor,
          ) ??
          defaultTextStyle.copyWith(
            font: font,
            fontBold: await onRequestBoldFont.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY),
            fontItalic: await onRequestItalicFont.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY),
            fontBoldItalic: await onRequestBothFont.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY),
            fontFallback: fonts,
            fontSize: !addFontSize ? null : fontSize ?? defaultFontSize.toDouble(),
            lineSpacing: lineSpacing,
            color: textColor,
            background: pw.BoxDecoration(color: backgroundTextColor),
            decorationColor: textColor ?? backgroundTextColor,
          );
      spans.add(
        pw.TextSpan(children: await applyInlineStyles(content, decided_style, addFontSize), style: decided_style),
      );
      currentIndex = match.end;
      i++;
    }
    final String remainingText = line.substring(currentIndex);
    if (remainingText.isNotEmpty) {
      if (Constant.INLINE_MATCHER.hasMatch(remainingText)) {
        spans.add(pw.TextSpan(
            children: await applyInlineStyles(remainingText, style, addFontSize),
            style: style ?? defaultTextStyle)); // Apply currentinheritedStyle
      } else {
        spans.add(pw.TextSpan(text: remainingText.decodeSymbols, style: style ?? defaultTextStyle)); // Apply currentinheritedStyle
      }
    }
    if (returnContentIfNeedIt && spans.isEmpty) return <pw.TextSpan>[pw.TextSpan(text: line, style: style)];
    return spans;
  }

  @override
  Future<List<pw.Widget>> getBlockQuote(String line, [pw.TextStyle? style]) async {
    final List<pw.Widget> widgets = <pw.Widget>[];
    final pw.TextStyle defaultStyle = pw.TextStyle(color: PdfColor.fromHex("#808080"));
    final pw.TextStyle blockquoteStyle = blockQuoteTextStyle ?? defaultStyle;
    final Iterable<RegExpMatch> matches = Constant.BLOCKQUOTE_PATTERN.allMatches(line);
    for (int i = 0; i < matches.length; i++) {
      final RegExpMatch match = matches.elementAt(i);
      final String content = match.group(1)!;
      final String fixedContent = content
          .decodeSymbols.convertUTF8QuotesToValidString; //we must to replace this, because the issue comes to coverter from delta to html|
      final List<pw.InlineSpan> spans = await _getStylesSpans(fixedContent);
      widgets.add(
        pw.Container(
          width: pageWidth,
          padding: const pw.EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
          decoration: pw.BoxDecoration(
            color: this.blockQuoteBackgroundColor ?? PdfColor.fromHex('#fbfbf9'),
            border: pw.Border(
              left: pw.BorderSide(
                color: blockQuoteDividerColor ?? PdfColors.blue,
                width: blockQuotethicknessDividerColor ?? 2.5,
              ),
            ),
          ),
          child: pw.RichText(
            softWrap: true,
            overflow: pw.TextOverflow.span,
            text: pw.TextSpan(
              style: blockquoteStyle,
              children: <pw.InlineSpan>[...spans],
            ),
          ),
        ),
      );
    }
    return widgets;
  }

  @override
  Future<List<pw.Widget>> getCodeBlock(String line, [pw.TextStyle? style]) async {
    final List<pw.Widget> spans = <pw.Widget>[];
    final pw.TextStyle defaultStyle = pw.TextStyle(
      fontSize: 12,
      font: codeBlockFont ?? pw.Font.courier(),
      fontFallback: <pw.Font>[pw.Font.courierBold(), pw.Font.courierBoldOblique(), pw.Font.courierOblique(), pw.Font.symbol()],
      letterSpacing: 1.5,
      lineSpacing: 1.1,
      wordSpacing: 0.5,
      color: PdfColor.fromHex("#808080"),
    );
    final pw.TextStyle codeBlockStyle = codeBlockTextStyle ?? defaultStyle;
    final Iterable<RegExpMatch> matches = Constant.CODE_PATTERN.allMatches(line);
    for (int i = 0; i < matches.length; i++) {
      final RegExpMatch match = matches.elementAt(i);
      final String codeBlock = match.group(1)!;
      final String fixedBlock = codeBlock
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>'); //we must to replace this, because the issue comes to coverter from delta to html|
      if (fixedBlock.contains('\n')) {
        final List<String> splittedBlock = fixedBlock.split('\n');
        if (splittedBlock.isNotEmpty && splittedBlock[splittedBlock.length - 1] == '') {
          splittedBlock.removeLast();
        }
        for (String newLine in splittedBlock) {
          _numCodeLine += 1;
          spans.add(pw.Container(
            width: pageWidth,
            color: this.codeBlockBackgroundColor ?? PdfColor.fromHex('#fbfbf9'),
            child: pw.RichText(
              softWrap: true,
              overflow: pw.TextOverflow.span,
              text: pw.TextSpan(
                style: codeBlockStyle,
                children: <pw.InlineSpan>[
                  pw.TextSpan(text: "$_numCodeLine", style: codeBlockNumLinesTextStyle),
                  pw.TextSpan(text: "   $newLine"),
                ],
              ),
            ),
          ));
        }
      } else {
        _numCodeLine += 1;
        spans.add(pw.Container(
          width: pageWidth,
          color: this.codeBlockBackgroundColor ?? PdfColor.fromHex('#fbfbf9'),
          child: pw.RichText(
            softWrap: true,
            overflow: pw.TextOverflow.span,
            text: pw.TextSpan(
              style: codeBlockStyle,
              children: <pw.InlineSpan>[
                pw.TextSpan(text: "$_numCodeLine", style: codeBlockNumLinesTextStyle),
                pw.TextSpan(text: "   $fixedBlock"),
              ],
            ),
          ),
        ));
      }
    }
    _numCodeLine = 0;
    return spans;
  }

  Future<List<pw.TextSpan>> applyInlineStyles(String line, [pw.TextStyle? style, bool addFontSize = true]) async {
    final List<pw.TextSpan> spans = <pw.TextSpan>[];
    final pw.TextStyle? inheritedStyle = style;
    final Iterable<RegExpMatch> matches = Constant.INLINE_MATCHER.allMatches(line);
    int currentIndex = 0;
    int i = 0;
    while (i < matches.length) {
      final RegExpMatch match = matches.elementAt(i);
      final String plainText = line.substring(currentIndex, match.start);
      if (plainText.isNotEmpty) {
        if (Constant.INLINE_MATCHER.hasMatch(plainText)) {
          spans.add(pw.TextSpan(
              children: await applyInlineStyles(plainText.convertUTF8QuotesToValidString, inheritedStyle, addFontSize),
              style: inheritedStyle ?? defaultTextStyle)); // Apply currentinheritedStyle
        } else {
          spans.add(pw.TextSpan(
              text: plainText.convertUTF8QuotesToValidString.decodeSymbols,
              style: inheritedStyle ?? defaultTextStyle)); // Apply currentinheritedStyle
        }
      }
      final String? contentInlineStyles = match.group(2) ?? match.group(4) ?? match.group(6) ?? match.group(8); //inline
      final String? contentLink = match.group(15); //link
      final List<pw.TextSpan> spansLineStyle =
          await getInlineStyles(contentInlineStyles?.convertUTF8QuotesToValidString ?? '', inheritedStyle);
      final List<pw.TextSpan> spansLinkStyle =
          await getLinkStyle(contentLink?.convertUTF8QuotesToValidString ?? '', inheritedStyle, addFontSize);
      spans.merge(<List<pw.TextSpan>>[spansLineStyle, spansLinkStyle]);
      currentIndex = match.end;
      i++;
    }
    final String remainingText = line.substring(currentIndex);
    if (remainingText.isNotEmpty) {
      if (Constant.INLINE_MATCHER.hasMatch(remainingText)) {
        spans.add(pw.TextSpan(
            children: await applyInlineStyles(remainingText.convertUTF8QuotesToValidString, inheritedStyle, addFontSize),
            style: inheritedStyle ?? defaultTextStyle)); // Apply currentinheritedStyle
      } else {
        spans.add(pw.TextSpan(
            text: remainingText.convertUTF8QuotesToValidString.decodeSymbols,
            style: inheritedStyle ?? defaultTextStyle)); // Apply currentinheritedStyle
      }
    }
    return spans;
  }

  @override
  Future<List<pw.TextSpan>> getLinkStyle(String line, [pw.TextStyle? style, bool addFontSize = true]) async {
    final List<pw.TextSpan> spans = <pw.TextSpan>[];
    final Iterable<RegExpMatch> matches = Constant.HTML_LINK_TAGS_PATTERN.allMatches(line);
    int currentIndexMatch = 0;
    int i = 0;
    while (i < matches.length) {
      final RegExpMatch match = matches.elementAt(i);
      final String plainText = line.substring(currentIndexMatch, match.start);
      if (plainText.isNotEmpty) {
        if (Constant.INLINE_MATCHER.hasMatch(plainText)) {
          spans.add(pw.TextSpan(
              children: await applyInlineStyles(plainText.convertUTF8QuotesToValidString, style, addFontSize),
              style: style ?? defaultTextStyle)); // Apply currentinheritedStyle
        } else {
          spans.add(pw.TextSpan(
              text: plainText.convertUTF8QuotesToValidString.decodeSymbols,
              style: style ?? defaultTextStyle)); // Apply currentinheritedStyle
        }
      }
      //get content into [title]
      final double? fontSize = double.tryParse(match.group(10) ?? '');
      final double? lineHeight = double.tryParse(match.group(5) ?? '');
      final String? fontFamily = match.group(8);
      final double? lineSpacing = lineHeight?.resolveLineHeight();
      final String href = match.group(11)!;
      final String hrefContent = match.group(13)!;
      final pw.Font font = await onRequestFont.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY);
      final List<pw.Font> fonts = await onRequestFallbacks?.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY) ?? <pw.Font>[];
      spans.add(
        pw.TextSpan(
          annotation: pw.AnnotationLink(href),
          text: hrefContent,
          style: (style ?? defaultTextStyle).copyWith(
            color: defaultLinkColor,
            font: font,
            fontBold: await onRequestBoldFont.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY),
            fontItalic: await onRequestItalicFont.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY),
            fontBoldItalic: await onRequestBothFont.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY),
            fontFallback: fonts,
            fontSize: !addFontSize ? null : fontSize ?? defaultFontSize.toDouble(),
            lineSpacing: lineSpacing,
            decoration: pw.TextDecoration.underline,
            decorationStyle: pw.TextDecorationStyle.solid,
            decorationColor: defaultLinkColor,
          ),
        ),
      );
      currentIndexMatch = match.end;
      i++;
    }
    final String remainingText = line.substring(currentIndexMatch);
    if (remainingText.isNotEmpty) {
      if (Constant.INLINE_MATCHER.hasMatch(remainingText)) {
        spans.add(pw.TextSpan(
            children: await applyInlineStyles(remainingText, style, addFontSize),
            style: style ?? defaultTextStyle)); // Apply currentinheritedStyle
      } else {
        spans.add(pw.TextSpan(
            text: remainingText.convertUTF8QuotesToValidString.decodeSymbols, style: style ?? defaultTextStyle)); // Apply current style
      }
    }
    return spans;
  }

  Future<List<pw.TextSpan>> getNewLinesWithSpacing(String line, [pw.TextStyle? style]) async {
    final List<pw.TextSpan> spans = <pw.TextSpan>[];
    final Iterable<RegExpMatch> matches = Constant.NEWLINE_WITH_SPACING_PATTERN.allMatches(line);
    for (int i = 0; i < matches.length; i++) {
      final RegExpMatch match = matches.elementAt(i);
      final double? spacing = double.tryParse(match.group(2)!);
      final String content = match.group(3)!;
      final pw.TextStyle decided_style = style?.copyWith(lineSpacing: spacing?.resolveLineHeight()) ??
          defaultTextStyle.copyWith(lineSpacing: spacing?.resolveLineHeight());
      spans.add(pw.TextSpan(text: content.convertUTF8QuotesToValidString.decodeSymbols, style: decided_style));
    }
    return spans;
  }

  @override
  Future<List<pw.TextSpan>> getInlineStyles(String line, [pw.TextStyle? style]) async {
    final List<pw.TextSpan> spans = <pw.TextSpan>[];
    final Iterable<RegExpMatch> matches = Constant.INLINE_STYLES_PATTERN.allMatches(line);
    int currentIndex = 0;
    int i = 0;
    while (i < matches.length) {
      final RegExpMatch match = matches.elementAt(i);
      final String plainText = line.substring(currentIndex, match.start);
      if (plainText.isNotEmpty) {
        if (Constant.INLINE_MATCHER.hasMatch(plainText)) {
          spans.add(pw.TextSpan(
              children: await applyInlineStyles(plainText, style), style: style ?? defaultTextStyle)); // Apply currentinheritedStyle
        } else {
          spans.add(pw.TextSpan(
              text: plainText.convertUTF8QuotesToValidString.decodeSymbols,
              style: style ?? defaultTextStyle)); // Apply currentinheritedStyle
        }
      }
      final String contentWithMd = match.group(0)!;
      final String content = match.group(2)!;
      final bool isBold = contentWithMd.isBold;
      final bool isItalic = contentWithMd.isItalic;
      final bool isUnder = contentWithMd.isUnderline;
      final bool isBoldItalicUnderline = contentWithMd.isAllStylesCombined;
      late pw.TextStyle textStyle;
      if (style == null) {
        textStyle = defaultTextStyle.resolveInline(isBold, isItalic, isUnder, isBoldItalicUnderline);
      } else {
        textStyle = style.resolveInline(isBold, isItalic, isUnder, isBoldItalicUnderline);
      }
      spans.add(pw.TextSpan(text: content.convertUTF8QuotesToValidString.replaceMd.decodeSymbols, style: textStyle));
      currentIndex = match.end;
      i++;
    }

    final String remainingText = line.substring(currentIndex);
    if (remainingText.isNotEmpty) {
      if (Constant.INLINE_MATCHER.hasMatch(remainingText)) {
        spans.add(pw.TextSpan(
            children: await applyInlineStyles(remainingText, style), style: style ?? defaultTextStyle)); // Apply currentinheritedStyle
      } else {
        spans.add(pw.TextSpan(
            text: remainingText.convertUTF8QuotesToValidString.decodeSymbols,
            style: style ?? defaultTextStyle)); // Apply currentinheritedStyle
      }
    }
    return spans;
  }

  @override
  Future<pw.Widget> getHeaderBlock(String line, [pw.TextStyle? style]) async {
    final RegExpMatch match = Constant.HEADER_PATTERN.firstMatch(line)!;

    final String headerLevel = match.group(1)!;
    final String headerText = match.group(2)!;
    final double defaultFontSize = headerLevel.resolveHeaderLevel();
    final pw.TextStyle textStyle = style ?? defaultTextStyle.copyWith(fontSize: defaultFontSize);
    final List<pw.InlineSpan> spans = await getRichTextInlineStyles(
      headerText.replaceAllMapped(Constant.STARTS_WITH_RICH_TEXT_INLINE_STYLES_PATTERN, (Match match) {
        final String content = match.group(10)!;
        final String? fontFamily = match.group(7);
        if (fontFamily == null) return content;
        return '<span style="font-family: $fontFamily">$content</span>';
      }),
      textStyle,
      true,
      false,
    );
    return pw.Container(
        padding: const pw.EdgeInsets.only(top: 7, bottom: 3.5),
        child: pw.RichText(
          softWrap: true,
          overflow: pw.TextOverflow.span,
          text: pw.TextSpan(
            children: spans,
          ),
        ));
  }

  @override
  Future<List<pw.Widget>> getAlignedHeaderBlock(String line, [pw.TextStyle? style]) async {
    final RegExpMatch match = Constant.ALIGNED_HEADER_PATTERN.firstMatch(line)!;
    final List<pw.Widget> widgets = <pw.Widget>[];
    final String hLevel = match.group(1)!;
    final String alignment = match.group(2)!;
    String content = match.group(3)!;
    //Verify if there's a error like: into a <h[n]> <span style="line-lineSpacing: 3.0;font-size: 14">Header into a span</span>
    //resolving alignments
    final pw.Alignment al = alignment.resolvePdfBlockAlign;
    final pw.TextAlign textAlign = alignment.resolvePdfTextAlign;
    //verify first if the header contains html new lines
    //remove br's
    final double currentFontSize = hLevel.resolveHeaderLevel();
    final pw.TextStyle header_style = style?.copyWith(fontSize: currentFontSize) ?? defaultTextStyle.copyWith(fontSize: currentFontSize);
    final List<pw.InlineSpan> spans = await _getStylesSpans(content, header_style, false, false);
    widgets.add(
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 7),
        alignment: al,
        child: pw.RichText(
          textAlign: textAlign,
          softWrap: true,
          overflow: pw.TextOverflow.span,
          text: pw.TextSpan(children: spans),
        ),
      ),
    );
    return widgets;
  }

  @override
  Future<List<pw.Widget>> getAlignedParagraphBlock(String line, [pw.TextStyle? style]) async {
    if (Constant.HTML_IMAGE_PATTERN.hasMatch(line)) {
      final RegExp matcher = Constant.HTML_IMAGE_PATTERN;
      final RegExpMatch match = matcher.firstMatch(line)!;
      final pw.Alignment alignment = match.group(1)!.resolvePdfBlockAlign;
      final String sourceImage = match.group(2)!;
      String mdImage = convertHtmlToMarkdown(sourceImage, rules, <String>[]);
      return <pw.Widget>[(await getImageBlock.call(mdImage, alignment)) ?? pw.SizedBox()];
    }
    final Iterable<RegExpMatch> matches = Constant.ALIGNED_P_PATTERN.allMatches(line);
    final List<pw.Widget> widgets = <pw.Widget>[];
    int index = 0;
    while (index < matches.length) {
      final RegExpMatch match = matches.elementAt(index);
      final String alignment = match.group(1)!;
      final String content = match.group(2)!;
      final pw.Alignment blockAlign = alignment.resolvePdfBlockAlign;
      final List<pw.InlineSpan> spans = <pw.InlineSpan>[];
      if (content.isNotEmpty) {
        spans.addAll(await _getStylesSpans(content, style));
      }

      widgets.add(
        pw.Container(
          alignment: blockAlign,
          padding: const pw.EdgeInsets.symmetric(vertical: 2),
          child: pw.RichText(
            textAlign: alignment.resolvePdfTextAlign,
            softWrap: true,
            overflow: pw.TextOverflow.span,
            text: pw.TextSpan(
              children: spans,
            ),
          ),
        ),
      );
      index++;
    }
    return widgets;
  }

  @override
  Future<pw.Widget> getListBlock(String line, bool isCheckList, [pw.TextStyle? style]) async {
    final List<pw.WidgetSpan> widgets = <pw.WidgetSpan>[];
    final RegExpMatch? checkMatch = Constant.LIST_CHECK_MD_PATTERN.firstMatch(line);
    final RegExpMatch? listMatch = Constant.LIST_PATTERN.firstMatch(line);
    final List<pw.InlineSpan> styledWidgets = <pw.InlineSpan>[];
    if (!isCheckList && listMatch != null) {
      final String typeList = listMatch.group(1)!;
      final String content = listMatch.group(2)!;
      styledWidgets.addAll(await _getStylesSpans(content, style));
      if (typeList.startsWith('*')) {
        //replace with bullet widget by error with fonts callback
        widgets.add(
          pw.WidgetSpan(
            child: pw.Container(
              padding: const pw.EdgeInsets.only(left: 15, bottom: 1.5),
              child: pw.RichText(
                softWrap: true,
                overflow: pw.TextOverflow.span,
                text: pw.TextSpan(
                  text: '• ',
                  children: <pw.InlineSpan>[
                    pw.TextSpan(children: styledWidgets),
                  ],
                ),
              ),
            ),
          ),
        );
        return pw.RichText(text: pw.TextSpan(children: widgets));
      }
      widgets.add(
        pw.WidgetSpan(
          child: pw.Container(
            padding: const pw.EdgeInsets.only(left: 15, bottom: 1.5),
            child: pw.RichText(
              softWrap: true,
              overflow: pw.TextOverflow.span,
              text: pw.TextSpan(
                text: '$typeList ',
                children: <pw.InlineSpan>[
                  pw.TextSpan(children: styledWidgets),
                ],
              ),
            ),
          ),
        ),
      );
      return pw.RichText(
        softWrap: true,
        overflow: pw.TextOverflow.span,
        text: pw.TextSpan(children: widgets),
      );
    }
    if (checkMatch != null) {
      final bool checked = checkMatch.group(2) != ' ';
      final String? align = checkMatch.group(4);
      final String content = checkMatch.group(5)!;
      styledWidgets.addAll(await _getStylesSpans(content, style));
      widgets.add(pw.WidgetSpan(
        child: pw.Container(
          padding: const pw.EdgeInsets.only(left: 15, bottom: 1.5),
          child: pw.Row(
            children: <pw.Widget>[
              pw.Checkbox(
                activeColor: PdfColors.blue400,
                name: 'check ${Random.secure().nextInt(9999999) + 50}',
                value: checked,
              ),
              pw.Expanded(
                child: pw.RichText(
                  textAlign: align?.resolvePdfTextAlign,
                  softWrap: true,
                  overflow: pw.TextOverflow.span,
                  text: pw.TextSpan(
                    children: <pw.InlineSpan>[
                      pw.TextSpan(children: <pw.InlineSpan>[...styledWidgets])
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ));
    }
    return pw.RichText(
      softWrap: true,
      overflow: pw.TextOverflow.span,
      text: pw.TextSpan(children: widgets),
    );
  }

  Future<List<pw.InlineSpan>> _getStylesSpans(String content,
      [pw.TextStyle? style, bool returnContentIfNeedIt = false, bool addFontSize = true]) async {
    if (Constant.RICH_TEXT_INLINE_STYLES_PATTERN.hasMatch(content)) {
      return await getRichTextInlineStyles(content, style, returnContentIfNeedIt, addFontSize);
    } else {
      return await applyInlineStyles(content, style, addFontSize);
    }
  }
}
