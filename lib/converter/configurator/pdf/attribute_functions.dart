///An interface that contains Inline functions for getting attributes from a [markdown]
mixin AttrInlineFunctions<I, TS> {
  Future<I> getInlineStyles(String line, [TS? style]);
  Future<I> getLinkStyle(String line, [TS? style]);
  Future<I> getRichTextInlineStyles(String line, [TS? style]);
}

///An interface that contains Block functions for getting attributes from a [markdown]
mixin AttrBlockFunctions<B, TS> {
  Future<B?> getImageBlock(String line);
  Future<List<B>> getAlignedHeaderBlock(String line, [TS? style]);
  Future<List<B>> getAlignedParagraphBlock(String line, [TS? style]);
  Future<List<B>> getBlockQuote(String line, [TS? style]);
  Future<List<B>> getCodeBlock(String line, [TS? style]);
  Future<B> getListBlock(String line, bool isCheck, [TS? style]);
  Future<B> getHeaderBlock(String line, [TS? style]);
}

//just used by LaTeX compilation
mixin AttrInlineBlockFunctions<I, TS> {
  Future<I> getInlineStyles(String line, [TS? style]);
  Future<I> getLinkStyle(String line, [TS? style]);
  Future<I> getRichTextInlineStyles(String line, [TS? style]);
  Future<I> getBlockQuote(String line, [TS? style]);
  Future<List<I>> getCodeBlock(String line, [TS? style]);
  Future<I?> getImageBlock(String line);
  Future<List<I>> getAlignedHeaderBlock(String line, [TS? style]);
  Future<List<I>> getAlignedParagraphBlock(String line, [TS? style]);
  Future<I> getListBlock(String line, bool isCheck, [TS? style]);
  Future<I> getHeaderBlock(String line, [TS? style]);
}
