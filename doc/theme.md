## 🎨 Theme customization

In some cases, we don't actually want to just customize the **blocks or custom detect** styles, we want to have our own version of every `TextStyle` by default. For these cases, the best thing we can do is create our own version of the `ThemeData`.

### Configurate your ThemeData

_The fonts used in the example code comes from the `FontsLoader` class from the example. You will need to implement your own fonts to make a similar behavior_

```dart
final pdfConverter = PDFConverter(
  themeData: pw.ThemeData(
    defaultTextStyle: pw.TextStyle(
      color: PdfColor.fromInt(0xFF555555),
      fontNormal: loader.getFontByName(fontFamily: 'Lora'),
      fontBold: loader.getFontByName(fontFamily: 'Lora', bold: true),
      fontBoldItalic: loader.getFontByName(fontFamily: 'Lora', bold: true, italic: true),
      fontItalic: loader.getFontByName(fontFamily: 'Lora', italic: true),
      inherit: true,
      lineSpacing: 1.0,
    ),
    header1: pw.TextStyle(
      fontSize: 27,
      color: PdfColor.fromInt(0xFF555555),
      fontNormal: loader.getFontByName(fontFamily: 'Lora'),
      fontBold: loader.getFontByName(fontFamily: 'Lora', bold: true),
      fontBoldItalic: loader.getFontByName(fontFamily: 'Lora', bold: true, italic: true),
      fontItalic: loader.getFontByName(fontFamily: 'Lora', italic: true),
      inherit: true,
      letterSpacing: 1.5,
      lineSpacing: 1.0,
    ),
    header2: pw.TextStyle(
      fontSize: 24,
      color: PdfColor.fromInt(0xFF555555),
      fontNormal: loader.getFontByName(fontFamily: 'Lora'),
      fontBold: loader.getFontByName(fontFamily: 'Lora', bold: true),
      fontBoldItalic: loader.getFontByName(fontFamily: 'Lora', bold: true, italic: true),
      fontItalic: loader.getFontByName(fontFamily: 'Lora', italic: true),
      inherit: true,
      letterSpacing: 1.5,
      lineSpacing: 1.0,
    ),
  ),
  document: _quillController.document.toDelta(),
  pageFormat: params,
);
```

#### 🔥 Pdf document result: 

<img src="https://github.com/user-attachments/assets/255525d5-a5a9-4f84-8faf-804510fa8075" style="display: block; margin-left: auto; margin-right: auto; width: 70%"/>
