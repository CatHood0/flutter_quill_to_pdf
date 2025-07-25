# 2.3.9

* Feat: support for apply striketrough style on checked elements and customize them by @CatHood0 in [#37](https://github.com/CatHood0/flutter_quill_to_pdf/pull/37)

# 2.3.8

* Chore: moved `http` package to the example app.
* Chore: updated dependencies to fix parsing issues.
* Chore(documentation): removed unnecessary step in `CONTRIBUTING` guide.

# 2.3.7

* Fix: themeData on PDF creation by @Faizan-26 in https://github.com/CatHood0/flutter_quill_to_pdf/pull/28

## New Contributors
* @Faizan-26 made their first contribution in https://github.com/CatHood0/flutter_quill_to_pdf/pull/28

# 2.3.6

* Fix: `pageBuilder` is not being passed correctly to `PdfService` class by @CatHood0 in https://github.com/CatHood0/flutter_quill_to_pdf/pull/24
* Fix: `zapfDingBats` is not being added to the fonts by @CatHood0 in https://github.com/CatHood0/flutter_quill_to_pdf/pull/26
* Feat: support for customize custom icons font by @CatHood0 in https://github.com/CatHood0/flutter_quill_to_pdf/pull/25

# 2.3.5

* Chore: support for header styles from `ThemeData` by @CatHood0 in https://github.com/CatHood0/flutter_quill_to_pdf/pull/23
* Chore: improved `kDefaultHeadingSizes` in `Constant` class.
* Chore: removed `IMAGE_LOCAL_STORAGE_PATH_PATTERN`.

# 2.3.4

* Fix: wrong method declaration of the `onDetectBlockquote` builder in example code of `PDFConverter`.
* Fix: links are not showing underline decoration as expected.
* Fix: `ThemeData` is not being passed to the `PdfDocument`.
* Chore: moved value that is passed to `maxPages` in `PdfService` to be part of `Constant` class, it now is called `kDefaultMaxPages`.
* Feat: added `DocumentOptions` to add some extra information to the pdf using `documentOptions` in `PDFConverter`. 

# 2.3.3

* Fix: links are not working as expected when try to interact with them [issue: #18](https://github.com/CatHood0/flutter_quill_to_pdf/issues/18)

# 2.3.2

* Fix: when a `Line` contains alignment and header attributes, `onDetectHeaderBlock` always will be ignored (even if it's passed)
* Chore: added some extra arguments for all methods that build custom pdf widgets in `PdfService`.

# 2.3.1

* Fix: url of the images in README

# 2.3.0

* Fix: issues related with detecting storage images.
* Fix: issues related with `ThemeData` from PDF not being applied to the pdf document.
* Fix: issues related with the font size of the `ThemeData` not being applied as expected.
* Fix: wrong default code-block widget.
* Fix: wrong default list widget.
* Fix: issue where the default leading of ordered lists is not being computed correctly.
* Fix: wrong behavior if `textDirection` is passed in `PDFConverter`.
* Fix: bad rendering of content elements by not await for `_applyBlockAttributes()` in `PDFService` class. 
* Fix(partially): bad rendering of content elements when directionality is RTL. 
* Chore(breaking changes): reorganized project structure.
* Chore: deprecated `createDocumentFile` since we cannot manage the errors with file permissions. 
* Chore: deprecated `blockquotePaddingLeft` and `blockquotePaddingRight` and replaced with `blockquotePadding`. 
* Chore: deprecated `blockquoteDividerColor` replaced with `blockquoteBoxDecoration`. 
* Chore(breaking changes): renamed `blockQuotethicknessDividerColor` to `blockquotethicknessDividerColor`. 
* Chore(breaking changes): renamed `blockQuoteBackgroundColor` to `blockquoteBackgroundColor`. 
* Chore(breaking changes): renamed `blockQuoteTextStyle` to `blockquoteTextStyle`. 
* Chore(breaking changes): renamed `IMAGE_FROM_URL_PATTERN` to `kDefaultImageUrlDetector` in `Constant` class. 
* Chore: renamed `_applyBlockAttributes()` to `_defaultLineBuilderForBlocks()` in `PDFService` class. 
* Chore: renamed `_applyInlineParagraph()` to `_defaultLineBuilderForInlines()` in `PDFService` class. 
* Chore: deprecated `fixCommonErrorInsertsInRawDelta` and `isTotallyEmpty` methods since them are not longer used into the project.
* Chore: moved embed implementation to `_defaultEmbedLineBuilder()` in `PDFService` class. 
* Chore: created `_applyCustomBlocks()` to add all the necessary logic for add custom widgets from the custom callbacks in `PDFService` class. 
* Chore(breaking changes): renamed `md_extension` file to `header_level_extension` in extensions.
* Chore(breaking changes): renamed `MdHeaderLevelExtension` to `HeaderLevelResolverExtension` in extensions.
* Chore(doc): added customization documention (only partially). 
* Chore(breaking changes): added `extraArgs` param to all `PDFWidgetBuilder`.
* Chore: deprecated `IMAGE_LOCAL_STORAGE_PATH_PATTERN` since only works for android devices. 
* Chore: deprecated `DeltaAttributesOptions`, `overrideAttributesPassedByUser`, `deltaOptionalAttr` and `shouldProcessDeltas` in `PDFConverter`, since its implementation is not needed for the current target of the package. 
* Feat: added `isFromLocalStorage` method to detect is the input passed is a storage path. 
* Feat: added `onDetectImageUrl` to allow us create our custom implementation for get bytes from a external url. 
* Feat: added `imageConstraints` to create a default width and height for images when them has not that attributes specified. 
* Feat: added support for custom code-block highlighting theme using `customCodeHighlightTheme`. Check about [highlight_utils](https://github.com/CatHood0/flutter_quill_to_pdf/blob/master/lib/src/core/highlight_utils/hightlight_themes.dart). 
* Feat: added support for build error images using `onDetectErrorInImage`. 
* Feat: added support for build video widgets `onDetectVideoBlock`. 
* Feat: added support for build a custom `TextStyle` for inline-code fragments using `inlineCodeStyle`. 
* Feat: added support for build custom leading widgets for lists using `listLeadingBuilder`. 
* Feat: added support for code-block highlighting using `enableCodeBlockHighlighting` and `isLightMode`. 
* Feat: added support for custom heading sizes using `customHeadingSizes`. 
* Feat: added support for switch between the different versions of the default list blocks using `listTypeWidget`. 

# 2.2.9

* Fix: replace bullet unicode text to bullet point widget by @ToddZeil in https://github.com/CatHood0/flutter_quill_to_pdf/pull/15

## New Contributors

* @ToddZeil made their first contribution in https://github.com/CatHood0/flutter_quill_to_pdf/pull/15

# 2.2.8

* Fix: rendering images in web and file generating (thanks to **johannesvedder** for his contributation).
* Feat: support for create custom pages
* Chore: added doc comment for `generateWidget` method


# 2.2.7

* Chore: deprecated all `onRequestFont` before `2.2.7` and replaced them with `onRequestFontFamily`

# 2.2.6

* Fix: `IMAGE_LOCAL_STORAGE_PATH_PATTERN` was improved to detect more cases

# 2.2.5

* Fix: Color bugs and list block with its leading sizes calculation by @Paul-creator in https://github.com/CatHood0/flutter_quill_to_pdf/pull/12
* Feat: Support for base64 encoded images
* Feat: added directionality support by @CatHood0 in https://github.com/CatHood0/flutter_quill_to_pdf/pull/13

**Full Changelog**: https://github.com/CatHood0/flutter_quill_to_pdf/compare/V-2.2.4...V-2.2.5

# 2.2.4

* Chore: removed deprecated instances
* Chore: removed outdated comments
* Feat: support for generate widgets instead whole pdf document - giving you full control of the PDF by @Paul-creator in https://github.com/CatHood0/flutter_quill_to_pdf/pull/11

## New Contributors
* @Paul-creator made their first contribution in https://github.com/CatHood0/flutter_quill_to_pdf/pull/11

**Full Changelog**: https://github.com/CatHood0/flutter_quill_to_pdf/compare/V-2.2.3...V-2.2.4

# 2.2.3

* Fix: `List` block doesn't span to the next page if needed
* Fix: `Image` block doesn't appears with any `Alignment`

# 2.2.2

* Fix: duplicate content
* Fix: Paragraph with images are ignored

# 2.2.1

* Fix: if there are images together a `Paragraph` these will be displayed badly on the `PDF`

# 2.2.0

* Feat: Support for multilevel `List`
* Fix: `dart:html` package doesn't let build project example

# 2.1.11

* Chore: updated dependency `flutter_quill_delta_easy_parser` to fix some new line issues 

# 2.1.1

* Fix: `Image` embed `block` attributes are ignored
* Fix: bad indent multiplier
* Fix: late initialization of 'widgets' variable on `getListBlock`
* Fix: double is not subtype of 'String' on `css.dart`
* Fix: line-height amount is incorrect

# 2.1.0

* Chore: now `onRequestFonts` are optional
* Fix: `PdfWidgetGenerator` was replaced by `PDFWidgetBuilder` 
* Fix: `video` block is detected as a `image` block
* Fix: `codeblock` has not padding on it's content
* Fix: comments to describe how new lines are detected on `blockGenerators` method
* Fix: `header` block indentation multiplier
* Feat: support for `customBuilders` again returned to replace `customCOnverters`
* Chore: was `deprecated` most of the `methods` and `params` that are no longer used

# 2.0.0

**¡BREAKING CHANGES!**

The way of build the PDF's it's different and better 

### Before implementation (using `vsc_quill_delta_to_html` and `html2md` with `RegExp` patterns)

The `PDF` is builded: first the `Delta` is converted to a custom implementation, then, after it will be transformed to a `Markdown` with some `HTML` styles to avoid losing align attrs or colors. 

On the creation of the `PDF` (using `PdfService`) all of this `HTML` with `Markdown` are detected using `RegExp` that made more difficult had a correct performance. Some devices even could crash on the building of that `PDF` way.

### New implementation (using `flutter_quill_delta_easy_parser`)

Transform directly a `Delta` to a `Structured-Document` type that it's more easy to be readed by a human, and getting the attributes from any `Line` or the block attributes from the current `Paragraph`.

### Other Changes

* Fix: app crashed when use `createDocument` method.
* Fix: bad perfomance while building a PDF.
* Chore: deprecated `customConverters` param from `PDFConverter` to avoid using after this release
* Fix: removed most of the `RegExp` used on Constant class.
* Fix: removed `MarkdownRules` class since is not necessary now.
* Fix: removed `vsc_quill_delta_to_html` and `html2md` since are not used now.
* Fix: removed `HTMLConverterOptions` local implementation since is not used now.
* Chore: removed `setCustomRules` method from Converter 
* Chore: moved some const values to example since wont be necessary be in the package.

**By now this version is not using CustomPDFWidget or PdfWidgetGenerator. This is just a temporary issue that will be fixed on next releases**

# 1.2.2

- [Fix] delta to html doesn't detect double values

# 1.2.1

- [Fix] renamed WidgetGenerator to PdfWidgetGenerator
- [Fix] renamed file markdown_rules_custom to markdown_rules
- [Chore] changed ConverterOptions from converter delta to html from `HTMLConverterOptions` to `ConverterOptions.forEmail()`
- [Feat] exposed PdfService
- [Feat] added support for strikethrough in PdfService
- [Feat] All params on DeltaAttributesOptions are supported
- [BREAKING CHANGES] rgbColor was renamed as hexColor and now is an int at DeltaAttributesOptions
- [BREAKING CHANGES] levelHeader was removed on DeltaAttributesOptions

# 1.2.0

- Removed unnecessary code
- Writed more documentation about classes and functions
- [Fix] rename at MarkdownRules by bad name of file
- [Fix] bad list formatting. The list block function generator didn't detect the span styles into itself
- [Feat] added support for image links
- [Feat] added support for colors
- [Feat] added support for blockquote
- [Feat] added support for codeblock
- [Feat] added support to render custom html using `renderCustomCallback` param from `convertDeltaToHtml`

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

- [Feat] added support for customize properties in blockquote and codeblock without create a custom widget

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

- [Fix] README bad dependecy name

# 1.1.1

- [Feat] improved README
- [Fix] bad unnecessary args remove
- [Fix] bad names in some classes and functions
- [Fix] bad test (by now cannot be created a test)

## 1.1.0

- [Feat] added support to custom delta to html converter
- [Feat] added support to custom html to markdown converter
- [Feat] added new factory to create document and write file
- [Feat] improved params descriptions
- [Feat] added support to customize markdown rules
- [Feat] now we can add a custom theme to pdf document
- [Feat] now we can pass functions to when the create doc ends sucessfully or when throws and exception
- [Fix] removed lineHeight attribute since flutt_quill and html2md has Rule class and creates conflicts on imports
- README now has better documentation, to be more accurate on how use this library

## 1.0.2

- [Fix] inconfortable name. PDFConvertersParam was changed to PDFPageFormat
- [Feat] improved README to make more easy read how works the package

## 1.0.1

- [Fix] minimal errors
- [Fix] issue where list (bullet, check, and ordered) takes a more space that it needs on top

## 1.0.0

- First commit
