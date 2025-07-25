import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:example/example_editor/editor/custom_quill_editor.dart';
import 'package:example/example_editor/utils/constants.dart';
import 'package:example/fonts_loader/fonts_loader.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
// ignore: implementation_imports
import 'package:flutter_quill_to_pdf/src/constants.dart';
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

/// This is the default loader for the fonts created to the example
/// see this class [here](https://github.com/CatHood0/flutter_quill_to_pdf/blob/master/example/lib/fonts_loader/fonts_loader.dart)
final FontsLoader loader = FontsLoader();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loader.loadFonts();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter quill to pdf Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 108, 189, 255)),
          useMaterial3: true,
          fontFamily: 'Noto Sans'),
      localizationsDelegates: [
        FlutterQuillLocalizations.delegate,
      ],
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool firstEntry = false;
  final PDFPageFormat params = PDFPageFormat.a4;
  final QuillController _quillController = QuillController(
      document: Document(),
      selection: const TextSelection.collapsed(offset: 0));
  final FocusNode _editorNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  final ValueNotifier<bool> _shouldShowToolbar = ValueNotifier<bool>(false);
  Delta? oldDelta;

  @override
  void dispose() {
    _quillController.dispose();
    _editorNode.dispose();
    _scrollController.dispose();
    _shouldShowToolbar.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 107, 188, 255),
        actions: [
          IconButton(
              onPressed: () async {
                final bool isAndroid = Platform.isAndroid;
                // on android devices is not available getSaveLocation
                final Object? result = isAndroid
                    ? await getDirectoryPath(
                        confirmButtonText: 'Select directory')
                    : await getSaveLocation(
                        suggestedName: 'document_pdf',
                        acceptedTypeGroups: [
                          XTypeGroup(
                            label: 'Pdf',
                            extensions: ['pdf'],
                            mimeTypes: ['application/pdf'],
                            uniformTypeIdentifiers: ['com.adobe.pdf'],
                          ),
                        ],
                      );
                if (result == null) {
                  return;
                }
                final File file = isAndroid
                    ? File(result as String)
                    : File((result as FileSaveLocation).path);
                PDFConverter pdfConverter = PDFConverter(
                  backMatterDelta: null,
                  frontMatterDelta: null,
                  isWeb: kIsWeb,
                  onDetectImageUrl: kIsWeb ? _fetchBlobAsBytes : null,
                  paintStrikethoughStyleOnCheckedElements: true,
                  checkboxDecorator: CheckboxDecorator.base(
                    strikethroughColor: "#AAAAAA",
                    italicOnStrikethrough: true,
                  ),
                  document: _quillController.document.toDelta(),
                  fallbacks: [...loader.allFonts()],
                  onRequestFontFamily: (FontFamilyRequest familyRequest) {
                    final normalFont =
                        loader.getFontByName(fontFamily: familyRequest.family);
                    final boldFont = loader.getFontByName(
                      fontFamily: familyRequest.family,
                      bold: familyRequest.isBold,
                    );
                    final italicFont = loader.getFontByName(
                      fontFamily: familyRequest.family,
                      italic: familyRequest.isItalic,
                    );
                    final boldItalicFont = loader.getFontByName(
                      fontFamily: familyRequest.family,
                      bold: familyRequest.isBold,
                      italic: familyRequest.isItalic,
                    );
                    return FontFamilyResponse(
                      fontNormalV: normalFont,
                      boldFontV: boldFont,
                      italicFontV: italicFont,
                      boldItalicFontV: boldItalicFont,
                      fallbacks: [
                        normalFont,
                        italicFont,
                        boldItalicFont,
                      ],
                    );
                  },
                  pageFormat: params,
                );
                final document = await pdfConverter.createDocument();
                if (document == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text(
                            'The file cannot be generated by an unknown error')),
                  );
                  _editorNode.unfocus();
                  _shouldShowToolbar.value = false;
                  return;
                }
                final String name =
                    'document_demo_flutter_quill_to_pdf${DateTime.now().millisecondsSinceEpoch.toString()}.pdf';
                final XFile textFile = XFile.fromData(
                  await document.save(),
                  mimeType: isAndroid
                      ? 'application/pdf'
                      : Platform.isMacOS || Platform.isIOS
                          ? (result as FileSaveLocation)
                                  .activeFilter
                                  ?.uniformTypeIdentifiers
                                  ?.single ??
                              'com.adobe.pdf'
                          : (result as FileSaveLocation)
                                  .activeFilter
                                  ?.mimeTypes
                                  ?.single ??
                              'application/pdf',
                  name: name,
                );
                await textFile.saveTo(isAndroid
                    ? join(result as String, name)
                    : (result as FileSaveLocation).path);
                _editorNode.unfocus();
                _shouldShowToolbar.value = false;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Generated document at path: ${file.path}')),
                );
              },
              icon: const Icon(
                Icons.print,
                color: Colors.white,
              )),
        ],
        centerTitle: true,
        title: const Text(
          'PDF Demo',
          style: TextStyle(
              fontFamily: 'Noto Sans',
              fontSize: 24.5,
              fontWeight: FontWeight.w900,
              color: Colors.white),
        ),
      ),
      body: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: <Widget>[
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.only(top: 0),
              child: Scrollbar(
                controller: _scrollController,
                notificationPredicate: (ScrollNotification notification) {
                  if (mounted && firstEntry) {
                    firstEntry =
                        false; //avoid issue with column (Ln225,Col49) that mnakes false scroll
                    setState(() {});
                  }
                  return notification.depth == 0;
                },
                interactive: true,
                radius: const Radius.circular(10),
                child: Column(
                  children: <Widget>[
                    if (Platform.isMacOS ||
                        Platform.isWindows ||
                        Platform.isLinux)
                      QuillSimpleToolbar(
                        controller: _quillController,
                        config: QuillSimpleToolbarConfig(
                          toolbarSize: 55,
                          linkStyleType: LinkStyleType.original,
                          headerStyleType: HeaderStyleType.buttons,
                          showAlignmentButtons: true,
                          multiRowsDisplay: true,
                          showLineHeightButton: true,
                          showDirection: true,
                          buttonOptions: const QuillSimpleToolbarButtonOptions(
                            selectLineHeightStyleDropdownButton:
                                QuillToolbarSelectLineHeightStyleDropdownButtonOptions(),
                            fontSize: QuillToolbarFontSizeButtonOptions(
                              items: fontSizes,
                              initialValue: 'Normal',
                              defaultDisplayText: 'Normal',
                            ),
                            fontFamily: QuillToolbarFontFamilyButtonOptions(
                              items: fontFamilies,
                              defaultDisplayText: 'Arial',
                              initialValue: 'Arial',
                            ),
                          ),
                          embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                        ),
                      ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 0),
                        child: CustomQuillEditor(
                          node: _editorNode,
                          controller: _quillController,
                          defaultFontFamily: Constant.DEFAULT_FONT_FAMILY,
                          scrollController: _scrollController,
                          onChange: (Document document) {
                            if (oldDelta == document.toDelta()) return;
                            oldDelta = document.toDelta();
                            if (mounted) {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                if (!_shouldShowToolbar.value) {
                                  _shouldShowToolbar.value = true;
                                }
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    if (Platform.isIOS ||
                        Platform.isAndroid ||
                        Platform.isFuchsia)
                      ValueListenableBuilder<bool>(
                        valueListenable: _shouldShowToolbar,
                        builder: (BuildContext _, bool value, __) => Visibility(
                          visible: value,
                          child: QuillSimpleToolbar(
                            controller: _quillController,
                            config: QuillSimpleToolbarConfig(
                              multiRowsDisplay: false,
                              toolbarSize: 55,
                              linkStyleType: LinkStyleType.original,
                              headerStyleType: HeaderStyleType.buttons,
                              buttonOptions:
                                  const QuillSimpleToolbarButtonOptions(
                                fontSize: QuillToolbarFontSizeButtonOptions(
                                  items: fontSizes,
                                  initialValue: 'Normal',
                                  defaultDisplayText: 'Normal',
                                ),
                                fontFamily: QuillToolbarFontFamilyButtonOptions(
                                  items: fontFamilies,
                                  defaultDisplayText: 'Arial',
                                  initialValue: 'Arial',
                                ),
                              ),
                              embedButtons: FlutterQuillEmbeds.toolbarButtons(),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<Uint8List?> _fetchBlobAsBytes(String blobUrl) async {
    final http.Response response = await http.get(Uri.parse(blobUrl));
    if (response.statusCode == 200) return response.bodyBytes;
    return null;
  }
}

class LoadingWithAnimtedWidget extends StatelessWidget {
  final String text;
  final double verticalTextPadding;
  final double? heightWidget;
  final double? spaceBetween;
  final double strokeWidth;
  final TextStyle? style;
  final Duration duration;
  final Color? loadingColor;
  final bool infinite;
  const LoadingWithAnimtedWidget({
    super.key,
    required this.text,
    this.loadingColor,
    this.strokeWidth = 7,
    this.spaceBetween,
    this.duration = const Duration(milliseconds: 260),
    this.infinite = false,
    this.style,
    this.heightWidget,
    this.verticalTextPadding = 30,
  });

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return PopScope(
      canPop: false,
      child: Dialog(
        surfaceTintColor: Colors.transparent,
        backgroundColor: Colors.transparent,
        child: SizedBox(
          height: heightWidget ?? size.height * 0.45,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(
                  strokeWidth: strokeWidth,
                  color: loadingColor,
                ),
                SizedBox(height: spaceBetween ?? 10),
                AnimatedWavyText(
                  infinite: infinite,
                  duration: duration,
                  text: text,
                  style: style ??
                      const TextStyle(
                          color: Color.fromARGB(255, 255, 255, 255)),
                  verticalPadding: verticalTextPadding,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedWavyText extends StatelessWidget {
  final double verticalPadding;
  final Key? animatedKey;
  final String text;
  final bool infinite;
  final int totalRepeatCount;
  final Duration duration;
  final TextStyle? style;
  const AnimatedWavyText({
    super.key,
    this.animatedKey,
    this.verticalPadding = 50,
    required this.text,
    this.infinite = false,
    this.totalRepeatCount = 4,
    this.duration = const Duration(milliseconds: 260),
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: verticalPadding),
      child: AnimatedTextKit(
        key: animatedKey,
        repeatForever: infinite,
        animatedTexts: <AnimatedText>[
          WavyAnimatedText(
            text,
            speed: duration,
            textStyle: style ??
                const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
        displayFullTextOnTap: true,
        totalRepeatCount: totalRepeatCount < 1 ? 1 : totalRepeatCount,
      ),
    );
  }
}
