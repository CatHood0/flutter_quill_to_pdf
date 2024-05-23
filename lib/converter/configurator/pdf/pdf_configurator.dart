import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:quill_to_pdf/core/constant/constants.dart';
import 'package:quill_to_pdf/core/extensions/list_extension.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:quill_to_pdf/quill_to_pdf.dart';
import '../attribute_functions.dart';
import '../book_functions.dart';
import '../abstract_converter.dart';

abstract class PdfConfigurator<T, D> extends ConverterConfigurator<T, D>
    implements
        AttrInlineFunctions<List<pw.InlineSpan>, pw.TextStyle?>,
        AttrBlockFunctions<pw.Widget, pw.TextStyle?>,
        BookFunctions<Delta, List<String>, List<pw.Widget>> {
  late final PdfColor default_link_color;
  late final pw.TextStyle default_style;
  final Delta? frontM;
  final Delta? backM;
  final List<CustomConverter> customConverters;
  final Future<pw.Font> Function(String fontFamily) onRequestFont;
  final Future<pw.Font> Function(String fontFamily) onRequestBoldFont;
  final Future<pw.Font> Function(String fontFamily) onRequestItalicFont;
  final Future<pw.Font> Function(String fontFamily) onRequestBothFont;
  final CustomPDFWidget? onDetectImageBlock;

  ///Detect Rich text styles like: size, spacing, font family
  final CustomPDFWidget? onDetectInlineRichTextStyles;

  ///Detect simple: # header
  final CustomPDFWidget? onDetectHeaderBlock;

  ///Detect html headers: <h1 style="text-align:center">header</h1>
  final CustomPDFWidget? onDetectHeaderAlignedBlock;

  ///Detect html headers: <p style="text-align:center">header</p>
  final CustomPDFWidget? onDetectAlignedParagraph;

  ///Detect simple text like: <p>paragraph</p> or <span>paragrap</span> or even plain text
  final CustomPDFWidget? onDetectCommonText;

  ///Detect classic inline markdown styles: **bold** *italic* _underline_ [strikethrogh is not supported yet]
  final CustomPDFWidget? onDetectInlinesMarkdown;

  ///Detect custom and common html links implementation like:
  ///<a style="line-height:1.0;font-family:Times new roman;font-size:12px" href="https://google.com" target="_blank">link to google</a>
  ///<a href="https://google.com" target="_blank">link to google</a>
  final CustomPDFWidget? onDetectLink;
  //Detect markdown list: * bullet, 1. ordered, [x] check list (still has errors in render or in detect indent)
  final CustomPDFWidget? onDetectList;
  final Future<List<pw.Font>?> Function(String fontFamily)? onRequestFallbacks;
  final int defaultFontSize = Constant.DEFAULT_FONT_SIZE; //avoid spans without font sizes not appears in the document
  late final double pageWidth, pageHeight;

  PdfConfigurator({
    required this.onRequestBoldFont,
    required this.onRequestBothFont,
    required this.onRequestFallbacks,
    required this.onRequestFont,
    required this.onRequestItalicFont,
    required this.customConverters,
    required super.document,
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
    default_link_color = const PdfColor.fromInt(0x2AAB);
  }

  //Network image is not supported yet
  @override
  Future<pw.Widget?> imageBlock(String line, [pw.Alignment? alignment]) async {
    final RegExpMatch? match = Constant.IMAGE_PATTERN.firstMatch(line);
    double? width = null;
    double? height = null;
    if (match != null) {
      final String objectFit = match.group(2)!;
      if (match.group(6) != null) width = double.tryParse(match.group(7)!);
      if (match.group(8) != null) width = double.tryParse(match.group(9)!);
      final String path = match.group(10)!;
      final File file = File(path);
      if (!(await file.exists())) {
        //if not exist the image will create a warning
        //TODO: add check to validate is the path really is a base64 and not a file path
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
  Future<List<pw.InlineSpan>> getDocLinksSpacingFontsStyle(String line,
      [pw.TextStyle? style, bool returnContentIfNeedIt = false, bool addFontSize = true]) async {
    final List<pw.InlineSpan> spans = <pw.InlineSpan>[];
    final Iterable<RegExpMatch> matches = Constant.INLINES_RICH_TEXT_PATTERN.allMatches(line);
    int i = 0;
    int currentIndex = 0;
    while (i < matches.length) {
      final RegExpMatch match = matches.elementAt(i);
      final String plainText = line.substring(currentIndex, match.start);
      if (plainText.isNotEmpty) {
        if (Constant.INLINE_MATCHER.hasMatch(plainText)) {
          spans.add(pw.TextSpan(
              children: await getAllStyles(plainText, style, addFontSize), style: style ?? default_style)); // Apply currentinheritedStyle
        } else {
          spans.add(pw.TextSpan(text: plainText.decodeSymbols, style: style ?? default_style)); // Apply currentinheritedStyle
        }
      }
      final double? spacing = double.tryParse(match.group(4) ?? '');
      final String? fontFamily = match.group(7);
      String? sizeMatch = match.group(8) ?? 'null';
      final double? fontSizeMatch = !addFontSize ? null : double.tryParse(sizeMatch);
      final double? fontSize = !addFontSize ? null : fontSizeMatch;
      final String content = match.group(10) ?? '';
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
              lineSpacing: lineSpacing) ??
          default_style.copyWith(
            font: font,
            fontBold: await onRequestBoldFont.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY),
            fontItalic: await onRequestItalicFont.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY),
            fontBoldItalic: await onRequestBothFont.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY),
            fontFallback: fonts,
            fontSize: !addFontSize ? null : fontSize ?? defaultFontSize.toDouble(),
            lineSpacing: lineSpacing,
          );
      spans.add(
        pw.TextSpan(children: await getAllStyles(content, decided_style, addFontSize), style: decided_style),
      );
      currentIndex = match.end;
      i++;
    }
    final String remainingText = line.substring(currentIndex);
    if (remainingText.isNotEmpty) {
      if (Constant.INLINE_MATCHER.hasMatch(remainingText)) {
        spans.add(pw.TextSpan(
            children: await getAllStyles(remainingText, style, addFontSize), style: style ?? default_style)); // Apply currentinheritedStyle
      } else {
        spans.add(pw.TextSpan(text: remainingText.decodeSymbols, style: style ?? default_style)); // Apply currentinheritedStyle
      }
    }
    if (returnContentIfNeedIt && spans.isEmpty) return <pw.TextSpan>[pw.TextSpan(text: line, style: style)];
    return spans;
  }

  Future<List<pw.TextSpan>> getAllStyles(String line, [pw.TextStyle? style, bool addFontSize = true]) async {
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
              children: await getAllStyles(plainText.convertUTF8QuotesToValidString, inheritedStyle, addFontSize),
              style: inheritedStyle ?? default_style)); // Apply currentinheritedStyle
        } else {
          spans.add(pw.TextSpan(
              text: plainText.convertUTF8QuotesToValidString.decodeSymbols,
              style: inheritedStyle ?? default_style)); // Apply currentinheritedStyle
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
            children: await getAllStyles(remainingText.convertUTF8QuotesToValidString, inheritedStyle, addFontSize),
            style: inheritedStyle ?? default_style)); // Apply currentinheritedStyle
      } else {
        spans.add(pw.TextSpan(
            text: remainingText.convertUTF8QuotesToValidString.decodeSymbols,
            style: inheritedStyle ?? default_style)); // Apply currentinheritedStyle
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
              children: await getAllStyles(plainText.convertUTF8QuotesToValidString, style, addFontSize),
              style: style ?? default_style)); // Apply currentinheritedStyle
        } else {
          spans.add(pw.TextSpan(
              text: plainText.convertUTF8QuotesToValidString.decodeSymbols, style: style ?? default_style)); // Apply currentinheritedStyle
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
          style: (style ?? default_style).copyWith(
            color: default_link_color,
            font: font,
            fontBold: await onRequestBoldFont.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY),
            fontItalic: await onRequestItalicFont.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY),
            fontBoldItalic: await onRequestBothFont.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY),
            fontFallback: fonts,
            fontSize: !addFontSize ? null : fontSize ?? defaultFontSize.toDouble(),
            lineSpacing: lineSpacing,
            decoration: pw.TextDecoration.underline,
            decorationStyle: pw.TextDecorationStyle.solid,
            decorationColor: default_link_color,
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
            children: await getAllStyles(remainingText, style, addFontSize), style: style ?? default_style)); // Apply currentinheritedStyle
      } else {
        spans.add(pw.TextSpan(
            text: remainingText.convertUTF8QuotesToValidString.decodeSymbols, style: style ?? default_style)); // Apply current style
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
      final pw.TextStyle decided_style =
          style?.copyWith(lineSpacing: spacing?.resolveLineHeight()) ?? default_style.copyWith(lineSpacing: spacing?.resolveLineHeight());
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
          spans.add(
              pw.TextSpan(children: await getAllStyles(plainText, style), style: style ?? default_style)); // Apply currentinheritedStyle
        } else {
          spans.add(pw.TextSpan(
              text: plainText.convertUTF8QuotesToValidString.decodeSymbols, style: style ?? default_style)); // Apply currentinheritedStyle
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
        textStyle = default_style.resolveInline(isBold, isItalic, isUnder, isBoldItalicUnderline);
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
        spans.add(
            pw.TextSpan(children: await getAllStyles(remainingText, style), style: style ?? default_style)); // Apply currentinheritedStyle
      } else {
        spans.add(pw.TextSpan(
            text: remainingText.convertUTF8QuotesToValidString.decodeSymbols,
            style: style ?? default_style)); // Apply currentinheritedStyle
      }
    }
    return spans;
  }

  @override
  Future<pw.Widget> getBlockHeaderStyle(String line, [pw.TextStyle? style]) async {
    final RegExpMatch match = Constant.HEADER_PATTERN.firstMatch(line)!;

    final String headerLevel = match.group(1)!;
    final String headerText = match.group(2)!;
    final double defaultFontSize = headerLevel.resolveHeaderLevel();
    final pw.TextStyle textStyle = style ?? default_style.copyWith(fontSize: defaultFontSize);
    final List<pw.InlineSpan> spans = await getDocLinksSpacingFontsStyle(
      headerText.replaceAllMapped(Constant.INLINES_RICH_TEXT_PATTERN_STRICT, (Match match) {
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
  Future<List<pw.Widget>> getAlignedBlockHeaderStyle(String line, [pw.TextStyle? style]) async {
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
    final pw.TextStyle header_style = style?.copyWith(fontSize: currentFontSize) ?? default_style.copyWith(fontSize: currentFontSize);
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
  Future<List<pw.Widget>> getAlignedBlockParagraphStyle(String line, [pw.TextStyle? style]) async {
    if (Constant.HTML_IMAGE_PATTERN.hasMatch(line)) {
      final RegExp matcher = Constant.HTML_IMAGE_PATTERN;
      final RegExpMatch match = matcher.firstMatch(line)!;
      final pw.Alignment alignment = match.group(1)!.resolvePdfBlockAlign;
      final String sourceImage = match.group(2)!;
      String mdImage = convertHtmlToMarkdown(sourceImage, rules, <String>[]);
      return <pw.Widget>[(await imageBlock.call(mdImage, alignment)) ?? pw.SizedBox()];
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
  Future<pw.Widget> getListBlockStyle(String line, bool isCheckList, [pw.TextStyle? style]) async {
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
              padding: const pw.EdgeInsets.only(left: 15, top: 1.5, bottom: 1.5),
              child: pw.RichText(
                softWrap: true,
                overflow: pw.TextOverflow.span,
                text: pw.TextSpan(
                  text: '\n• ',
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
            padding: const pw.EdgeInsets.only(left: 15, top: 1.5, bottom: 1.5),
            child: pw.RichText(
              softWrap: true,
              overflow: pw.TextOverflow.span,
              text: pw.TextSpan(
                text: '\n$typeList ',
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
          padding: const pw.EdgeInsets.only(left: 15, bottom: 1.5, top: 1.5),
          child: pw.Row(
            children: <pw.Widget>[
              pw.Checkbox(
                activeColor: PdfColors.blue400,
                name: 'check ${Random.secure().nextInt(9999999) + 50}',
                value: checked,
              ),
              pw.SizedBox(
                width: 7,
              ),
              pw.Expanded(
                child: pw.RichText(
                  textAlign: align?.resolvePdfTextAlign,
                  softWrap: true,
                  overflow: pw.TextOverflow.span,
                  text: pw.TextSpan(
                    children: <pw.InlineSpan>[
                      pw.TextSpan(children: <pw.InlineSpan>[const pw.TextSpan(text: '\n'), ...styledWidgets])
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
    if (Constant.INLINES_RICH_TEXT_PATTERN.hasMatch(content)) {
      return await getDocLinksSpacingFontsStyle(content, style, returnContentIfNeedIt, addFontSize);
    } else {
      return await getAllStyles(content, style, addFontSize);
    }
  }
}
