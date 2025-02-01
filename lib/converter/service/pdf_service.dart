import 'dart:async';
import 'dart:collection';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_quill_delta_easy_parser/flutter_quill_delta_easy_parser.dart';
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart';
import 'package:meta/meta.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

///A Manager that contains all operations for PDF services
class PdfService extends PdfConfigurator<Delta, pw.Document> {
  late final List<pw.Font> _fonts;
  //page configs
  late final double _marginLeft;
  late final double _marginBottom;
  late final double _marginTop;
  late final double _marginRight;
  late final double _width;
  late final double _height;
  final pw.TextDirection textDirection;
  final List<pw.Widget> contentPerPage = <pw.Widget>[];
  @experimental
  final pw.Page Function(List<pw.Widget> children, pw.ThemeData theme, PdfPageFormat pageFormat)? pageBuilder;

  PdfService({
    required PDFPageFormat pageFormat,
    required List<pw.Font> fonts,
    this.pageBuilder,
    this.textDirection = pw.TextDirection.ltr,
    super.isWeb,
    super.onRequestFontFamily,
    required super.customBuilders,
    required super.document,
    pw.ThemeData? customTheme,
    super.codeBlockFont,
    super.blockQuoteBackgroundColor,
    super.codeBlockBackgroundColor,
    super.codeBlockNumLinesTextStyle,
    super.codeBlockTextStyle,
    super.blockQuoteDividerColor,
    super.blockQuoteTextStyle,
    super.blockQuotePaddingLeft,
    super.blockQuotePaddingRight,
    super.blockQuotethicknessDividerColor,
    super.onDetectBlockquote,
    super.onDetectCodeBlock,
    super.onDetectAlignedParagraph,
    super.onDetectCommonText,
    super.onDetectHeaderBlock,
    super.onDetectImageBlock,
    super.onDetectInlineRichTextStyles,
    super.onDetectLink,
    super.onDetectList,
    super.backM,
    super.frontM,
  }) {
    _fonts = fonts;
    defaultTextStyle = pw.TextStyle(
      fontSize: defaultFontSize.toDouble(),
      lineSpacing: 1.0,
      fontFallback: <pw.Font>[..._fonts],
    );
    _marginLeft = pageFormat.marginLeft;
    _marginBottom = pageFormat.marginBottom;
    _marginTop = pageFormat.marginTop;
    _marginRight = pageFormat.marginRight;
    _width = pageFormat.width;
    _height = pageFormat.height;
    pageWidth = pageFormat.width;
    pageHeight = pageFormat.height;
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
    contentPerPage.clear();
    final pw.Document pdf = pw.Document(
      compress: true,
      verbose: true,
      pageMode: PdfPageMode.outlines,
      version: PdfVersion.pdf_1_5,
    );
    final PdfPageFormat pdfPageFormat = PdfPageFormat(_width, _height,
        marginBottom: _marginBottom,
        marginLeft: _marginLeft,
        marginRight: _marginRight,
        marginTop: _marginTop);
    // front matter
    final List<List<pw.Widget>> docWidgets = await generatePages(
        documents: <Delta>[frontM ?? Delta(), document, backM ?? Delta()]);
    for (int i = 0; i < docWidgets.length; i++) {
      final List<pw.Widget> widgets = docWidgets.elementAt(i);
      final pw.Page? pageBuilded = pageBuilder?.call(widgets, defaultTheme, pdfPageFormat);
      pdf.addPage(
       pageBuilded ?? pw.MultiPage(
          theme: defaultTheme,
          pageFormat: pdfPageFormat,
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
  Future<pw.Widget> generateWidget({
    double? maxWidth,
    double? maxHeight,
  }) async {
    final Document? document = RichTextParser().parseDelta(this.document);
    if (document == null) {
      throw StateError(
          'The Delta passed is not valid to be parsed. Please, first ensure the Delta to have not empty content.');
    }
    final List<pw.Widget> widgets = await blockGenerators(document);
    final pw.Widget content = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: widgets,
    );
    pw.Container widget = pw.Container(
      width: maxWidth,
      height: maxHeight,
      child: content,
    );
    return widget;
  }

  @override
  Future<List<List<pw.Widget>>> generatePages({
    required List<Delta> documents,
  }) async {
    LinkedHashSet<List<pw.Widget>> docMap = LinkedHashSet<List<pw.Widget>>();
    int i = 0;
    int totalDocuments = documents.length;
    while (i < totalDocuments) {
      final Delta doc = documents.elementAt(i);
      if (doc.isNotEmpty) {
        final Document? document = RichTextParser().parseDelta(doc);
        docMap.add(List<pw.Widget>.from(await blockGenerators(document!)));
      }
      i++;
    }
    return List<List<pw.Widget>>.from(docMap);
  }

  @override
  Future<List<pw.Widget>> blockGenerators(Document document) async {
    final List<Paragraph> paragraphs = <Paragraph>[...document.paragraphs];
    for (int i = 0; i < paragraphs.length; i++) {
      final Paragraph paragraph = paragraphs.elementAt(i);
      final Map<String, dynamic>? blockAttributes = paragraph.blockAttributes;
      final List<pw.InlineSpan> spansToWrap = <pw.InlineSpan>[];
      final List<pw.InlineSpan> inlineSpansToMerge = <pw.InlineSpan>[];
      bool goToNextParagraph = false;
      for (CustomWidget customBuilder in super.customBuilders) {
        if (customBuilder.predicate(paragraph)) {
          contentPerPage.add(customBuilder.widgetCallback(
              paragraph, paragraph.blockAttributes));
          goToNextParagraph = true;
          break;
        }
      }
      if (goToNextParagraph) continue;
      verifyBlock(blockAttributes);
      //verify if paragraph is just a simple new line
      if (paragraph.lines.length == 1 &&
          paragraph.lines.firstOrNull?.data == '\n' &&
          blockAttributes == null) {
        final List<pw.InlineSpan> spans = await getRichTextInlineStyles.call(
            paragraph.lines.first, defaultTextStyle);
        _applyInlineParagraph(contentPerPage, spans);
        continue;
      }
      //verify if the data line is a embed
      if (paragraph.type == ParagraphType.embed &&
          paragraph.lines.firstOrNull?.data is Map) {
        final Line line = paragraph.lines.first;
        if ((line.data as Map<String, dynamic>)['video'] != null) {
          contentPerPage.add(pw.RichText(
              text: pw.TextSpan(
                  text: (line.data as Map<String, dynamic>)['video'])));
          continue;
        }
        //avoid any another embed that is not a image
        if ((line.data as Map<String, dynamic>)['image'] == null) continue;
        if (onDetectImageBlock != null) {
          contentPerPage
              .add(onDetectImageBlock!.call(line, paragraph.blockAttributes));
          continue;
        }
        contentPerPage.add(await getImageBlock.call(line,
            (blockAttributes?['align'] as String?)?.resolvePdfBlockAlign));
        continue;
      }
      for (int l = 0; l < paragraph.lines.length; l++) {
        final Line line = paragraph.lines.elementAt(l);
        if (paragraph.type == ParagraphType.block || blockAttributes != null) {
          if ((line.data is Map)) {
            if ((line.data as Map)['video'] != null) {
              spansToWrap.add(pw.TextSpan(
                  text: '\n${(line.data as Map<String, dynamic>)['video']}\n'));
              continue;
            }
            //avoid any another embed that is not a image
            if ((line.data as Map)['image'] == null) continue;
            if (onDetectImageBlock != null) {
              final pw.Widget widget =
                  onDetectImageBlock!.call(line, paragraph.blockAttributes);
              spansToWrap.add(pw.WidgetSpan(child: widget));
              continue;
            }
            final pw.Widget widget = await getImageBlock.call(line,
                (blockAttributes?['align'] as String?)?.resolvePdfBlockAlign);
            spansToWrap.add(pw.WidgetSpan(child: widget));
            continue;
          }
          final (pw.TextStyle style, bool addFontSize) =
              _getInlineTextStyle(blockAttributes);
          if (line.attributes?['link'] != null) {
            if (onDetectLink != null) {
              spansToWrap
                  .addAll(onDetectLink!.call(line, paragraph.blockAttributes));
              continue;
            }
            spansToWrap
                .addAll(await getLinkStyle.call(line, style, addFontSize));
            continue;
          }
          if (onDetectInlineRichTextStyles != null) {
            spansToWrap.addAll(onDetectInlineRichTextStyles!
                .call(line, paragraph.blockAttributes));
            continue;
          }
          spansToWrap.addAll(await getRichTextInlineStyles.call(
              line, style, false, addFontSize));
        } else if (paragraph.type == ParagraphType.inline ||
            blockAttributes == null) {
          if (line.data is Map) {
            if ((line.data as Map)['video'] != null) {
              inlineSpansToMerge.add(pw.TextSpan(
                  text: '\n${(line.data as Map<String, dynamic>)['video']}\n'));
              continue;
            }
            //avoid any another embed that is not a image
            if ((line.data as Map)['image'] == null) continue;
            if (onDetectImageBlock != null) {
              final pw.Widget widget =
                  onDetectImageBlock!.call(line, paragraph.blockAttributes);
              inlineSpansToMerge.add(pw.WidgetSpan(child: widget));
              continue;
            }
            final pw.Widget widget = await getImageBlock.call(line,
                (blockAttributes?['align'] as String?)?.resolvePdfBlockAlign);
            inlineSpansToMerge.add(pw.WidgetSpan(child: widget));
            continue;
          } else if (line.attributes != null) {
            if (onDetectInlineRichTextStyles != null) {
              inlineSpansToMerge.addAll(onDetectInlineRichTextStyles!
                  .call(line, paragraph.blockAttributes));
              continue;
            }
            inlineSpansToMerge.addAll(
                await getRichTextInlineStyles.call(line, defaultTextStyle));
            continue;
          }
          if (onDetectCommonText != null) {
            inlineSpansToMerge.addAll(
                onDetectCommonText!.call(line, paragraph.blockAttributes));
            continue;
          }
          //if it doesn't have attrs then just put the content
          inlineSpansToMerge.add(
              pw.TextSpan(text: line.data as String, style: defaultTextStyle));
        }
      }
      //then put the block styles
      if (blockAttributes != null) {
        _applyBlockAttributes(
          spansToWrap,
          blockAttributes,
        );
      }
      _applyInlineParagraph(contentPerPage, inlineSpansToMerge);
    }
    return contentPerPage;
  }

  void _applyInlineParagraph(
      List<pw.Widget> contentPerPage, List<pw.InlineSpan> inlineSpansToMerge) {
    if (inlineSpansToMerge.isEmpty) return;
    final double spacing =
        (inlineSpansToMerge.firstOrNull?.style?.lineSpacing ?? 1.0);
    contentPerPage.add(
      pw.Padding(
        padding:
            pw.EdgeInsets.only(bottom: spacing.resolvePaddingByLineHeight()),
        child: pw.RichText(
          softWrap: true,
          overflow: pw.TextOverflow.span,
          textDirection: textDirection,
          text: pw.TextSpan(
            children: inlineSpansToMerge,
          ),
        ),
      ),
    );
  }

  (pw.TextStyle, bool) _getInlineTextStyle(
      Map<String, dynamic>? blockAttributes) {
    bool addFontSize = true;
    final double? lineHeight = blockAttributes?['line-height'];
    if (blockAttributes?['header'] != null) {
      final int headerLevel = blockAttributes!['header'];
      final double currentFontSize = headerLevel.resolveHeaderLevel();
      pw.TextStyle style = defaultTextStyle.copyWith(fontSize: currentFontSize);
      style = style.copyWith(lineSpacing: lineHeight?.resolveLineHeight());
      addFontSize = false;
      return (style, addFontSize);
    } else if (blockAttributes?['code-block'] != null) {
      final pw.TextStyle defaultCodeBlockStyle = pw.TextStyle(
        fontSize: 12,
        font: pw.Font.courier(),
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
      pw.TextStyle style = defaultCodeBlockStyle;
      style = style.copyWith(lineSpacing: lineHeight?.resolveLineHeight());
      return (style, addFontSize);
    } else if (blockAttributes?['blockquote'] != null) {
      final pw.TextStyle defaultStyle =
          pw.TextStyle(color: PdfColor.fromHex("#808080"), lineSpacing: 6.5);
      final pw.TextStyle blockquoteStyle = defaultStyle;
      pw.TextStyle style = blockquoteStyle;
      style = style.copyWith(lineSpacing: lineHeight?.resolveLineHeight());
      return (style, addFontSize);
    } else {
      final pw.TextStyle style = defaultTextStyle.copyWith(
          lineSpacing: lineHeight?.resolveLineHeight());
      return (style, addFontSize);
    }
  }

  void verifyBlock(Map<String, dynamic>? blockAttributes) {
    final int? indent = blockAttributes?['indent'];
    if (blockAttributes?['list'] != null) {
      if (indent != null) {
        // validate if the last indent is different that the current one
        //
        // if it is, then must reload the specific index counter to avoid generate
        // a bad index for the current item
        if (lastListIndent != indent) {
          if (indent == 1) numberIndent1List = 0;
          if (indent == 2) numberIndent2List = 0;
          if (indent == 3) numberIndent3List = 0;
          if (indent == 4) numberIndent4List = 0;
          if (indent == 5) numberIndent5List = 0;
        }
        lastListIndent = indent;
        if (indent == 1) numberIndent1List++;
        if (indent == 2) numberIndent2List++;
        if (indent == 3) numberIndent3List++;
        if (indent == 4) numberIndent4List++;
        if (indent == 5) numberIndent5List++;
      } else {
        lastListIndent = 0;
        numberList++;
      }
    } else {
      lastListIndent = 0;
      numberList = 0;
      numberIndent1List = 0;
      numberIndent2List = 0;
      numberIndent3List = 0;
      numberIndent4List = 0;
      numberIndent5List = 0;
    }
    blockAttributes?['code-block'] != null ? numCodeLine++ : numCodeLine = 0;
  }

  void _applyBlockAttributes(List<pw.InlineSpan> currentSpans,
      Map<String, dynamic> blockAttributes) async {
    final int? header = blockAttributes['header'];
    final String? direction = blockAttributes['direction'];
    final String? align = blockAttributes['align'];
    final String? listType = blockAttributes['list'];
    final int? indent = blockAttributes['indent'];
    final double? lineHeight = blockAttributes['line-height'];
    final bool? codeblock = blockAttributes['code-block'];
    final bool? blockquote = blockAttributes['blockquote'];
    int indentLevel = indent ?? 0;
    if (indentLevel > 0) {
      indentLevel++;
    }
    final pw.TextDirection textDirectionToUse =
        direction == 'rtl' ? pw.TextDirection.rtl : textDirection;
    if (header != null) {
      if (onDetectHeaderBlock != null) {
        final pw.Widget customBlock =
            onDetectHeaderBlock!.call(currentSpans, blockAttributes);
        contentPerPage.add(pw.Directionality(
            textDirection: textDirectionToUse, child: customBlock));
        return;
      }
      if (align != null) {
        final pw.Widget alignedBlock = await getAlignedHeaderBlock(
            currentSpans, header, align, indentLevel);
        contentPerPage.add(pw.Directionality(
            textDirection: textDirectionToUse, child: alignedBlock));
        return;
      }
      final pw.Widget headerBlock =
          await getHeaderBlock(currentSpans, header, indentLevel);
      contentPerPage.add(pw.Directionality(
          textDirection: textDirectionToUse, child: headerBlock));
      return;
    }
    if (codeblock != null) {
      if (onDetectCodeBlock != null) {
        final pw.Widget customBlock =
            onDetectCodeBlock!.call(currentSpans, blockAttributes);
        contentPerPage.add(pw.Directionality(
            textDirection: textDirectionToUse, child: customBlock));
        return;
      }
      final pw.Widget codeBlock = await getCodeBlock(currentSpans);
      contentPerPage.add(pw.Directionality(
          textDirection: textDirectionToUse, child: codeBlock));
      return;
    }
    if (blockquote != null) {
      if (onDetectBlockquote != null) {
        final pw.Widget customBlock =
            onDetectBlockquote!.call(currentSpans, blockAttributes);
        contentPerPage.add(pw.Directionality(
            textDirection: textDirectionToUse, child: customBlock));
        return;
      }
      final pw.Widget blockquoteBlock = await getBlockQuote(currentSpans);
      contentPerPage.add(pw.Directionality(
          textDirection: textDirectionToUse, child: blockquoteBlock));
      return;
    }
    if (listType != null) {
      if (onDetectList != null) {
        final pw.Widget customBlock =
            onDetectList!.call(currentSpans, blockAttributes);
        contentPerPage.add(pw.Directionality(
            textDirection: textDirectionToUse, child: customBlock));
        return;
      }
      final pw.Widget listBlock = await getListBlock(
          currentSpans, listType, align ?? 'left', indentLevel);
      contentPerPage.add(pw.Directionality(
          textDirection: textDirectionToUse, child: listBlock));
      return;
    }
    if (align != null) {
      if (onDetectAlignedParagraph != null) {
        final pw.Widget customBlock =
            onDetectAlignedParagraph!.call(currentSpans, blockAttributes);
        contentPerPage.add(pw.Directionality(
            textDirection: textDirectionToUse, child: customBlock));
        return;
      }
      final pw.Widget alignedParagraphBlock =
          await getAlignedParagraphBlock(currentSpans, align, indentLevel);
      contentPerPage.add(pw.Directionality(
          textDirection: textDirectionToUse, child: alignedParagraphBlock));
      return;
    }
    if (indent != null) {
      final double spacing =
          (currentSpans.firstOrNull?.style?.lineSpacing ?? 1.0);
      contentPerPage.add(pw.Container(
        alignment: align?.resolvePdfBlockAlign,
        padding: pw.EdgeInsets.only(
            left: textDirectionToUse == pw.TextDirection.rtl
                ? 0
                : indentLevel * 12.5,
            right: textDirectionToUse == pw.TextDirection.rtl
                ? indentLevel * 12.5
                : 0,
            bottom: spacing.resolvePaddingByLineHeight()),
        child: pw.RichText(
          textAlign: align.resolvePdfTextAlign,
          softWrap: true,
          textDirection: textDirectionToUse,
          overflow: pw.TextOverflow.span,
          text: pw.TextSpan(
            children: currentSpans,
          ),
        ),
      ));
      return;
    }
    if (lineHeight != null) {
      contentPerPage.add(
        pw.Padding(
          padding: pw.EdgeInsets.only(
              bottom:
                  lineHeight.resolveLineHeight().resolvePaddingByLineHeight()),
          child: pw.RichText(
            softWrap: true,
            overflow: pw.TextOverflow.span,
            textDirection: textDirectionToUse,
            text: pw.TextSpan(
              style: defaultTextStyle.copyWith(
                  lineSpacing: lineHeight.resolveLineHeight()),
              children: currentSpans,
            ),
          ),
        ),
      );
      return;
    }
  }
}
