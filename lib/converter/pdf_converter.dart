import 'dart:convert';
import 'dart:io';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart' show PdfColor;
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart' as qpdf;

import '../flutter_quill_to_pdf.dart';

class PDFConverter {
  //Is the main body of the PDF document
  final Delta document;

  ///This [delta] is used before the main content
  final Delta? frontMatterDelta;

  ///This [delta] is used after the main content
  final Delta? backMatterDelta;

  final qpdf.PDFPageFormat params;

  ///[CustomConverter] allow devs to use [custom] regex patterns to detect and [create] custom widgets
  final List<CustomConverter> customConverters;

  ///A simple [request] font when converter detect a font
  final Future<pw.Font> Function(String) onRequestFont;

  ///A simple [request] font when converter detect a font
  final Future<pw.Font> Function(String) onRequestBoldFont;

  ///A simple [request] font when converter detect a font
  final Future<pw.Font> Function(String) onRequestItalicFont;

  ///A simple [request] font when converter detect a font
  final Future<pw.Font> Function(String) onRequestBoldItalicFont;

  ///Used by PDF converter to transform [delta to html].
  ///if you use your own delta implementation, use this to avoid [conflicts]
  final String Function(Delta)? customDeltaToHTMLConverter;

  ///Used by PDF converter to transform [formatted html to markdown]
  ///By default, [markdown] contains [html] into it
  final String Function(String)? customHTMLToMarkdownConverter;

  ///If you need to [customize] the [theme] of the [pdf document], override this param
  final pw.ThemeData? themeData;

  ///If you need [customize] exactly how the [code block looks], then you use this [theme]
  final pw.TextStyle? codeBlockTextStyle;

  ///If you need just a different [font] to show your code blocks, use this font [(by default is pw.Font.courier())]
  final pw.Font? codeBlockFont;

  ///Customize the background color of the code block
  final PdfColor? codeBlockBackgroundColor;

  ///Customize the style of the num lines in code block
  final pw.TextStyle? codeBlockNumLinesTextStyle;

  ///Define the text style of the general blockquote. [This overrides any style detected like: line-height, size, font families, color]
  final pw.TextStyle? blockQuoteTextStyle;

  ///Define the left space between divider and text
  final double? blockQuotePaddingLeft;
  final double? blockQuotePaddingRight;

  ///Define the width of the divider
  final double? blockQuotethicknessDividerColor;

  ///Customize the background of the blockquote
  final PdfColor? blockQuoteBackgroundColor;

  ///Customize the left/right divider color to blockquotes
  final PdfColor? blockQuoteDividerColor;

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

  ///Detect classic inline markdown styles: **bold** *italic* _underline_ [strikethrough is not supported yet]
  final CustomPDFWidget? onDetectInlinesMarkdown;

  final List<qpdf.Rule>? customRules;

  ///Detect custom and common html links implementation like:
  ///<a style="line-height:1.0;font-family:Times new roman;font-size:12px" href="https://google.com" target="_blank">link to google</a>
  ///<a href="https://google.com" target="_blank">link to google</a>
  final CustomPDFWidget? onDetectLink;
  //Detect markdown list: * bullet, 1. ordered, [x] check list (still has errors in render or in detect indent)
  final CustomPDFWidget? onDetectList;

  /// Detect html code tag <pre>some code</pre> and it could be multiline
  final CustomPDFWidget? onDetectCodeBlock;

  /// Detect html blockquote tag <blockquote>text in blockquote</blockquote> and it could be multiline
  final CustomPDFWidget? onDetectBlockquote;

  ///If this [request] is null, list is [empty] or is list [null], will be used another by default
  final Future<List<pw.Font>?> Function(String)? onRequestFallbackFont;
  late final List<pw.Font> globalFontsFallbacks;

  ///These are the configurations used by [vsc_quill_to_html] to manage how use the attributes and add custom attrs
  ///You can check [vsc_quill_to_delta_html] documentation here: https://github.com/VisualSystemsCorp/vsc_quill_delta_to_html
  final ConverterOptions? convertOptions;
  PDFConverter({
    required this.params,
    required this.document,
    required this.frontMatterDelta,
    required this.backMatterDelta,
    required this.customConverters,
    required this.onRequestBoldFont,
    required this.onRequestBoldItalicFont,
    required this.onRequestFallbackFont,
    required this.onRequestFont,
    required this.onRequestItalicFont,
    required List<pw.Font> fallbacks,
    this.blockQuotePaddingLeft,
    this.blockQuotePaddingRight,
    this.blockQuotethicknessDividerColor,
    this.blockQuoteBackgroundColor,
    this.blockQuoteDividerColor,
    this.blockQuoteTextStyle,
    this.codeBlockBackgroundColor,
    this.codeBlockNumLinesTextStyle,
    this.customRules,
    this.codeBlockFont,
    this.codeBlockTextStyle,
    this.themeData,
    this.customDeltaToHTMLConverter,
    this.customHTMLToMarkdownConverter,
    this.onDetectBlockquote,
    this.onDetectCodeBlock,
    this.onDetectAlignedParagraph,
    this.onDetectCommonText,
    this.onDetectHeaderAlignedBlock,
    this.onDetectHeaderBlock,
    this.onDetectImageBlock,
    this.onDetectInlineRichTextStyles,
    this.onDetectInlinesMarkdown,
    this.onDetectLink,
    this.onDetectList,
    this.convertOptions,
  })  : assert(params.height > 30, 'Page size height isn\'t valid'),
        assert(params.width > 30, 'Page size width isn\'t valid'),
        assert(params.marginBottom >= 0.0,
            'Margin to bottom with value ${params.marginBottom}'),
        assert(params.marginLeft >= 0.0,
            'Margin to left with value ${params.marginLeft}'),
        assert(params.marginRight >= 0.0,
            'Margin to right with value ${params.marginRight}'),
        assert(params.marginTop >= 0.0,
            'Margin to tp with value ${params.marginTop}') {
    globalFontsFallbacks = <pw.Font>[
      ...fallbacks,
      pw.Font.helvetica(),
      pw.Font.helveticaBold(),
      pw.Font.helveticaOblique(),
      pw.Font.symbol(),
      pw.Font.times(),
      pw.Font.timesBold(),
      pw.Font.timesItalic(),
      pw.Font.timesBoldItalic(),
      pw.Font.courier(),
      pw.Font.courierBold(),
      pw.Font.courierOblique(),
      pw.Font.courierBoldOblique(),
    ];
  }

  ///Creates the PDF document an return this one
  Future<pw.Document?> createDocument({
    DeltaAttributesOptions? deltaOptionalAttr,
    bool overrideAttributesPassedByUser = false,
    void Function(dynamic error)? onException,
    bool shouldProcessDeltas = true,
  }) async {
    deltaOptionalAttr ??= DeltaAttributesOptions.common();
    final Converter<Delta, pw.Document> converter = PdfService(
      params: params,
      fonts: globalFontsFallbacks,
      onRequestBoldFont: onRequestBoldFont,
      onRequestBothFont: onRequestBoldItalicFont,
      customDeltaToHTMLConverter: customDeltaToHTMLConverter,
      customHTMLToMarkdownConverter: customHTMLToMarkdownConverter,
      customTheme: themeData,
      blockQuoteBackgroundColor: blockQuoteBackgroundColor,
      blockQuoteDividerColor: blockQuoteDividerColor,
      codeBlockBackgroundColor: codeBlockBackgroundColor,
      codeBlockFont: codeBlockFont,
      codeBlockNumLinesTextStyle: codeBlockNumLinesTextStyle,
      codeBlockTextStyle: codeBlockTextStyle,
      blockQuoteTextStyle: blockQuoteTextStyle,
      onRequestFallbacks: onRequestFallbackFont,
      onDetectAlignedParagraph: onDetectAlignedParagraph,
      onDetectCommonText: onDetectCommonText,
      onDetectBlockquote: onDetectBlockquote,
      onDetectCodeBlock: onDetectCodeBlock,
      blockQuotePaddingLeft: blockQuotePaddingLeft,
      blockQuotePaddingRight: blockQuotePaddingRight,
      blockQuotethicknessDividerColor: blockQuotethicknessDividerColor,
      onDetectHeaderAlignedBlock: onDetectHeaderAlignedBlock,
      onDetectHeaderBlock: onDetectHeaderBlock,
      onDetectImageBlock: onDetectImageBlock,
      onDetectInlineRichTextStyles: onDetectInlineRichTextStyles,
      onDetectInlinesMarkdown: onDetectInlinesMarkdown,
      onDetectLink: onDetectLink,
      onDetectList: onDetectList,
      onRequestFont: onRequestFont,
      backM: !shouldProcessDeltas
          ? backMatterDelta
          : processDelta(backMatterDelta, deltaOptionalAttr,
              overrideAttributesPassedByUser),
      converterOptions: convertOptions,
      frontM: !shouldProcessDeltas
          ? frontMatterDelta
          : processDelta(frontMatterDelta, deltaOptionalAttr,
              overrideAttributesPassedByUser),
      onRequestItalicFont: onRequestItalicFont,
      customConverters: customConverters,
      document: !shouldProcessDeltas
          ? document
          : processDelta(
              document, deltaOptionalAttr, overrideAttributesPassedByUser)!,
    );
    if (customRules != null) {
      assert(customRules!.isNotEmpty,
          'Cannot be passed a list of new rules empty');
      final List<qpdf.Rule>? rules = customRules;
      converter.customRules(rules!, clearDefaultRules: true);
    }
    try {
      return await converter.generateDoc();
    } catch (e) {
      onException?.call(e);
      debugPrint(e.toString());
      return null;
    }
  }

  ///This Create the PDF document and write it to storage path
  //This implementation can throw PathNotFoundException or exceptions based in Storage capabilities
  Future<void> createDocumentFile({
    required String path,
    void Function(dynamic error)? onException,
    void Function([Object? data])? onSucessWrite,
    DeltaAttributesOptions? deltaOptionalAttr,
    bool overrideAttributesPassedByUser = false,
    bool shouldProcessDeltas = true,
  }) async {
    deltaOptionalAttr ??= DeltaAttributesOptions.common();
    final Converter<Delta, pw.Document> converter = PdfService(
      params: params,
      fonts: globalFontsFallbacks,
      onRequestBoldFont: onRequestBoldFont,
      onRequestBothFont: onRequestBoldItalicFont,
      onRequestFallbacks: onRequestFallbackFont,
      onRequestFont: onRequestFont,
      customDeltaToHTMLConverter: customDeltaToHTMLConverter,
      customHTMLToMarkdownConverter: customHTMLToMarkdownConverter,
      onDetectAlignedParagraph: onDetectAlignedParagraph,
      onDetectCommonText: onDetectCommonText,
      customTheme: themeData,
      blockQuoteBackgroundColor: blockQuoteBackgroundColor,
      blockQuoteDividerColor: blockQuoteDividerColor,
      codeBlockBackgroundColor: codeBlockBackgroundColor,
      codeBlockFont: codeBlockFont,
      codeBlockNumLinesTextStyle: codeBlockNumLinesTextStyle,
      codeBlockTextStyle: codeBlockTextStyle,
      blockQuoteTextStyle: blockQuoteTextStyle,
      onDetectBlockquote: onDetectBlockquote,
      onDetectCodeBlock: onDetectCodeBlock,
      onDetectHeaderAlignedBlock: onDetectHeaderAlignedBlock,
      onDetectHeaderBlock: onDetectHeaderBlock,
      onDetectImageBlock: onDetectImageBlock,
      blockQuotePaddingLeft: blockQuotePaddingLeft,
      blockQuotePaddingRight: blockQuotePaddingRight,
      blockQuotethicknessDividerColor: blockQuotethicknessDividerColor,
      onDetectInlineRichTextStyles: onDetectInlineRichTextStyles,
      onDetectInlinesMarkdown: onDetectInlinesMarkdown,
      onDetectLink: onDetectLink,
      onDetectList: onDetectList,
      backM: !shouldProcessDeltas
          ? backMatterDelta
          : processDelta(backMatterDelta, deltaOptionalAttr,
              overrideAttributesPassedByUser),
      converterOptions: convertOptions,
      frontM: !shouldProcessDeltas
          ? frontMatterDelta
          : processDelta(frontMatterDelta, deltaOptionalAttr,
              overrideAttributesPassedByUser),
      onRequestItalicFont: onRequestItalicFont,
      customConverters: customConverters,
      document: !shouldProcessDeltas
          ? document
          : processDelta(
              document, deltaOptionalAttr, overrideAttributesPassedByUser)!,
    );
    if (customRules != null) {
      assert(customRules!.isNotEmpty,
          'Cannot be passed a list of new rules empty');
      final List<qpdf.Rule>? rules = customRules;
      converter.customRules(rules!, clearDefaultRules: true);
    }
    try {
      final pw.Document doc = await converter.generateDoc();
      await File(path).writeAsBytes(await doc.save());
      onSucessWrite?.call(path);
    } catch (e) {
      onException?.call(e);
      debugPrint(e.toString());
      if (onException == null) debugPrint(e.toString());
    }
  }

  static Delta? processDelta(Delta? delta, DeltaAttributesOptions options,
      bool overrideAttributesPassedByUser) {
    if (delta == null) return null;
    if (delta.isEmpty) return delta;
    final String json = applyAttributesIfNeeded(
            json: jsonEncode(delta.toJson()),
            attr: options,
            overrideAttributes: overrideAttributesPassedByUser)
        .fixCommonErrorInsertsInRawDelta
        .withBrackets;
    return Delta.fromJson(jsonDecode(json));
  }
}
