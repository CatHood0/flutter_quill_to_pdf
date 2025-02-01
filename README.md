# Flutter Quill to PDF

This package allow us create PDF's using `Deltas` from `Quill`.

Some options that can be configured:

- `DeltaAttributesOptions` (this attributes will be applied to whole delta)
- We can use custom fonts. Using `onRequestFont` functions in `PDFConverter` we can detect the font family detected, and use a custom implementation to return a `Font` valid to `pdf` package. 
- `CustomWidget`, which helps you create custom `PDF` widgets using the `Paragraph` implementation from `flutter_quill_delta_easy_parser`.
- Optional front matter and back matter
- We can set a default directionality for the PDF widgets using `textDirection` from `PDFConverter`
- Page format using `PDFPageFormat` class
- `PDFWidgetBuilder` functions in `PDFConverter` that let us customize the detected style, and create a custom pdf widget implementation
- `PageBuilder` function in `PDFConverter` let us create dinamically pdf pages as we want. 
- `ThemeData` optional theme data that let us changes the theme for to pdf document

> By default, the delta is processed by a local implementation that uses `DeltaAttributesOptions` to apply custom attributes (if it is not null), making it easier to add an attribute to the entire delta. If you want to create your own implementation or simply use a default delta, use `PDFConverter(...params).createDocument(shouldProcessDeltas: false)`.

![Delta in editor](https://github.com/CatHood0/flutter_quill_to_pdf/blob/master/example/assets/delta_to_convert.jpg)
![Delta converted in PDF](https://github.com/CatHood0/flutter_quill_to_pdf/blob/master/example/assets/delta_converted.jpg)

### Add dependencies

```yaml
dependencies:
  flutter_quill_to_pdf: <lastest_version>
```

### Import package

```dart
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart':
```

### Personalize the settings of the page (`height`, `width` and `margins`)

We can use two types differents constructors of the same `PDFPageFormat` class

##### The common, with all set params:

```dart
final PDFPageFormat pageFormat = PDFPageFormat(
   width: ..., //max width of the page
   height: ..., //max height of the page,
   marginTop: ...,
   marginBottom: ...,
   marginLeft: ...,
   marginRight: ...,
);
```

##### The factory to marginize all `PDFPageFormat`

```dart
final PDFPageFormat pageFormat = PDFPageFormat.all(
   width: ..., //max width of the page
   height: ..., //max height of the page,
   margin: ..., //will set the property to the others margins
);
```

### Using `PDFConverter` to create finally our document

```dart
final pdfConverter = PDFConverter(
    backMatterDelta: null,
    frontMatterDelta: null,
    textDirection: Directionality.of(context), // set a default Direction to your pdf widgets
    // if you support web platform, you will need to pass this param, since fetching images in web works differently
    isWeb: kIsWeb,
    document: _quillController.document.toDelta(),
    pageFormat: pageFormat,
    fallbacks: [...your global fonts],
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

## To create it, we have three options:

#### `createDocument` _returns the PDF document associated_

```dart
final pw.Document? document = await pdfConverter.createDocument();
```

#### `createDocumentFile` _makes the same of the before one, write in the selected file path_

```dart
await pdfConverter.createDocumentFile(path: filepath, <...other optional params>);
```

#### `generateWidget` _returns a Widget that gives to you full control of the PDF_

```dart
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';

// Generate a widget from the PDF converter
final pw.Widget? pwWidget = await pdfConverter.generateWidget(
    maxWidth: pwWidgetWidth,
    maxHeight: pwWidgetHeight,
);

// Create a new PDF document with specific settings
final pw.Document document = pw.Document(
    compress: true,
    verbose: true,
    pageMode: PdfPageMode.outlines,
    version: PdfVersion.pdf_1_5,
);

// Create A4 page without margins
final PdfPageFormat pdfPageFormat = PdfPageFormat(
    PDFPageFormat.a4.width, PDFPageFormat.a4.height,
    marginAll: 0);

// Add a page to the document with custom layout
document.addPage(
    pw.Page(
    pageFormat: pdfPageFormat,
    build: (pw.Context context) {
        return pw.Stack(children: [
        // Create a full-page blue background
        pw.Expanded(
            child: pw.Rectangle(
            fillColor: PdfColor.fromHex("#5AACFE"),
            ),
        ),
        // Position the editor content in the top-left corner
        pw.Positioned(
            top: PdfPageFormat.a4.marginTop,
            left: PdfPageFormat.a4.marginLeft,
            child: pwWidget!),
        // Position a copy of the editor content in the bottom-right corner
        pw.Positioned(
            bottom: PdfPageFormat.a4.marginBottom,
            right: PdfPageFormat.a4.marginRight,
            child: pwWidget!),
        ]);
    },
    ),
);
// Save the document to a file
await file.writeAsBytes(await document.save());
```

## Supported

- Font family
- Size
- Bold
- Italic
- Strikethrough
- Underline
- Link
- Color
- Background Color
- Line-height
- Code block
- Direction
- Blockquote
- Align
- Embed image (Base64, URL, and Storage Paths)
- Embed video (Just the URL of the Video will be pasted as a text)
- Header
- List (Multilevel List too)
  1. Ordered List 
  *  Bullet List
  - [x] CheckBox List
- Indent

## No supported

- Superscript/Subscript (Not planned since is not supported by pdf package)
- Embed formula (Not planned)

You can contribute reporting issues or requesting to add new features on [flutter_quill_to_pdf](https://github.com/CatHood0/flutter_quill_to_pdf)
