import 'dart:async';
import 'dart:collection';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_quill_to_pdf/utils/utils.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:flutter_quill_to_pdf/converter/configurator/converter_option/pdf_page_format.dart';
import 'package:flutter_quill_to_pdf/core/extensions/pdf_extension.dart';
import 'package:flutter_quill_to_pdf/core/extensions/string_extension.dart';
import 'package:flutter_quill_to_pdf/packages/vsc_quill_delta_to_html/src/quill_delta_to_html_converter.dart';

import '../../core/constant/constants.dart';
import '../configurator/converter_option/custom_converter.dart';
import '../../utils/converters_utils.dart';
import '../configurator/pdf/pdf_configurator.dart';

///A Manager that contains all operations for PDF services
class PdfService extends PdfConfigurator<Delta, pw.Document> {
  late final List<pw.Font> _fonts;
  late final pw.ThemeData defaultTheme;

  //page configs
  late final double _marginLeft;
  late final double _marginBottom;
  late final double _marginTop;
  late final double _marginRight;
  late final double _width;
  late final double _height;
  final String Function(Delta)? customDeltaToHTMLConverter;
  final String Function(String html)? customHTMLToMarkdownConverter;
  final ConverterOptions? converterOptions;

  PdfService({
    required PDFPageFormat params,
    required List<pw.Font> fonts,
    required super.onRequestBoldFont,
    required super.onRequestBothFont,
    required super.onRequestFallbacks,
    required super.onRequestFont,
    required super.onRequestItalicFont,
    required super.customConverters,
    required super.document,
    pw.ThemeData? customTheme,
    super.codeBlockFont,
    super.blockQuoteBackgroundColor,
    super.codeBlockBackgroundColor,
    super.codeBlockNumLinesTextStyle,
    super.codeBlockTextStyle,
    super.blockQuoteDividerColor,
    super.blockQuoteTextStyle,
    this.customDeltaToHTMLConverter,
    this.customHTMLToMarkdownConverter,
    super.blockQuotePaddingLeft,
    super.blockQuotePaddingRight,
    super.blockQuotethicknessDividerColor,
    super.onDetectBlockquote,
    super.onDetectCodeBlock,
    super.onDetectAlignedParagraph,
    super.onDetectCommonText,
    super.onDetectHeaderAlignedBlock,
    super.onDetectHeaderBlock,
    super.onDetectImageBlock,
    super.onDetectInlineRichTextStyles,
    super.onDetectInlinesMarkdown,
    super.onDetectLink,
    super.onDetectList,
    this.converterOptions,
    super.backM,
    super.frontM,
  }) {
    _fonts = fonts;
    defaultTextStyle = pw.TextStyle(
      fontSize: defaultFontSize.toDouble(),
      fontFallback: <pw.Font>[..._fonts],
    );
    _marginLeft = params.marginLeft;
    _marginBottom = params.marginBottom;
    _marginTop = params.marginTop;
    _marginRight = params.marginRight;
    _width = params.width;
    _height = params.height;
    pageWidth = params.width;
    pageHeight = params.height;
    defaultTheme = customTheme ??
        pw.ThemeData(
          softWrap: true,
          textAlign: pw.TextAlign.left,
          iconTheme: pw.IconThemeData.fallback(pw.Font.symbol()),
          overflow: pw.TextOverflow.span,
          defaultTextStyle: pw.TextStyle(
            color: PdfColors.black,
            fontWeight: pw.FontWeight.normal,
            fontStyle: pw.FontStyle.normal,
            letterSpacing: 0,
            wordSpacing: 1.0,
            lineSpacing: 1.0,
            height: 1,
            decoration: pw.TextDecoration.none,
            decorationColor: null,
            decorationStyle: pw.TextDecorationStyle.solid,
            decorationThickness: 1,
            renderingMode: PdfTextRenderingMode.fill,
            fontFallback: <pw.Font>[..._fonts],
          ),
        );
  }

  @override
  Future<pw.Document> generateDoc() async {
    final pw.Document pdf = pw.Document(
      compress: true,
      verbose: true,
      pageMode: PdfPageMode.outlines,
      version: PdfVersion.pdf_1_5,
    );
    final PdfPageFormat pageFormat = PdfPageFormat(_width, _height,
        marginBottom: _marginBottom, marginLeft: _marginLeft, marginRight: _marginRight, marginTop: _marginTop);
    // front matter
    final List<Map<String, dynamic>> docWidgets = await generatePages(documents: <Delta>[frontM ?? Delta(), document, backM ?? Delta()]);
    for (int i = 0; i < docWidgets.length; i++) {
      final Map<String, dynamic> map = docWidgets.elementAt(i);
      final List<pw.Widget> widgets = map['content'] as List<pw.Widget>;
      pdf.addPage(
        pw.MultiPage(
          theme: defaultTheme,
          pageFormat: pageFormat,
          maxPages: 99999999,
          build: (pw.Context context) {
            return <pw.Widget>[...widgets];
          },
        ),
      );
    }
    return pdf;
  }

  @override
  Future<List<Map<String, dynamic>>> generatePages({required List<Delta> documents}) async {
    String markdownText = "";
    LinkedHashSet<Map<String, dynamic>> docMap = LinkedHashSet<Map<String, dynamic>>();
    int i = 0;
    int totalDocuments = documents.length;
    while (i < totalDocuments) {
      final Delta doc = documents.elementAt(i);
      if (doc.isNotEmpty) {
        try {
          final String html = customDeltaToHTMLConverter != null
              ? customDeltaToHTMLConverter!.call(doc)
              : convertDeltaToHtml(doc, converterOptions).convertWrongInlineStylesToSpans.replaceAll('<p><br/><p>', '<p><br></p>');
          markdownText = customHTMLToMarkdownConverter != null
              ? customHTMLToMarkdownConverter!.call(html)
              : convertHtmlToMarkdown(html, rules, <String>[], removeLeadingWhitespaces: false, escape: false);
        } on ArgumentError catch (e) {
          debugPrint(e.toString());
          rethrow;
        } on FormatException catch (e) {
          debugPrint(e.toString());
          rethrow;
        }
        docMap.add(<String, dynamic>{
          'content': List<pw.Widget>.from(await blockGenerators(markdownText.splitBasedNewLine)),
        });
      }
      i++;
    }
    return List<Map<String, dynamic>>.from(docMap);
  }

  @override
  Future<List<pw.Widget>> blockGenerators(List<String> lines, [Map<String, dynamic>? extraInfo]) async {
    final bool isDefaulBlockConvertion = customHTMLToMarkdownConverter == null;
    final List<pw.Widget> contentPerPage = <pw.Widget>[];
    for (int i = 0; i < lines.length; i++) {
      late String line;
      if (!isDefaulBlockConvertion) {
        line = lines.elementAt(i);
      } else {
        line = lines.elementAt(i).replaceAll(r'\"', '"').convertHTMLToMarkdown; //delete the encode that avoid conflicts with delta map
      }
      if (customConverters.isNotEmpty) {
        for (final CustomConverter detector in customConverters) {
          if (detector.predicate.hasMatch(line)) {
            final List<RegExpMatch> matches = List<RegExpMatch>.from(detector.predicate.allMatches(line));
            if (matches.isNotEmpty) {
              contentPerPage.add(detector.callback(
                matches: matches,
                input: line,
                lineWithoutFormatting: line.decodeSymbols.convertUTF8QuotesToValidString,
              ));
              continue;
            }
          }
        }
      }
      //search any span that contains just ![]() images
      if (Constant.IMAGE_PATTERN_IN_SPAN.hasMatch(line.decodeSymbols)) {
        if (onDetectImageBlock != null) {
          contentPerPage.add(await onDetectImageBlock!.call(Constant.IMAGE_PATTERN_IN_SPAN, line));
          continue;
        }
        final pw.Widget? image = await getImageBlock.call(Constant.IMAGE_PATTERN_IN_SPAN.firstMatch(line.decodeSymbols)!.group(1)!);
        if (image != null) contentPerPage.add(image);
        continue;
      } else if (Constant.BLOCKQUOTE_PATTERN.hasMatch(line.decodeSymbols)) {
        if (onDetectBlockquote != null) {
          contentPerPage.add(await onDetectBlockquote!.call(Constant.BLOCKQUOTE_PATTERN, line.decodeSymbols));
          continue;
        }

        /// founds multiline where starts with <pre> and ends with </pre>
        contentPerPage.addAll(await getBlockQuote.call(line.decodeSymbols));
      } else if (Constant.CODE_PATTERN.hasMatch(line.replaceAll('\n', r'\n').decodeSymbols)) {
        if (onDetectCodeBlock != null) {
          contentPerPage.add(await onDetectCodeBlock!.call(Constant.CODE_PATTERN, line.decodeSymbols));
          continue;
        }

        /// founds multiline where starts with <pre> and ends with </pre>
        contentPerPage.addAll(await getCodeBlock.call(line.decodeSymbols));
      } else if (Constant.NEWLINE_WITH_SPACING_PATTERN.hasMatch(line)) {
        /// founds lines like <span style="line-spacing: 1.0">\n</span>
        contentPerPage.add(
            pw.RichText(softWrap: true, overflow: pw.TextOverflow.span, text: pw.TextSpan(children: await getNewLinesWithSpacing(line))));
      } else if (Constant.STARTS_WITH_RICH_TEXT_INLINE_STYLES_PATTERN.hasMatch(line)) {
        if (onDetectInlineRichTextStyles != null) {
          contentPerPage.add(await onDetectInlineRichTextStyles!.call(Constant.STARTS_WITH_RICH_TEXT_INLINE_STYLES_PATTERN, line));
          continue;
        }

        /// founds lines like <span style="wiki-doc: id">(.*?)<\/span>) or <span style="line-height: 2.0")">(.*?)<\/span> or <span\s?style="font-size: 12">(.*?)<\/span>)
        /// and those three ones together are matched
        final List<pw.InlineSpan> spans = await getRichTextInlineStyles.call(line, defaultTextStyle);
        final double spacing = (spans.first.style?.lineSpacing ?? 1.0);
        contentPerPage.add(
          pw.Padding(
            padding: pw.EdgeInsets.only(bottom: spacing.resolvePaddingByLineHeight()),
            child: pw.RichText(
              softWrap: true,
              overflow: pw.TextOverflow.span,
              text: pw.TextSpan(
                children: spans,
              ),
            ),
          ),
        );
      } else if (Constant.HEADER_PATTERN.hasMatch(line) || Constant.ALIGNED_HEADER_PATTERN.hasMatch(line)) {
        /// founds lines like # header 1 or <h1 style="text-align:center">header 1</h1>
        if (Constant.HEADER_PATTERN.hasMatch(line)) {
          if (onDetectHeaderBlock != null) {
            contentPerPage.add(await onDetectHeaderBlock!.call(Constant.HEADER_PATTERN, line));
            continue;
          }

          /// founds lines like # header 1 or ## header 2
          contentPerPage.add(await getHeaderBlock.call(line));
          continue;
        }
        if (onDetectHeaderBlock != null) {
          contentPerPage.add(await onDetectHeaderBlock!.call(Constant.ALIGNED_HEADER_PATTERN, line));
          continue;
        }
        contentPerPage.addAll(await getAlignedHeaderBlock.call(line));
      } else if (Constant.IMAGE_PATTERN.hasMatch(line)) {
        /// founds lines like ![max-width: 100%;object-fit: fill](image_bytes)
        /// also ![styles](url|file-path)
        if (onDetectImageBlock != null) {
          contentPerPage.add(await onDetectImageBlock!.call(Constant.IMAGE_PATTERN, line));
          continue;
        }
        final pw.Widget? image = await getImageBlock.call(line);
        if (image != null) contentPerPage.add(image);
      } else if (Constant.ALIGNED_P_PATTERN.hasMatch(line)) {
        /// founds lines like <p style="text-align:center">paragraph</p>
        if (onDetectAlignedParagraph != null) {
          contentPerPage.add(await onDetectAlignedParagraph!.call(Constant.ALIGNED_P_PATTERN, line));
          continue;
        }
        contentPerPage.addAll(await getAlignedParagraphBlock.call(line));
      } else if (line.isTotallyEmpty || Constant.EMPTY_ALIGNED_H.hasMatch(line) || Constant.EMPTY_ALIGNED_P.hasMatch(line)) {
        /// founds lines like [] or <p style="text-align:center">\n</p> or <h1 style="text-align:center">\n</h1>
        // this could be returning/printing br word in document instead \n
        //TODO: make a function to get the last or the first and get the spacing
        bool isHeaderEmpty = Constant.EMPTY_ALIGNED_H.hasMatch(line);
        final String newLineDecided = line.isNotEmpty
            ? isHeaderEmpty
                ? line.replaceAll(RegExp(r'<h([1-6])(.+?)?>|<\/h(\1)>'), '').replaceHtmlBrToManyNewLines
                : line.replaceAll(RegExp(r'<p>|<p.*?>|<\/p>'), '').replaceHtmlBrToManyNewLines
            : '\n';
        contentPerPage.add(
          pw.Paragraph(
            text: newLineDecided,
            style: defaultTextStyle,
            padding: const pw.EdgeInsets.symmetric(vertical: 1.5),
            margin: pw.EdgeInsets.zero,
          ),
        );
      } else if (Constant.LIST_PATTERN.hasMatch(line) || Constant.LIST_CHECK_MD_PATTERN.hasMatch(line)) {
        if (onDetectList != null) {
          contentPerPage.add(await onDetectList!
              .call(Constant.LIST_PATTERN.hasMatch(line) ? Constant.LIST_PATTERN : Constant.LIST_CHECK_MD_PATTERN, line));
          continue;
        }
        //TODO: now add support for indented lists ->
        //TODO: now add support for list with different prefixes
        /// founds lines like:
        /// "[x] checked" or
        /// "[ ] uncheck" or
        /// "1. ordered list" or
        /// "i. ordered list" or
        /// "a. ordered list" or
        /// "* unordered list"
        contentPerPage.add(await getListBlock.call(line, Constant.LIST_CHECK_MD_PATTERN.hasMatch(line)));
      } else if (Constant.HTML_LINK_TAGS_PATTERN.hasMatch(line)) {
        if (onDetectLink != null) {
          contentPerPage.add(await onDetectLink!.call(Constant.HTML_LINK_TAGS_PATTERN, line));
          continue;
        }

        /// founds lines like (title)[href]
        contentPerPage.add(
          pw.RichText(
            softWrap: true,
            overflow: pw.TextOverflow.span,
            text: pw.TextSpan(
              children: await getLinkStyle.call(line),
            ),
          ),
        );
      } else if (Constant.INLINE_STYLES_PATTERN.hasMatch(line)) {
        if (onDetectInlinesMarkdown != null) {
          contentPerPage.add(await onDetectInlinesMarkdown!.call(Constant.INLINE_STYLES_PATTERN, line));
          continue;
        }

        /// founds lines like *italic* _underline_ **bold** or those three ones together
        final List<pw.TextSpan> spans = await getInlineStyles.call(line);
        final double spacing = (spans.firstOrNull?.style?.lineSpacing ?? 1.0);
        contentPerPage.add(
          pw.Padding(
            padding: pw.EdgeInsets.symmetric(vertical: spacing.resolvePaddingByLineHeight()),
            child: pw.RichText(
              softWrap: true,
              overflow: pw.TextOverflow.span,
              text: pw.TextSpan(children: spans),
            ),
          ),
        );
      } else {
        if (Constant.RICH_TEXT_INLINE_STYLES_PATTERN.hasMatch(line)) {
          if (onDetectInlineRichTextStyles != null) {
            contentPerPage.add(await onDetectInlineRichTextStyles!.call(Constant.RICH_TEXT_INLINE_STYLES_PATTERN, line));
            continue;
          }

          /// founds lines like <span style="wiki-doc: id">(.*?)<\/span>) or <span style="line-height: 2.0")">(.*?)<\/span> or <span\s?style="font-size: 12">(.*?)<\/span>)
          /// and those three ones together are matched
          final List<pw.InlineSpan> spans = await getRichTextInlineStyles.call(line, defaultTextStyle);
          final double spacing = (spans.first.style?.lineSpacing ?? 1.0);
          contentPerPage.add(
            pw.Padding(
              padding: pw.EdgeInsets.symmetric(vertical: spacing.resolvePaddingByLineHeight()),
              child: pw.RichText(
                softWrap: true,
                overflow: pw.TextOverflow.span,
                text: pw.TextSpan(
                  children: spans,
                ),
              ),
            ),
          );
          continue;
        }
        if (onDetectCommonText != null) {
          contentPerPage.add(await onDetectCommonText!.call(null, line));
          continue;
        }
        if (isHTML(line)) {
          final List<pw.TextSpan> spans = await applyInlineStyles.call(line);
          contentPerPage.add(
            pw.Padding(
              padding: pw.EdgeInsets.symmetric(vertical: ((spans.firstOrNull?.style?.lineSpacing ?? 0.40) - 0.40).resolveLineHeight()),
              child: pw.RichText(
                softWrap: true,
                overflow: pw.TextOverflow.span,
                text: pw.TextSpan(children: spans),
              ),
            ),
          );
          continue;
        }
        //Wether found a plain text, then set default styles since we cannot detect any style to plain content
        contentPerPage.add(
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(vertical: 1.0),
            child: pw.RichText(
              softWrap: true,
              overflow: pw.TextOverflow.span,
              text: pw.TextSpan(text: line, style: defaultTextStyle),
            ),
          ),
        );
      }
    }
    return contentPerPage;
  }
}
