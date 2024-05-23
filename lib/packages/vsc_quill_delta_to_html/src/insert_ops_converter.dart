// ignore_for_file: always_specify_types

import 'package:collection/collection.dart';

import 'delta_insert_op.dart';
import 'helpers/js.dart';
import 'insert_data.dart';
import 'insert_op_denormalizer.dart';
import 'op_attribute_sanitizer.dart';
import 'op_link_sanitizer.dart';
import 'value_types.dart';

/// Converts raw delta insert ops to array of denormalized DeltaInsertOp objects.
class InsertOpsConverter {
  static List<DeltaInsertOp> convert(
    List<Map<String, dynamic>>? deltaOps,
    OpAttributeSanitizerOptions options,
  ) {
    if (deltaOps == null) {
      return <DeltaInsertOp>[];
    }

    final List<Map<String, dynamic>> denormalizedOps = deltaOps.map(InsertOpDenormalizer.denormalize).flattened.toList();
    final List<DeltaInsertOp> results = <DeltaInsertOp>[];

    for (final Map<String, dynamic> op in denormalizedOps) {
      final rawInsertValue = op['insert'];
      if (!isTruthy(rawInsertValue)) {
        continue;
      }

      final InsertData? insertVal = InsertOpsConverter.convertInsertVal(rawInsertValue, options);
      if (insertVal == null) {
        continue;
      }

      final rawAttributes = op['attributes'];
      final OpAttributes? attributes =
          rawAttributes == null ? null : OpAttributeSanitizer.sanitize(OpAttributes()..attrs.addAll(rawAttributes), options);

      results.add(DeltaInsertOp(insertVal, attributes));
    }

    return results;
  }

  static InsertData? convertInsertVal(dynamic insertPropVal, OpAttributeSanitizerOptions sanitizeOptions) {
    if (insertPropVal is String) {
      return InsertDataQuill(DataType.text, insertPropVal);
    }

    if (!isTruthy(insertPropVal) || insertPropVal is! Map<String, dynamic>) {
      return null;
    }

    final List<String> keys = insertPropVal.keys.toList(growable: false);
    if (keys.isEmpty) {
      return null;
    }

    if (keys.contains(DataType.image.value)) {
      return InsertDataQuill(DataType.image, OpLinkSanitizer.sanitize(insertPropVal[DataType.image.value].toString(), sanitizeOptions));
    }

    if (keys.contains(DataType.video.value)) {
      return InsertDataQuill(DataType.video, OpLinkSanitizer.sanitize(insertPropVal[DataType.video.value].toString(), sanitizeOptions));
    }

    if (keys.contains(DataType.formula.value)) {
      return InsertDataQuill(DataType.formula, insertPropVal[DataType.formula.value]);
    }

    // custom
    final String firstKey = keys.first;
    return InsertDataCustom(firstKey, insertPropVal[firstKey]);
  }
}
