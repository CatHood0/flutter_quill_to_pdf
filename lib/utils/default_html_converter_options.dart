import 'package:flutter_quill_to_pdf/core/constant/constants.dart';
import 'package:flutter_quill_to_pdf/core/extensions/string_extension.dart';
import 'package:flutter_quill_to_pdf/utils/typedefs.dart';
import '../packages/vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

///Default Delta to HTML converter used by this library
class HTMLConverterOptions {
  HTMLConverterOptions._();

  static ConverterOptions options({
    bool multiLineBlockquote = true,
    bool multiLineHeader = false,
    bool multiLineCodeblock = true,
    bool multiLineParagraph = false,
    bool multiLineCustomBlock = true,
    String docLineSpacingTag = 'line-height',
    CustomCssStylesFn? customCssStyles,
    OpAttributeSanitizerOptions? satitizerOptions,
  }) =>
      ConverterOptions(
          orderedListTag: 'ol',
          bulletListTag: 'ul',
          multiLineBlockquote: multiLineBlockquote,
          multiLineHeader: multiLineHeader,
          multiLineCodeblock: multiLineCodeblock,
          multiLineParagraph: multiLineParagraph,
          multiLineCustomBlock: multiLineCustomBlock,
          sanitizerOptions: satitizerOptions ??
              OpAttributeSanitizerOptions(allow8DigitHexColors: true),
          converterOptions: OpConverterOptions(
            customCssStyles: customCssStyles ??
                (DeltaInsertOp op) {
                  ///Add custom attributes if are available to the image block (height, margin, width, alignment)
                  if (op.isImage()) {
                    final OpAttributes attributes = op.attributes;
                    final String? attrs = attributes['style'];
                    // Fit images within restricted parent width.
                    return <String>[
                      'max-width: 100%',
                      'object-fit: ${Constant.DEFAULT_OBJECT_FIT}',
                      (attrs ?? '')
                    ];
                  }
                  return null;
                },
            inlineStyles: InlineStyles(<String, InlineStyleType>{
              'font': InlineStyleType(
                  fn: (String value, _) =>
                      defaultInlineFonts[value] ?? 'font-family: $value'),
              'size': InlineStyleType(fn: (String value, _) {
                //default sizes
                if (value.equals('small')) return 'font-size: 8px';
                if (value.equals('large')) return 'font-size: 15.5px';
                if (value.equals('huge')) return 'font-size: 19.5px';
                //accept any int or double type size
                return 'font-size: ${value}px';
              }),
              'indent': InlineStyleType(fn: (String value, DeltaInsertOp op) {
                final double indentSize =
                    (double.tryParse(value) ?? double.nan) * 3;
                final String side =
                    op.attributes['direction'] == 'rtl' ? 'right' : 'left';
                return 'padding-$side:${indentSize}px';
              }),
              'list': InlineStyleType(map: <String, String>{
                'checked': "list-style-type:'\\2611';padding-left: 0.5em;",
                'unchecked': "list-style-type:'\\2610';padding-left: 0.5em;",
              }),
            }),
            inlineStylesFlag: true,
          ));
}
