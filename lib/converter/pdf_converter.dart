import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_quill_delta_easy_parser/flutter_quill_delta_easy_parser.dart'
    as ep;
import 'package:flutter_quill_to_pdf/core/request/font_family_request.dart';
import 'package:flutter_quill_to_pdf/core/response/font_family_response.dart';
import 'package:flutter_quill_to_pdf/utils/extensions.dart';
import 'package:flutter_quill_to_pdf/utils/typedefs.dart';
import 'package:meta/meta.dart';
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

  final qpdf.PDFPageFormat pageFormat;

  /// This will set the default direction for all the document
  /// or the common widgets if them doesn't have direction attribute
  final TextDirection textDirection;

  ///[CustomPDFWidget] allow devs to use builders to create custom widgets
  final List<qpdf.CustomWidget> customBuilders;

  ///A font when converter detect a font
  final FontFamilyResponse Function(FontFamilyRequest familyRequest)?
      onRequestFontFamily;

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

  /// When a rich text styles are detected, this builder is called
  final qpdf.PDFWidgetBuilder<ep.Line, List<pw.InlineSpan>>?
      onDetectInlineRichTextStyles;

  /// When a header block is detected, this builder is called
  final qpdf.PDFWidgetBuilder<List<pw.InlineSpan>, pw.Widget>?
      onDetectHeaderBlock;

  /// When a aligned block is detected, this builder is called
  final qpdf.PDFWidgetBuilder<List<pw.InlineSpan>, pw.Widget>?
      onDetectAlignedParagraph;

  /// When a non rich text line is detected, this builder is called
  /// Tipically this happens when the insertion has not inline attributes
  final qpdf.PDFWidgetBuilder<ep.Line, List<pw.InlineSpan>>? onDetectCommonText;

  /// When a link line is detected, this builder is called
  final qpdf.PDFWidgetBuilder<ep.Line, List<pw.InlineSpan>>? onDetectLink;

  /// When a list block is detected, this builder is called
  final qpdf.PDFWidgetBuilder<List<pw.InlineSpan>, pw.Widget>? onDetectList;

  /// When a code block is detected, this builder is called
  final qpdf.PDFWidgetBuilder<List<pw.InlineSpan>, pw.Widget>?
      onDetectCodeBlock;

  /// When a block quote is detected, this builder is called
  final qpdf.PDFWidgetBuilder<List<pw.InlineSpan>, pw.Widget>?
      onDetectBlockquote;

  late final List<pw.Font> globalFontsFallbacks;

  /// [isWeb] is used to know is the current platform is web since the way of the fetch images files
  /// is different from the other platforms 
  @experimental
  final bool isWeb;

  PDFConverter({
    required this.pageFormat,
    required this.document,
    this.isWeb = false,
    this.textDirection = TextDirection.ltr,
    this.frontMatterDelta,
    this.backMatterDelta,
    this.customBuilders = const <qpdf.CustomWidget>[],
    this.onRequestFontFamily,
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
    this.onDetectBlockquote,
    this.onDetectCodeBlock,
    this.onDetectAlignedParagraph,
    this.onDetectCommonText,
    this.onDetectHeaderBlock,
    this.onDetectImageBlock,
    this.onDetectInlineRichTextStyles,
    this.onDetectLink,
    this.onDetectList,
  })  : assert(pageFormat.height > 30, 'Page size height isn\'t valid'),
        assert(pageFormat.width > 30, 'Page size width isn\'t valid'),
        assert(pageFormat.marginBottom >= 0.0,
            'Margin to bottom with value ${pageFormat.marginBottom}'),
        assert(pageFormat.marginLeft >= 0.0,
            'Margin to left with value ${pageFormat.marginLeft}'),
        assert(pageFormat.marginRight >= 0.0,
            'Margin to right with value ${pageFormat.marginRight}'),
        assert(pageFormat.marginTop >= 0.0,
            'Margin to tp with value ${pageFormat.marginTop}') {
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
    PageBuilder? pageBuilder,
    bool shouldProcessDeltas = true,
  }) async {
    deltaOptionalAttr ??= qpdf.DeltaAttributesOptions.common();
    final qpdf.Converter<Delta, pw.Document> converter = qpdf.PdfService(
      pageFormat: pageFormat,
      fonts: globalFontsFallbacks,
      customTheme: themeData,
      textDirection: textDirection.toPdf(),
      pageBuilder: pageBuilder,
      isWeb: isWeb,
      customBuilders: customBuilders,
      blockQuoteBackgroundColor: blockQuoteBackgroundColor,
      blockQuoteDividerColor: blockQuoteDividerColor,
      codeBlockBackgroundColor: codeBlockBackgroundColor,
      codeBlockFont: codeBlockFont,
      codeBlockNumLinesTextStyle: codeBlockNumLinesTextStyle,
      codeBlockTextStyle: codeBlockTextStyle,
      blockQuoteTextStyle: blockQuoteTextStyle,
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
      onDetectLink: onDetectLink,
      onDetectList: onDetectList,
      onRequestFontFamily: onRequestFontFamily,
      backM: !shouldProcessDeltas
          ? backMatterDelta
          : processDelta(backMatterDelta, deltaOptionalAttr,
              overrideAttributesPassedByUser),
      frontM: !shouldProcessDeltas
          ? frontMatterDelta
          : processDelta(frontMatterDelta, deltaOptionalAttr,
              overrideAttributesPassedByUser),
      document: !shouldProcessDeltas
          ? document
          : processDelta(
              document, deltaOptionalAttr, overrideAttributesPassedByUser)!,
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
  Future<void> createDocumentFile({
    required String path,
    void Function(dynamic error)? onException,
    void Function([Object? data])? onSucessWrite,
    qpdf.DeltaAttributesOptions? deltaOptionalAttr,
    bool overrideAttributesPassedByUser = false,
    PageBuilder? pageBuilder,
    bool shouldProcessDeltas = true,
    @Deprecated('Use isWeb global variable from PDFConverter instead')
    bool isWeb = false,
  }) async {
    deltaOptionalAttr ??= qpdf.DeltaAttributesOptions.common();
    final qpdf.Converter<Delta, pw.Document> converter = qpdf.PdfService(
      pageFormat: pageFormat,
      fonts: globalFontsFallbacks,
      customBuilders: customBuilders,
      pageBuilder: pageBuilder,
      isWeb: this.isWeb,
      onRequestFontFamily: onRequestFontFamily,
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
      textDirection: textDirection.toPdf(),
      onDetectBlockquote: onDetectBlockquote,
      onDetectCodeBlock: onDetectCodeBlock,
      onDetectHeaderBlock: onDetectHeaderBlock,
      onDetectImageBlock: onDetectImageBlock,
      blockQuotePaddingLeft: blockQuotePaddingLeft,
      blockQuotePaddingRight: blockQuotePaddingRight,
      blockQuotethicknessDividerColor: blockQuotethicknessDividerColor,
      onDetectInlineRichTextStyles: onDetectInlineRichTextStyles,
      onDetectLink: onDetectLink,
      onDetectList: onDetectList,
      backM: !shouldProcessDeltas
          ? backMatterDelta
          : processDelta(backMatterDelta, deltaOptionalAttr,
              overrideAttributesPassedByUser),
      frontM: !shouldProcessDeltas
          ? frontMatterDelta
          : processDelta(frontMatterDelta, deltaOptionalAttr,
              overrideAttributesPassedByUser),
      document: !shouldProcessDeltas
          ? document
          : processDelta(
              document, deltaOptionalAttr, overrideAttributesPassedByUser)!,
    );
    try {
      final pw.Document doc = await converter.generateDoc();
      final Uint8List bytes = await doc.save();
      if (isWeb) {
        List<int> fileInts = List<int>.from(bytes);
        web.AnchorElement()
          ..href =
              "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(fileInts)}"
          ..setAttribute(
              "download", File(path).uri.pathSegments.last)
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

  static Delta? processDelta(Delta? delta, qpdf.DeltaAttributesOptions options,
      bool overrideAttributesPassedByUser) {
    if (delta == null) return null;
    if (delta.isEmpty) return delta;
    final String json = qpdf
        .applyAttributesIfNeeded(
            json: jsonEncode(delta.toJson()),
            attr: options,
            overrideAttributes: overrideAttributesPassedByUser)
        .fixCommonErrorInsertsInRawDelta
        .withBrackets;
    return Delta.fromJson(jsonDecode(json));
  }

  /// Return a container with the widgets generated from the Document passed 
  Future<pw.Widget?> generateWidget({
    qpdf.DeltaAttributesOptions? deltaOptionalAttr,
    double? maxWidth,
    double? maxHeight,
    bool overrideAttributesPassedByUser = false,
    void Function(dynamic error)? onException,
    bool shouldProcessDeltas = true,
  }) async {
    deltaOptionalAttr ??= qpdf.DeltaAttributesOptions.common();
    final qpdf.Converter<Delta, pw.Document> converter = qpdf.PdfService(
      pageFormat: pageFormat,
      textDirection: textDirection.toPdf(),
      onRequestFontFamily: onRequestFontFamily,
      isWeb: isWeb,
      fonts: globalFontsFallbacks,
      customTheme: themeData,
      customBuilders: customBuilders,
      blockQuoteBackgroundColor: blockQuoteBackgroundColor,
      blockQuoteDividerColor: blockQuoteDividerColor,
      codeBlockBackgroundColor: codeBlockBackgroundColor,
      codeBlockFont: codeBlockFont,
      codeBlockNumLinesTextStyle: codeBlockNumLinesTextStyle,
      codeBlockTextStyle: codeBlockTextStyle,
      blockQuoteTextStyle: blockQuoteTextStyle,
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
      onDetectLink: onDetectLink,
      onDetectList: onDetectList,
      backM: !shouldProcessDeltas
          ? backMatterDelta
          : processDelta(backMatterDelta, deltaOptionalAttr,
              overrideAttributesPassedByUser),
      frontM: !shouldProcessDeltas
          ? frontMatterDelta
          : processDelta(frontMatterDelta, deltaOptionalAttr,
              overrideAttributesPassedByUser),
      document: !shouldProcessDeltas
          ? document
          : processDelta(
              document, deltaOptionalAttr, overrideAttributesPassedByUser)!,
    );
    try {
      return await converter.generateWidget(
          maxWidth: maxWidth, maxHeight: maxHeight);
    } catch (e) {
      onException?.call(e);
      rethrow;
    }
  }

}
