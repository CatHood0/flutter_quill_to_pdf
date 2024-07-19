class Constant {
  const Constant._();
  static const String WHITESPACE = ' ';
  static const String DEFAULT_OBJECT_FIT = 'contain';
  static const double DEFAULT_LINE_HEIGHT = 1.0;
  static const int DEFAULT_FONT_SIZE = 12;
  static const String DEFAULT_FONT_FAMILY = 'Arial';
  //to encode markdown characters to avoid detection

  static const List<double> default_heading_size = <double>[37, 30, 24, 18, 12];
  static const List<String> default_editor_spacing = <String>['1.0', '1.15', '1.5', '2.0'];
  static const Map<String, String> fontSizes = <String, String>{
    "Tiny": "small",
    "Normal": "16", //clear to make the transform assign DEFAULT_FONT_SIZE -> 12
    "Large": "large",
    "Huge": "huge",
    "Subtitle": "23",
    "Title": "28",
  };

  static const Map<String, String> fontFamilies = <String, String>{
    "Monospace": "monospace",
    "Arial": "arial",
    "Courier": "Courier",
    "Inria Serif": "Inria Serif",
    "Noto Sans": "Noto Sans",
    "Open Sans": "Open Sans",
    "Ubuntu Mono": "Ubuntu Mono",
    "Tinos": "Tinos",
  };

  static final RegExp IMAGE_LOCAL_STORAGE_PATH_PATTERN = RegExp(r'^((\/[a-zA-Z0-9-_]+)+|\/)$');
  static final RegExp IMAGE_FROM_NETWORK_URL = RegExp(
      r'^(?:(?<scheme>[^:\/?#]+):)?(?:\/\/(?<authority>[^\/?#]*))?(?<path>[^?#]*\/)?(?<file>[^?#]*\.(?<extension>[Jj][Pp][Ee]?[Gg]|[Pp][Nn][Gg]|[Gg][Ii][Ff]))(?:\?(?<query>[^#]*))?(?:#(?<fragment>.*))?$');
}
