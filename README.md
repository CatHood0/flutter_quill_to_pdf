# 📖 Flutter Quill to PDF

**Flutter Quill to PDF** is a powerful package designed to convert documents created with **Flutter Quill** (based on Deltas) into high-quality PDF files. This package offers a wide range of customization options, allowing developers to adjust page formatting (width, height, and margins), customize fonts, text styles, and add elements such as images, videos, lists, blockquotes, and code blocks. Additionally, it supports the generation of custom widgets to integrate PDF content directly into the **Flutter** user interface. 

<details>
    <summary>Show/Hide screenshots</summary>
    <h4>Content used to generate the PDF</h4>
    <img src="https://github.com/CatHood0/flutter_quill_to_pdf/blob/master/assets/demo_to_pdf.png?raw=true" style="width: 70%;"/>
    <h4>PDF generated</h4>
    <img src="https://github.com/CatHood0/flutter_quill_to_pdf/blob/master/assets/result_demo_to_pdf.png?raw=true" style="width: 60%; height: 60%"/>
</details>
<p></p>

> [!TIP]
> If you are using the version **v2.2.9** or a minor version, [see the breaking changes that were maded in **v2.3.0**](https://github.com/CatHood0/flutter_quill_to_pdf/blob/master/CHANGELOG.md#230)

## 📚 Resources

[code-block customization](https://github.com/CatHood0/flutter_quill_to_pdf/blob/master/doc/code-block.md)
[blockquote customization](https://github.com/CatHood0/flutter_quill_to_pdf/blob/master/doc/blockquote.md)
[theme customization](https://github.com/CatHood0/flutter_quill_to_pdf/blob/master/doc/theme.md)
[header customization](https://github.com/CatHood0/flutter_quill_to_pdf/blob/master/doc/header.md)

### 🔎 Creating your PDF file  

#### 📎 First: personalize the settings of the page (`height`, `width` and `margins`)

```dart
final PDFPageFormat pageFormat = PDFPageFormat(
   width: ..., //max width of the page
   height: ..., //max height of the page,
   marginTop: ...,
   marginBottom: ...,
   marginLeft: ...,
   marginRight: ...,
);
// or use
final PDFPageFormat pageFormat = PDFPageFormat.all(
   width: ..., //max width of the page
   height: ..., //max height of the page,
   margin: ..., //will set the property to the others margins
);
```

#### ⚒️  Second: create your PDFConverter

```dart
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart':

final pdfConverter = PDFConverter(
    backMatterDelta: null,
    frontMatterDelta: null,
    // set a default Direction to your pdf widgets
    textDirection: Directionality.of(context), 
    // if you support web platform, you will need to pass this param, 
    // since fetching images in web works differently
    isWeb: kIsWeb,
    pageFormat: pageFormat, // pass your page format here
    themeData: null, // your custom theme for the document
    listTypeWidget: ListTypeWidget.stable, // or ListTypeWidget.modern
    listLeadingBuilder: (String type, int level, Object? args) => null,
    enableCodeBlockHighlighting: true, 
    customHeadingSizes: [50, 45, 40, 35, 30], // override default heading sizes
    isLightCodeBlockTheme: false,
    // your custom theme for code-block (see code-block customization resource)
    customCodeHighlightTheme: <String, pw.TextStyle>{},
    codeBlockBackgroundColor: null, // override default implementation
    codeBlockNumLinesTextStyle: null, // override default implementation
    codeBlockFont: null, // override default implementation
    inlineCodeStyle: null, // override default implementation
    blockquoteTextStyle: null, // override default implementation
    blockquotePadding: null, // override default implementation
    blockquoteBoxDecoration: null, // override default implementation
    onDetectBlockquote: (Paragraph pr, Object? args) {
      return YourPdfWidget();
    },
    onDetectCodeBlock: null,
    onDetectVideoBlock: null,
    document: _quillController.document.toDelta(),
    fallbacks: <pw.Font>[], // here you can put all your pdf font fallbacks
    onRequestFontFamily: (FontFamilyRequest familyRequest) {
        return FontFamilyResponse(
          fontNormalV: <anyFontThatYouWant>, 
          boldFontV: familyRequest.isBold ? <yourBoldFontFamily> : null,
          italicFontV: familyRequest.isItalic ? <yourItalicFontFamily> : null,
          boldItalicFontV: familyRequest.isItalic && familyRequest.isBold ? <yourBoldItalicFontFamily> : null,
          fallbacks: const <pw.Font>[],
        );
    },
);
```

### 📝 Creating the PdfDocument/widgets:

```dart
import 'dart:io';
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart';
import 'package:pdf/pdf.dart';

// return a pdf Document
final doc = await pdfConverter.createDocument();
// Generate the widgets without adding them to a pdf document
final pw.Widget? pwWidget = await pdfConverter.generateWidget(
    maxWidth: pwWidgetWidth,
    maxHeight: pwWidgetHeight,
);
// with this, we can use doc.save() to write the bytes into a File in a Storage Path
```

## Supported Attributes 

#### Inlines

- Size
- Bold
- Link
- Color
- Italic
- Underline
- inline code 
- Font family
- Strikethrough
- Background Color
- Superscript/Subscript (**being planned**)

#### Blocks 
##### Combinable with other Block/Non block Attributes 

- Align
- Indent
- Direction
- Line-height

##### Exclusives

- Header
- Code-block
- Blockquote
- Embed image (Base64, URL, and common storage paths)
- Embed video (by default, just the URL of the video will be pasted as a text)
- Embed formula (**being planned**)
- List (Multilevel List too)
  1. Ordered List 
  *  Bullet List
  - [x] CheckBox List

## Contributing

We greatly appreciate your time and effort.

To keep the project consistent and maintainable, we have a few guidelines that we ask all contributors to follow. These guidelines help ensure that everyone can understand and work with the code easier.

See [Contributing](https://github.com/CatHood0/flutter_quill_to_pdf/blob/master/CONTRIBUTING.md) for more details.
