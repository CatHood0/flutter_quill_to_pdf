# Quill Delta to PDF

This package allows you to create PDFs using deltas from Quill.

You can configure:

* `DeltaAttributesOptions` (this are attributes that will appear in the delta if certain attributes are not found in the delta.
* The fonts that the PDF can use for your text.
* `CustomConverter`, which helps you create custom PDF widgets using custom regular expressions.
* Optional front matter and back matter.
* Even the page format.

> By default, the delta when creating the document is processed by a local implementation that uses `DeltaAttributesOptions` to apply custom attributes, making it easier to add an attribute to the entire delta. If you want to create your own implementation or simply use a default delta, use `PDFConverter(...params).createDocument(shouldProcessDeltas: false)`.

<Screenshots>
    <br>
<img src="./example/assets/delta_to_convert.jpg" width="250" alt="Delta in editor">
<img src="./example/assets/delta_converted.jpg" width="350" alt="Delta converted in PDF">
</Screenshots>

### Add dependency

```yaml
dependencies: 
    quill_to_pdf: ^1.0.0
```

### Import package

```dart
import 'package:quill_to_pdf/quill_to_pdf.dart':
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
    params: PDFConverterParams(...),// this decide the page format
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
