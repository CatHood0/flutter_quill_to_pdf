import 'dart:async';
import 'dart:collection';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_quill_delta_easy_parser/flutter_quill_delta_easy_parser.dart';
import 'package:flutter_quill_to_pdf/core/constant/constants.dart';
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart';
import 'package:flutter_quill_to_pdf/internals/universal_merger.dart';
import 'package:meta/meta.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

///A Manager that contains all operations for PDF services
class PdfService extends PdfConfigurator<Delta, pw.Document> {
  final DocumentParser _parser = DocumentParser(mergerBuilder: UniversalMergerBuilder.instance());
  late final List<pw.Font> _fonts;
  //page configs
  late final double _marginLeft;
  late final double _marginBottom;
  late final double _marginTop;
  late final double _marginRight;
  late final double _width;
  late final double _height;
  final List<pw.Widget> contentPerPage = <pw.Widget>[];
  @experimental
  final pw.Page Function(List<pw.Widget> children, pw.ThemeData theme, PdfPageFormat pageFormat)? pageBuilder;

  PdfService({
    required PDFPageFormat pageFormat,
    required List<pw.Font> fonts,
    this.pageBuilder,
    super.directionality,
    super.enableCodeBlockHighlighting,
    super.isLightCodeBlockTheme,
    super.customCodeHighlightTheme,
    super.isWeb,
    super.customHeadingSizes,
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
    super.inlineCodeStyle,
    super.onDetectVideoBlock,
    super.blockQuotethicknessDividerColor,
    super.onDetectBlockquote,
    super.onDetectCodeBlock,
    super.onDetectAlignedParagraph,
    super.onDetectCommonText,
    super.onDetectHeaderBlock,
    super.onDetectImageBlock,
    super.onDetectErrorInImage,
    super.onDetectInlineRichTextStyles,
    super.onDetectLink,
    super.onDetectList,
    super.backM,
    super.frontM,
  }) {
    _fonts = fonts;
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
            fontSize: defaultFontSize.toDouble(),
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
    _marginLeft = pageFormat.marginLeft;
    _marginBottom = pageFormat.marginBottom;
    _marginTop = pageFormat.marginTop;
    _marginRight = pageFormat.marginRight;
    _width = pageFormat.width;
    _height = pageFormat.height;
    pageWidth = pageFormat.width;
    pageHeight = pageFormat.height;
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
    final PdfPageFormat pdfPageFormat = PdfPageFormat(
      _width,
      _height,
      marginBottom: _marginBottom,
      marginLeft: _marginLeft,
      marginRight: _marginRight,
      marginTop: _marginTop,
    );
    // front matter
    final List<List<pw.Widget>> docWidgets = await generatePages(
      documents: <Delta>[frontM ?? Delta(), document, backM ?? Delta()],
    );
    for (int i = 0; i < docWidgets.length; i++) {
      final List<pw.Widget> widgets = docWidgets.elementAt(i);
      final pw.Page? pageBuilded = pageBuilder?.call(widgets, defaultTheme, pdfPageFormat);
      pdf.addPage(
        pageBuilded ??
            pw.MultiPage(
              theme: defaultTheme,
              pageFormat: pdfPageFormat,
              maxPages: 99999999,
              build: (pw.Context context) => <pw.Widget>[...widgets],
            ),
      );
    }
    return pdf;
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
        final Document? document = _parser.parseDelta(delta: doc);
        if (document == null || document.paragraphs.isEmpty) continue;
        docMap.add(List<pw.Widget>.from(await blockGenerators(document)));
      }
      i++;
    }
    return List<List<pw.Widget>>.from(docMap);
  }

  @override
  Future<pw.Widget> generateWidget({
    double? maxWidth,
    double? maxHeight,
  }) async {
    final Document? document = _parser.parseDelta(delta: this.document);
    if (document == null) {
      throw StateError('The Delta passed is not valid to be parsed');
    }
    final List<pw.Widget> widgets = await blockGenerators(document);
    final pw.Widget content = pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: widgets,
    );
    pw.Widget widget = pw.Directionality(
      textDirection: directionality,
      child: pw.Container(
        width: maxWidth,
        height: maxHeight,
        child: content,
      ),
    );
    return widget;
  }

  @override
  Future<List<pw.Widget>> blockGenerators(Document document) async {
    final List<Paragraph> paragraphs = <Paragraph>[...document.paragraphs];
    for (int z = 0; z < paragraphs.length; z++) {
      final Paragraph paragraph = paragraphs.elementAt(z);
      final List<pw.Widget> contents = <pw.Widget>[];
      final Map<String, dynamic> blockAttributes = paragraph.blockAttributes ?? <String, dynamic>{};
      final bool added = _applyCustomBlocks(paragraph: paragraph);
      if (added) continue;
      if (paragraph.isEmbed) {
        _defaultEmbedLineBuilder(paragraph: paragraph);
        continue;
      }
      final bool isHeader = blockAttributes.containsKey('header');
      final bool isCodeBlock = blockAttributes.containsKey('code-block');
      final bool isBlockquote = blockAttributes.containsKey('blockquote');
      for (int k = 0; k < paragraph.lines.length; k++) {
        final Line line = paragraph.lines.elementAt(k);
        final bool added = _applyCustomBlocks(paragraph: paragraph, line: line);
        if (added) continue;
        _updateLineNumbers(blockAttributes);
        final (pw.TextStyle style, bool addFontSize) = _getInlineTextStyle(blockAttributes);
        final List<pw.InlineSpan> spans = <pw.InlineSpan>[];
        for (int j = 0; j < line.length; j++) {
          final TextFragment fragment = line.elementAt(j);
          if (fragment.attributes != null || isHeader || isBlockquote || isCodeBlock) {
            if (fragment.attributes?['link'] != null && onDetectLink != null) {
              spans.add(onDetectLink!.call(
                fragment,
                blockAttributes,
                <String, dynamic>{
                  'currentStyle': style,
                  'shouldApplyFontSizeAttributeFromLine': true,
                },
              ));
            }
            spans.add(
              onDetectInlineRichTextStyles?.call(
                    fragment,
                    paragraph.blockAttributes,
                    <String, dynamic>{
                      'currentStyle': style,
                    },
                  ) ??
                  await getRichTextInlineStyles(
                    line: fragment,
                    isCodeBlock: isCodeBlock,
                    isBlockquote: isBlockquote,
                    headerLevel: blockAttributes['header'] as int?,
                    style: style,
                    returnContentIfNeedIt: false,
                    addFontSize: addFontSize,
                  ),
            );
            continue;
          }
          spans.add(
            onDetectCommonText?.call(
                  fragment,
                  paragraph.blockAttributes,
                  <String, dynamic>{
                    'currentStyle': style,
                  },
                ) ??
                pw.TextSpan(
                  text: fragment.data as String,
                  style: style,
                ),
          );
        }
        if (paragraph.isBlock) {
          bool willNeedContinue = false;
          if (paragraph.blockAttributes!.containsKey('code-block')) {
            contents.add(
              codeBlockLineBuilder(
                spans: spans,
                codeBlockStyle: style,
              ),
            );
            willNeedContinue = true;
          }
          if (paragraph.blockAttributes!.containsKey('blockquote')) {
            contents.add(
              lineBuilder(
                spans: spans,
                align: blockAttributes['align'] as String? ?? 'left',
                textDirection: blockAttributes['direction'] == 'rtl' ? pw.TextDirection.rtl : null,
              ),
            );
            willNeedContinue = true;
          }
          final bool isLast = k + 1 >= paragraph.length;
          if (willNeedContinue && !isLast) {
            continue;
          }
          await _defaultLineBuilderForBlocks(
            line: line,
            spans: spans,
            widgets: contents,
            blockAttributes: blockAttributes,
          );
          continue;
        }
        await _defaultLineBuilderForInlines(
          contentPerPage,
          <pw.InlineSpan>[...spans],
        );
      }
    }
    return contentPerPage;
  }

  Future<void> _defaultLineBuilderForInlines(
    List<pw.Widget> contentPerPage,
    List<pw.InlineSpan> inlineSpansToMerge,
  ) async {
    if (inlineSpansToMerge.isEmpty) return;
    final double spacing = (inlineSpansToMerge.firstOrNull?.style?.lineSpacing ?? 1.0);
    contentPerPage.add(
      pw.Directionality(
        textDirection: directionality,
        child: pw.Padding(
          padding: pw.EdgeInsetsDirectional.only(
            bottom: spacing.resolvePaddingByLineHeight(),
          ),
          child: pw.RichText(
            softWrap: true,
            overflow: pw.TextOverflow.span,
            textDirection: directionality,
            text: pw.TextSpan(
              children: inlineSpansToMerge,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _defaultEmbedLineBuilder({
    required Paragraph paragraph,
  }) async {
    final Map<String, dynamic> blockAttributes = paragraph.blockAttributes ?? <String, dynamic>{};
    _updateLineNumbers(blockAttributes);
    for (Line line in paragraph.lines) {
      for (TextFragment fragment in line.fragments) {
        if ((fragment.data as Map<String, dynamic>)['video'] != null) {
          contentPerPage.add(
            pw.RichText(
              textDirection: blockAttributes['direction'] ?? directionality,
              softWrap: true,
              overflow: pw.TextOverflow.span,
              text: pw.TextSpan(
                text: (fragment.data as Map<String, dynamic>)['video']?.toString(),
              ),
            ),
          );
        }
        //avoid any another embed that is not a image
        if ((fragment.data as Map<String, dynamic>)['image'] != null) {
          contentPerPage.add(
            await getImageBlock.call(
              fragment,
              (blockAttributes['align'] as String?)?.resolvePdfBlockAlign,
              blockAttributes['direction'],
            ),
          );
        }
      }
    }
  }

  Future<void> _defaultLineBuilderForBlocks({
    required Line line,
    required List<pw.InlineSpan> spans,
    required List<pw.Widget>? widgets,
    Map<String, dynamic> blockAttributes = const <String, dynamic>{},
  }) async {
    if (blockAttributes.isEmpty) {
      _defaultLineBuilderForInlines(contentPerPage, spans);
      return;
    }
    final int? header = blockAttributes['header'];
    final String? direction = blockAttributes['direction'];
    final String? align = blockAttributes['align'];
    final String? listType = blockAttributes['list'];
    final int? indent = blockAttributes['indent'];
    final double? lineHeight = blockAttributes['line-height'];
    final bool codeblock = blockAttributes['code-block'] ?? false;
    final bool blockquote = blockAttributes['blockquote'] ?? false;
    int indentLevel = indent ?? 0;
    if (indentLevel > 0) {
      indentLevel++;
    }
    final pw.TextDirection textDirectionToUse = direction == 'rtl' ? pw.TextDirection.rtl : directionality;
    //TODO: change the conditions to only apply exclusive blocks
    // and then apply correctly non exclusive attributes
    if (header != null) {
      contentPerPage.add(pw.SizedBox(height: 5));
      if (align != null) {
        final pw.Widget alignedBlock = await getAlignedHeaderBlock(
          child: lineBuilder(spans: spans, align: align, textDirection: textDirectionToUse),
          headerLevel: header,
          align: align,
          indentLevel: indentLevel,
          style: null,
          textDirection: textDirectionToUse,
        );
        contentPerPage.add(alignedBlock);
        return;
      }
      final pw.Widget headerBlock = await getHeaderBlock(
        child: lineBuilder(spans: spans, align: align ?? 'left', textDirection: textDirectionToUse),
        headerLevel: header,
        indentLevel: indentLevel,
        style: null,
        textDirection: textDirectionToUse,
      );
      contentPerPage.add(headerBlock);
      return;
    } else if (codeblock) {
      final pw.Widget codeBlock = await getCodeBlock(
        widgets!,
        null,
        textDirectionToUse,
      );
      contentPerPage.add(codeBlock);
      return;
    } else if (blockquote) {
      final pw.Widget blockquoteBlock = await getBlockQuote(
        widgets!,
        null,
        align,
        indentLevel,
        textDirectionToUse,
      );
      contentPerPage.add(blockquoteBlock);
      return;
    } else if (listType != null) {
      final pw.Widget listBlock = await getListBlock(
        spans,
        listType,
        align ?? 'left',
        indentLevel,
        null,
        textDirectionToUse,
      );
      contentPerPage.add(listBlock);
      return;
    }
    if (align != null || indent != null) {
      final pw.Widget alignedParagraphBlock = await getAlignedParagraphBlock(
        child: lineBuilder(spans: spans, align: align ?? 'left', textDirection: textDirectionToUse),
        align: align ?? 'left',
        indentLevel: indentLevel,
        firstSpanStyle: spans.firstOrNull?.style,
        style: null,
        textDirection: textDirectionToUse,
      );
      contentPerPage.add(alignedParagraphBlock);
      return;
    }
    if (lineHeight != null) {
      contentPerPage.add(
        pw.Directionality(
          textDirection: textDirectionToUse,
          child: pw.Padding(
            padding: pw.EdgeInsetsDirectional.only(
              bottom: lineHeight.resolveLineHeight().resolvePaddingByLineHeight(),
            ),
            child: pw.RichText(
              softWrap: true,
              overflow: pw.TextOverflow.span,
              textDirection: textDirectionToUse,
              textAlign: textDirectionToUse == pw.TextDirection.rtl
                  ? 'left'.resolvePdfTextAlign.reversed
                  : 'left'.resolvePdfTextAlign,
              text: pw.TextSpan(
                style: defaultTheme.defaultTextStyle.copyWith(
                  lineSpacing: lineHeight.resolveLineHeight(),
                ),
                children: spans,
              ),
            ),
          ),
        ),
      );
      return;
    }
  }

  (pw.TextStyle, bool) _getInlineTextStyle(Map<String, dynamic>? blockAttributes) {
    bool addFontSize = true;
    final double? lineHeight = blockAttributes?['line-height'];
    if (blockAttributes?['header'] != null) {
      final int headerLevel = blockAttributes!['header'];
      final double currentFontSize =
          headerLevel.resolveHeaderLevel(headingSizes: customHeadingSizes ?? Constant.kDefaultHeadingSizes);
      pw.TextStyle style = defaultTheme.defaultTextStyle.copyWith(fontSize: currentFontSize);
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
      pw.TextStyle style = defaultCodeBlockStyle.merge(defaultTheme.defaultTextStyle);
      style = style.copyWith(lineSpacing: lineHeight?.resolveLineHeight());
      return (style, addFontSize);
    } else if (blockAttributes?['blockquote'] != null) {
      final pw.TextStyle defaultStyle = defaultTheme.defaultTextStyle.copyWith(
        color: PdfColor.fromHex("#808080"),
        lineSpacing: 6.5,
      );
      final pw.TextStyle blockquoteStyle = defaultStyle;
      pw.TextStyle style = blockquoteStyle;
      style = style.copyWith(lineSpacing: lineHeight?.resolveLineHeight());
      return (style, addFontSize);
    } else {
      final pw.TextStyle style =
          defaultTheme.defaultTextStyle.copyWith(lineSpacing: lineHeight?.resolveLineHeight());
      return (style, addFontSize);
    }
  }

  void _updateLineNumbers(Map<String, dynamic>? blockAttributes) {
    final int? indent = blockAttributes?['indent'];
    if (blockAttributes?['list'] != null) {
      if (indent != null) {
        // validate if the last indent is different that the current one
        //
        // if it is, then must reload the specific index counter to avoid generate
        // a bad index for the current item
        final bool itsSameIndentButDifferentListType =
            lastListIndent == indent && lastListType != blockAttributes?['list'];
        if (itsSameIndentButDifferentListType) {
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
        if (lastListType != blockAttributes?['list']) {
          numberList = 1;
        }
      }
      lastListType = blockAttributes?['list'];
    } else {
      lastListType = null;
      lastListIndent = 0;
      numberList = 0;
      numberIndent1List = 0;
      numberIndent2List = 0;
      numberIndent3List = 0;
      numberIndent4List = 0;
      numberIndent5List = 0;
    }
    final bool? codeBlock = blockAttributes?['code-block'] as bool?;
    codeBlock != null && codeBlock ? numCodeLine++ : numCodeLine = 0;
  }

  bool _applyCustomBlocks({
    required Paragraph paragraph,
    Line? line,
  }) {
    final Map<String, dynamic> blockAttributes = paragraph.blockAttributes ?? <String, dynamic>{};
    if (line == null) {
      if (paragraph.isEmbed && (onDetectImageBlock != null || onDetectVideoBlock != null)) {
        bool shouldEndAsAdded = false;
        _updateLineNumbers(blockAttributes);
        for (Line line in paragraph.lines) {
          for (TextFragment fragment in line.fragments) {
            if (onDetectVideoBlock != null && (fragment.data as Map<String, dynamic>)['video'] != null) {
              shouldEndAsAdded = true;
              contentPerPage.add(onDetectVideoBlock!.call(fragment, paragraph.blockAttributes));
            }
            //avoid any another embed that is not a image
            if (onDetectImageBlock != null && (fragment.data as Map<String, dynamic>)['image'] != null) {
              shouldEndAsAdded = true;
              contentPerPage.add(
                onDetectImageBlock!.call(
                  fragment,
                  paragraph.blockAttributes,
                ),
              );
            }
          }
        }
        if (shouldEndAsAdded) return true;
      }
      if (super.customBuilders.isNotEmpty) {
        for (CustomWidget customBuilder in super.customBuilders) {
          if (customBuilder.predicate(paragraph)) {
            contentPerPage.add(
              customBuilder.widgetCallback(
                paragraph,
                paragraph.blockAttributes,
              ),
            );
            return true;
          }
        }
      }
      if (paragraph.isBlock &&
          paragraph.blockAttributes!.containsKey('blockquote') &&
          onDetectBlockquote != null) {
        final pw.Widget blockquoteBlock = onDetectBlockquote!.call(
          paragraph,
          blockAttributes,
        );
        contentPerPage.add(blockquoteBlock);
        return true;
      }

      if (paragraph.isBlock && paragraph.blockAttributes!.containsKey('code-block') && onDetectCodeBlock != null) {
        _updateLineNumbers(blockAttributes);
        final pw.Widget codeBlock = onDetectCodeBlock!.call(
          paragraph,
          blockAttributes,
        );
        contentPerPage.add(codeBlock);
        return true;
      }

      if (paragraph.isBlock && paragraph.blockAttributes!.containsKey('list') && onDetectList != null) {
        _updateLineNumbers(blockAttributes);
        final pw.Widget codeBlock = onDetectList!.call(
          paragraph,
          blockAttributes,
        );
        contentPerPage.add(codeBlock);
        return true;
      }
    }
    if (line != null) {
      if (paragraph.isBlock &&
          !paragraph.blockAttributes!.containsKey('align') &&
          paragraph.blockAttributes!.containsKey('header') &&
          onDetectHeaderBlock != null) {
        final pw.Widget customBlock = onDetectHeaderBlock!.call(line, blockAttributes);
        contentPerPage.add(customBlock);
        return true;
      }
      if (paragraph.isBlock &&
          paragraph.blockAttributes!.containsKey('align') &&
          !paragraph.blockAttributes!.containsKey('header') &&
          onDetectAlignedParagraph != null) {
        final pw.Widget alignedParagraphBlock = onDetectAlignedParagraph!.call(
          line,
          blockAttributes,
        );
        contentPerPage.add(alignedParagraphBlock);
        return true;
      }
    }

    return false;
  }
}
