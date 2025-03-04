import 'package:flutter_quill_delta_easy_parser/extensions/helpers/map_helper.dart';
import 'package:flutter_quill_delta_easy_parser/flutter_quill_delta_easy_parser.dart';

const UniversalMergerBuilder _instance = UniversalMergerBuilder._();

class UniversalMergerBuilder extends MergerBuilder {
  const UniversalMergerBuilder._();

  static UniversalMergerBuilder instance() {
    return _instance;
  }

  @override
  List<Paragraph> buildAccumulation(List<Paragraph> paragraphs) {
    final List<Paragraph> result = <Paragraph>[];
    final Set<int> indexsIgnore = <int>{};
    for (int i = 0; i < paragraphs.length; i++) {
      final Paragraph curParagraph = paragraphs.elementAt(i);
      final Paragraph? nextParagraph = paragraphs.elementAtOrNull(i + 1);
      if (indexsIgnore.contains(i)) {
        if (nextParagraph != null) {
          if (canMergeBothParagraphs(
              paragraph: curParagraph, nextParagraph: nextParagraph)) {
            final Paragraph lastParagraph = result.last;
            final Paragraph paragraphResult = Paragraph(
              lines: <Line>[
                ...lastParagraph.lines,
                ...nextParagraph.lines,
              ],
              blockAttributes: curParagraph.blockAttributes,
              type: curParagraph.type,
            );
            result[result.length - 1] = paragraphResult;
            indexsIgnore.add(i + 1);
          }
        }
        continue;
      }
      // check if the current iteration is the last
      if (nextParagraph == null) {
        result.add(curParagraph);
        break;
      }
      if (canMergeBothParagraphs(
          paragraph: curParagraph, nextParagraph: nextParagraph)) {
        final Paragraph paragraphResult = Paragraph(
          lines: <Line>[
            ...curParagraph.lines,
            ...nextParagraph.lines,
          ],
          blockAttributes: curParagraph.blockAttributes,
          type: curParagraph.type,
        );
        result.add(paragraphResult);
        indexsIgnore.add(i + 1);
        continue;
      }
      result.add(curParagraph);
    }
    indexsIgnore.clear();
    return <Paragraph>[...result];
  }

  @override
  bool get enabled => true;

  @override
  bool canMergeBothParagraphs({
    required Paragraph paragraph,
    required Paragraph nextParagraph,
  }) {
    return paragraph.isTextInsert && nextParagraph.isTextInsert ||
        paragraph.isBlock &&
            nextParagraph.isBlock &&
            mapEquality(
              paragraph.blockAttributes,
              nextParagraph.blockAttributes,
            ) ||
        (paragraph.isBlock && nextParagraph.isNewLine ||
                paragraph.isNewLine && nextParagraph.isBlock ||
                paragraph.isNewLine && nextParagraph.isNewLine) &&
            mapEquality(
              paragraph.blockAttributes,
              nextParagraph.blockAttributes,
            );
  }
}
