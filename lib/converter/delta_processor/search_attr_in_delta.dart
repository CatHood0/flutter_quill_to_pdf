import 'package:dart_quill_delta/dart_quill_delta.dart' as fq;

import '../../core/constant/constants.dart';

final RegExp _newLinesRegexp = RegExp('\n|\\n');

enum DeltaDetectionLimit { newline, end, mid, nextInsert }

String? searchNextAttr({
  required fq.Delta delta,
  required int currentIndex,
  required DeltaDetectionLimit limitTo,
  required String attr,
}) {
  if (delta.isEmpty) return null;
  int index = currentIndex + 1; // go to next operation instead the current
  bool breakLoop = false;
  if (limitTo == DeltaDetectionLimit.mid && currentIndex > 0) {
    final List<fq.Operation> ops = delta.operations;
    ops.removeRange(0, currentIndex);
    delta = fq.Delta.fromOperations(ops);
    index = 0;
  }
  while (index < delta.length) {
    final fq.Operation operation = delta.elementAt(index);
    //verify if the insertion contains just new lines without human text
    if (breakLoop) {
      return null;
    }
    if (limitTo == DeltaDetectionLimit.newline) {
      if (operation.data is String && Constant.newLinesInsertions.hasMatch((operation.data as String)) && operation.attributes != null) {
        final String? attribute = operation.attributes?[attr];
        if (attribute != null) {
          return attribute;
        }
      }
      // just continue if the insert doesnt contains any new line
      if (operation.data is String && !operation.data.toString().contains(_newLinesRegexp)) {
        index++;
        continue;
      }
      if (operation.data is String && operation.data.toString().contains(_newLinesRegexp)) {
        return null;
      }
    }
    //Search the attribute until the end of the delta
    if (limitTo == DeltaDetectionLimit.end) {
      if (operation.data is String && Constant.newLinesInsertions.hasMatch((operation.data as String)) && operation.attributes != null) {
        final String? attribute = operation.attributes?[attr];
        if (attribute != null) {
          return attribute;
        }
      }
      if (operation.data is String && !operation.data.toString().contains(_newLinesRegexp)) {
        index++;
        continue;
      }
    }
    //Search until the next insert
    if (limitTo == DeltaDetectionLimit.nextInsert) {
      breakLoop = true;
      if (operation.data is String && Constant.newLinesInsertions.hasMatch((operation.data as String)) && operation.attributes != null) {
        final String? attribute = operation.attributes?[attr];
        if (attribute != null) {
          return attribute;
        }
      }
      if (operation.data is String && !operation.data.toString().contains(_newLinesRegexp)) {
        index++;
        continue;
      }
    }
    if (limitTo == DeltaDetectionLimit.mid) {
      final int mid = (delta.length / 2).floor();
      if (index <= mid) {
        if (operation.data is String && Constant.newLinesInsertions.hasMatch((operation.data as String)) && operation.attributes != null) {
          final String? attribute = operation.attributes?[attr];
          if (attribute != null) {
            return attribute;
          }
        }
      } else {
        return null;
      }
    }
    index++;
  }
  return null;
}
