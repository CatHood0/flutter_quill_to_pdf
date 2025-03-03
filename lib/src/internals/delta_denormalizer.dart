import 'package:collection/collection.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';

/// Extension on `Delta` to denormalize operations within a Quill Delta object.
extension DeltaDenormilazer on Delta {
  /// Fully denormalizes the operations within the Delta.
  ///
  /// Converts each operation in the Delta to a fully expanded form,
  /// where operations that contain newlines are split into separate operations.
  Delta denormalize() {
    if (isEmpty) return this;

    final List<Map<String, dynamic>> denormalizedOps =
        map<List<Map<String, dynamic>>>(
            (Operation op) => _denormalize(op.toJson())).flattened.toList();
    return Delta.fromOperations(denormalizedOps
        .map<Operation>((Map<String, dynamic> e) => Operation.fromJson(e))
        .toList());
  }

  /// Denormalizes a single operation map by splitting newlines into separate operations.
  ///
  /// [op] is a Map representing a single operation within the Delta.
  List<Map<String, dynamic>> _denormalize(Map<String, dynamic> op) {
    const String newLine = '\n';
    final Object? insertValue = op['insert'] as Object?;
    if (insertValue is Map || insertValue == newLine) {
      return <Map<String, dynamic>>[op];
    }

    final List<String> newlinedArray =
        tokenizeWithNewLines(insertValue.toString());

    if (newlinedArray.length == 1) {
      return <Map<String, dynamic>>[op];
    }

    // Copy op to retain its attributes, but replace the insert value with a newline.
    final Map<String, dynamic> nlObj = <String, dynamic>{
      ...op,
      ...<String, String>{'insert': newLine}
    };

    return newlinedArray.map((String line) {
      if (line == newLine) {
        return nlObj;
      }
      return <String, dynamic>{
        ...op,
        ...<String, String>{'insert': line},
      };
    }).toList();
  }
}

/// Splits a string [str] by new line characters ("\n"), preserving empty lines
/// as separate tokens in the resulting array.
///
/// Example:
/// ```dart
/// String input = "hello\n\nworld\n ";
/// List<String> tokens = tokenizeWithNewLines(input);
/// print(tokens); // Output: ["hello", "\n", "\n", "world", "\n", " "]
/// ```
///
/// Returns a list of strings where each element represents either a line of text
/// or a new line character.
List<String> tokenizeWithNewLines(String str) {
  const String newLine = '\n';

  if (str == newLine) {
    return <String>[str];
  }

  List<String> lines = str.split(newLine);

  if (lines.length == 1) {
    return lines;
  }

  int lastIndex = lines.length - 1;

  return lines.foldIndexed(<String>[], (int ind, List<String> pv, String line) {
    if (ind != lastIndex) {
      if (line != '') {
        pv.add(line);
        pv.add(newLine);
      } else {
        pv.add(newLine);
      }
    } else if (line != '') {
      pv.add(line);
    }
    return pv;
  });
}
