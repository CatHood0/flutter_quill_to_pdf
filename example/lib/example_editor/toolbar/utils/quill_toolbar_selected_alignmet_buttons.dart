// ignore_for_file: always_specify_types

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class QuillToolbarSelectAlignmentButtons extends StatelessWidget {
  const QuillToolbarSelectAlignmentButtons({
    required this.controller,
    this.options = const QuillToolbarSelectAlignmentButtonOptions(),
    super.key,
  });

  final QuillController controller;
  final QuillToolbarSelectAlignmentButtonOptions options;

  List<Attribute> get _attrbuites {
    return options.attributes ??
        [
          if (options.showLeftAlignment) Attribute.leftAlignment,
          if (options.showCenterAlignment) Attribute.centerAlignment,
          if (options.showRightAlignment) Attribute.rightAlignment,
          if (options.showJustifyAlignment) Attribute.justifyAlignment,
        ];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: _attrbuites
          .map((e) => QuillToolbarToggleStyleButton(
                controller: controller,
                attribute: e,
                options: QuillToolbarToggleStyleButtonOptions(
                  iconData: options.iconData,
                  iconSize: options.iconSize,
                  iconButtonFactor: options.iconButtonFactor,
                  afterButtonPressed: options.afterButtonPressed,
                  iconTheme: options.iconTheme,
                  tooltip: options.tooltip,
                ),
              ))
          .toList(),
    );
  }
}
