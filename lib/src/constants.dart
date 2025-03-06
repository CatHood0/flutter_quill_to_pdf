class Constant {
  const Constant._();
  static const int kDefaultMaxPages = 99999999;
  static const double kDefaultLineHeight = 1.0;
  static const int DEFAULT_FONT_SIZE = 12;
  static const String DEFAULT_FONT_FAMILY = 'Arial';
  static const List<double> kDefaultHeadingSizes = <double>[
    28,
    25,
    23,
    21,
    18,
    15,
  ];
  /*
  Now can check if the input is a storage path (no fully support for android)
  Unix/Linux/macOS/iOS:
    /
    /home/user
    /home/user/file.txt
    /home/user/file
    /home/user/file.tar.gz
  Windows:
    C:\
    C:\Users\John\file.txt
    C:\Users\John\Documents\file
    \\server\share\file.txt
    \\server\share\folder\file
  */
  /// Check if the input passed is a local storage for common platforms
  ///
  /// Note: android has not fully support at this RegExp
  static final RegExp localStorageFileDetectorUniversal = RegExp(
      r'^(?:(?:[a-zA-Z]:\\|\\\\[^\\/:*?"<>|\r\n]+\\[^\\/:*?"<>|\r\n]+\\|\/)'
      r'(?:[^\\/:*?"<>|\r\n]+[\\\/])*'
      r'[^\\/:*?"<>|\r\n]*'
      r'(?:\.[^\\/:*?"<>|\r\n]+)?)$');

  /// Check if the input passed is a local storage in Android platform
  static final RegExp localStorageFileDetectorAndroid = RegExp(
      r'^(?:\/(?:[a-zA-Z0-9\-_]+(?:\/[a-zA-Z0-9\-_]+)*)?(?:\.[a-zA-Z0-9\-_]+)?)$');

  /// Check if the file comes from a content uri data
  static final RegExp contentUriFileDetector =
      RegExp(r'^content:\/\/([a-zA-Z0-9\-_]+(?:\/[a-zA-Z0-9\-_]+)*)$');

  static bool isFromLocalStorage(String input) {
    return localStorageFileDetectorUniversal.hasMatch(
          input,
        ) ||
        localStorageFileDetectorAndroid.hasMatch(input);
  }

  static final RegExp kDefaultImageUrlDetector = RegExp(
      r'^http(s)?(?:(?<scheme>[^:\/?#]+):)?(?:\/\/(?<authority>[^\/?#]*))?(?<path>[^?#]*\/)?(?<file>[^?#]*\.(?<extension>[Jj][Pp][Ee]?[Gg]|[Pp][Nn][Gg]|[Gg][Ii][Ff]))(?:\?(?<query>[^#]*))?(?:#(?<fragment>.*))?$');
}
