import 'dart:convert';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_quill_to_pdf/converter/configurator/abstract_converter.dart';
import 'package:flutter_quill_to_pdf/converter/delta_processor/delta_attributes_options.dart';
import 'package:flutter_quill_to_pdf/converter/delta_processor/delta_processor.dart';
import 'package:flutter_quill_to_pdf/converter/service/pdf_service.dart';
import 'package:flutter_quill_to_pdf/domain/entities/custom_converter.dart';
import 'package:flutter_quill_to_pdf/packages/vsc_quill_delta_to_html/src/quill_delta_to_html_converter.dart';
import 'package:flutter_quill_to_pdf/quill_to_pdf.dart' as qpdf;

class PDFConverter {
  //Is the main body of the PDF document
  final Delta document;

  ///This [delta] is used before the main content
  final Delta? frontMatterDelta;

  ///This [delta] is used after the main content
  final Delta? backMatterDelta;
  final qpdf.PDFConverterParams params;

  ///This allow detect and create custom widgets
  final List<CustomConverter> customConverters;

  ///A simple [request] font when converter detect a font that don't is default
  final Future<pw.Font> Function(String) onRequestFont;

  ///A simple [request] font when converter detect a font that don't is default
  final Future<pw.Font> Function(String) onRequestBoldFont;

  ///A simple [request] font when converter detect a font that don't is default
  final Future<pw.Font> Function(String) onRequestItalicFont;

  ///A simple [request] font when converter detect a font that don't is default
  final Future<pw.Font> Function(String) onRequestBoldItalicFont;

  ///If this [request] is null, list is [empty] or is list [null], will be used another by default
  final Future<List<pw.Font>?> Function(String)? onRequestFallbackFont;
  late final List<pw.Font> globalFontsFallbacks;
  final ConverterOptions? convertOptions;
  PDFConverter({
    required this.params,
    required this.document,
    required this.frontMatterDelta,
    required this.backMatterDelta,
    required this.customConverters,
    required this.onRequestBoldFont,
    required this.onRequestBoldItalicFont,
    required this.onRequestFallbackFont,
    required this.onRequestFont,
    required this.onRequestItalicFont,
    required List<pw.Font> fallbacks,
    this.convertOptions,
  })  : assert(params.height > 70, 'Page size height isn\'t valid'),
        assert(params.width > 70, 'Page size width isn\'t valid'),
        assert(params.marginBottom >= 0.0, 'Margin to bottom with value ${params.marginBottom}'),
        assert(params.marginLeft >= 0.0, 'Margin to left with value ${params.marginLeft}'),
        assert(params.marginRight >= 0.0, 'Margin to right with value ${params.marginRight}'),
        assert(params.marginTop >= 0.0, 'Margin to tp with value ${params.marginTop}') {
    globalFontsFallbacks = <pw.Font>[
      ...fallbacks,
      pw.Font.helvetica(),
      pw.Font.helveticaBold(),
      pw.Font.helveticaOblique(),
      pw.Font.symbol(),
      pw.Font.times(),
      pw.Font.timesBold(),
      pw.Font.timesItalic(),
      pw.Font.timesBoldItalic(),
      pw.Font.courier(),
      pw.Font.courierBold(),
      pw.Font.courierOblique(),
      pw.Font.courierBoldOblique(),
    ];
  }

  Future<pw.Document?> createDocument({
    DeltaAttributesOptions? deltaOptionalAttr,
    bool overrideAttributesPassedByUser = false,
    bool shouldProcessDeltas = true,
  }) async {
    final Converter<Delta, pw.Document> converter = PdfService(
      params: params,
      fonts: globalFontsFallbacks,
      onRequestBoldFont: onRequestBoldFont,
      onRequestBothFont: onRequestBoldItalicFont,
      onRequestFallbacks: onRequestFallbackFont,
      onRequestFont: onRequestFont,
      backM: !shouldProcessDeltas
          ? backMatterDelta
          : processDelta(backMatterDelta, deltaOptionalAttr ?? DeltaAttributesOptions.common(), overrideAttributesPassedByUser),
      converterOptions: convertOptions,
      frontM: !shouldProcessDeltas
          ? frontMatterDelta
          : processDelta(frontMatterDelta, deltaOptionalAttr ?? DeltaAttributesOptions.common(), overrideAttributesPassedByUser),
      onRequestItalicFont: onRequestItalicFont,
      customConverters: customConverters,
      document: !shouldProcessDeltas
          ? document
          : processDelta(document, deltaOptionalAttr ?? DeltaAttributesOptions.common(), overrideAttributesPassedByUser)!,
    );
    return await converter.generateDoc();
  }

  static Delta? processDelta(Delta? delta, DeltaAttributesOptions options, bool overrideAttributesPassedByUser) {
    if (delta == null) return null;
    if (delta.isEmpty) return delta;
    final String json =
        applyAttributesIfNeeded(json: jsonEncode(delta.toJson()), attr: options, overrideAttributes: overrideAttributesPassedByUser)
            .fixCommonErrorInsertsInRawDelta
            .withBrackets;
    return Delta.fromJson(jsonDecode(json));
  }
}
