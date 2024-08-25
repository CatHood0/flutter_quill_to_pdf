import 'package:example/example_editor/buttons/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_to_pdf/core/constant/constants.dart';

import '../buttons/line_height_button.dart';
import 'utils/quill_toolbar_arrows_indicators.dart';
import 'utils/quill_toolbar_selected_alignmet_buttons.dart';

class CustomQuillToolbar extends StatelessWidget {
  final QuillController controller;
  final String defaultFontFamily;
  final double toolbarSize;
  const CustomQuillToolbar({
    super.key,
    required this.controller,
    this.defaultFontFamily = Constant.DEFAULT_FONT_FAMILY,
    this.toolbarSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    final QuillSimpleToolbarConfigurations configurations =
        toolbarConfigurations();
    List<Widget> childrenBuilder(BuildContext context) {
      final QuillSimpleToolbarConfigurations toolbarConfigurations =
          context.requireQuillSimpleToolbarConfigurations;
      final List<EmbedButtonBuilder>? theEmbedButtons =
          configurations.embedButtons;
      final double? globalIconSize =
          toolbarConfigurations.buttonOptions.base.iconSize;

      return <Widget>[
        QuillToolbarFontFamilyButton(
          options: toolbarConfigurations.buttonOptions.fontFamily
              .copyWith(initialValue: defaultFontFamily),
          controller: controller,
        ),
        QuillToolbarFontSizeButton(
          options: toolbarConfigurations.buttonOptions.fontSize.copyWith(
            initialValue: 'Normal',
            rawItemsMap: fontSizes,
          ),
          controller: controller,
        ),
        QuillLineHeightButton(
          options:
              const QuillLineHeightButtonOptions(defaultDisplayText: "1.0"),
          controller: controller,
        ),
        QuillToolbarToggleStyleButton(
          attribute: Attribute.bold,
          options: toolbarConfigurations.buttonOptions.bold,
          controller: controller,
        ),
        QuillToolbarToggleStyleButton(
          attribute: Attribute.italic,
          options: toolbarConfigurations.buttonOptions.italic,
          controller: controller,
        ),
        QuillToolbarToggleStyleButton(
          attribute: Attribute.underline,
          options: toolbarConfigurations.buttonOptions.underLine,
          controller: controller,
        ),
        QuillToolbarToggleStyleButton(
          attribute: Attribute.strikeThrough,
          options: toolbarConfigurations.buttonOptions.strikeThrough,
          controller: controller,
        ),
        if (theEmbedButtons != null)
          for (final EmbedButtonBuilder builder in theEmbedButtons)
            builder(
                controller,
                globalIconSize ?? kDefaultIconSize,
                context.quillToolbarBaseButtonOptions?.iconTheme,
                configurations.dialogTheme),
        QuillToolbarSelectAlignmentButtons(
          controller: controller,
          options: toolbarConfigurations.buttonOptions.selectAlignmentButtons
              .copyWith(
            showLeftAlignment: configurations.showLeftAlignment,
            showCenterAlignment: configurations.showCenterAlignment,
            showRightAlignment: configurations.showRightAlignment,
            showJustifyAlignment: configurations.showJustifyAlignment,
          ),
        ),
        QuillToolbarSelectHeaderStyleButtons(
          controller: controller,
          options: toolbarConfigurations.buttonOptions.selectHeaderStyleButtons,
        ),
        QuillToolbarToggleStyleButton(
          attribute: Attribute.ol,
          options: toolbarConfigurations.buttonOptions.listNumbers,
          controller: controller,
        ),
        QuillToolbarToggleStyleButton(
          attribute: Attribute.ul,
          options: toolbarConfigurations.buttonOptions.listBullets,
          controller: controller,
        ),
        QuillToolbarToggleStyleButton(
            attribute: Attribute.blockQuote, controller: controller),
        QuillToolbarToggleStyleButton(
            controller: controller, attribute: Attribute.codeBlock),
        QuillToolbarToggleCheckListButton(
          options: toolbarConfigurations.buttonOptions.toggleCheckList,
          controller: controller,
        ),
        QuillToolbarIndentButton(
          controller: controller,
          isIncrease: true,
          options: toolbarConfigurations.buttonOptions.indentIncrease,
        ),
        QuillToolbarIndentButton(
          controller: controller,
          isIncrease: false,
          options: toolbarConfigurations.buttonOptions.indentDecrease,
        ),
        toolbarConfigurations.linkStyleType.isOriginal
            ? QuillToolbarLinkStyleButton(
                controller: controller,
                options: toolbarConfigurations.buttonOptions.linkStyle,
              )
            : QuillToolbarLinkStyleButton2(
                controller: controller,
                options: toolbarConfigurations.buttonOptions.linkStyle2,
              ),
        QuillToolbarSearchButton(
          controller: controller,
          options: toolbarConfigurations.buttonOptions.search,
        ),
        QuillToolbarColorButton(
          controller: controller,
          isBackground: false,
          options: toolbarConfigurations.buttonOptions.color,
        ),
        QuillToolbarColorButton(
          options: toolbarConfigurations.buttonOptions.backgroundColor,
          controller: controller,
          isBackground: true,
        ),
        QuillToolbarClearFormatButton(
          controller: controller,
          options: toolbarConfigurations.buttonOptions.clearFormat,
        ),
      ];
    }

    return QuillSimpleToolbarProvider(
      toolbarConfigurations: configurations,
      child: QuillToolbar(
        configurations: QuillToolbarConfigurations(
            buttonOptions: configurations.buttonOptions),
        child: Builder(
          builder: (BuildContext context) {
            if (configurations.multiRowsDisplay) {
              return Wrap(
                direction: configurations.axis,
                alignment: configurations.toolbarIconAlignment,
                crossAxisAlignment: configurations.toolbarIconCrossAlignment,
                runSpacing: configurations.toolbarRunSpacing,
                spacing: configurations.toolbarSectionSpacing,
                children: childrenBuilder(context),
              );
            }
            return Container(
              decoration: configurations.decoration ??
                  BoxDecoration(
                    color:
                        configurations.color ?? Theme.of(context).canvasColor,
                  ),
              constraints: BoxConstraints.tightFor(
                height: configurations.axis == Axis.horizontal
                    ? configurations.toolbarSize
                    : null,
                width: configurations.axis == Axis.vertical
                    ? configurations.toolbarSize
                    : null,
              ),
              child: QuillToolbarArrowIndicatedButtonList(
                axis: configurations.axis,
                buttons: childrenBuilder(context),
              ),
            );
          },
        ),
      ),
    );
  }

  QuillSimpleToolbarConfigurations toolbarConfigurations() {
    return QuillSimpleToolbarConfigurations(
      axis: Axis.horizontal,
      headerStyleType: HeaderStyleType.buttons,
      toolbarSize: toolbarSize,
      fontFamilyValues: fontFamilies,
      multiRowsDisplay: false,
      buttonOptions: const QuillSimpleToolbarButtonOptions(
        codeBlock: QuillToolbarToggleStyleButtonOptions(),
        fontFamily: QuillToolbarFontFamilyButtonOptions(
          renderFontFamilies: true,
        ),
        selectAlignmentButtons: QuillToolbarSelectAlignmentButtonOptions(
          showCenterAlignment: true,
          showJustifyAlignment: true,
          showLeftAlignment: true,
          showRightAlignment: true,
          iconsData: QuillSelectAlignmentValues<IconData>(
            leftAlignment: Icons.format_align_left_outlined,
            centerAlignment: Icons.format_align_center_outlined,
            rightAlignment: Icons.format_align_right_outlined,
            justifyAlignment: Icons.format_align_justify_outlined,
          ),
        ),
      ),
      sharedConfigurations: const QuillSharedConfigurations(
        locale: Locale('en'),
      ),
    );
  }
}
