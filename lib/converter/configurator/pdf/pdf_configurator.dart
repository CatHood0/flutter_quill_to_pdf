import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:dio/dio.dart';
import 'package:flutter_quill_delta_easy_parser/flutter_quill_delta_easy_parser.dart';
import 'package:flutter_quill_to_pdf/core/constant/constants.dart';
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart';
import 'package:numerus/roman/roman.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart' show PdfColor, PdfColors, PdfPageFormat;
import 'package:pdf/widgets.dart' as pw;

import '../../../utils/css.dart';
import 'attribute_functions.dart';
import 'document_functions.dart';

abstract class PdfConfigurator<T, D> extends ConverterConfigurator<T, D>
    implements
        AttrInlineFunctions<List<pw.InlineSpan>, pw.TextStyle?>,
        AttrBlockFunctions<pw.Widget, pw.TextStyle?>,
        DocumentFunctions<Delta, Document, List<pw.Widget>> {
  late final pw.ThemeData defaultTheme;
  late final PdfColor defaultLinkColor;
  late final pw.TextStyle defaultTextStyle;
  //show default this on ordered list
  int lastListIndent = 0;
  int numberList = 0;
  int numberIndent1List = 0;
  int numberIndent2List = 0;
  int numberIndent3List = 0;
  int numberIndent4List = 0;
  int numberIndent5List = 0;
  int numCodeLine = 0;
  final Delta? frontM;
  final Delta? backM;
  final List<CustomWidget> customBuilders;
  final Future<pw.Font> Function(String fontFamily)? onRequestFont;
  final Future<pw.Font> Function(String fontFamily)? onRequestBoldFont;
  final Future<pw.Font> Function(String fontFamily)? onRequestItalicFont;
  final Future<pw.Font> Function(String fontFamily)? onRequestBothFont;
  final PDFWidgetBuilder<Line, pw.Widget>? onDetectImageBlock;
  final PDFWidgetBuilder<Line, List<pw.InlineSpan>>?
      onDetectInlineRichTextStyles;
  final PDFWidgetBuilder<List<pw.InlineSpan>, pw.Widget>? onDetectHeaderBlock;
  final PDFWidgetBuilder<List<pw.InlineSpan>, pw.Widget>?
      onDetectAlignedParagraph;
  final PDFWidgetBuilder<Line, List<pw.InlineSpan>>? onDetectCommonText;

  final PDFWidgetBuilder<Line, List<pw.InlineSpan>>? onDetectLink;
  final PDFWidgetBuilder<List<pw.InlineSpan>, pw.Widget>? onDetectList;
  final PDFWidgetBuilder<List<pw.InlineSpan>, pw.Widget>? onDetectCodeBlock;
  final PDFWidgetBuilder<List<pw.InlineSpan>, pw.Widget>? onDetectBlockquote;
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
  final int defaultFontSize = Constant
      .DEFAULT_FONT_SIZE; //avoid spans without font sizes not appears in the document
  late final double pageWidth, pageHeight;
  PdfConfigurator({
    this.onRequestBoldFont,
    this.onRequestBothFont,
    this.onRequestFallbacks,
    this.onRequestFont,
    this.onRequestItalicFont,
    required this.customBuilders,
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
    this.onDetectHeaderBlock,
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
  //TODO: implement validation for base64 parsing
  @override
  Future<pw.Widget> getImageBlock(Line line, [pw.Alignment? alignment]) async {
    double? width = null;
    double? height = null;
    final String data = (line.data as Map<String, dynamic>)['image'];
    final Map<String, dynamic> attributes =
        parseCssStyles(line.attributes?['style'] ?? '', 'left');
    if (attributes.isNotEmpty) {
      width = attributes['width'] ?? pageWidth;
      height = attributes['height'];
    }
    late final File? file;
    if (Constant.IMAGE_FROM_NETWORK_URL.hasMatch(data)) {
      final String url = data;
      final String pathStorage =
          '${(await getApplicationCacheDirectory()).path}/image (${Random.secure().nextInt(99999) + 50})';
      try {
        file = File(pathStorage);
        await Dio().download(url, pathStorage);
      } on DioException {
        rethrow;
      }
    } else if (Constant.IMAGE_LOCAL_STORAGE_PATH_PATTERN.hasMatch(data)) {
      file = File(data);
    } else {
      final Uint8List bytes = base64Decode(data);
      final String pathStorage =
          '${(await getApplicationCacheDirectory()).path}/image (${Random.secure().nextInt(99999) + 50})';
      try {
        file = File(pathStorage);
        file.writeAsBytes(bytes);
      } on DioException {
        rethrow;
      }
    }

    if (!(await file.exists())) {
      return pw.SizedBox.shrink();
    }
    // verify if exceded height using page format params
    if (height != null && height >= pageHeight) height = pageHeight;
    // verify if exceded width using page format params
    if (width != null && width >= pageWidth) width = pageWidth;
    return pw.RichText(
      softWrap: true,
      overflow: pw.TextOverflow.span,
      text: pw.WidgetSpan(
        child: pw.Container(
          alignment: alignment,
          constraints:
              height == null ? const pw.BoxConstraints(maxHeight: 450) : null,
          child: pw.Image(
            pw.MemoryImage((await file.readAsBytes())),
            dpi: 230,
            height: height,
            width: width,
          ),
        ),
      ),
    );
  }

  @override
  Future<List<pw.InlineSpan>> getRichTextInlineStyles(Line line,
      [pw.TextStyle? style,
      bool returnContentIfNeedIt = false,
      bool addFontSize = true]) async {
    final List<pw.InlineSpan> spans = <pw.InlineSpan>[];
    final PdfColor? textColor = pdfColorString(line.attributes?['color']);
    final PdfColor? backgroundTextColor =
        pdfColorString(line.attributes?['background']);
    final double? spacing = line.attributes?['line-height'];
    final String? fontFamily = line.attributes?['font'];
    final String? fontSizeMatch = line.attributes?['size'];
    double fontSizeHelper = defaultTextStyle.fontSize!;
    if (fontSizeMatch != null) {
      if (fontSizeMatch == 'small') fontSizeHelper = 8;
      if (fontSizeMatch == 'large') fontSizeHelper = 15.5;
      if (fontSizeMatch == 'huge') fontSizeHelper = 18.5;
      if (fontSizeMatch != 'huge' &&
          fontSizeMatch != 'large' &&
          fontSizeMatch != 'small') {
        fontSizeHelper = double.parse(fontSizeMatch);
      }
    }
    final bool bold = line.attributes?['bold'] ?? false;
    final bool italic = line.attributes?['italic'] ?? false;
    final bool strike = line.attributes?['strike'] ?? false;
    final bool underline = line.attributes?['underline'] ?? false;
    final double? fontSize = !addFontSize ? null : fontSizeHelper;
    final String content = line.data as String;
    final double? lineSpacing = spacing?.resolveLineHeight();
    final pw.Font font =
        await onRequestFont?.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY) ??
            pw.Font.helvetica();
    final List<pw.Font> fonts = await onRequestFallbacks
            ?.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY) ??
        <pw.Font>[];
    // Give just the necessary fallbacks for the founded fontFamily
    final pw.TextStyle decided_style = style?.copyWith(
          font: font,
          fontStyle: italic ? pw.FontStyle.italic : null,
          fontWeight: bold ? pw.FontWeight.bold : null,
          decoration: pw.TextDecoration.combine(<pw.TextDecoration>[
            if (strike) pw.TextDecoration.lineThrough,
            if (underline) pw.TextDecoration.underline,
          ]),
          decorationStyle: pw.TextDecorationStyle.solid,
          decorationColor: textColor ?? backgroundTextColor,
          fontBold: await onRequestBoldFont
              ?.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY),
          fontItalic: await onRequestItalicFont
              ?.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY),
          fontBoldItalic: await onRequestBothFont
              ?.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY),
          fontFallback: fonts,
          fontSize:
              !addFontSize ? null : fontSize ?? defaultFontSize.toDouble(),
          lineSpacing: lineSpacing,
          color: textColor,
          background: pw.BoxDecoration(color: backgroundTextColor),
        ) ??
        defaultTextStyle.copyWith(
          font: font,
          decoration: pw.TextDecoration.combine(<pw.TextDecoration>[
            if (strike) pw.TextDecoration.lineThrough,
            if (underline) pw.TextDecoration.underline,
          ]),
          decorationStyle: pw.TextDecorationStyle.solid,
          decorationColor: textColor ?? backgroundTextColor,
          fontBold: await onRequestBoldFont
              ?.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY),
          fontItalic: await onRequestItalicFont
              ?.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY),
          fontBoldItalic: await onRequestBothFont
              ?.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY),
          fontFallback: fonts,
          fontSize:
              !addFontSize ? null : fontSize ?? defaultFontSize.toDouble(),
          lineSpacing: lineSpacing,
          color: textColor,
          background: pw.BoxDecoration(color: backgroundTextColor),
        );
    spans.add(pw.TextSpan(text: content, style: decided_style));
    if (returnContentIfNeedIt && spans.isEmpty) {
      return <pw.TextSpan>[
        pw.TextSpan(text: line.data.toString(), style: style ?? decided_style)
      ];
    }
    return spans;
  }

  @override
  Future<pw.Widget> getBlockQuote(List<pw.InlineSpan> spansToWrap,
      [pw.TextStyle? style]) async {
    final pw.TextStyle defaultStyle =
        pw.TextStyle(color: PdfColor.fromHex("#808080"), lineSpacing: 6.5);
    final pw.TextStyle blockquoteStyle = blockQuoteTextStyle ?? defaultStyle;
    final pw.Container widget = pw.Container(
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
          children: <pw.InlineSpan>[...spansToWrap],
        ),
      ),
    );
    return widget;
  }

  @override
  Future<pw.Widget> getCodeBlock(List<pw.InlineSpan> spansToWrap,
      [pw.TextStyle? style]) async {
    final pw.TextStyle defaultCodeBlockStyle = pw.TextStyle(
      fontSize: 12,
      font: codeBlockFont ?? pw.Font.courier(),
      fontFallback: <pw.Font>[
        pw.Font.courierBold(),
        pw.Font.courierBoldOblique(),
        pw.Font.courierOblique(),
        pw.Font.symbol()
      ],
      letterSpacing: 1.5,
      lineSpacing: 1.1,
      wordSpacing: 0.5,
      color: PdfColor.fromHex("#808080"),
    );
    final pw.TextStyle codeBlockStyle =
        codeBlockTextStyle ?? defaultCodeBlockStyle;
    final pw.Widget widget = pw.Container(
      width: pageWidth,
      color: this.codeBlockBackgroundColor ?? PdfColor.fromHex('#fbfbf9'),
      padding: const pw.EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      child: pw.RichText(
        softWrap: true,
        overflow: pw.TextOverflow.span,
        text: pw.TextSpan(
          style: codeBlockStyle,
          children: <pw.InlineSpan>[
            pw.TextSpan(
                text: "$numCodeLine", style: codeBlockNumLinesTextStyle),
            const pw.TextSpan(text: "  "),
            ...spansToWrap,
          ],
        ),
      ),
    );
    return widget;
  }

  @override
  Future<List<pw.TextSpan>> getLinkStyle(Line line,
      [pw.TextStyle? style, bool addFontSize = true]) async {
    final List<pw.TextSpan> spans = <pw.TextSpan>[];
    final double? fontSize = double.tryParse(line.attributes?['size']);
    final double? lineHeight = line.attributes?['line-height'];
    final String? fontFamily = line.attributes?['font'];
    final PdfColor? textColor = pdfColorString(line.attributes?['color']);
    final PdfColor? backgroundTextColor =
        pdfColorString(line.attributes?['background']);
    final double? lineSpacing = lineHeight?.resolveLineHeight();
    final bool bold = line.attributes?['bold'] ?? false;
    final bool italic = line.attributes?['italic'] ?? false;
    final bool strike = line.attributes?['strike'] ?? false;
    final bool underline = line.attributes?['underline'] ?? false;
    final String href = line.attributes!['link'];
    final String hrefContent = line.data as String;
    final pw.Font font =
        await onRequestFont?.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY) ??
            pw.Font.helvetica();
    final List<pw.Font> fonts = await onRequestFallbacks
            ?.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY) ??
        <pw.Font>[];
    spans.add(
      pw.TextSpan(
        annotation: pw.AnnotationLink(href),
        text: hrefContent,
        style: (style ?? defaultTextStyle).copyWith(
          color: textColor ?? defaultLinkColor,
          background: backgroundTextColor == null
              ? null
              : pw.BoxDecoration(color: backgroundTextColor),
          fontStyle: italic ? pw.FontStyle.italic : null,
          fontWeight: bold ? pw.FontWeight.bold : null,
          decoration: pw.TextDecoration.combine(<pw.TextDecoration>[
            if (strike) pw.TextDecoration.lineThrough,
            if (underline) pw.TextDecoration.underline,
          ]),
          decorationStyle: pw.TextDecorationStyle.solid,
          decorationColor: defaultLinkColor,
          font: font,
          fontBold: await onRequestBoldFont
              ?.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY),
          fontItalic: await onRequestItalicFont
              ?.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY),
          fontBoldItalic: await onRequestBothFont
              ?.call(fontFamily ?? Constant.DEFAULT_FONT_FAMILY),
          fontFallback: fonts,
          fontSize:
              !addFontSize ? null : fontSize ?? defaultFontSize.toDouble(),
          lineSpacing: lineSpacing,
        ),
      ),
    );
    return spans;
  }

  @override
  Future<pw.Widget> getHeaderBlock(
      List<pw.InlineSpan> spansToWrap, int headerLevel, int indentLevel,
      [pw.TextStyle? style]) async {
    final double defaultFontSize = headerLevel.resolveHeaderLevel();
    final pw.TextStyle textStyle = style?.copyWith(fontSize: defaultFontSize) ??
        defaultTextStyle.copyWith(fontSize: defaultFontSize);
    return pw.Container(
        padding: pw.EdgeInsets.only(
            left: indentLevel.toDouble() * 7, top: 3, bottom: 3.5),
        child: pw.RichText(
          softWrap: true,
          overflow: pw.TextOverflow.span,
          text: pw.TextSpan(
            style: textStyle,
            children: spansToWrap,
          ),
        ));
  }

  @override
  Future<pw.Widget> getAlignedHeaderBlock(
    List<pw.InlineSpan> spansToWrap,
    int headerLevel,
    String align,
    int indentLevel, [
    pw.TextStyle? style,
  ]) async {
    final String alignment = align;
    final pw.Alignment al = alignment.resolvePdfBlockAlign;
    final pw.TextAlign textAlign = alignment.resolvePdfTextAlign;
    final double spacing = (spansToWrap.firstOrNull?.style?.lineSpacing ?? 1.0);
    return pw.Container(
      padding: pw.EdgeInsets.only(
          left: indentLevel * 12.5,
          top: 3,
          bottom: spacing.resolvePaddingByLineHeight()),
      alignment: al,
      child: pw.RichText(
        textAlign: textAlign,
        softWrap: true,
        overflow: pw.TextOverflow.span,
        text: pw.TextSpan(children: spansToWrap),
      ),
    );
  }

  @override
  Future<pw.Widget> getAlignedParagraphBlock(
    List<pw.InlineSpan> spansToWrap,
    String align,
    int indentLevel, [
    pw.TextStyle? style,
  ]) async {
    final double spacing = (spansToWrap.firstOrNull?.style?.lineSpacing ?? 1.0);
    return pw.Container(
      alignment: align.resolvePdfBlockAlign,
      padding: pw.EdgeInsets.only(
          left: indentLevel * 12.5,
          bottom: spacing.resolvePaddingByLineHeight()),
      child: pw.RichText(
        textAlign: align.resolvePdfTextAlign,
        softWrap: true,
        overflow: pw.TextOverflow.span,
        text: pw.TextSpan(
          children: spansToWrap,
        ),
      ),
    );
  }

  @override
  Future<pw.Widget> getListBlock(
    List<pw.InlineSpan> spansToWrap,
    String listType,
    String align,
    int indentLevel, [
    pw.TextStyle? style,
  ]) async {
    pw.InlineSpan? widgets;
    final double? spacing = (spansToWrap.firstOrNull?.style?.lineSpacing);

    // Get the style from the first span to wrap
    final pw.TextStyle? firstSpanStyle =
        spansToWrap.isNotEmpty ? spansToWrap.first.style : null;

    if (listType != 'unchecked' && listType != 'checked') {
      // Apply the first span's style to the list marker
      if (listType == 'ordered') {
        widgets = pw.TextSpan(
          text: '${_getListIdentifier(indentLevel)} ',
          style: firstSpanStyle ?? defaultTextStyle,
          children: <pw.InlineSpan>[
            pw.TextSpan(children: spansToWrap),
          ],
        );
      } else if (listType == 'bullet') {
        widgets = pw.TextSpan(
          children: <pw.InlineSpan>[
            pw.WidgetSpan(
              child: pw.Container(
                width: 2.0 * PdfPageFormat.mm,
                height: 2.0 * PdfPageFormat.mm,
                decoration: const pw.BoxDecoration(
                    color: PdfColors.black, shape: pw.BoxShape.circle),
              ),
            ),
            pw.TextSpan(
              children: <pw.InlineSpan>[
                const pw.TextSpan(text: ' '),
                pw.TextSpan(children: <pw.InlineSpan>[...spansToWrap])
              ],
            ),
          ],
        );
      }
    } else if (listType == 'checked' || listType == 'unchecked') {
      widgets = pw.TextSpan(
        children: <pw.InlineSpan>[
          pw.WidgetSpan(
            child: pw.Checkbox(
              activeColor: PdfColors.blue400,
              name: 'check ${Random.secure().nextInt(9999999) + 50}',
              value: listType == 'checked' ? true : false,
            ),
          ),
          pw.TextSpan(
            children: <pw.InlineSpan>[
              const pw.TextSpan(text: ' '),
              pw.TextSpan(children: <pw.InlineSpan>[...spansToWrap])
            ],
          ),
        ],
      );
    }

    return pw.Container(
      padding: pw.EdgeInsets.only(
        left: indentLevel > 0 ? indentLevel * 12.5 : 15,
        bottom: spacing?.resolvePaddingByLineHeight() ?? 1.5,
      ),
      child: pw.RichText(
        textAlign: align.resolvePdfTextAlign,
        softWrap: true,
        overflow: pw.TextOverflow.span,
        text: pw.TextSpan(
          style: defaultTextStyle,
          children: <pw.InlineSpan>[
            widgets!,
          ],
        ),
      ),
    );
  }

  String _getListIdentifier(int indentLevel) {
    if (indentLevel > 0) indentLevel--;
    if (indentLevel == 1 || indentLevel == 4) {
      return '${_getLetterIdentifier(indentLevel == 1 ? numberIndent1List : numberIndent4List)}.';
    }
    if (indentLevel == 2 || indentLevel == 5) {
      return '${(indentLevel == 2 ? numberIndent2List : numberIndent5List).toRomanNumeralString()}.';
    }
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
}
