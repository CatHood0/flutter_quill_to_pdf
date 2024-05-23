# Quill Delta to PDF

Allow we create PDF'S using delta from Quill. 

We can configure: the attributes that will appears in delta using `DeltaAttributesOptions` (if certains attrs not be found in delta, this optional attributes will be used), the fonts that the pdfcan use to our text, `CustomConverter` that help us to create custom PDF widgets using custom regex, front matter and back matter (optionals), and even page format.

> By default, the delta when create document are processed by a local implementation that use `DeltaAttributesOptions`to apply custom attrs make more easy add a attribute to whole delta. If you want just make you're own implementation, or just use a default delta, use `PDFConverter(...params).createDocument(shouldProcessDeltas: false)`

<Screenshots>
<img src="./example/assets/delta_to_convert.jpg" width="250" alt="Delta in editor">
<img src="./example/assets/delta_converted.jpg" width="350" alt="Delta converted in PDF">
</Screenshots>

### Suppoted

* font family
* size
* bold
* italic
* underline
* Link
* line-height (custom attribute used from this package)
* Align
* Image embed (Files path yet)
* Header
* List (check, bullet, ordered)

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
