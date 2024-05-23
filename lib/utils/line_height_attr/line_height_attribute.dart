import 'package:flutter_quill/flutter_quill.dart';

const String lineHeightKey = 'line-height';
const AttributeScope lineHeightScope = AttributeScope.block;

class LineHeightAttribute extends Attribute<String?> {
  const LineHeightAttribute({String? value = "1.0"})
      : super(
          lineHeightKey,
          lineHeightScope,
          value,
        );
}
