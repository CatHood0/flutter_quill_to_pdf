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
    final List<pw.Widget> contentPerPage = <pw.Widget>[];
    final List<Paragraph> paragraphs = <Paragraph>[...document.paragraphs];
    for (int i = 0; i < paragraphs.length; i++) {
      final Paragraph paragraph = paragraphs.elementAt(i);
      final Map<String, dynamic>? blockAttributes = paragraph.blockAttributes;
      final List<pw.InlineSpan> spansToWrap = <pw.InlineSpan>[];
      for (int l = 0; l < paragraph.lines.length; l++) {
        final Line line = paragraph.lines.elementAt(l);
        //verify if the data line is a embed
        if (paragraph.type == ParagraphType.embed || line.data is Map) {
          final bool isImage = (line.data as Map<String, dynamic>)['image'] != null;
          if (!isImage) {
            continue;
          }
          contentPerPage.add(await getImageBlock.call(line));
        } else if (paragraph.type == ParagraphType.block || blockAttributes != null) {
          if ((line.data as Map<String, dynamic>)['image'] != null) {
            if (spansToWrap.isNotEmpty && blockAttributes != null) {
              // if found a paragraph with a embed between the lines, then must separate in two different lists
              // and apply first the before content with the block attributes and after clean those before lines to avoid
              // duplicate content
              _applyBlockAttributes(spansToWrap, blockAttributes, contentPerPage);
              spansToWrap.clear();
            }
            contentPerPage.add(await getImageBlock.call(line));
            continue;
          }
          verifyBlock(blockAttributes);
          pw.TextStyle? style = null;
          final double? lineHeight = blockAttributes?['line-height'];
          if (blockAttributes?['header'] != null) {
            final int headerLevel = blockAttributes!['header'];
            final double currentFontSize = headerLevel.resolveHeaderLevel();
            style = defaultTextStyle.copyWith(fontSize: currentFontSize);
            style = style.copyWith(lineSpacing: lineHeight?.resolveLineHeight());
          } else if (blockAttributes?['code-block']) {
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
            spansToWrap.addAll(await getLinkStyle.call(line, style));
            continue;
          }
          spansToWrap.addAll(await getRichTextInlineStyles.call(line, style));
        } else if (paragraph.type == ParagraphType.inline || blockAttributes == null) {
          if (line.attributes != null) {
            if (onDetectInlineRichTextStyles != null) {
              contentPerPage.add(await onDetectInlineRichTextStyles!.call(line));
              continue;
            }

            /// founds lines like <span style="wiki-doc: id">(.*?)<\/span> or <span style="line-height: 2.0")">(.*?)<\/span> or <span\s?style="font-size: 12">(.*?)<\/span>)
            /// and those three ones together are matched
            final List<pw.InlineSpan> spans = await getRichTextInlineStyles.call(line, defaultTextStyle);
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
          if (onDetectCommonText != null) {
            contentPerPage.add(await onDetectCommonText!.call(line, blockAttributes));
            continue;
          }
          contentPerPage.add(
            pw.Padding(
              padding: const pw.EdgeInsets.symmetric(vertical: 1.0),
              child: pw.RichText(
                softWrap: true,
                overflow: pw.TextOverflow.span,
                text: pw.TextSpan(text: line.data as String, style: defaultTextStyle),
              ),
            ),
          );
        }
      }
      //then put the block styles
      if (blockAttributes != null) {
        _applyBlockAttributes(
          spansToWrap,
          blockAttributes,
          contentPerPage,
        );
      }
    }
    return contentPerPage;
  }

  void verifyBlock(Map<String, dynamic>? blockAttributes) {
    if (blockAttributes?['list'] != null) {
      numberList++;
      lastWasList = true;
    } else {
      numberList = 0;
      lastWasList = false;
    }
    if (blockAttributes?['code-block'] != null) {
      numCodeLine++;
    } else {
      numCodeLine = 0;
    }
  }

  void _applyBlockAttributes(
      List<pw.InlineSpan> currentSpans, Map<String, dynamic> blockAttributes, List<pw.Widget> contentPerPage) async {
    final int? header = int.tryParse(blockAttributes['header'] ?? 'null');
    final String? align = blockAttributes['align'];
    final String? listType = blockAttributes['list'];
    final int? indent = blockAttributes['indent'];
    final bool? codeblock = blockAttributes['code-block'];
    final bool? blockquote = blockAttributes['blockquote'];
    final int indentLevel = indent ?? 0;
    if (header != null) {
      if (align != null) {
        contentPerPage.add(await getAlignedHeaderBlock(currentSpans, header, align, indentLevel));
        return;
      }
      contentPerPage.add(await getHeaderBlock(currentSpans, header, indentLevel));
      return;
    }
    if (codeblock != null) {
      contentPerPage.add(await getCodeBlock(currentSpans));
    }
    if (blockquote != null) {
      contentPerPage.add(await getBlockQuote(currentSpans));
    }
    if (listType != null) {
      contentPerPage.add(await getListBlock(currentSpans, listType, align ?? 'left', indentLevel));
      return;
    }
  }
}
