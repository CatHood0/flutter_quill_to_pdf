import '../constant/constants.dart';

extension MdHeaderLevelExtension on num {
  double resolveHeaderLevel(
      {List<double> headingSizes = Constant.default_heading_size}) {
    return this == 1
        ? headingSizes[0]
        : this == 2
            ? headingSizes[1]
            : this == 3
                ? headingSizes[2]
                : this == 4
                    ? headingSizes[3]
                    : headingSizes[4];
  }
}
