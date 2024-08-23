import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
// import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:flutter_quill_to_pdf/core/constant/constants.dart';
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart';

class CustomQuillEditor extends HookWidget {
  final void Function(Document document) onChange;
  final QuillController controller;
  final FocusNode node;
  final ScrollController scrollController;
  final String? defaultFontFamily;
  const CustomQuillEditor({
    super.key,
    required this.onChange,
    required this.controller,
    required this.node,
    required this.scrollController,
    this.defaultFontFamily = Constant.DEFAULT_FONT_FAMILY,
  });

  @override
  Widget build(BuildContext context) {
    useEffect(() {
      controller.addListener(() => onChange(controller.document));
      return () =>
          controller.removeListener(() => onChange(controller.document));
    }, <Object?>[controller.document]);
    return QuillEditor.basic(
      focusNode: node,
      scrollController: scrollController,
      configurations: QuillEditorConfigurations(
        embedBuilders: FlutterQuillEmbeds.editorBuilders(),
        controller: controller,
        textCapitalization: TextCapitalization.sentences,
        detectWordBoundary: true,
        placeholder: 'Write something',
        magnifierConfiguration: TextMagnifier.adaptiveMagnifierConfiguration,
        padding: const EdgeInsets.only(bottom: 20),
        autoFocus: false,
        enableSelectionToolbar: true,
        enableInteractiveSelection: true,
        textSelectionControls: Platform.isAndroid
            ? MaterialTextSelectionControls()
            : DesktopTextSelectionControls(),
        customStyleBuilder: (Attribute<dynamic> attribute) {
          if (attribute.key.equals('line-height')) {
            return TextStyle(
              height: attribute.value,
            );
          }
          if (attribute.key.equals('bold')) {
            return TextStyle(
              fontWeight: attribute.value ? FontWeight.bold : null,
            );
          }
          if (attribute.key.equals('italic')) {
            return TextStyle(
              fontStyle: attribute.value ? FontStyle.italic : null,
            );
          }
          if (attribute.key.equals('font')) {
            return TextStyle(
              fontFamily: attribute.value,
            );
          }
          if (attribute.key.equals('size')) {
            return TextStyle(
              fontSize: resolveSize(attribute.value.toString()),
            );
          }
          if (attribute.key.equals('header')) {
            return TextStyle(
              fontSize:
                  (attribute.value as num).resolveHeaderLevel().toDouble(),
              color: Colors.black,
            );
          }
          //default | paragraph style
          return TextStyle(fontFamily: defaultFontFamily, height: 1.0);
        },
        customStyles: DefaultStyles(
          h1: const DefaultTextBlockStyle(TextStyle(), HorizontalSpacing(0, 0),
              VerticalSpacing(10, 1), VerticalSpacing(5, 0), BoxDecoration()),
          h2: const DefaultTextBlockStyle(TextStyle(), HorizontalSpacing(0, 0),
              VerticalSpacing(7, 1), VerticalSpacing(5, 0), BoxDecoration()),
          h3: const DefaultTextBlockStyle(TextStyle(), HorizontalSpacing(0, 0),
              VerticalSpacing(4, 1), VerticalSpacing(5, 0), BoxDecoration()),
          indent: DefaultTextBlockStyle(
            TextStyle(
                color: Theme.of(context).textTheme.displayMedium!.color,
                fontSize: 16,
                fontFamily: defaultFontFamily,
                height: 1.15),
            const HorizontalSpacing(0, 0),
            const VerticalSpacing(0, 1),
            const VerticalSpacing(0, 0),
            const BoxDecoration(),
          ),
          lists: DefaultListBlockStyle(
            TextStyle(
                color: Theme.of(context).textTheme.displayMedium!.color,
                fontSize: 16,
                fontFamily: defaultFontFamily,
                height: 1.15),
            const HorizontalSpacing(0, 0),
            const VerticalSpacing(5, 0),
            const VerticalSpacing(0, 0),
            null,
            null,
          ),
          leading: DefaultTextBlockStyle(
            TextStyle(
                fontFamily: defaultFontFamily,
                fontSize: 16,
                height: 1.15,
                decoration: TextDecoration.none),
            const HorizontalSpacing(0, 0),
            const VerticalSpacing(0, 0),
            const VerticalSpacing(0, 0),
            null,
          ),
          code: DefaultTextBlockStyle(
              const TextStyle(
                  fontSize: 11,
                  fontFamily: 'monospace',
                  color: Color.fromARGB(255, 117, 117, 117)),
              const HorizontalSpacing(0, 0),
              const VerticalSpacing(5, 5),
              const VerticalSpacing(5, 5),
              BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: const Color.fromARGB(255, 234, 234, 234))),
          quote: DefaultTextBlockStyle(
            TextStyle(
                fontSize: 15,
                height: 1.15,
                fontFamily: defaultFontFamily,
                color: Colors.grey),
            const HorizontalSpacing(0, 0),
            const VerticalSpacing(0, 1),
            const VerticalSpacing(0, 0),
            const BoxDecoration(
              border: BorderDirectional(
                  start: BorderSide(
                      width: 5, color: Color.fromARGB(201, 84, 224, 255))),
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(15),
                  bottomRight: Radius.circular(15)),
              color: Color.fromARGB(15, 255, 255, 255),
            ),
          ),
          align: DefaultTextBlockStyle(
            TextStyle(
                color: Theme.of(context).textTheme.displayMedium!.color,
                height: 1.15,
                fontSize: 16,
                fontFamily: defaultFontFamily),
            const HorizontalSpacing(0, 0),
            const VerticalSpacing(0, 1),
            const VerticalSpacing(0, 0),
            const BoxDecoration(),
          ),
          paragraph: DefaultTextBlockStyle(
            TextStyle(
                color: Theme.of(context).textTheme.displayMedium!.color,
                height: 1.15,
                fontSize: 16,
                fontFamily: defaultFontFamily),
            const HorizontalSpacing(0, 0),
            const VerticalSpacing(0, 1),
            const VerticalSpacing(0, 0),
            const BoxDecoration(),
          ),
          link: const TextStyle(color: Color.fromARGB(255, 115, 192, 255)),
        ),
        elementOptions: const QuillEditorElementOptions(
            codeBlock:
                QuillEditorCodeBlockElementOptions(enableLineNumbers: true)),
        sharedConfigurations: const QuillSharedConfigurations(
          locale: Locale('en'),
        ),
      ),
    );
  }

  double? resolveSize(String size) {
    return size.equals('small')
        ? 12
        : size.equals('large')
            ? 19.5
            : size.equals('huge')
                ? 22.5
                : double.tryParse(size);
  }
}
