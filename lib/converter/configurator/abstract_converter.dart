import 'package:flutter_quill_to_pdf/packages/html2md/lib/html2md.dart' as hm2;
import 'package:flutter_quill_to_pdf/utils/markdown_rules.dart';

///Converter is a parent that's [provides the essential rules]
///for generate and create a document pdf file for that project
sealed class Converter<Doc, Type> {
  ///Determine the markdown rules to transform html
  late final List<hm2.Rule> _rules;

  ///Main body to the converter
  late final Doc _document;

  Converter({
    required Doc document,
  }) {
    _document = document;
    _rules = MarkdownRules.allRules;
  }
  List<hm2.Rule> get rules => _rules;
  Doc get document => _document;

  ///This fuction let us add new rules as we wants. We can clear the default rules, or just write our rules.
  ///You can check [html2md] documentation about here: https://github.com/jarontai/html2md
  void customRules(List<hm2.Rule> customRules,
      {bool clearDefaultRules = false}) {
    if (clearDefaultRules) _rules.clear();
    _rules.addAll(customRules);
  }

  ///This functions generates the [document]
  Future<Type> generateDoc();
}

///Use this class if you want to create your own PDF configurator implementation instead Converter
abstract class ConverterConfigurator<D, T> extends Converter<D, T> {
  ConverterConfigurator({required super.document});
}
