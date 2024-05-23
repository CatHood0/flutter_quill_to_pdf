import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart' as fq;
import 'package:flutter_quill_to_pdf/core/extensions/string_extension.dart';

import '../../packages/vsc_quill_delta_to_html/src/helpers/string.dart';
import '../../utils/utils.dart';

extension DeltaDenormilazer on fq.Delta {
  fq.Delta fullDenormalizer() {
    if (isEmpty) return this;

    final List<Map<String, dynamic>> denormalizedOps =
        map<List<Map<String, dynamic>>>((fq.Operation op) => denormalize(op.toJson())).flattened.toList();
    return fq.Delta.fromOperations(denormalizedOps.map<fq.Operation>((Map<String, dynamic> e) => fq.Operation.fromJson(e)).toList());
  }

  List<Map<String, dynamic>> denormalize(Map<String, dynamic> op) {
    const String newLine = '\n';
    final insertValue = op['insert'];
    if (insertValue is Map || insertValue == newLine) {
      return <Map<String, dynamic>>[op];
    }

    final List<String> newlinedArray = tokenizeWithNewLines(insertValue.toString());

    if (newlinedArray.length == 1) {
      return <Map<String, dynamic>>[op];
    }

    // Copy op in to keep its attributes, but replace the insert value with a newline.
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

extension StringRawDelta on String {
  String get encodeDeltaData {
    String json = closeWithBracketsIfNeeded;
    int index = 0;
    if (json.isEmpty) return quillDeltaNewLine.withBrackets;
    fq.Delta deltaHelper = fq.Delta.fromJson(jsonDecode(json));
    final fq.Delta delta = fq.Delta();
    while (index < deltaHelper.length) {
      final fq.Operation operation = deltaHelper.elementAt(index);
      if (operation.data is String) {
        delta.insert(operation.data.toString().encodeSymbols, operation.attributes);
        index++;
        continue;
      }
      delta.insert(operation.data, operation.attributes);
      index++;
    }
    return jsonEncode(delta.toJson()).fixCommonErrorInsertsInRawDelta;
  }
}

//just a string raw delta helper that just have one thing to do
extension StringExt on String {
  String get closeWithBracketsIfNeeded => startsWith('{') ? withBrackets : this;
}
