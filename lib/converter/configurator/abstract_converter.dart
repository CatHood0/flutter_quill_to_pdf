import 'package:quill_to_pdf/packages/html2md/lib/html2md.dart' as hm2;
import 'package:quill_to_pdf/utils/makdown_rules_custom.dart';

///Converter is a parent that's [provides the essential rules]
///for generate and create the [book] file for that project
sealed class Converter<Doc, Type> {
  late final List<hm2.Rule> _rules;
  late final Doc _document;

  Converter({
    required Doc document,
  }) {
    _document = document;
    _rules = MarkdownRules.allRules;
  }
  List<hm2.Rule> get rules => _rules;
  Doc get document => _document;

  void customRules(List<hm2.Rule> customRules, {bool clearDefaultRules = false}) {
    if (clearDefaultRules) _rules.clear();
    _rules.addAll(customRules);
  }

  ///This functions creates the [type document] selected for us file using the widgets that are provides by [generatePages] functions
  Future<Type> generateDoc();
}

abstract class ConverterConfigurator<D, T> extends Converter<D, T> {
  ConverterConfigurator({required super.document});
}
