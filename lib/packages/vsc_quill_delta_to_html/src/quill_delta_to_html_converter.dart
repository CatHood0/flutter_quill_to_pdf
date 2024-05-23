// ignore_for_file: always_specify_types

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:flutter_quill_to_pdf/packages/vsc_quill_delta_to_html/src/funcs_html.dart';

import '../vsc_quill_delta_to_html.dart';

class ConverterOptions {
  ConverterOptions({
    this.orderedListTag,
    this.bulletListTag,
    this.multiLineBlockquote,
    this.multiLineHeader,
    this.multiLineCodeblock,
    this.multiLineParagraph,
    this.multiLineCustomBlock,
    OpAttributeSanitizerOptions? sanitizerOptions,
    OpConverterOptions? converterOptions,
  }) {
    this.sanitizerOptions = sanitizerOptions ?? OpAttributeSanitizerOptions();
    this.converterOptions = converterOptions ?? OpConverterOptions();
    _initCommon();
  }

  ConverterOptions.forEmail() {
    sanitizerOptions = OpAttributeSanitizerOptions();
    converterOptions = OpConverterOptions(
        inlineStylesFlag: true,
        customCssStyles: (DeltaInsertOp op) {
          if (op.isImage()) {
            // Fit images within restricted parent width.
            return <String>['max-width: 100%', 'object-fit: contain'];
          }
          if (op.isBlockquote()) {
            return <String>['border-left: 4px solid #ccc', 'padding-left: 16px'];
          }
          return null;
        });
    _initCommon();
  }

  void _initCommon() {
    orderedListTag ??= 'ol';
    bulletListTag ??= 'ul';
    multiLineBlockquote ??= true;
    multiLineHeader ??= true;
    multiLineCodeblock ??= true;
    multiLineParagraph ??= true;
    multiLineCustomBlock ??= true;
  }

  String? orderedListTag;
  String? bulletListTag;
  bool? multiLineBlockquote;
  bool? multiLineHeader;
  bool? multiLineCodeblock;
  bool? multiLineParagraph;
  bool? multiLineCustomBlock;
  late OpAttributeSanitizerOptions sanitizerOptions;
  late OpConverterOptions converterOptions;
}

const String brTag = '<br/>';

/// Converts [Quill's Delta](https://quilljs.com/docs/delta/) format to HTML (insert ops only) with properly nested lists.
/// It has full support for Quill operations - including images, videos, formulas, tables, and mentions. Conversion
/// can be performed in vanilla Dart (i.e., server-side or CLI) or in Flutter.
///
/// This is a complete port of the popular [quill-delta-to-html](https://www.npmjs.com/package/quill-delta-to-html)
/// Typescript/Javascript package to Dart.
///
/// This converter can convert to HTML for a number of purposes, not the least of which is for generating
/// HTML-based emails. It makes a great pairing with [Flutter Quill](https://pub.dev/packages/flutter_quill).
///
/// Documentation can be found [here](https://github.com/VisualSystemsCorp/vsc_quill_delta_to_html).
class QuillDeltaToHtmlConverter {
  QuillDeltaToHtmlConverter(this._rawDeltaOps, [ConverterOptions? options]) {
    _options = options ?? ConverterOptions();
    _converterOptions = _options.converterOptions;
    _converterOptions.linkTarget ??= '_blank';
  }

  late ConverterOptions _options;
  final List<Map<String, dynamic>> _rawDeltaOps;
  late OpConverterOptions _converterOptions;

  // render callbacks
  String? Function(GroupType groupType, TDataGroup data)? _beforeRenderCallback;
  set beforeRender(String? Function(GroupType groupType, TDataGroup data)? callback) => _beforeRenderCallback = callback;

  String? Function(GroupType groupType, String htmlString)? _afterRenderCallback;
  set afterRender(String? Function(GroupType groupType, String htmlString)? callback) => _afterRenderCallback = callback;

  String Function(DeltaInsertOp customOp, DeltaInsertOp? contextOp)? _renderCustomWithCallback;
  set renderCustomWith(String Function(DeltaInsertOp customOp, DeltaInsertOp? contextOp)? callback) => _renderCustomWithCallback = callback;

  @visibleForTesting
  String getListTag(DeltaInsertOp op) {
    if (op.isOrderedList()) return _options.orderedListTag.toString();
    if (op.isBulletList()) return _options.bulletListTag.toString();
    if (op.isCheckedList()) return _options.bulletListTag.toString();
    if (op.isUncheckedList()) return _options.bulletListTag.toString();
    return '';
  }

  List<TDataGroup> getGroupedOps() {
    List<DeltaInsertOp> deltaOps = InsertOpsConverter.convert(_rawDeltaOps, _options.sanitizerOptions);

    List<TDataGroup> pairedOps = Grouper.pairOpsWithTheirBlock(deltaOps);

    List groupedSameStyleBlocks = Grouper.groupConsecutiveSameStyleBlocks(
      pairedOps,
      blockquotes: _options.multiLineBlockquote ?? false,
      header: _options.multiLineHeader ?? false,
      codeBlocks: _options.multiLineCodeblock ?? false,
      customBlocks: _options.multiLineCustomBlock ?? false,
    );

    List<TDataGroup> groupedOps = Grouper.reduceConsecutiveSameStyleBlocksToOne(groupedSameStyleBlocks);

    groupedOps = TableGrouper().group(groupedOps);
    return ListNester().nest(groupedOps);
  }

  /// Convert the Delta ops provided at construction to an HTML string.
  String convert() {
    final List<TDataGroup> groups = getGroupedOps();
    return groups.map((TDataGroup group) {
      if (group is ListGroup) {
        return _renderWithCallbacks(GroupType.list, group, () => _renderList(group));
      }
      if (group is TableGroup) {
        return _renderWithCallbacks(GroupType.table, group, () => _renderTable(group));
      }
      if (group is BlockGroup) {
        return _renderWithCallbacks(GroupType.block, group, () => renderBlock(group.op, group.ops));
      }
      if (group is BlotBlock) {
        return _renderCustom(group.op, null);
      }
      if (group is VideoItem) {
        return _renderWithCallbacks(GroupType.video, group, () {
          OpToHtmlConverter converter = OpToHtmlConverter(group.op, _converterOptions);
          return converter.getHtml();
        });
      }

      // InlineGroup
      return _renderWithCallbacks(GroupType.inlineGroup, group, () => renderInlines((group as InlineGroup).ops, true));
    }).join('');
  }

  _renderWithCallbacks(
    GroupType groupType,
    TDataGroup group,
    String Function() myRenderFn,
  ) {
    String html = _beforeRenderCallback?.call(groupType, group) ?? '';

    if (html.isEmpty) {
      html = myRenderFn();
    }

    html = _afterRenderCallback?.call(groupType, html) ?? html;

    return html;
  }

  String _renderList(ListGroup list) {
    final ListItem firstItem = list.items[0];
    return makeStartTag(getListTag(firstItem.item.op)) +
        list.items.map((ListItem li) => _renderListItem(li)).join('') +
        makeEndTag(getListTag(firstItem.item.op));
  }

  String _renderListItem(ListItem li) {
    //if (!isOuterMost) {
    li.item.op.attributes.indent = 0;
    //}
    final OpToHtmlConverter converter = OpToHtmlConverter(li.item.op, _converterOptions);
    final HtmlParts parts = converter.getHtmlParts();
    final String liElementsHtml = renderInlines(li.item.ops, false);
    return parts.openingTag + liElementsHtml + (li.innerList != null ? _renderList(li.innerList!) : '') + parts.closingTag;
  }

  String _renderTable(TableGroup table) {
    return makeStartTag('table') +
        makeStartTag('tbody') +
        table.rows.map((TableRow row) => _renderTableRow(row)).join('') +
        makeEndTag('tbody') +
        makeEndTag('table');
  }

  String _renderTableRow(TableRow row) {
    return makeStartTag('tr') + row.cells.map((TableCell cell) => _renderTableCell(cell)).join('') + makeEndTag('tr');
  }

  String _renderTableCell(TableCell cell) {
    final OpToHtmlConverter converter = OpToHtmlConverter(cell.item.op, _converterOptions);
    final HtmlParts parts = converter.getHtmlParts();
    final String cellElementsHtml = renderInlines(cell.item.ops, false);
    return makeStartTag('td', <TagKeyValue>[
          TagKeyValue(
            key: 'data-row',
            value: cell.item.op.attributes.table,
          ),
        ]) +
        parts.openingTag +
        cellElementsHtml +
        parts.closingTag +
        makeEndTag('td');
  }

  @visibleForTesting
  String renderBlock(DeltaInsertOp bop, List<DeltaInsertOp> ops) {
    final OpToHtmlConverter converter = OpToHtmlConverter(bop, _converterOptions);
    final HtmlParts htmlParts = converter.getHtmlParts();

    if (bop.isCodeBlock()) {
      return htmlParts.openingTag +
          encodeHtml(ops.map((DeltaInsertOp iop) => iop.isCustomEmbed() ? _renderCustom(iop, bop) : iop.insert.value).join('')) +
          htmlParts.closingTag;
    }

    final String inlines = ops.map((DeltaInsertOp op) => _renderInline(op, bop)).join('');
    return htmlParts.openingTag + (inlines.isEmpty ? brTag : inlines) + htmlParts.closingTag;
  }

  @visibleForTesting
  String renderInlines(List<DeltaInsertOp> ops, [bool isInlineGroup = true]) {
    final int opsLen = ops.length - 1;
    final String html = ops.mapIndexed((int i, DeltaInsertOp op) {
      if (i > 0 && i == opsLen && op.isJustNewline()) {
        return '';
      }
      return _renderInline(op, null);
    }).join('');
    if (!isInlineGroup) {
      return html;
    }

    final String startParaTag = makeStartTag(_converterOptions.paragraphTag);
    final String endParaTag = makeEndTag(_converterOptions.paragraphTag);
    if (html == brTag || _options.multiLineParagraph == true) {
      return startParaTag + html + endParaTag;
    }

    return startParaTag + html.split(brTag).map((String v) => v.isEmpty ? brTag : v).join(endParaTag + startParaTag) + endParaTag;
  }

  String _renderInline(DeltaInsertOp op, DeltaInsertOp? contextOp) {
    if (op.isCustomEmbed()) {
      return _renderCustom(op, contextOp);
    }

    final OpToHtmlConverter converter = OpToHtmlConverter(op, _converterOptions);
    return converter.getHtml().replaceAll('\n', brTag);
  }

  String _renderCustom(DeltaInsertOp op, DeltaInsertOp? contextOp) {
    return _renderCustomWithCallback?.call(op, contextOp) ?? '';
  }
}
