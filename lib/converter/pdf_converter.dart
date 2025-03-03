import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_quill_delta_easy_parser/flutter_quill_delta_easy_parser.dart' as ep;
import 'package:flutter_quill_to_pdf/converter/delta_processor/delta_attributes_options.dart';
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
  final ui.TextDirection textDirection;

  ///[CustomPDFWidget] allow devs to use builders to create custom widgets
  final List<qpdf.CustomWidget> customBuilders;

  ///A font when converter detect a font
  final FontFamilyResponse Function(FontFamilyRequest familyRequest)? onRequestFontFamily;

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

  /// When an image is detected, this will be called to build a custom implementation of it 
  final qpdf.PDFWidgetBuilder<ep.TextFragment, pw.Widget>? onDetectImageBlock;

  /// When an image is being builded and an error is catched, this is called
  final PDFWidgetErrorBuilder<String, pw.Widget, ep.TextFragment>? onDetectErrorInImage;

  /// When a rich text styles are detected, this builder is called
  final qpdf.PDFWidgetBuilder<ep.TextFragment, pw.InlineSpan>? onDetectInlineRichTextStyles;

  /// When a header block is detected, this builder is called
  final qpdf.PDFWidgetBuilder<ep.Line, pw.Widget>? onDetectHeaderBlock;

  /// When a aligned block is detected, this builder is called
  final qpdf.PDFWidgetBuilder<ep.Line, pw.Widget>? onDetectAlignedParagraph;

  /// When a non rich text line is detected, this builder is called
  /// Tipically this happens when the insertion has not inline attributes
  final qpdf.PDFWidgetBuilder<ep.TextFragment, pw.InlineSpan>? onDetectCommonText;

  /// When a link line is detected, this builder is called
  final qpdf.PDFWidgetBuilder<ep.TextFragment, pw.InlineSpan>? onDetectLink;

  /// When a list block is detected, this builder is called
  final qpdf.PDFWidgetBuilder<ep.Paragraph, pw.Widget>? onDetectList;

  /// When a code block is detected, this builder is called
  final qpdf.PDFWidgetBuilder<ep.Paragraph, pw.Widget>? onDetectCodeBlock;

  /// When a block quote is detected, this builder is called
  final qpdf.PDFWidgetBuilder<ep.Paragraph, pw.Widget>? onDetectBlockquote;

  late final List<pw.Font> globalFontsFallbacks;

  /// This enable the highlight for code-block blocks
  @experimental
  final bool enableCodeBlockHighlighting;

  /// isLightCodeBlockTheme is used when enableCodeBlockHighlighting is true
  /// to decide the correct style for the spans
  @experimental
  final bool isLightCodeBlockTheme;

  /// This gives the ability to have our custom code-block highlight theme
  @experimental
  final Map<String, pw.TextStyle>? customCodeHighlightTheme;
  // This let us create custom sizes when a Header is detected
  @experimental
  final List<double>? customHeadingSizes;

  /// [isWeb] is used to know is the current platform is web since the way of the fetch images files
  /// is different from the other platforms
  @experimental
  final bool isWeb;

  PDFConverter({
    required this.pageFormat,
    required this.document,
    @experimental this.enableCodeBlockHighlighting = true,
    @experimental this.customHeadingSizes,
    @experimental this.isLightCodeBlockTheme = true,
    @experimental this.customCodeHighlightTheme,
    @experimental this.isWeb = false,
    this.textDirection = ui.TextDirection.ltr,
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
    this.onDetectErrorInImage,
    this.onDetectInlineRichTextStyles,
    this.onDetectLink,
    this.onDetectList,
  }) {
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
    @Deprecated('deltaOptionalAttr is no longer used, and will be removed in future releases.')
    qpdf.DeltaAttributesOptions? deltaOptionalAttr,
    @Deprecated('overrideAttributes is no longer used and will be removed in future releases.')
    bool overrideAttributesPassedByUser = false,
    @Deprecated('shouldProcessDeltas is no longer used and will be removed in future releases.')
    bool shouldProcessDeltas = true,
    void Function(dynamic error)? onException,
    PageBuilder? pageBuilder,
  }) async {
    final qpdf.Converter<Delta, pw.Document> converter = qpdf.PdfService(
      pageFormat: pageFormat,
      fonts: globalFontsFallbacks,
      customTheme: themeData,
      directionality: textDirection.toPdf(),
      pageBuilder: pageBuilder,
      isWeb: isWeb,
      enableCodeBlockHighlighting: enableCodeBlockHighlighting,
      isLightCodeBlockTheme: isLightCodeBlockTheme,
      customCodeHighlightTheme: customCodeHighlightTheme,
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
      onDetectErrorInImage: onDetectErrorInImage,
      onDetectInlineRichTextStyles: onDetectInlineRichTextStyles,
      onDetectLink: onDetectLink,
      onDetectList: onDetectList,
      onRequestFontFamily: onRequestFontFamily,
      backM: backMatterDelta,
      frontM: frontMatterDelta,
      document: document,
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
    @Deprecated('deltaOptionalAttr is no longer used, and will be removed in future releases')
    qpdf.DeltaAttributesOptions? deltaOptionalAttr,
    @Deprecated('overrideAttributes is no longer used and will be removed in future releases.')
    bool overrideAttributesPassedByUser = false,
    @Deprecated('shouldProcessDeltas is no longer used and will be removed in future releases.')
    bool shouldProcessDeltas = true,
    @Deprecated('Use isWeb global variable from PDFConverter instead') bool isWeb = false,
    void Function(dynamic error)? onException,
    void Function([Object? data])? onSucessWrite,
    PageBuilder? pageBuilder,
  }) async {
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
      enableCodeBlockHighlighting: enableCodeBlockHighlighting,
      isLightCodeBlockTheme: isLightCodeBlockTheme,
      customCodeHighlightTheme: customCodeHighlightTheme,
      blockQuoteBackgroundColor: blockQuoteBackgroundColor,
      blockQuoteDividerColor: blockQuoteDividerColor,
      codeBlockBackgroundColor: codeBlockBackgroundColor,
      codeBlockFont: codeBlockFont,
      codeBlockNumLinesTextStyle: codeBlockNumLinesTextStyle,
      codeBlockTextStyle: codeBlockTextStyle,
      onDetectErrorInImage: onDetectErrorInImage,
      blockQuoteTextStyle: blockQuoteTextStyle,
      directionality: textDirection.toPdf(),
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
      backM: backMatterDelta,
      frontM: frontMatterDelta,
      document: document,
    );
    try {
      final pw.Document doc = await converter.generateDoc();
      final Uint8List bytes = await doc.save();
      if (isWeb) {
        List<int> fileInts = List<int>.from(bytes);
        web.AnchorElement()
          ..href = "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(fileInts)}"
          ..setAttribute("download", File(path).uri.pathSegments.last)
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

  /// Return a container with the widgets generated from the Document passed
  Future<pw.Widget?> generateWidget({
    @Deprecated('deltaOptionalAttr is no longer used, and will be removed in future releases.')
    qpdf.DeltaAttributesOptions? deltaOptionalAttr,
    @Deprecated('overrideAttributes is no longer used and will be removed in future releases.')
    bool overrideAttributesPassedByUser = false,
    @Deprecated('shouldProcessDeltas is no longer used and will be removed in future releases.')
    bool shouldProcessDeltas = true,
    double? maxWidth,
    double? maxHeight,
    void Function(dynamic error)? onException,
  }) async {
    final qpdf.Converter<Delta, pw.Document> converter = qpdf.PdfService(
      pageFormat: pageFormat,
      directionality: textDirection.toPdf(),
      onRequestFontFamily: onRequestFontFamily,
      isWeb: isWeb,
      fonts: globalFontsFallbacks,
      customTheme: themeData,
      customBuilders: customBuilders,
      blockQuoteBackgroundColor: blockQuoteBackgroundColor,
      blockQuoteDividerColor: blockQuoteDividerColor,
      codeBlockBackgroundColor: codeBlockBackgroundColor,
      enableCodeBlockHighlighting: enableCodeBlockHighlighting,
      isLightCodeBlockTheme: isLightCodeBlockTheme,
      customCodeHighlightTheme: customCodeHighlightTheme,
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
      onDetectErrorInImage: onDetectErrorInImage,
      blockQuotethicknessDividerColor: blockQuotethicknessDividerColor,
      onDetectHeaderBlock: onDetectHeaderBlock,
      onDetectImageBlock: onDetectImageBlock,
      onDetectInlineRichTextStyles: onDetectInlineRichTextStyles,
      onDetectLink: onDetectLink,
      onDetectList: onDetectList,
      backM: backMatterDelta,
      frontM: frontMatterDelta,
      document: document,
    );
    try {
      return await converter.generateWidget(maxWidth: maxWidth, maxHeight: maxHeight);
    } catch (e) {
      onException?.call(e);
      rethrow;
    }
  }

  @Deprecated('processDelta is no longer used. It always return null now. It will be removed in future releases.')
  static Delta? processDelta(Delta delta, DeltaAttributesOptions options, bool overrideAttributesPassedByUser) {
    return null;
  }
}
