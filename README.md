# Quill Delta to PDF

This package allows you to create PDFs using deltas from Quill.

You can configure:

* `DeltaAttributesOptions` (this are attributes that will appear in the delta if certain attributes are not found in the delta).
* The fonts that the PDF can use for your text.
* `CustomConverter`, which helps you create custom PDF widgets using custom regular expressions.
* Optional front matter and back matter.
* Even the page format using `PDFPageFormat` class.

> By default, the delta when creating the document is processed by a local implementation that uses `DeltaAttributesOptions` to apply custom attributes, making it easier to add an attribute to the entire delta. If you want to create your own implementation or simply use a default delta, use `PDFConverter(...params).createDocument(shouldProcessDeltas: false)`.

<details>
    <summary>Tap to show/hide screenshots</summary>
    <br>
<img src="./example/assets/delta_to_convert.jpg" width="250" alt="Delta in editor">
<img src="./example/assets/delta_converted.jpg" width="350" alt="Delta converted in PDF">
</details>

### Add dependency

```yaml
dependencies: 
    quill_to_pdf: ^1.0.0
```

### Import package

```dart
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart':
```

### Personalize the settings of the page that will be printed (height,width,margins)

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

##### The marginize all `PDFPageFormat` implementation

```dart
final PDFPageFormat pageFormat = PDFPageFormat.all(
   width: ..., //max width of the page
   height: ..., //max height of the page,
   margin: ..., //will set the property to the others margins
);
```

### Using pdf converter and required params

```dart
PDFConverter pdfConverter = PDFConverter(
    backMatterDelta: null,
    frontMatterDelta: null,
    customConverters: [],
    document: _quillController.document.toDelta(),
    fallbacks: [...your global fonts],
    onRequestBoldFont: (String fontFamily) async {
       ...your local font implementation
    },
    onRequestBoldItalicFont: (String fontFamily) async {
       ...your local font implementation
    },
    onRequestFallbackFont: (String fontFamily) async {
       ...your local font implementation
    },
    onRequestItalicFont: (String fontFamily) async {
       ...your local font implementation
    },
    onRequestFont: (String fontFamily) async {
       ...your local font implementation
    },
    params: pageFormat,
);
final pw.Document? document = await pdfConverter.createDocument();
```
### Suppoted

* font family
* size
* bold
* italic
* underline
* Link
* line-height (custom attribute used from this package)
* Align
* Embed image (File path yet)
* Header
* List (check, bullet, ordered)

## Not support yet

* Images links
* Code block
* Blockquote
* text Color 
* background color
* indented text,
* indented list (bullet, unordered, check)
* formula 

You can contribute reporting issues or requesting to add new features in: https://github.com/CatHood0/quill_to_pdf 
