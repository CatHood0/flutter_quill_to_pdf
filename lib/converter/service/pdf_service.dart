import 'dart:async';
import 'dart:collection';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_quill_delta_easy_parser/flutter_quill_delta_easy_parser.dart';
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart';
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
  final List<pw.Widget> contentPerPage = <pw.Widget>[];

  PdfService({
    required PDFPageFormat params,
    required List<pw.Font> fonts,
    super.onRequestBoldFont,
    super.onRequestBothFont,
    super.onRequestFallbacks,
    super.onRequestFont,
    super.onRequestItalicFont,
    required super.customConverters,
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
    super.onDetectInlinesMarkdown,
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
    contentPerPage.clear();
    final pw.Document pdf = pw.Document(
      compress: true,
      verbose: true,
      pageMode: PdfPageMode.outlines,
      version: PdfVersion.pdf_1_5,
    );
    final PdfPageFormat pageFormat = PdfPageFormat(_width, _height,
        marginBottom: _marginBottom, marginLeft: _marginLeft, marginRight: _marginRight, marginTop: _marginTop);
    // front matter
    final List<Map<String, dynamic>> docWidgets =
        await generatePages(documents: <Delta>[frontM ?? Delta(), document, backM ?? Delta()]);
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
    LinkedHashSet<Map<String, dynamic>> docMap = LinkedHashSet<Map<String, dynamic>>();
    int i = 0;
    int totalDocuments = documents.length;
    while (i < totalDocuments) {
      final Delta doc = documents.elementAt(i);
      if (doc.isNotEmpty) {
        final Document? document = RichTextParser().parseDelta(doc);
        docMap.add(<String, dynamic>{
          'content': List<pw.Widget>.from(await blockGenerators(document!)),
        });
      }
      i++;
    }
    return List<Map<String, dynamic>>.from(docMap);
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
          contentPerPage.add(customBuilder.widgetCallback(paragraph, paragraph.blockAttributes));
          goToNextParagraph = true;
          break;
        }
      }
      if (goToNextParagraph) continue;
      verifyBlock(blockAttributes);
      //verify if paragraph is just a simple new line
      if (paragraph.lines.length == 1 && paragraph.lines.firstOrNull?.data == '\n' && blockAttributes == null) {
        final List<pw.InlineSpan> spans = await getRichTextInlineStyles.call(paragraph.lines.first, defaultTextStyle);
        final double spacing = (spans.firstOrNull?.style?.lineSpacing ?? 1.0);
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
      //verify if the data line is a embed
      if (paragraph.type == ParagraphType.embed && paragraph.lines.firstOrNull?.data is Map) {
        final Line line = paragraph.lines.first;
        if ((line.data as Map)['video'] != null) {
          contentPerPage.add(pw.RichText(text: pw.TextSpan(text: (line.data as Map<String, dynamic>)['video'])));
          continue;
        }
        //avoid any another embed that is not a image
        if ((line.data as Map<String, dynamic>)['image'] == null) continue;
        if (onDetectImageBlock != null) {
          contentPerPage.add(onDetectImageBlock!.call(line, paragraph.blockAttributes));
          continue;
        }
        contentPerPage.add(await getImageBlock.call(line));
        continue;
      }
      for (int l = 0; l < paragraph.lines.length; l++) {
        final Line line = paragraph.lines.elementAt(l);
        if (paragraph.type == ParagraphType.block || blockAttributes != null) {
          if ((line.data is Map)) {
            if (spansToWrap.isNotEmpty && blockAttributes != null) {
              // if found a paragraph with a embed between the lines, then must separate in two different lists
              // and apply first the before content with the block attributes and after clean those before lines to avoid
              // duplicate content
              _applyBlockAttributes(spansToWrap, blockAttributes);
              spansToWrap.clear();
            }
            if (onDetectImageBlock != null) {
              contentPerPage.add(onDetectImageBlock!.call(line, paragraph.blockAttributes));
              continue;
            }
            contentPerPage.add(await getImageBlock.call(line));
            continue;
          }
          pw.TextStyle? style = null;
          bool addFontSize = true;
          final double? lineHeight = blockAttributes?['line-height'];
          if (blockAttributes?['header'] != null) {
            final int headerLevel = blockAttributes!['header'];
            final double currentFontSize = headerLevel.resolveHeaderLevel();
            style = defaultTextStyle.copyWith(fontSize: currentFontSize);
            style = style.copyWith(lineSpacing: lineHeight?.resolveLineHeight());
            addFontSize = false;
          } else if (blockAttributes?['code-block'] != null) {
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
            style = codeBlockTextStyle ?? defaultCodeBlockStyle;
            style = style.copyWith(lineSpacing: lineHeight?.resolveLineHeight());
          } else if (blockAttributes?['blockquote'] != null) {
            final pw.TextStyle defaultStyle = pw.TextStyle(color: PdfColor.fromHex("#808080"), lineSpacing: 6.5);
            final pw.TextStyle blockquoteStyle = blockQuoteTextStyle ?? defaultStyle;
            style = blockquoteStyle;
            style = style.copyWith(lineSpacing: lineHeight?.resolveLineHeight());
          } else {
            style = defaultTextStyle.copyWith(lineSpacing: lineHeight?.resolveLineHeight());
          }
          if (line.attributes?['link'] != null) {
            if (onDetectLink != null) {
              spansToWrap.addAll(onDetectLink!.call(line, paragraph.blockAttributes));
              continue;
            }
            spansToWrap.addAll(await getLinkStyle.call(line, style, addFontSize));
            continue;
          }
          if (onDetectInlineRichTextStyles != null) {
            spansToWrap.addAll(onDetectInlineRichTextStyles!.call(line, paragraph.blockAttributes));
          }
          spansToWrap.addAll(await getRichTextInlineStyles.call(line, style, false, addFontSize));
        } else if (paragraph.type == ParagraphType.inline || blockAttributes == null) {
          if (line.attributes != null) {
            if (onDetectInlineRichTextStyles != null) {
              inlineSpansToMerge.addAll(onDetectInlineRichTextStyles!.call(line, paragraph.blockAttributes));
            }
            inlineSpansToMerge.addAll(await getRichTextInlineStyles.call(line, defaultTextStyle));
            continue;
          }
          if (onDetectCommonText != null) {
            inlineSpansToMerge.addAll(onDetectCommonText!.call(line, paragraph.blockAttributes));
          }
          //if it doesn't have attrs then just put the content
          inlineSpansToMerge.add(pw.TextSpan(text: line.data as String, style: defaultTextStyle));
        }
      }
      //then put the block styles
      if (blockAttributes != null) {
        _applyBlockAttributes(
          spansToWrap,
          blockAttributes,
        );
      }
      if (blockAttributes == null && inlineSpansToMerge.isNotEmpty) {
        final double spacing = (inlineSpansToMerge.firstOrNull?.style?.lineSpacing ?? 1.0);
        contentPerPage.add(
          pw.Padding(
            padding: pw.EdgeInsets.symmetric(vertical: spacing.resolvePaddingByLineHeight()),
            child: pw.RichText(
              softWrap: true,
              overflow: pw.TextOverflow.span,
              text: pw.TextSpan(
                children: inlineSpansToMerge,
              ),
            ),
          ),
        );
      }
    }
    return contentPerPage;
  }

  void verifyBlock(Map<String, dynamic>? blockAttributes) {
    blockAttributes?['list'] != null ? numberList++ : numberList = 0;
    blockAttributes?['code-block'] != null ? numCodeLine++ : numCodeLine = 0;
  }

  void _applyBlockAttributes(List<pw.InlineSpan> currentSpans, Map<String, dynamic> blockAttributes) async {
    final int? header = blockAttributes['header'];
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
    if (header != null) {
      if (onDetectHeaderBlock != null) {
        contentPerPage.add(onDetectHeaderBlock!.call(currentSpans, blockAttributes));
        return;
      }
      if (align != null) {
        contentPerPage.add(await getAlignedHeaderBlock(currentSpans, header, align, indentLevel));
        return;
      }
      contentPerPage.add(await getHeaderBlock(currentSpans, header, indentLevel));
      return;
    }
    if (codeblock != null) {
      if (onDetectCodeBlock != null) {
        contentPerPage.add(onDetectCodeBlock!.call(currentSpans, blockAttributes));
        return;
      }
      contentPerPage.add(await getCodeBlock(currentSpans));
      return;
    }
    if (blockquote != null) {
      if (onDetectBlockquote != null) {
        contentPerPage.add(onDetectBlockquote!.call(currentSpans, blockAttributes));
        return;
      }
      contentPerPage.add(await getBlockQuote(currentSpans));
      return;
    }
    if (listType != null) {
      if (onDetectList != null) {
        contentPerPage.add(onDetectList!.call(currentSpans, blockAttributes));
        return;
      }
      contentPerPage.add(await getListBlock(currentSpans, listType, align ?? 'left', indentLevel));
      return;
    }
    if (align != null) {
      if (onDetectAlignedParagraph != null) {
        contentPerPage.add(onDetectAlignedParagraph!.call(currentSpans, blockAttributes));
        return;
      }
      contentPerPage.add(await getAlignedParagraphBlock(currentSpans, align, indentLevel));
      return;
    }
    if (indent != null) {
      final double spacing = (currentSpans.firstOrNull?.style?.lineSpacing ?? 1.0);
      contentPerPage.add(pw.Container(
        alignment: align?.resolvePdfBlockAlign,
        padding: pw.EdgeInsets.only(left: indentLevel * 7, bottom: spacing.resolvePaddingByLineHeight()),
        child: pw.RichText(
          textAlign: align.resolvePdfTextAlign,
          softWrap: true,
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
          padding: pw.EdgeInsets.only(bottom: lineHeight.resolvePaddingByLineHeight()),
          child: pw.RichText(
            softWrap: true,
            overflow: pw.TextOverflow.span,
            text: pw.TextSpan(
              style: defaultTextStyle.copyWith(lineSpacing: lineHeight.resolveLineHeight()),
              children: currentSpans,
            ),
          ),
        ),
      );
      return;
    }
  }
}
