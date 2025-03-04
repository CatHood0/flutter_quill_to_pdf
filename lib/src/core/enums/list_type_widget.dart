/// This is an enum that decides how will be builded the [List] block
///
/// * [stable]: decides that the builded widget will be the old version
///     It's called stable, because this implementation does not cause rendering errors 
///     if the widgets overlaps the height of the page
/// * [modern]: decides that the builded widget will be new version 
///     It's called modern, because this implementation does it's more exact than the versions used in DOCX or another editors 
///     _Since this version is not stable, can cause rendering errors if the widget overlaps the entire page height_ 
enum ListTypeWidget {
  /// decides that the builded widget will be the old version
  ///
  /// It's called "stable", because this implementation does not cause rendering errors 
  /// if the widgets overlaps the height of the page
  stable,
  /// decides that the builded widget will be new version 
  /// It's called modern, because this implementation does it's more exact than the versions used in DOCX or another editors 
  ///
  /// _Since this version is not stable, can cause rendering errors if the widget overlaps the entire page height_ 
  modern,
}
