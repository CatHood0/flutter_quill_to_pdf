# 1.2.0

* Removed unnecessary code
* Writed more documentation about classes and functions
* [Fix] rename at MarkdownRules by bad name of file
* [Fix] bad list formatting. The list block function generator didn't detect the span styles into itself
* [Feat] added support for image links
* [Feat] added support for colors 
* [Feat] added support for blockquote
* [Feat] added support for codeblock
* [Feat] added support to render custom html using `renderCustomCallback` param from `convertDeltaToHtml` 

```dart
//it looks like
String convertDeltaToHtml(Delta delta, [ConverterOptions? options,String Function(DeltaInsertOp customOp, DeltaInsertOp? contextOp)? customRenderCallback]) {
  final QuillDeltaToHtmlConverter converterDeltaToHTML = QuillDeltaToHtmlConverter(
    delta.toJson(),
    options ?? HTMLConverterOptions.options(),
  );
  converterDeltaToHTML.renderCustomWith = customRenderCallback;
  return converterDeltaToHTML.convert();
}
```

* [Feat] added support for customize properties in blockquote and codeblock without create a custom widget

```dart
  ///If you need [customize] exactly how the [code block looks], then you use this [theme]
  final pw.TextStyle? codeBlockTextStyle;

  ///If you need just a different [font] to show your code blocks, use this font [(by default is pw.Font.courier())]
  final pw.Font? codeBlockFont;

  ///Customize the background color of the code block
  final PdfColor? codeBlockBackgroundColor;

  ///Customize the style of the num lines in code block
  final pw.TextStyle? codeBlockNumLinesTextStyle;

  ///Define the text style of the general blockquote. [This overrides any style detected like: line-height, size, font families, color]
  final pw.TextStyle? blockQuoteTextStyle;

  ///Define the left space between divider and text
  final double? blockQuotePaddingLeft;
  final double? blockQuotePaddingRight;

  ///Define the width of the divider
  final double? blockQuotethicknessDividerColor;

  ///Customize the background of the blockquote
  final PdfColor? blockQuoteBackgroundColor;

  ///Customize the left/right divider color to blockquotes
  final PdfColor? blockQuoteDividerColor;
```


# 1.1.4

* [Fix] README bad dependecy name

# 1.1.1

* [Feat] improved README 
* [Fix] bad unnecessary args remove 
* [Fix] bad names in some classes and functions
* [Fix] bad test (by now cannot be created a test)

## 1.1.0

* [Feat] added support to custom delta to html converter
* [Feat] added support to custom html to markdown converter
* [Feat] added new factory to create document and write file
* [Feat] improved params descriptions
* [Feat] added support to customize markdown rules
* [Feat] now we can add a custom theme to pdf document
* [Feat] now we can pass functions to when the create doc ends sucessfully or when throws and exception
* [Fix] removed lineHeight attribute since flutt_quill and html2md has Rule class and creates conflicts on imports
* README now has better documentation, to be more accurate on how  use this library

## 1.0.2

* [Fix] inconfortable name. PDFConvertersParam was changed to PDFPageFormat
* [Feat] improved README to make more easy read how works the package

## 1.0.1

* [Fix] minimal errors
* [Fix] issue where list (bullet, check, and ordered) takes a more space that it needs on top  

## 1.0.0

* First commit 
