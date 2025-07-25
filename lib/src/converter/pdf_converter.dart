import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_quill_delta_easy_parser/flutter_quill_delta_easy_parser.dart'
    as ep;
import 'package:flutter_quill_to_pdf/src/core/decorators/checkbox_decorator.dart';
import 'package:flutter_quill_to_pdf/src/core/delta_processor/delta_attributes_options.dart';
import 'package:flutter_quill_to_pdf/src/core/document_options.dart';
import 'package:flutter_quill_to_pdf/src/core/enums/list_type_widget.dart';
import 'package:flutter_quill_to_pdf/src/core/request/font_family_request.dart';
import 'package:flutter_quill_to_pdf/src/core/response/font_family_response.dart';
import 'package:flutter_quill_to_pdf/src/utils/extensions.dart';
import 'package:flutter_quill_to_pdf/src/utils/typedefs.dart';
import 'package:meta/meta.dart';
import 'package:pdf/pdf.dart' show PdfColor, PdfPageFormat;
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart' as qpdf;

class PDFConverter {
  // This is the main body of the PDF document
  final Delta document;

  /// This [delta] is used before the main content
  final Delta? frontMatterDelta;

  /// This [delta] is used after the main content
  final Delta? backMatterDelta;

  final qpdf.PDFPageFormat pageFormat;

  /// This is a font that renderize correctly every icon into the pdf document
  @experimental
  final pw.Font? iconsFont;

  /// These are the general configuration for
  /// the pdf document and general
  /// view mode and orientation
  @experimental
  final DocumentOptions documentOptions;

  /// This will set the default direction for all the document
  /// or the common widgets if them doesn't have direction attribute
  final ui.TextDirection textDirection;

  /// [CustomPDFWidget] allows to use custom builders to create custom widgets
  final List<qpdf.CustomWidget> customBuilders;

  /// A font when converter detect a font
  @experimental
  final FontFamilyResponse Function(FontFamilyRequest familyRequest)?
      onRequestFontFamily;

  /// This decides how will be builded the default [List] block
  final ListTypeWidget listTypeWidget;

  /// Build a custom version of the leading into the lists
  final PDFLeadingWidget<pw.Widget?>? listLeadingBuilder;

  ///If you need to [customize] the [theme] of the [pdf document], override this param
  final pw.ThemeData? themeData;

  /// This customizes the code-block text style in the default implementation
  final pw.TextStyle? codeBlockTextStyle;

  /// This customizes the inline-code text style in the default implementation
  final pw.TextStyle? inlineCodeStyle;

  /// This customizes the code-block font in the default implementation
  final pw.Font? codeBlockFont;

  /// Customize the background color of the code-block
  final PdfColor? codeBlockBackgroundColor;

  /// Customize the style of the num lines in code block
  final pw.TextStyle? codeBlockNumLinesTextStyle;

  /// Define the text style of the general blockquote into the default implementation
  final pw.TextStyle? blockquoteTextStyle;

  /// Define the left space between divider and text into the default implementation
  @Deprecated(
      'blockQuotePaddingLeft is not longer used and will be removed in future releases. use blockquoteEdgeInsets instead')
  final double? blockQuotePaddingLeft;
  @Deprecated(
      'blockQuotePaddingRight is not longer used and will be removed in future releases. use blockquotePadding instead')
  final double? blockQuotePaddingRight;

  /// Define the padding space into the blockquote default implementation
  @experimental
  final pw.EdgeInsetsGeometry? Function(int indent, pw.TextDirection direction)?
      blockquotePadding;

  /// Define the width of the divider
  final double? blockquotethicknessDividerColor;

  /// Customize the background of the blockquote
  final PdfColor? blockquoteBackgroundColor;

  /// Customize the left/right divider color to blockquotes
  @Deprecated(
      'blockQuoteDividerColor is no longer supported. Use blockquoteBoxDecoration instead')
  final PdfColor? blockquoteDividerColor;

  /// Customize the border of the blockquote into the default implementation
  final pw.BoxDecoration? Function(pw.TextDirection direction)?
      blockquoteBoxDecoration;

  /// When an image is detected, this will be called to build a custom implementation of it
  final qpdf.PDFWidgetBuilder<ep.TextFragment, pw.Widget>? onDetectImageBlock;

  /// When a video is detected, this will be called to build a custom implementation of it
  @experimental
  final qpdf.PDFWidgetBuilder<ep.TextFragment, pw.Widget>? onDetectVideoBlock;

  /// When an image is being builded and an error is catched, this is called
  final PDFWidgetErrorBuilder<String, pw.Widget, ep.TextFragment>?
      onDetectErrorInImage;

  /// When a rich text styles are detected, this builder is called
  final qpdf.PDFWidgetBuilder<ep.TextFragment, pw.InlineSpan>?
      onDetectInlineRichTextStyles;

  /// When a header block is detected, this builder is called
  final qpdf.PDFWidgetBuilder<ep.Line, pw.Widget>? onDetectHeaderBlock;

  /// When a aligned block is detected, this builder is called
  final qpdf.PDFWidgetBuilder<ep.Line, pw.Widget>? onDetectAlignedParagraph;

  /// When a non rich text line is detected, this builder is called
  /// Tipically this happens when the insertion has not inline attributes
  final qpdf.PDFWidgetBuilder<ep.TextFragment, pw.InlineSpan>?
      onDetectCommonText;

  /// When a link line is detected, this builder is called
  final qpdf.PDFWidgetBuilder<ep.TextFragment, pw.InlineSpan>? onDetectLink;

  /// When a list block is detected, this builder is called
  final qpdf.PDFWidgetBuilder<ep.Paragraph, pw.Widget>? onDetectList;

  /// When a code block is detected, this builder is called
  final qpdf.PDFWidgetBuilder<ep.Paragraph, pw.Widget>? onDetectCodeBlock;

  /// When a block quote is detected, this builder is called
  final qpdf.PDFWidgetBuilder<ep.Paragraph, pw.Widget>? onDetectBlockquote;

  late final List<pw.Font> globalFontsFallbacks;

  /// When a image has not a defined height, this will be called to fit images to a specific
  /// contraints
  @experimental
  final pw.BoxConstraints? imageConstraints;

  /// When the data of a image is an url, this allow us create a custom implementation to get the bytes
  @experimental
  final Future<Uint8List?> Function(String url)? onDetectImageUrl;

  /// This enable the highlight for code-block blocks
  @experimental
  final bool enableCodeBlockHighlighting;

  /// isLightCodeBlockTheme is used when enableCodeBlockHighlighting is true
  /// to decide the correct style for the spans
  @experimental
  final bool isLightCodeBlockTheme;

  /// This gives the ability to have our custom code-block highlight theme
  @experimental
  final Map<String, pw.TextStyle>? Function(String? languageDetected)?
      customCodeHighlightTheme;
  // This let us create custom sizes when a Header is detected
  @experimental
  final List<double>? customHeadingSizes;

  /// Determines if the elements of check lists
  /// will be painted with ~strikethough style~ when
  /// checked is `true`
  @experimental
  final bool paintStrikethoughStyleOnCheckedElements;

  /// Determines the appareance of the checkbox leading widget
  ///
  /// _Can be ignored, since is configured by default_
  @experimental
  final CheckboxDecorator? checkboxDecorator;

  /// [isWeb] is used to know is the current platform is web since the way of the fetch images files
  /// is different from the other platforms
  @experimental
  final bool isWeb;

  PDFConverter({
    required this.pageFormat,
    required this.document,
    @experimental this.checkboxDecorator,
    @experimental this.paintStrikethoughStyleOnCheckedElements = false,
    @experimental this.documentOptions = const DocumentOptions(),
    @experimental this.enableCodeBlockHighlighting = true,
    @experimental this.customHeadingSizes,
    @experimental this.isLightCodeBlockTheme = true,
    @experimental this.customCodeHighlightTheme,
    @experimental this.isWeb = false,
    @experimental this.listLeadingBuilder,
    @experimental this.imageConstraints,
    @experimental this.onDetectImageUrl,
    @experimental this.iconsFont,
    this.blockquotePadding,
    this.blockquoteBoxDecoration,
    this.inlineCodeStyle,
    this.textDirection = ui.TextDirection.ltr,
    this.frontMatterDelta,
    this.listTypeWidget = ListTypeWidget.modern,
    this.backMatterDelta,
    this.customBuilders = const <qpdf.CustomWidget>[],
    this.onRequestFontFamily,
    required List<pw.Font> fallbacks,
    @Deprecated(
        'blockquotePaddingLeft is not longer used and will be removed in future releases. use blockquoteEdgeInsets instead')
    this.blockQuotePaddingLeft,
    @Deprecated(
        'blockquotePaddingLeft is not longer used and will be removed in future releases. use blockquoteEdgeInsets instead')
    this.blockQuotePaddingRight,
    this.blockquotethicknessDividerColor,
    this.blockquoteBackgroundColor,
    this.blockquoteDividerColor,
    this.blockquoteTextStyle,
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
    this.onDetectVideoBlock,
    this.onDetectInlineRichTextStyles,
    this.onDetectLink,
    this.onDetectList,
  }) : assert(customHeadingSizes == null || customHeadingSizes.length >= 4,
            'customHeadingSizes must have minimun 4 items.') {
    globalFontsFallbacks = <pw.Font>[
      ...fallbacks,
      pw.Font.helvetica(),
      pw.Font.helveticaBold(),
      pw.Font.helveticaOblique(),
      pw.Font.symbol(),
      pw.Font.zapfDingbats(),
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
    @Deprecated(
        'deltaOptionalAttr is no longer used, and will be removed in future releases.')
    qpdf.DeltaAttributesOptions? deltaOptionalAttr,
    @Deprecated(
        'overrideAttributes is no longer used and will be removed in future releases.')
    bool overrideAttributesPassedByUser = false,
    @Deprecated(
        'shouldProcessDeltas is no longer used and will be removed in future releases.')
    bool shouldProcessDeltas = true,
    void Function(dynamic error)? onException,
    PageBuilder? pageBuilder,
  }) async {
    final qpdf.Converter<Delta, pw.Document> converter =
        _buildService(pageBuilder);
    try {
      return await converter.generateDoc();
    } catch (e) {
      onException?.call(e);
      rethrow;
    }
  }

  /// This Create the PDF document and write it to storage path
  /// This implementation can throw PathNotFoundException or exceptions based in Storage capabilities
  @Deprecated(
      'createDocumentFile is no longer supported since can throw PathNotFoundException. Use createDocument instead')
  Future<void> createDocumentFile({
    required String path,
    @Deprecated(
        'deltaOptionalAttr is no longer used, and will be removed in future releases')
    qpdf.DeltaAttributesOptions? deltaOptionalAttr,
    @Deprecated(
        'overrideAttributes is no longer used and will be removed in future releases.')
    bool overrideAttributesPassedByUser = false,
    @Deprecated(
        'shouldProcessDeltas is no longer used and will be removed in future releases.')
    bool shouldProcessDeltas = true,
    @Deprecated('Use isWeb global variable from PDFConverter instead')
    bool isWeb = false,
    void Function(dynamic error)? onException,
    void Function([Object? data])? onSucessWrite,
    PageBuilder? pageBuilder,
  }) async {}

  /// Return a container with the widgets generated from the Document passed
  Future<pw.Widget?> generateWidget({
    @Deprecated(
        'deltaOptionalAttr is no longer used, and will be removed in future releases.')
    qpdf.DeltaAttributesOptions? deltaOptionalAttr,
    @Deprecated(
        'overrideAttributes is no longer used and will be removed in future releases.')
    bool overrideAttributesPassedByUser = false,
    @Deprecated(
        'shouldProcessDeltas is no longer used and will be removed in future releases.')
    bool shouldProcessDeltas = true,
    double? maxWidth,
    double? maxHeight,
    void Function(dynamic error)? onException,
  }) async {
    final qpdf.Converter<Delta, pw.Document> converter = _buildService(null);
    try {
      return await converter.generateWidget(
          maxWidth: maxWidth, maxHeight: maxHeight);
    } catch (e) {
      onException?.call(e);
      rethrow;
    }
  }

  qpdf.PdfService _buildService(
    pw.Page Function(List<pw.Widget> children, pw.ThemeData theme,
            PdfPageFormat pageFormat)?
        pageBuilder,
  ) =>
      qpdf.PdfService(
        paintStrikethoughStyleOnCheckedElements:
            paintStrikethoughStyleOnCheckedElements,
        checkboxDecorator: checkboxDecorator ?? CheckboxDecorator.base(),
        pageFormat: pageFormat,
        fonts: globalFontsFallbacks,
        customTheme: themeData,
        directionality: textDirection.toPdf(),
        iconsFont: iconsFont,
        pageBuilder: pageBuilder,
        isWeb: isWeb,
        enableCodeBlockHighlighting: enableCodeBlockHighlighting,
        isLightCodeBlockTheme: isLightCodeBlockTheme,
        documentOptions: documentOptions,
        customCodeHighlightTheme: customCodeHighlightTheme,
        customBuilders: customBuilders,
        blockquoteBackgroundColor: blockquoteBackgroundColor,
        codeBlockBackgroundColor: codeBlockBackgroundColor,
        codeBlockFont: codeBlockFont,
        codeBlockNumLinesTextStyle: codeBlockNumLinesTextStyle,
        codeBlockTextStyle: codeBlockTextStyle,
        blockquoteTextStyle: blockquoteTextStyle,
        onDetectAlignedParagraph: onDetectAlignedParagraph,
        onDetectCommonText: onDetectCommonText,
        onDetectBlockquote: onDetectBlockquote,
        onDetectCodeBlock: onDetectCodeBlock,
        inlineCodeStyle: inlineCodeStyle,
        onDetectVideoBlock: onDetectImageBlock,
        blockquotethicknessDividerColor: blockquotethicknessDividerColor,
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
        customHeadingSizes: customHeadingSizes,
        listTypeWidget: listTypeWidget,
        blockquotePadding: blockquotePadding,
        blockquoteBoxDecoration: blockquoteBoxDecoration,
        listLeadingBuilder: listLeadingBuilder,
        imageConstraints:
            imageConstraints ?? const pw.BoxConstraints(maxHeight: 450),
        onDetectImageUrl: onDetectImageUrl,
      );

  @Deprecated(
      'processDelta is no longer used. It always return null now. It will be removed in future releases.')
  static Delta? processDelta(Delta delta, DeltaAttributesOptions options,
      bool overrideAttributesPassedByUser) {
    return null;
  }
}
