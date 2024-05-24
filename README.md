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

### Add dependencies

```yaml
dependencies: 
    pdf: <latest_version>
    quill_to_pdf: ^1.1.0
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

### Configure delta to html options (optional)

_This is a fragment from: [vsc_quill_delta_to_html](https://github.com/VisualSystemsCorp/vsc_quill_delta_to_html) description (If you want to know more about these configs, and custom attributes rendering, visit his github)_

We can configure a custom `ConverterOptions` using the param `convertOptions` from `PDFConverter()`

`QuillDeltaToHtmlConverter` accepts a few configuration (`ConverterOptions`, `OpConverterOptions`, 
and `OpAttributeSanitizerOptions`) options as shown below:

| Option                                  | Type                                                  | Default        | Description                                                                                                                                                                                                                                                                                                                                                                                                                     
|-----------------------------------------|-------------------------------------------------------|----------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `converterOptions.paragraphTag`         | string                                                | 'p'            | Custom tag to wrap inline html elements                                                                                                                                                                                                                                                                                                                                                                                         |
| `converterOptions.encodeHtml`           | boolean                                               | true           | If true, `<, >, /, ', ", &` characters in content will be encoded.                                                                                                                                                                                                                                                                                                                                                              |
| `converterOptions.classPrefix`          | string                                                | 'ql'           | A css class name to prefix class generating styles such as `size`, `font`, etc.                                                                                                                                                                                                                                                                                                                                                 |
| `converterOptions.inlineStylesFlag`     | boolean                                               | false          | If true, use inline styles instead of classes.                                                                                                                                                                                                                                                                                                                                                                                  |
| `converterOptions.inlineStyles`         | InlineStyles                                          | null           | If non-null, use inline styles instead of classes. See Rendering Inline Styles section below for usage.                                                                                                                                                                                                                                                                                                                         |
| `multiLineBlockquote`                   | boolean                                               | true           | Instead of rendering multiple `blockquote` elements for quotes that are consecutive and have same styles(`align`, `indent`, and `direction`), it renders them into only one                                                                                                                                                                                                                                                     |
| `multiLineHeader`                       | boolean                                               | true           | Same deal as `multiLineBlockquote` for headers                                                                                                                                                                                                                                                                                                                                                                                  |
| `multiLineCodeblock`                    | boolean                                               | true           | Same deal as `multiLineBlockquote` for code-blocks                                                                                                                                                                                                                                                                                                                                                                              |
| `multiLineParagraph`                    | boolean                                               | true           | Set to false to generate a new paragraph tag after each enter press (new line)                                                                                                                                                                                                                                                                                                                                                  |
| `multiLineCustomBlock`                  | boolean                                               | true           | Same deal as `multiLineBlockquote` for custom blocks.                                                                                                                                                                                                                                                                                                                                                                           |
| `bulletListTag`                         | string                                                | 'ul'           | Tag for unordered bullet lists.                                                                                                                                                                                                                                                                                                                                                                                                 |
| `orderedListTag`                        | string                                                | 'ol'           | Tag for ordered/numbered lists.                                                                                                                                                                                                                                                                                                                                                                                                 |
| `converterOptions.linkRel`              | string                                                | none generated | Specifies a value to put on the `rel` attr on all links. This can be overridden by an individual link op by specifying the `rel` attribute in the respective op's attributes                                                                                                                                                                                                                                                    |
| `converterOptions.linkTarget`           | string                                                | '_blank'       | Specifies target for all links; use `''` (empty string) to not generate `target` attribute. This can be overridden by an individual link op by specifiying the `target` with a value in the respective op's attributes.                                                                                                                                                                                                         |
| `converterOptions.allowBackgroundClasses` | boolean                                               | false          | If true, css classes will be added for background attr                                                                                                                                                                                                                                                                                                                                                                          |
| `sanitizerOptions.urlSanitizer`         | `String? Function(String url)`                                 | null           | A function that is called once per url in the ops (image, video, link) for you to do custom sanitization. If your function returns a string, it is assumed that you sanitized the url and no further sanitization will be done by the library; when anything other than a string is returned (e.g. undefined), it is assumed that no sanitization has been done and the library's own function will be used to clean up the url |                                                                                                                                                                                                              
| `sanitizerOptions.allow8DigitHexColors` | boolean                                               | false          | If true, hex colors in `#AARRGGBB` format are allowed in the ops                                                                                                                                                                                                                                                                                                                                                                     |
| `converterOptions.customTag`            | `String? Function(String format, DeltaInsertOp op)`   | null           | Callback allows to provide custom html tag for some format                                                                                                                                                                                                                                                                                                                                                                      |
| `converterOptions.customTagAttributes`  | `Map<String, String>? Function(DeltaInsertOp op)` | null           | Allows custom html tag attributes for the given op                                                                                                                                                                                                                                                                                                                                                                              | 
| `converterOptions.customCssClasses`     | `List<String>? Function(DeltaInsertOp op)`           | null           | Allows custom CSS classes for the given op                                                                                                                                                                                                                                                                                                                                                                                      | 
| `converterOptions.customCssStyles`      | `List<String>? Function(DeltaInsertOp op)`              | null           | Allows custom CSS styles attributes for the given op                                                                                                                                                                                                                                                                                                                                                                            | 


### Configuring custom markdown rules (optional)

You can set custom rules using 
```dart
//By default is null, and it will throws error if rules are empty
PDFConverter(..., customRules: [...your custom rules]);
```

_This is a fragment from [html2md](https://github.com/jarontai/html2md) package documentation_

#### Custom Rules

Want to customize element converting? Write your rules!

Rule fields explaination

~~~dart
final String name; // unique rule name
final List<String>? filters; // simple element name filters, e.g. ['aside']
final FilterFn? filterFn; // function for building complex element filter logic
final Replacement? replacement; // function for doing the replacing
final Append? append; // function for appending content
~~~

Rule example - Convert the onebox section of [discourse](https://www.discourse.org/) post to a link

~~~html
<aside class="onebox">
  <header class="source">
      <img src="https://discoursesite/uploads/default/original/1X/test.png" class="site-icon" width="32" height="32">
      <a href="https://events.google.com/io/program/content?4=topic_flutter&amp;lng=zh-CN" target="_blank" rel="noopener">Google I/O 2021</a>
  </header>
</aside>
~~~

~~~dart
Rule(
  'discourse-onebox',
  filterFn: (node) {
    // Find aside with onebox class
    if (node.nodeName == 'aside' &&
        node.className.contains('onebox')) {
        return true;
    }
    return false;
  },
  replacement: (content, node) {
    // find the first a element under header
    var header = node.firstChild;
    var link = header!
        .childNodes()
        .firstWhere((element) => element.nodeName == 'a');
    var href = link.getAttribute('href');
    if (href != null && href.isNotEmpty) {
      return '[$href]($href)'; // build the link
    }
    return '';
  },
)
~~~

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
```

#### We can use a document create method

```dart
final pw.Document? document = await pdfConverter.createDocument();
```

#### Or just use this, that creates PDF document and writed in the selected file path
```dart
await pdfConverter.createDocumentFile(path: filepath, ...other optional params);
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
