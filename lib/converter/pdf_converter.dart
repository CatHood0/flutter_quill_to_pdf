import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_quill_delta_easy_parser/flutter_quill_delta_easy_parser.dart' as ep;
import 'package:pdf/pdf.dart' show PdfColor;
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart' as qpdf;
import 'package:universal_html/html.dart' as web;

class PDFConverter {
  //Is the main body of the PDF document
  final Delta document;

  ///This [delta] is used before the main content
  final Delta? frontMatterDelta;

  ///This [delta] is used after the main content
  final Delta? backMatterDelta;

  final qpdf.PDFPageFormat params;

  ///[CustomConverter] allow devs to use [custom] regex patterns to detect and [create] custom widgets
  @Deprecated('This option is not longer used by the converter and will be removed on future releases')
  final List<qpdf.CustomConverter> customConverters;

  ///[CustomPDFWidget] allow devs to use builders to create custom widgets
  final List<qpdf.CustomWidget> customBuilders;

  ///A simple [request] font when converter detect a font
  final Future<pw.Font> Function(String)? onRequestFont;

  ///A simple [request] font when converter detect a font
  final Future<pw.Font> Function(String)? onRequestBoldFont;

  ///A simple [request] font when converter detect a font
  final Future<pw.Font> Function(String)? onRequestItalicFont;

  ///A simple [request] font when converter detect a font
  final Future<pw.Font> Function(String)? onRequestBoldItalicFont;

  ///Used by PDF converter to transform [delta to html].
  ///if you use your own delta implementation, use this to avoid [conflicts]
  @Deprecated(
      'customDeltaToHTMLConverter is no longer used since this implementation was changed and will be removed on future releases')
  final String Function(Delta)? customDeltaToHTMLConverter;

  ///Used by PDF converter to transform [formatted html to markdown]
  ///By default, [markdown] contains [html] into it
  @Deprecated(
      'customHTMLToMarkdownConverter is no longer used since this implementation was changed and will be removed on future releases')
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

  final qpdf.PDFWidgetBuilder<ep.Line, pw.Widget>? onDetectImageBlock;

  ///Detect Rich text styles like: size, spacing, font family
  final qpdf.PDFWidgetBuilder<ep.Line, List<pw.InlineSpan>>? onDetectInlineRichTextStyles;

  ///Detect simple: # header
  final qpdf.PDFWidgetBuilder<List<pw.InlineSpan>, pw.Widget>? onDetectHeaderBlock;

  final qpdf.PDFWidgetBuilder<List<pw.InlineSpan>, pw.Widget>? onDetectAlignedParagraph;

  final qpdf.PDFWidgetBuilder<ep.Line, List<pw.InlineSpan>>? onDetectCommonText;

  @Deprecated('onDetectInlinesMarkdown is no longer used and will be removed on future releases')
  final qpdf.CustomPDFWidget? onDetectInlinesMarkdown;

  final qpdf.PDFWidgetBuilder<ep.Line, List<pw.InlineSpan>>? onDetectLink;
  //Detect markdown list: * bullet, 1. ordered, [x] check list (still has errors in render or in detect indent)
  final qpdf.PDFWidgetBuilder<List<pw.InlineSpan>, pw.Widget>? onDetectList;

  /// Detect html code tag <pre>some code</pre> and it could be multiline
  final qpdf.PDFWidgetBuilder<List<pw.InlineSpan>, pw.Widget>? onDetectCodeBlock;

  /// Detect html blockquote tag <blockquote>text in blockquote</blockquote> and it could be multiline
  final qpdf.PDFWidgetBuilder<List<pw.InlineSpan>, pw.Widget>? onDetectBlockquote;

  ///If this [request] is null, list is [empty] or is list [null], will be used another by default
  final Future<List<pw.Font>?> Function(String)? onRequestFallbackFont;
  late final List<pw.Font> globalFontsFallbacks;

  PDFConverter({
    required this.params,
    required this.document,
    required this.frontMatterDelta,
    required this.backMatterDelta,
    this.customConverters = const <qpdf.CustomConverter>[],
    this.customBuilders = const <qpdf.CustomWidget>[],
    this.onRequestBoldFont,
    this.onRequestBoldItalicFont,
    this.onRequestFallbackFont,
    this.onRequestFont,
    this.onRequestItalicFont,
    required List<pw.Font> fallbacks,
    this.blockQuotePaddingLeft,
    this.blockQuotePaddingRight,
    this.blockQuotethicknessDividerColor,
    this.blockQuoteBackgroundColor,
    this.blockQuoteDividerColor,
    this.blockQuoteTextStyle,
    this.codeBlockBackgroundColor,
    this.codeBlockNumLinesTextStyle,
    this.codeBlockFont,
    this.codeBlockTextStyle,
    this.themeData,
    this.customDeltaToHTMLConverter,
    this.customHTMLToMarkdownConverter,
    this.onDetectBlockquote,
    this.onDetectCodeBlock,
    this.onDetectAlignedParagraph,
    this.onDetectCommonText,
    this.onDetectHeaderBlock,
    this.onDetectImageBlock,
    this.onDetectInlineRichTextStyles,
    this.onDetectInlinesMarkdown,
    this.onDetectLink,
    this.onDetectList,
  })  : assert(params.height > 30, 'Page size height isn\'t valid'),
        assert(params.width > 30, 'Page size width isn\'t valid'),
        assert(params.marginBottom >= 0.0, 'Margin to bottom with value ${params.marginBottom}'),
        assert(params.marginLeft >= 0.0, 'Margin to left with value ${params.marginLeft}'),
        assert(params.marginRight >= 0.0, 'Margin to right with value ${params.marginRight}'),
        assert(params.marginTop >= 0.0, 'Margin to tp with value ${params.marginTop}') {
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
    qpdf.DeltaAttributesOptions? deltaOptionalAttr,
    bool overrideAttributesPassedByUser = false,
    void Function(dynamic error)? onException,
    bool shouldProcessDeltas = true,
  }) async {
    deltaOptionalAttr ??= qpdf.DeltaAttributesOptions.common();
    final qpdf.Converter<Delta, pw.Document> converter = qpdf.PdfService(
      params: params,
      fonts: globalFontsFallbacks,
      onRequestBoldFont: onRequestBoldFont,
      onRequestBothFont: onRequestBoldItalicFont,
      customTheme: themeData,
      customBuilders: customBuilders,
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
      onDetectHeaderBlock: onDetectHeaderBlock,
      onDetectImageBlock: onDetectImageBlock,
      onDetectInlineRichTextStyles: onDetectInlineRichTextStyles,
      onDetectInlinesMarkdown: onDetectInlinesMarkdown,
      onDetectLink: onDetectLink,
      onDetectList: onDetectList,
      onRequestFont: onRequestFont,
      backM: !shouldProcessDeltas
          ? backMatterDelta
          : processDelta(backMatterDelta, deltaOptionalAttr, overrideAttributesPassedByUser),
      frontM: !shouldProcessDeltas
          ? frontMatterDelta
          : processDelta(frontMatterDelta, deltaOptionalAttr, overrideAttributesPassedByUser),
      onRequestItalicFont: onRequestItalicFont,
      customConverters: customConverters,
      document:
          !shouldProcessDeltas ? document : processDelta(document, deltaOptionalAttr, overrideAttributesPassedByUser)!,
    );
    try {
      return await converter.generateDoc();
    } catch (e) {
      onException?.call(e);
      rethrow;
    }
  }

  /// This Create the PDF document and write it to storage path
  /// This implementation can throw PathNotFoundException or exceptions based in Storage capabilities
  ///
  /// [isWeb] is used to know is the current platform is web since the way of the how is saved PDF file
  /// is different from the common on mobile devices or Desktop
  Future<void> createDocumentFile({
    required String path,
    void Function(dynamic error)? onException,
    void Function([Object? data])? onSucessWrite,
    qpdf.DeltaAttributesOptions? deltaOptionalAttr,
    bool overrideAttributesPassedByUser = false,
    bool shouldProcessDeltas = true,
    bool isWeb = false,
  }) async {
    deltaOptionalAttr ??= qpdf.DeltaAttributesOptions.common();
    final qpdf.Converter<Delta, pw.Document> converter = qpdf.PdfService(
      params: params,
      fonts: globalFontsFallbacks,
      customBuilders: customBuilders,
      onRequestBoldFont: onRequestBoldFont,
      onRequestBothFont: onRequestBoldItalicFont,
      onRequestFallbacks: onRequestFallbackFont,
      onRequestFont: onRequestFont,
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
          : processDelta(backMatterDelta, deltaOptionalAttr, overrideAttributesPassedByUser),
      frontM: !shouldProcessDeltas
          ? frontMatterDelta
          : processDelta(frontMatterDelta, deltaOptionalAttr, overrideAttributesPassedByUser),
      onRequestItalicFont: onRequestItalicFont,
      customConverters: customConverters,
      document:
          !shouldProcessDeltas ? document : processDelta(document, deltaOptionalAttr, overrideAttributesPassedByUser)!,
    );
    try {
      final pw.Document doc = await converter.generateDoc();
      final Uint8List bytes = await doc.save();
      if (isWeb) {
        List<int> fileInts = List<int>.from(bytes);
        web.AnchorElement()
          ..href = "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(fileInts)}"
          ..setAttribute("download", "${DateTime.now().millisecondsSinceEpoch}.pdf")
          ..click();
        onSucessWrite?.call('');
        return;
      }
      await File(path).writeAsBytes(bytes);
      onSucessWrite?.call(path);
    } catch (e) {
      onException?.call(e);
    }
  }

  static Delta? processDelta(Delta? delta, qpdf.DeltaAttributesOptions options, bool overrideAttributesPassedByUser) {
    if (delta == null) return null;
    if (delta.isEmpty) return delta;
    final String json = qpdf
        .applyAttributesIfNeeded(
            json: jsonEncode(delta.toJson()), attr: options, overrideAttributes: overrideAttributesPassedByUser)
        .fixCommonErrorInsertsInRawDelta
        .withBrackets;
    return Delta.fromJson(jsonDecode(json));
  }
}
