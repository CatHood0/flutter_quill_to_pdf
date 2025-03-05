## 📜 Blockquote customization

### 🎨 Customizing styles of the default blockquote widget 

To customize some of the details of the default version of the blockquote widget, you can use the following settings (the values you pass will be up to you, the following is just an example) to create a custom version of the block:

```dart
final pdfConverter = PDFConverter(
  document: yourdelta,
  pageFormat: yourformat,
  blockquotePadding: (int indent, pw.TextDirection direction) => pw.EdgeInsets.only(top: 5, bottom: 5, left: 10),
  blockquoteTextStyle: pw.TextStyle(
    color: PdfColor.fromInt(0xFF666666),
    font: loader.getFontByName(fontFamily: 'Ubuntu Mono'),
    lineSpacing: 1.0,
    fontStyle: pw.FontStyle.italic,
  ),
  blockquoteBoxDecoration: (pw.TextDirection direction) => pw.BoxDecoration(
    border: pw.Border(
      left: direction == pw.TextDirection.rtl
          ? pw.BorderSide.none
          : pw.BorderSide(
              color: PdfColors.green300,
              width: 4,
            ),
      right: (direction) != pw.TextDirection.rtl
          ? pw.BorderSide.none
          : pw.BorderSide(
              color: PdfColors.green300,
              width: 4,
            ),
    ),
  ),
);
```

Now, when you create your pdf using this configuration, you should get something like:

<img src="https://github.com/user-attachments/assets/0f32196e-c825-495f-a6cc-68a9d652d6c7"/>
<p></p>

### 📑 Custom Blockquote widget 

In case we wanted a completely different version of blockquote, we would have to build it from scratch. 

For this example, we will use a special blockquote aspect that Github uses:

<img src="https://github.com/user-attachments/assets/75eafcc8-d9c2-4f3d-980c-c44ab8930466"/>
<p></p>

#### ✂️ Creating the Github Blockquote-like Widget

```dart
pw.Widget generateGithubBlockquote(Paragraph paragraph, Map<String, dynamic>? blockAttributes, [Object? args]) {
  final int indentLevel = blockAttributes?['indent'] as int? ?? 0;
  final pw.InlineSpan textSpan = _buildRichSpans(paragraph.lines);
  return pw.Container(
    padding: pw.EdgeInsetsDirectional.only(
      start: (indentLevel > 0 ? indentLevel * 12.5 : 10),
      end: 10,
      top: 5,
      bottom: 5,
    ),
    decoration: pw.BoxDecoration(
      border: pw.Border(
        left: pw.BorderSide(
          color: PdfColors.green600,
          width: 3,
        ),
      ),
    ),
    child: pw.Column(
      mainAxisAlignment: pw.MainAxisAlignment.start,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      mainAxisSize: pw.MainAxisSize.min,
      children: <pw.Widget>[
        pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.start,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisSize: pw.MainAxisSize.min,
            children: [
              pw.Image(
                  pw.MemoryImage(
                    base64Decode(tipImage),
                    dpi: 250,
                  ),
                  fit: pw.BoxFit.contain,
                  width: 15,
                  height: 13,
              ),
              pw.SizedBox(width: 3),
              pw.Text(
                  'Tip',
                  // into the args passed, the package give to us the styles that 
                  // are being used by the ThemeData of pdf
                  style: ((args as Map)['textStyle'] as pw.TextStyle).copyWith(
                    color: PdfColors.green600,
                  ),
              ),
            ],
        ),
        pw.SizedBox(height: 5),
        pw.RichText(
          overflow: pw.TextOverflow.span,
          softWrap: true,
          text: textSpan,
        ),
      ],
    ),
  );
}

pw.InlineSpan _buildRichSpans(List<Line> lines) {
  final List<pw.InlineSpan> spans = [];
  for(final line in lines) {
    spans.add(_buildRichSpan(line));
  }
  return pw.TextSpan(children: spans);
}

pw.InlineSpan _buildRichSpan(Line line) {
  //.. your logic for build the spans
}

// this base64 was generated in https://icons8.com
final String tipImage = 'iVBORw0KGgoAAAANSUhEUgAAADIAAAAyCAYAAAAeP4ixAAAACXBIWXMAAAsTAAALEwEAmpwYAAAD0ElEQVR4nO1aXYgURxAuzx/8exJ/8mZUiLJ40705L5xGXU0Q5JyqPcVFyLtB8xiMIQ/hIuIvCj4IvoiCoIKvQkBQfBBdb7r2TsNFBR9Eo8YfAiEkxChxQ830nOffZnadvp2T/aBhmamu7q+7qrqqZwFaaCH7KJ0qjW3n4jLFtE8ZKmuDDxXjU2nhb0NleScyIgtZQ9el0iRlcKtMVjNVE7WQGG4tnC9MhCxAG1qvGe/EE1QGrynGXfmK/3l7QPO9K6umSOtgf4E800y7FdP1F6TwjlfBdc1jUIUxyuAP2tDzkABToJhWJu2er/iLNdOFaHdCHbuh2tsGI4pqb5tiPGlN5J+8oU1CrH49MEYzbg59KFqMEyNKRhnaYc3it3yFlr+rPh34BdGlI53b05llEp8QU5CdSIFEDGWKK6LoRs8V01pwHZ1ixw7NKWVo9r+yJnbbaTRTBr+129/XkE8kCiBUjsbwt4ALyAE2dE4EfsHJIADgMX5mQ/MDJ44v/mDPiZ/BMTTjDTvWpy6U74+U087Ulb82Fu2xoX1v6spj25XTGRxDG1wVOT1eTF25MvRIlHt9PR+BY7QHNH/IT9KGnBuiPDdYmgqOkRssTbWpyxNnRDr4y/E15Rj7NeNPnX3dH7z6Tp4pQ1fD8F0DucHSBHdEbAqRu1SaVksummh4qF0fTiYkMZT14kDNsfpXz7A6HqfJIVLOOBD6SED5WnLDJxyTedOzWjqU6fkkzqhTJ6IYj9vV3Px/sq9OvB4SAsX0jZU/DGlDMW20yn9MIv+yKSUnMTzUe5XiBkgb3pW1M212+mRhGWcl6SMTj4kkJaEDvzPKgPH3DvYngwsopmP2oDqUtE9MJJFwtbdNIpo14e/BFfKV7tmK6W/F9Oxjxq60iWiDe21qcktKBnAJZXCbXbFfkphYUiJS32hbOst1EbhGlM7TubgukRuSdyWiufiFNvivDQobU5/0WwfuXz1DGbppT9/ThfOFcY0S0UFxiQQQuzDfwUijg3vmSVJnzeFgI0SknI1LZ2XwADQL+Qot0ob+lHDpsb+0XiKeoa9jE236Faqyp7BmOlMvEc1UiXa02A3NxsIyzrKr+ke9RBTTX1FG7U+HLEDXXvWG3jUFLSI8inakFlpEXCHxV6q3NMgK9PtGBEaonzO0iHDGdkQZvFfv7bkkmbYMuAtZgWLc1aijy/dIyApyg6UJQibemUTN0F0hIX0hq9CGjtrVPisFmDT5bYuwIzBaoAaKHyqmX18zI8b7chMDowntwZq58geA8Ltj9Oea495lnNPseUHW8R/X620zw101bAAAAABJRU5ErkJggg==';
```

#### 📌 Pass it to the PDFConverter

```dart
final pdfConverter = PDFConverter(
  onDetectBlockquote: generateGithubBlockquote, 
  document: yourdelta,
  pageFormat: yourformat,
);
// now implement your logic to save the document file
```

#### 🔥 Pdf document result

<img src="https://github.com/user-attachments/assets/f1ab9f04-2eb4-4b65-a23e-e9e0ca799c92"/>
<p></p>
