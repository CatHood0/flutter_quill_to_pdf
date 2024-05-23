///An interface that contains Inline functions for getting attributes from a [markdown]
mixin AttrInlineFunctions<I, TS> {
  Future<I> getInlineStyles(String line, [TS? style]);
  Future<I> getLinkStyle(String line, [TS? style]);
  Future<I> getDocLinksSpacingFontsStyle(String line, [TS? style]);
}

///An interface that contains Block functions for getting attributes from a [markdown]
mixin AttrBlockFunctions<B, TS> {
  Future<B?> imageBlock(String line);
  Future<List<B>> getAlignedBlockHeaderStyle(String line, [TS? style]);
  Future<List<B>> getAlignedBlockParagraphStyle(String line, [TS? style]);
  Future<B> getListBlockStyle(String line, bool isCheck, [TS? style]);
  Future<B> getBlockHeaderStyle(String line, [TS? style]);
}

//just used by LaTeX compilation
mixin AttrInlineBlockFunctions<I, TS> {
  Future<I> getInlineStyles(String line, [TS? style]);
  Future<I> getLinkStyle(String line, [TS? style]);
  Future<I> getDocLinksSpacingFontsStyle(String line, [TS? style]);
  Future<I?> imageBlock(String line);
  Future<List<I>> getAlignedBlockHeaderStyle(String line, [TS? style]);
  Future<List<I>> getAlignedBlockParagraphStyle(String line, [TS? style]);
  Future<I> getListBlockStyle(String line, bool isCheck, [TS? style]);
  Future<I> getBlockHeaderStyle(String line, [TS? style]);
}
