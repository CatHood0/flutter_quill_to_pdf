import 'dart:math' as math;

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';

typedef _ChildSizingFunction = double? Function(Widget child, double? extent);

class Flex extends MultiChildWidget with SpanningWidget {
  Flex({
    required this.direction,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.max,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.verticalDirection = VerticalDirection.down,
    List<Widget> children = const <Widget>[],
  }) : super(children: children);

  final Axis direction;

  final MainAxisAlignment mainAxisAlignment;

  final MainAxisSize mainAxisSize;

  final CrossAxisAlignment crossAxisAlignment;

  final VerticalDirection verticalDirection;

  final FlexContext _context = FlexContext();

  double _getIntrinsicSize(
      {Axis? sizingDirection,
      double? extent, // the extent in the direction that isn't the sizing direction
      _ChildSizingFunction? childSize // a method to find the size in the sizing direction
      }) {
    if (direction == sizingDirection) {
      // INTRINSIC MAIN SIZE
      // Intrinsic main size is the smallest size the flex container can take
      // while maintaining the min/max-content contributions of its flex items.
      double totalFlex = 0.0;
      double inflexibleSpace = 0.0;
      double maxFlexFractionSoFar = 0.0;

      for (final Widget child in children) {
        final int flex = child is Flexible ? child.flex : 0;
        totalFlex += flex;
        if (flex > 0) {
          final double flexFraction = childSize!(child, extent)! / flex;
          maxFlexFractionSoFar = math.max(maxFlexFractionSoFar, flexFraction);
        } else {
          inflexibleSpace += childSize!(child, extent)!;
        }
      }
      return maxFlexFractionSoFar * totalFlex + inflexibleSpace;
    } else {
      // INTRINSIC CROSS SIZE
      // Intrinsic cross size is the max of the intrinsic cross sizes of the
      // children, after the flexible children are fit into the available space,
      // with the children sized using their max intrinsic dimensions.

      // Get inflexible space using the max intrinsic dimensions of fixed children in the main direction.
      final double? availableMainSpace = extent;
      int totalFlex = 0;
      double inflexibleSpace = 0.0;
      double maxCrossSize = 0.0;
      for (final Widget child in children) {
        final int flex = child is Flexible ? child.flex : 0;
        totalFlex += flex;
        double? mainSize;
        double? crossSize;
        if (flex == 0) {
          switch (direction) {
            case Axis.horizontal:
              mainSize = child.box!.width;
              crossSize = childSize!(child, mainSize);
              break;
            case Axis.vertical:
              mainSize = child.box!.height;
              crossSize = childSize!(child, mainSize);
              break;
          }
          inflexibleSpace += mainSize;
          maxCrossSize = math.max(maxCrossSize, crossSize!);
        }
      }

      // Determine the spacePerFlex by allocating the remaining available space.
      // When you're over-constrained spacePerFlex can be negative.
      final double spacePerFlex = math.max(0.0, (availableMainSpace! - inflexibleSpace) / totalFlex);

      // Size remaining (flexible) items, find the maximum cross size.
      for (final Widget child in children) {
        final int flex = child is Flexible ? child.flex : 0;
        if (flex > 0) {
          maxCrossSize = math.max(maxCrossSize, childSize!(child, spacePerFlex * flex)!);
        }
      }

      return maxCrossSize;
    }
  }

  double computeMinIntrinsicWidth(double height) {
    return _getIntrinsicSize(
        sizingDirection: Axis.horizontal,
        extent: height,
        childSize: (Widget child, double? extent) => child.box!.width);
  }

  double computeMaxIntrinsicWidth(double height) {
    return _getIntrinsicSize(
        sizingDirection: Axis.horizontal,
        extent: height,
        childSize: (Widget child, double? extent) => child.box!.width);
  }

  double computeMinIntrinsicHeight(double width) {
    return _getIntrinsicSize(
        sizingDirection: Axis.vertical,
        extent: width,
        childSize: (Widget child, double? extent) => child.box!.height);
  }

  double computeMaxIntrinsicHeight(double width) {
    return _getIntrinsicSize(
        sizingDirection: Axis.vertical,
        extent: width,
        childSize: (Widget child, double? extent) => child.box!.height);
  }

  double _getCrossSize(Widget child) {
    switch (direction) {
      case Axis.horizontal:
        return child.box!.height;
      case Axis.vertical:
        return child.box!.width;
    }
  }

  double _getMainSize(Widget child) {
    switch (direction) {
      case Axis.horizontal:
        return child.box!.width;
      case Axis.vertical:
        return child.box!.height;
    }
  }

  @override
  void layout(Context context, BoxConstraints constraints, {bool parentUsesSize = false}) {
    // Determine used flex factor, size inflexible items, calculate free space.
    int totalFlex = 0;
    Widget? lastFlexChild;

    final double maxMainSize = direction == Axis.horizontal ? constraints.maxWidth : constraints.maxHeight;
    final bool canFlex = maxMainSize < double.infinity;

    double crossSize = 0.0;
    double allocatedSize = 0.0; // Sum of the sizes of the non-flexible children.
    int index = _context.firstChild;

    for (final Widget child in children.sublist(_context.firstChild)) {
      final int flex = child is Flexible ? child.flex : 0;
      final FlexFit fit = child is Flexible ? child.fit : FlexFit.loose;
      if (flex > 0) {
        assert(() {
          final String dimension = direction == Axis.horizontal ? 'width' : 'height';
          if (!canFlex && (mainAxisSize == MainAxisSize.max || fit == FlexFit.tight)) {
            throw Exception('Flex children have non-zero flex but incoming $dimension constraints are unbounded.');
          } else {
            return true;
          }
        }());
        totalFlex += flex;
      } else {
        BoxConstraints? innerConstraints;
        if (crossAxisAlignment == CrossAxisAlignment.stretch) {
          switch (direction) {
            case Axis.horizontal:
              innerConstraints =
                  BoxConstraints(minHeight: constraints.maxHeight, maxHeight: constraints.maxHeight);
              break;
            case Axis.vertical:
              innerConstraints = BoxConstraints(minWidth: constraints.maxWidth, maxWidth: constraints.maxWidth);
              break;
          }
        } else {
          switch (direction) {
            case Axis.horizontal:
              innerConstraints = BoxConstraints(maxHeight: constraints.maxHeight);
              break;
            case Axis.vertical:
              innerConstraints = BoxConstraints(maxWidth: constraints.maxWidth);
              break;
          }
        }
        child.layout(context, innerConstraints, parentUsesSize: true);
        assert(child.box != null);
        allocatedSize += _getMainSize(child);
        crossSize = math.max(crossSize, _getCrossSize(child));
        if (direction == Axis.vertical && allocatedSize > constraints.maxHeight) {
          break;
        }
      }
      lastFlexChild = child;
      index++;
    }
    _context.lastChild = index;
    final int totalChildren = _context.lastChild - _context.firstChild;

    // Distribute free space to flexible children, and determine baseline.
    final double freeSpace = math.max(0.0, (canFlex ? maxMainSize : 0.0) - allocatedSize);
    double allocatedFlexSpace = 0.0;
    if (totalFlex > 0) {
      final double spacePerFlex = canFlex && totalFlex > 0 ? (freeSpace / totalFlex) : double.nan;

      for (final Widget child in children) {
        final int flex = child is Flexible ? child.flex : 0;
        final FlexFit fit = child is Flexible ? child.fit : FlexFit.loose;
        if (flex > 0) {
          final double maxChildExtent = canFlex
              ? (child == lastFlexChild ? (freeSpace - allocatedFlexSpace) : spacePerFlex * flex)
              : double.infinity;
          double? minChildExtent;
          switch (fit) {
            case FlexFit.tight:
              assert(maxChildExtent < double.infinity);
              minChildExtent = maxChildExtent;
              break;
            case FlexFit.loose:
              minChildExtent = 0.0;
              break;
          }

          BoxConstraints? innerConstraints;
          if (crossAxisAlignment == CrossAxisAlignment.stretch) {
            switch (direction) {
              case Axis.horizontal:
                innerConstraints = BoxConstraints(
                    minWidth: minChildExtent,
                    maxWidth: maxChildExtent,
                    minHeight: constraints.maxHeight,
                    maxHeight: constraints.maxHeight);
                break;
              case Axis.vertical:
                innerConstraints = BoxConstraints(
                    minWidth: constraints.maxWidth,
                    maxWidth: constraints.maxWidth,
                    minHeight: minChildExtent,
                    maxHeight: maxChildExtent);
                break;
            }
          } else {
            switch (direction) {
              case Axis.horizontal:
                innerConstraints = BoxConstraints(
                    minWidth: minChildExtent, maxWidth: maxChildExtent, maxHeight: constraints.maxHeight);
                break;
              case Axis.vertical:
                innerConstraints = BoxConstraints(
                    maxWidth: constraints.maxWidth, minHeight: minChildExtent, maxHeight: maxChildExtent);
                break;
            }
          }
          child.layout(context, innerConstraints, parentUsesSize: true);
          assert(child.box != null);
          final double childSize = _getMainSize(child);
          assert(childSize <= maxChildExtent);
          allocatedSize += childSize;
          allocatedFlexSpace += maxChildExtent;
          crossSize = math.max(crossSize, _getCrossSize(child));
        }
      }
    }

    // Align items along the main axis.
    final double idealSize = canFlex && mainAxisSize == MainAxisSize.max ? maxMainSize : allocatedSize;
    double? actualSize;
    double actualSizeDelta;
    late PdfPoint size;
    switch (direction) {
      case Axis.horizontal:
        size = constraints.constrain(PdfPoint(idealSize, crossSize));
        actualSize = size.x;
        crossSize = size.y;
        break;
      case Axis.vertical:
        size = constraints.constrain(PdfPoint(crossSize, idealSize));
        actualSize = size.y;
        crossSize = size.x;
        break;
    }

    box = PdfRect.fromPoints(PdfPoint.zero, size);
    actualSizeDelta = actualSize - allocatedSize;

    final double remainingSpace = math.max(0.0, actualSizeDelta);
    double? leadingSpace;
    late double betweenSpace;

    final TextDirection textDirection = Directionality.of(context);
    final bool flipMainAxis = !(_startIsTopLeft(direction, textDirection, verticalDirection) ?? true);

    switch (mainAxisAlignment) {
      case MainAxisAlignment.start:
        leadingSpace = 0.0;
        betweenSpace = 0.0;
        break;
      case MainAxisAlignment.end:
        leadingSpace = remainingSpace;
        betweenSpace = 0.0;
        break;
      case MainAxisAlignment.center:
        leadingSpace = remainingSpace / 2.0;
        betweenSpace = 0.0;
        break;
      case MainAxisAlignment.spaceBetween:
        leadingSpace = 0.0;
        betweenSpace = totalChildren > 1 ? remainingSpace / (totalChildren - 1) : 0.0;
        break;
      case MainAxisAlignment.spaceAround:
        betweenSpace = totalChildren > 0 ? remainingSpace / totalChildren : 0.0;
        leadingSpace = betweenSpace / 2.0;
        break;
      case MainAxisAlignment.spaceEvenly:
        betweenSpace = totalChildren > 0 ? remainingSpace / (totalChildren + 1) : 0.0;
        leadingSpace = betweenSpace;
        break;
    }

    // Position elements
    double childMainPosition = flipMainAxis ? actualSize - leadingSpace : leadingSpace;

    for (Widget child in children.sublist(_context.firstChild, _context.lastChild)) {
      double? childCrossPosition;
      switch (crossAxisAlignment) {
        case CrossAxisAlignment.start:
        case CrossAxisAlignment.end:
          childCrossPosition = _startIsTopLeft(flipAxis(direction), textDirection, verticalDirection) ==
                  (crossAxisAlignment == CrossAxisAlignment.start)
              ? 0.0
              : crossSize - _getCrossSize(child);
          break;
        case CrossAxisAlignment.center:
          childCrossPosition = crossSize / 2.0 - _getCrossSize(child) / 2.0;
          break;
        case CrossAxisAlignment.stretch:
          childCrossPosition = 0.0;
          break;
      }

      if (flipMainAxis) {
        childMainPosition -= _getMainSize(child);
      }
      switch (direction) {
        case Axis.horizontal:
          child.box = PdfRect(
              box!.x + childMainPosition, box!.y + childCrossPosition, child.box!.width, child.box!.height);
          break;
        case Axis.vertical:
          child.box = PdfRect(childCrossPosition, childMainPosition, child.box!.width, child.box!.height);
          break;
      }
      if (flipMainAxis) {
        childMainPosition -= betweenSpace;
      } else {
        childMainPosition += _getMainSize(child) + betweenSpace;
      }
    }
  }

  Axis flipAxis(Axis direction) {
    switch (direction) {
      case Axis.horizontal:
        return Axis.vertical;
      case Axis.vertical:
        return Axis.horizontal;
    }
  }

  bool? _startIsTopLeft(Axis direction, TextDirection? textDirection, VerticalDirection? verticalDirection) {
    // If the relevant value of textDirection or verticalDirection is null, this returns null too.
    switch (direction) {
      case Axis.horizontal:
        switch (textDirection) {
          case TextDirection.ltr:
            return true;
          case TextDirection.rtl:
            return false;
          case null:
            return null;
        }
      case Axis.vertical:
        switch (verticalDirection) {
          case VerticalDirection.down:
            return false;
          case VerticalDirection.up:
            return true;
          case null:
            return null;
        }
    }
  }

  @override
  void paint(Context context) {
    super.paint(context);

    final mat = Matrix4.identity();
    mat.translate(box!.x, box!.y);
    context.canvas
      ..saveContext()
      ..setTransform(mat);

    for (final Widget child in children.sublist(_context.firstChild, _context.lastChild)) {
      child.paint(context);
    }
    context.canvas.restoreContext();
  }

  @override
  bool get canSpan => direction == Axis.vertical;

  @override
  bool get hasMoreWidgets => true;

  @override
  void restoreContext(FlexContext context) {
    _context.firstChild = context.lastChild;
  }

  @override
  WidgetContext saveContext() {
    return _context;
  }
}
