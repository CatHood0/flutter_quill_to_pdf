import 'package:flutter/material.dart';

extension ColorExtension on String {
  Color? tryToColor() {
    final RegExp rgbRegex = RegExp(r'^rgb\((\d+),\s*?(\d+),\s*?(\d+)\)$');
    final RegExp rgbaRegex = RegExp(r'^rgba\((\d+),\s*(\d+),\s*(\d+),\s*([\d.]+)\)$');
    final RegExp hexRegex = RegExp(r'^(0x|#)([0-9A-Fa-f]{6}|[0-9A-Fa-f]{8})$');

    if (rgbRegex.hasMatch(this)) {
      final RegExpMatch? match = rgbRegex.firstMatch(this);
      if (match != null && match.groupCount == 3) {
        final int? r = int.tryParse(match.group(1)!);
        final int? g = int.tryParse(match.group(2)!);
        final int? b = int.tryParse(match.group(3)!);
        if (r != null && g != null && b != null) {
          return Color.fromARGB(255, r, g, b);
        }
      }
    } else if (rgbaRegex.hasMatch(this)) {
      final RegExpMatch? match = rgbaRegex.firstMatch(this);
      if (match != null && match.groupCount == 4) {
        final int? r = int.tryParse(match.group(1)!);
        final int? g = int.tryParse(match.group(2)!);
        final int? b = int.tryParse(match.group(3)!);
        final double? a = double.tryParse(match.group(4)!);
        if (r != null && g != null && b != null && a != null) {
          return Color.fromARGB((a * 255).toInt(), r, g, b);
        }
      }
    } else if (hexRegex.hasMatch(this)) {
      final RegExpMatch? match = hexRegex.firstMatch(this);
      if (match != null && match.groupCount == 2) {
        final int? hexValue = int.tryParse(match.group(2)!, radix: 16);
        if (hexValue != null) {
          if (match.group(2)!.length == 6) {
            // 6-character hex format without alpha
            return Color(hexValue).withAlpha(255);
          } else {
            // 8-character hex format with alpha
            return Color(hexValue);
          }
        }
      }
    }

    return null; // Return null if parsing fails
  }
}

extension HexExtension on Color {
  String toHex() {
    return '0x${value.toRadixString(16)}';
  }
}

extension ColorExtension2 on Color {
  /// Try to parse the `rgba(red, greed, blue, alpha)`
  /// from the string.
  static Color? tryFromRgbaString(String colorString) {
    final RegExp reg = RegExp(r'rgba\((\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*,\s*(\d+)\s*\)');
    final RegExpMatch? match = reg.firstMatch(colorString);
    if (match == null) {
      return null;
    }

    if (match.groupCount < 4) {
      return null;
    }
    final String? redStr = match.group(1);
    final String? greenStr = match.group(2);
    final String? blueStr = match.group(3);
    final String? alphaStr = match.group(4);

    final int? red = redStr != null ? int.tryParse(redStr) : null;
    final int? green = greenStr != null ? int.tryParse(greenStr) : null;
    final int? blue = blueStr != null ? int.tryParse(blueStr) : null;
    final int? alpha = alphaStr != null ? int.tryParse(alphaStr) : null;

    if (red == null || green == null || blue == null || alpha == null) {
      return null;
    }

    return Color.fromARGB(alpha, red, green, blue);
  }

  String toRgbaString() {
    return 'rgba($red, $green, $blue, $alpha)';
  }
}
