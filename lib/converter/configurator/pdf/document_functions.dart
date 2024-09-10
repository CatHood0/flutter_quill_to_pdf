import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:pdf/widgets.dart' as pw;

///Basic functions to create documents and generates widgets
mixin DocumentFunctions<D extends Delta, T, RW extends Object> {
  ///This function create a (valid) file [transforming]
  ///[delta format to markdown] and detecting all [markdown syntax] for
  ///put the attributes to the paragraph
  ///
  ///[Use the parameter for print a just one document] and not all the project
  Future<List<List<pw.Widget>>> generatePages({required List<D> documents});

  ///This function generate [widgets] to create a book with custom views of the content
  Future<RW> blockGenerators(T lines);
}
