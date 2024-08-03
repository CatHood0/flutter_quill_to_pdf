# Flutter Quill to PDF

This package allow us create PDF's using `Deltas` from `Quill`.

Some options that can be configured:

- `DeltaAttributesOptions` (this attributes will be applied to whole delta)
- We can use custom fonts. Using `onRequestFont` functions in `PDFConverter` we can detect the font family detected, and use a custom implementation to return a `Font` valid to `pdf` package _Just works automatically with the default library implementation_
- `CustomWidget`, which helps you create custom `PDF` widgets using the `Paragraph` implementation from `flutter_quill_delta_easy_parser`.
- Optional front matter and back matter
- Page format using `PDFPageFormat` class
- `PDFWidgetBuilder` functions in `PDFConverter` that let us customize the detected style, and create a custom pdf widget implementation
- `ThemeData` optional theme data that let us changes the theme for to pdf document

> By default, the delta is processed by a local implementation that uses `DeltaAttributesOptions` to apply custom attributes (if it is not null), making it easier to add an attribute to the entire delta. If you want to create your own implementation or simply use a default delta, use `PDFConverter(...params).createDocument(shouldProcessDeltas: false)`.

<details>
    <summary>Tap to show/hide screenshots</summary>
    <br>
<img src="https://github.com/CatHood0/flutter_quill_to_pdf/blob/master/example/assets/delta_to_convert.jpg" width="250" alt="Delta in editor">
<img src="https://github.com/CatHood0/flutter_quill_to_pdf/blob/master/example/assets/delta_converted.jpg" width="350" alt="Delta converted in PDF">
</details>

### Add dependencies

```yaml
dependencies:
  flutter_quill_to_pdf: ^2.2.3
```

### Import package

```dart
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart':
```

### Personalize the settings of the page (height, width and margins)

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

### Using PDFConverter to create finally our document

```dart
PDFConverter pdfConverter = PDFConverter(
    backMatterDelta: null,
    frontMatterDelta: null,
    document: QuillController.basic().document.toDelta(),
    fallbacks: [...your global fonts],
    onRequestBoldFont: (String fontFamily) async {
        // this is optional
       ...your local font implementation
    },
    onRequestBoldItalicFont: (String fontFamily) async {
        // this is optional
       ...your local font implementation
    },
    onRequestFallbackFont: (String fontFamily) async {
        // this is optional
       ...your local font implementation
    },
    onRequestItalicFont: (String fontFamily) async {
        // this is optional
       ...your local font implementation
    },
    onRequestFont: (String fontFamily) async {
        // this is optional
       ...your local font implementation
    },
    params: pageFormat,
);
```

## To create it, we have two options :

#### `createDocument` _returns the PDF document associated_

```dart
final pw.Document? document = await pdfConverter.createDocument();
```

#### `createDocumentFile` _makes the same of the before one, write in the selected file path_

```dart
// [isWeb] is used to know how save automatically the PDF generated
await pdfConverter.createDocumentFile(path: filepath, isWeb: kIsWeb,...other optional params);
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
- Line-height (custom attribute used from this package)
- Code block
- Blockquote
- Align
- Embed image (base 64 doesn't work yet)
- Embed video (Just the URL of the Video will be pasted as a text)
- Header
- List (Multilevel List too)
- Indent

## No supported

- Superscript/Subscript (Not planned since is not supported by pdf package)
- Embed formula (Not planned)

You can contribute reporting issues or requesting to add new features on [flutter_quill_to_pdf](https://github.com/CatHood0/flutter_quill_to_pdf)

