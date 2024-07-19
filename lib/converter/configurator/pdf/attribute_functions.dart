import 'package:flutter_quill_delta_easy_parser/flutter_quill_delta_easy_parser.dart' show Line;
import 'package:pdf/widgets.dart' as pw;

///An interface that contains Inline functions for getting attributes from a [markdown]
mixin AttrInlineFunctions<I, TS> {
  Future<I> getLinkStyle(Line line, [TS? style]);
  Future<I> getRichTextInlineStyles(Line line, [TS? style]);
}

///An interface that contains Block functions for getting attributes from a [markdown]
mixin AttrBlockFunctions<B, TS> {
  Future<B?> getImageBlock(Line line);
  Future<B> getBlockQuote(List<pw.InlineSpan> spansToWrap, [TS? style]);
  Future<B> getCodeBlock(List<pw.InlineSpan> spansToWrap, [TS? style]);
  Future<B> getAlignedHeaderBlock(List<pw.InlineSpan> spansToWrap, int headerLevel, String align, int indentLevel,
      [TS? style]);
  Future<B> getAlignedParagraphBlock(List<pw.InlineSpan> spansToWrap, String align, int indentLevel, [TS? style]);
  Future<B> getListBlock(List<pw.InlineSpan> spansToWrap, String typeList, String align, int indentLevel, [TS? style]);
  Future<B> getHeaderBlock(List<pw.InlineSpan> spansToWrap, int headerLevel, int indentLevel, [TS? style]);
}

//just used by LaTeX compilation
mixin AttrInlineBlockFunctions<I, TS> {
  Future<I> getCodeBlock(List<pw.InlineSpan> spansToWrap, [TS? style]);
  Future<I> getRichTextInlineStyles(Line line, [TS? style]);
  Future<I> getLinkStyle(Line line, [TS? style]);
  Future<I> getBlockQuote(List<pw.InlineSpan> spansToWrap, [TS? style]);
  Future<I?> getImageBlock(Line line);
  Future<I> getAlignedHeaderBlock(List<pw.InlineSpan> spansToWrap, int headerLevel, String align, int indentLevel,
      [TS? style]);
  Future<I> getAlignedParagraphBlock(List<pw.InlineSpan> spansToWrap, String align, int indentLevel, [TS? style]);
  Future<I> getListBlock(List<pw.InlineSpan> spansToWrap, String typeList, String align, int indentLevel, [TS? style]);
  Future<I> getHeaderBlock(List<pw.InlineSpan> spansToWrap, int headerLevel, int indentLevel, [TS? style]);
}
