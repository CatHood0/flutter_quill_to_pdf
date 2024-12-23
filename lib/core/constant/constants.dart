class Constant {
  const Constant._();
  static const double DEFAULT_LINE_HEIGHT = 1.0;
  static const int DEFAULT_FONT_SIZE = 12;
  static const String DEFAULT_FONT_FAMILY = 'Arial';
  // to encode markdown characters to avoid detection
  static const List<double> default_heading_size = <double>[37, 30, 24, 18, 12];
  static final RegExp newLinesInsertions = RegExp(r'^¶+');
  // only valid for mobile devices
  static final RegExp IMAGE_LOCAL_STORAGE_PATH_PATTERN =
      RegExp(r'^((\/[a-zA-Z0-9-_]+)+|\/)(\..+)?$');
  static final RegExp IMAGE_FROM_NETWORK_URL = RegExp(
      r'^http(s)?(?:(?<scheme>[^:\/?#]+):)?(?:\/\/(?<authority>[^\/?#]*))?(?<path>[^?#]*\/)?(?<file>[^?#]*\.(?<extension>[Jj][Pp][Ee]?[Gg]|[Pp][Nn][Gg]|[Gg][Ii][Ff]))(?:\?(?<query>[^#]*))?(?:#(?<fragment>.*))?$');
}
