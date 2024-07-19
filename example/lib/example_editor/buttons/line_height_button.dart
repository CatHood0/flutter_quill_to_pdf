import 'package:example/example_editor/buttons/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/extensions.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/translations.dart';
import 'package:flutter_quill_to_pdf/flutter_quill_to_pdf.dart';

class QuillLineHeightButton
    extends QuillToolbarBaseValueButton<QuillLineHeightButtonOptions, QuillLineHeightButtonExtraOptions> {
  QuillLineHeightButton({
    required super.controller,
    @Deprecated('Please use the default display text from the options') this.defaultDisplayText,
    super.options = const QuillLineHeightButtonOptions(),
    super.key,
  })  : assert(options.rawItems?.isNotEmpty ?? true),
        assert(options.initialValue == null || (options.initialValue?.isNotEmpty ?? true));

  final String? defaultDisplayText;

  @override
  QuillLineHeightButtonState createState() => QuillLineHeightButtonState();
}

class QuillLineHeightButtonState extends QuillToolbarBaseValueButtonState<QuillLineHeightButton,
    QuillLineHeightButtonOptions, QuillLineHeightButtonExtraOptions, String> {
  Size? size;
  final MenuController _menuController = MenuController();

  List<String> get rawItemsMap {
    const List<String> spacings = default_editor_spacing;
    return spacings;
  }

  String get _defaultDisplayText {
    return options.initialValue ??
        widget.options.defaultDisplayText ??
        widget.defaultDisplayText ??
        context.loc.fontSize;
  }

  @override
  String get currentStateValue {
    final Attribute<dynamic>? attribute = controller.getSelectionStyle().attributes[const LineHeightAttribute().key];
    return attribute == null ? _defaultDisplayText : attribute.value ?? _defaultDisplayText;
  }

  @override
  String get defaultTooltip => context.loc.fontSize;

  void _onDropdownButtonPressed() {
    if (_menuController.isOpen) {
      _menuController.close();
    } else {
      _menuController.open();
    }
    afterButtonPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    size ??= MediaQuery.sizeOf(context);
    return MenuAnchor(
      controller: _menuController,
      menuChildren: rawItemsMap.map((String spacing) {
        return MenuItemButton(
          key: ValueKey<String>(spacing),
          onPressed: () {
            final String newValue = spacing;
            final attribute0 = currentValue == spacing
                ? const LineHeightAttribute()
                : LineHeightAttribute(lineHeight: double.tryParse(newValue));
            controller.formatSelection(attribute0);
            setState(() {
              currentValue = newValue;
              options.onSelected?.call(newValue);
            });
          },
          child: SizedBox(
            height: 65,
            child: Row(
              children: [
                const Icon(Icons.format_line_spacing),
                const SizedBox(width: 5),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                          text: 'Spacing: ',
                          style:
                              TextStyle(fontWeight: currentValue.equals(spacing) ? FontWeight.bold : FontWeight.w300)),
                      TextSpan(
                        text: spacing,
                        style: TextStyle(fontWeight: currentValue.equals(spacing) ? FontWeight.bold : FontWeight.w300),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
      child: Builder(
        builder: (BuildContext context) {
          final bool isMaterial3 = Theme.of(context).useMaterial3;
          if (!isMaterial3) {
            return RawMaterialButton(
              onPressed: _onDropdownButtonPressed,
              child: _buildContent(context),
            );
          }
          return QuillToolbarIconButton(
            tooltip: tooltip,
            isSelected: false,
            iconTheme: iconTheme,
            onPressed: _onDropdownButtonPressed,
            icon: _buildContent(context),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final bool hasFinalWidth = options.width != null;
    return Padding(
      padding: options.padding ?? const EdgeInsets.fromLTRB(10, 0, 0, 0),
      child: Row(
        mainAxisSize: !hasFinalWidth ? MainAxisSize.min : MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          UtilityWidgets.maybeWidget(
            enabled: hasFinalWidth,
            wrapper: (Widget child) => Expanded(child: child),
            child: Text(
              currentValue,
              overflow: options.labelOverflow,
              style: options.style ??
                  TextStyle(
                    fontSize: iconSize / 1.15,
                  ),
            ),
          ),
          Icon(
            Icons.arrow_drop_down,
            size: iconSize * iconButtonFactor,
          )
        ],
      ),
    );
  }
}

/// The [T] is the options for the button
/// The [E] is the extra options for the button
abstract class QuillToolbarBaseValueButton<T extends QuillToolbarBaseButtonOptions<T, E>,
    E extends QuillToolbarBaseButtonExtraOptions> extends StatefulWidget {
  const QuillToolbarBaseValueButton({required this.controller, required this.options, super.key});

  final T options;

  final QuillController controller;
}

/// The [W] is the widget that creates this State
/// The [V] is the type of the currentValue
abstract class QuillToolbarBaseValueButtonState<W extends QuillToolbarBaseValueButton<T, E>,
    T extends QuillToolbarBaseButtonOptions<T, E>, E extends QuillToolbarBaseButtonExtraOptions, V> extends State<W> {
  T get options => widget.options;

  QuillController get controller => widget.controller;

  late V currentValue;

  /// Callback to query the widget's state for the value to be assigned to currentState
  V get currentStateValue;

  @override
  void initState() {
    super.initState();
    controller.addListener(didChangeEditingValue);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentValue = currentStateValue;
  }

  void _checkSelectionAttribute() {
    final attr = controller.getSelectionStyle().attributes[const LineHeightAttribute().key];
    if (attr != null) {
      // checkbox tapping causes controller.selection to go to offset 0
      // controller.formatSelection(const LineHeightAttribute(value: null));
      return;
    }
    return;
  }

  void didChangeEditingValue() {
    setState(() {
      _checkSelectionAttribute();
      currentValue = currentStateValue;
    });
  }

  @override
  void dispose() {
    controller.removeListener(didChangeEditingValue);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant W oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != controller) {
      oldWidget.controller.removeListener(didChangeEditingValue);
      controller.addListener(didChangeEditingValue);
      _checkSelectionAttribute();
      currentValue = currentStateValue;
    }
  }

  String get defaultTooltip;

  String get tooltip {
    return options.tooltip ?? context.quillToolbarBaseButtonOptions?.tooltip ?? defaultTooltip;
  }

  double get iconSize {
    final double? baseFontSize = baseButtonExtraOptions?.iconSize;
    final double? iconSize = options.iconSize;
    return iconSize ?? baseFontSize ?? kDefaultIconSize;
  }

  double get iconButtonFactor {
    final double? baseIconFactor = baseButtonExtraOptions?.iconButtonFactor;
    final double? iconButtonFactor = options.iconButtonFactor;
    return iconButtonFactor ?? baseIconFactor ?? kDefaultIconButtonFactor;
  }

  QuillIconTheme? get iconTheme {
    return options.iconTheme ?? baseButtonExtraOptions?.iconTheme;
  }

  QuillToolbarBaseButtonOptions? get baseButtonExtraOptions {
    return context.quillToolbarBaseButtonOptions;
  }

  VoidCallback? get afterButtonPressed {
    return options.afterButtonPressed ?? baseButtonExtraOptions?.afterButtonPressed;
  }
}

class QuillLineHeightButtonExtraOptions extends QuillToolbarBaseButtonExtraOptions {
  const QuillLineHeightButtonExtraOptions({
    required super.controller,
    required this.currentValue,
    required this.defaultDisplayText,
    required super.context,
    required super.onPressed,
  });

  final String currentValue;
  final String defaultDisplayText;
}

@immutable
class QuillLineHeightButtonOptions
    extends QuillToolbarBaseButtonOptions<QuillLineHeightButtonOptions, QuillLineHeightButtonExtraOptions> {
  const QuillLineHeightButtonOptions({
    super.iconSize,
    super.iconButtonFactor,
    this.rawItems,
    this.onSelected,
    this.attribute = const LineHeightAttribute(lineHeight: 1.0),
    super.afterButtonPressed,
    super.tooltip,
    this.padding,
    this.style,
    @Deprecated('No longer used') this.width,
    this.initialValue,
    this.labelOverflow = TextOverflow.visible,
    this.itemHeight,
    this.itemPadding,
    this.defaultItemColor = Colors.red,
    super.childBuilder,
    this.shape,
    this.defaultDisplayText,
  });

  final ButtonStyle? shape;

  final List<String>? rawItems;
  final ValueChanged<String>? onSelected;
  final LineHeightAttribute attribute;
  final EdgeInsetsGeometry? padding;
  final TextStyle? style;
  final double? width;
  final String? initialValue;
  final TextOverflow labelOverflow;
  @Deprecated('No longer used')
  final double? itemHeight;
  @Deprecated('No longer used')
  final EdgeInsets? itemPadding;
  final Color? defaultItemColor;
  final String? defaultDisplayText;

  QuillLineHeightButtonOptions copyWith({
    double? iconSize,
    double? iconButtonFactor,
    double? hoverElevation,
    double? highlightElevation,
    List<PopupMenuEntry<String>>? items,
    List<String>? rawItems,
    ValueChanged<String>? onSelected,
    LineHeightAttribute? attribute,
    EdgeInsetsGeometry? padding,
    TextStyle? style,
    double? width,
    String? initialValue,
    TextOverflow? labelOverflow,
    double? itemHeight,
    EdgeInsets? itemPadding,
    Color? defaultItemColor,
    VoidCallback? afterButtonPressed,
    String? tooltip,
    OutlinedBorder? shape,
    String? defaultDisplayText,
  }) {
    return QuillLineHeightButtonOptions(
      iconSize: iconSize ?? this.iconSize,
      iconButtonFactor: iconButtonFactor ?? this.iconButtonFactor,
      rawItems: rawItems ?? this.rawItems,
      onSelected: onSelected ?? this.onSelected,
      attribute: attribute ?? this.attribute,
      padding: padding ?? this.padding,
      style: style ?? this.style,
      // ignore: deprecated_member_use_from_same_package
      width: width ?? this.width,
      initialValue: initialValue ?? this.initialValue,
      labelOverflow: labelOverflow ?? this.labelOverflow,
      // ignore: deprecated_member_use_from_same_package
      itemHeight: itemHeight ?? this.itemHeight,
      // ignore: deprecated_member_use_from_same_package
      itemPadding: itemPadding ?? this.itemPadding,
      defaultItemColor: defaultItemColor ?? this.defaultItemColor,
      tooltip: tooltip ?? super.tooltip,
      afterButtonPressed: afterButtonPressed ?? super.afterButtonPressed,
      defaultDisplayText: defaultDisplayText ?? this.defaultDisplayText,
    );
  }
}
