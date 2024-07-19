///Converter is a parent that's [provides the essential rules]
///for generate and create a document pdf file for that project
sealed class Converter<Doc, Type> {
  ///Main body to the converter
  late final Doc _document;

  Converter({
    required Doc document,
  }) {
    _document = document;
  }
  Doc get document => _document;

  ///This functions generates the [document]
  Future<Type> generateDoc();
}

///Use this class if you want to create your own PDF configurator implementation instead Converter
abstract class ConverterConfigurator<D, T> extends Converter<D, T> {
  ConverterConfigurator({required super.document});
}
