import 'package:meta/meta.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

final Map<String, TextStyle> lightThemeInCodeblock = <String, TextStyle>{
  'root': const TextStyle(
    background: BoxDecoration(
      color: PdfColor.fromInt(0xfffbf1c7),
    ),
    color: PdfColor.fromInt(0xff3c3836),
  ),
  'subst': const TextStyle(color: PdfColor.fromInt(0xff3c3836)),
  'deletion': const TextStyle(color: PdfColor.fromInt(0xff9d0006)),
  'formula': const TextStyle(color: PdfColor.fromInt(0xff9d0006)),
  'keyword': const TextStyle(color: PdfColor.fromInt(0xff9d0006)),
  'link': const TextStyle(color: PdfColor.fromInt(0xff9d0006)),
  'selector-tag': const TextStyle(color: PdfColor.fromInt(0xff9d0006)),
  'built_in': const TextStyle(color: PdfColor.fromInt(0xff076678)),
  'emphasis': TextStyle(
    color: const PdfColor.fromInt(0xff076678),
    fontStyle: FontStyle.italic,
  ),
  'name': const TextStyle(color: PdfColor.fromInt(0xff076678)),
  'quote': const TextStyle(color: PdfColor.fromInt(0xff076678)),
  'strong': TextStyle(
    color: const PdfColor.fromInt(0xff076678),
    fontWeight: FontWeight.bold,
  ),
  'title': const TextStyle(color: PdfColor.fromInt(0xff076678)),
  'variable': const TextStyle(color: PdfColor.fromInt(0xff076678)),
  'attr': const TextStyle(color: PdfColor.fromInt(0xffb57614)),
  'params': const TextStyle(color: PdfColor.fromInt(0xffb57614)),
  'template-tag': const TextStyle(color: PdfColor.fromInt(0xffb57614)),
  'type': const TextStyle(color: PdfColor.fromInt(0xffb57614)),
  'builtin-name': const TextStyle(color: PdfColor.fromInt(0xff8f3f71)),
  'doctag': const TextStyle(color: PdfColor.fromInt(0xff8f3f71)),
  'literal': const TextStyle(color: PdfColor.fromInt(0xff8f3f71)),
  'number': const TextStyle(color: PdfColor.fromInt(0xff8f3f71)),
  'code': const TextStyle(color: PdfColor.fromInt(0xffaf3a03)),
  'meta': const TextStyle(color: PdfColor.fromInt(0xffaf3a03)),
  'regexp': const TextStyle(color: PdfColor.fromInt(0xffaf3a03)),
  'selector-id': const TextStyle(color: PdfColor.fromInt(0xffaf3a03)),
  'template-variable': const TextStyle(color: PdfColor.fromInt(0xffaf3a03)),
  'addition': const TextStyle(color: PdfColor.fromInt(0xff79740e)),
  'meta-string': const TextStyle(color: PdfColor.fromInt(0xff79740e)),
  'section': TextStyle(
    color: const PdfColor.fromInt(0xff79740e),
    fontWeight: FontWeight.bold,
  ),
  'selector-attr': const TextStyle(color: PdfColor.fromInt(0xff79740e)),
  'selector-class': const TextStyle(color: PdfColor.fromInt(0xff79740e)),
  'string': const TextStyle(color: PdfColor.fromInt(0xff79740e)),
  'symbol': const TextStyle(color: PdfColor.fromInt(0xff79740e)),
  'attribute': const TextStyle(color: PdfColor.fromInt(0xff427b58)),
  'bullet': const TextStyle(color: PdfColor.fromInt(0xff427b58)),
  'class': const TextStyle(color: PdfColor.fromInt(0xff427b58)),
  'function': const TextStyle(color: PdfColor.fromInt(0xff427b58)),
  'meta-keyword': const TextStyle(color: PdfColor.fromInt(0xff427b58)),
  'selector-pseudo': const TextStyle(color: PdfColor.fromInt(0xff427b58)),
  'tag': TextStyle(
    color: const PdfColor.fromInt(0xff427b58),
    fontWeight: FontWeight.bold,
  ),
  'comment': TextStyle(
    color: const PdfColor.fromInt(0xff928374),
    fontStyle: FontStyle.italic,
  ),
  'link_label': const TextStyle(color: PdfColor.fromInt(0xff8f3f71)),
};

final Map<String, TextStyle> darkThemeInCodeBlock = <String, TextStyle>{
  'root': const TextStyle(
    background: BoxDecoration(
      color: PdfColor.fromInt(0xff000000),
    ),
    color: PdfColor.fromInt(0xfff8f8f8),
  ),
  'comment': TextStyle(
    color: const PdfColor.fromInt(0xffaeaeae),
    fontStyle: FontStyle.italic,
  ),
  'quote': TextStyle(
    color: const PdfColor.fromInt(0xffaeaeae),
    fontStyle: FontStyle.italic,
  ),
  'keyword': const TextStyle(color: PdfColor.fromInt(0xffe28964)),
  'selector-tag': const TextStyle(color: PdfColor.fromInt(0xffe28964)),
  'type': const TextStyle(color: PdfColor.fromInt(0xffe28964)),
  'string': const TextStyle(color: PdfColor.fromInt(0xff65b042)),
  'subst': const TextStyle(color: PdfColor.fromInt(0xffdaefa3)),
  'regexp': const TextStyle(color: PdfColor.fromInt(0xffe9c062)),
  'link': const TextStyle(color: PdfColor.fromInt(0xffe9c062)),
  'title': const TextStyle(color: PdfColor.fromInt(0xff89bdff)),
  'section': const TextStyle(color: PdfColor.fromInt(0xff89bdff)),
  'tag': const TextStyle(color: PdfColor.fromInt(0xff89bdff)),
  'name': const TextStyle(color: PdfColor.fromInt(0xff89bdff)),
  'symbol': const TextStyle(color: PdfColor.fromInt(0xff3387cc)),
  'bullet': const TextStyle(color: PdfColor.fromInt(0xff3387cc)),
  'number': const TextStyle(color: PdfColor.fromInt(0xff3387cc)),
  'params': const TextStyle(color: PdfColor.fromInt(0xff3e87e3)),
  'variable': const TextStyle(color: PdfColor.fromInt(0xff3e87e3)),
  'template-variable': const TextStyle(color: PdfColor.fromInt(0xff3e87e3)),
  'attribute': const TextStyle(color: PdfColor.fromInt(0xffcda869)),
  'meta': const TextStyle(color: PdfColor.fromInt(0xff8996a8)),
  'formula': TextStyle(
    background: const BoxDecoration(
      color: PdfColor.fromInt(0xff0e2231),
    ),
    color: const PdfColor.fromInt(0xfff8f8f8),
    fontStyle: FontStyle.italic,
  ),
  'addition': const TextStyle(
    background: BoxDecoration(
      color: PdfColor.fromInt(0xff253b22),
    ),
    color: PdfColor.fromInt(0xfff8f8f8),
  ),
  'deletion': const TextStyle(
    background: BoxDecoration(
      color: PdfColor.fromInt(0xff420e09),
    ),
    color: PdfColor.fromInt(0xfff8f8f8),
  ),
  'selector-class': const TextStyle(color: PdfColor.fromInt(0xff9b703f)),
  'selector-id': const TextStyle(color: PdfColor.fromInt(0xff8b98ab)),
  'emphasis': TextStyle(fontStyle: FontStyle.italic),
  'strong': TextStyle(fontWeight: FontWeight.bold),
};

Map<String, TextStyle> createCustomHighlightTheme({required TextStyle Function(String typeVar) styleBuilder, Map<String, TextStyle>? alternativeTheme}) {
  if(alternativeTheme != null && alternativeTheme.isNotEmpty) return alternativeTheme;
  return <String, TextStyle>{
  'root': styleBuilder('root'),
  'comment': styleBuilder('comment'),
  'quote': styleBuilder('quote'),
  'keyword': styleBuilder('keyword'),
  'selector-tag': styleBuilder('selector-tag'),
  'type': styleBuilder('type'),
  'string': styleBuilder('string'),
  'subst': styleBuilder('subst'),
  'regexp': styleBuilder('regexp'),
  'link': styleBuilder('link'),
  'title': styleBuilder('title'),
  'section': styleBuilder('section'),
  'tag': styleBuilder('tag'),
  'name': styleBuilder('name'),
  'symbol': styleBuilder('symbol'),
  'bullet': styleBuilder('bullet'),
  'number': styleBuilder('number'),
  'params': styleBuilder('params'),
  'variable': styleBuilder('variable'),
  'template-variable': styleBuilder('template-variable'),
  'attribute': styleBuilder('attribute'),
  'meta': styleBuilder('meta'),
  'formula': styleBuilder('formula'),
  'addition': styleBuilder('addition'),
  'deletion': styleBuilder('deletion'),
  'selector-class': styleBuilder('selector-class'),
  'selector-id': styleBuilder('selector-id'),
  'emphasis': styleBuilder('emphasis'),
  'strong': styleBuilder('strong'),
  };
}
