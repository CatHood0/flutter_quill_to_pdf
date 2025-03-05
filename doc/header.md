## 🖌️ Header customization

### 🎨 Custom widgets 

In some cases, we don't actually want to just customize the header size, but we really want to have our own version of the header. For these cases, the best thing we can do is create our own version of the same header.

For this example, we'll use the look that Github uses for **level 1 to 2 headers**.

<img src="https://github.com/user-attachments/assets/3b1b3b44-a120-4ddb-af2e-30ec3ce4091d" style="width: 100%;"/>
<p></p>

####  ✂️ Creating the Github Header-like Widget

To make a header like that, you can create a custom widget like this:

```dart
import 'package:flutter_quill_delta_easy_parser/flutter_quill_delta_easy_parser.dart';
import 'package:pdf/widgets.dart' as pw;

final List<double> _mySizes = <double>[27, 24, 22, 19, 17];

pw.InlineSpan _buildRichSpan(TextFragment fragment, int headerLevel) {
  final double size = _mySizes[level - 1];
  final pw.TextStyle headerStyle = pw.TextStyle(
    //... your styles using fragment attributes
    fontSize: size,
    fontWeight: pw.FontWeight.bold,
    inherit: true,
  );
  return pw.TextSpan(text: fragment.data as String, style: headerStyle);
}

pw.Widget generateGithubHeader(Line line, Map<String, dynamic>? blockAttributes, [Object? args]) {
  final int level = blockAttributes['header'] as int;
  final int indent = blockAttributes?['indent'] as int? ?? 0;
  // you can get the pageWidth using: 
  // final double pageWidth = (args as Map)['pageWidth'] as double;
  final pw.TextSpan spans = pw.TextSpan(children: line.fragments.map((frag) {
    return _buildRichSpan(frag, level);
  }).toList());
  return pw.Column(
    mainAxisAlignment: pw.MainAxisAlignment.start,
    mainAxisSize: pw.MainAxisSize.min,
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      pw.Container(
        alignment: pw.AlignmentDirectional.centerStart,
        padding: pw.EdgeInsets.only(
          left: indent * 7,
        ),
        decoration: level > 2 ? null : pw.BoxDecoration(
          border: pw.Border(
            bottom: pw.BorderSide(
              style: pw.BorderStyle.solid,
            ),
          ),
        ),
        child: pw.RichText(
          softWrap: true,
          overflow: pw.TextOverflow.span,
          text: spans,
        ),
      ),
      // give a little space between the next blocks
      pw.SizedBox(height: 10),
    ],
  );
}
```

####  📌 Now pass it to the converter 

```dart
final pdfConverter = PDFConverter(
  onDetectHeaderBlock: generateGithubHeader, 
  document: yourdelta,
  pageFormat: yourformat,
);
// now implement your logic to save the document file
```

#### 🔥 Pdf document result: 

<img src="https://github.com/user-attachments/assets/96bb2039-5d4a-47e8-9b66-83ec0938af68" style="width: 100%"/>
<p></p>

###  💡 Custom sizes

Sometimes, we need a different size for each header. Maybe, the default values are not enough. An example of this, would be if we have headers of **level 1 to 10**. By default, **only 1 to level 6 is supported**, which would cause an exception like this when creating the headers:

```console
StateError: "Heading of level 7 is not supported into the passed list: [37, 34, 28, 24, 20, 17]"
```

To avoid this type of errors, and also customize the size of the headers to one that fits what we want, we can configure it using the `customHeaderSizes` parameter in `PDFConverter`:

```dart
final pdfConverter = PDFConverter(
  customHeadingSizes: [
    50, // h1 
    46, // h2 
    43, // h3 
    39, // h4 
    35, // h5
    31, // h6
    28, // h7
    25, // h8
    22, // h9
    19, // h10
  ],
  document: yourdelta,
  pageFormat: yourformat,
);
```
