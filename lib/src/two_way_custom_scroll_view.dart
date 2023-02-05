import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class TwoWayCustomScrollView extends CustomScrollView {
  const TwoWayCustomScrollView({
    super.key,
    super.scrollDirection,
    super.reverse,
    super.controller,
    super.primary,
    super.physics,
    super.scrollBehavior,
    super.shrinkWrap,
    required Key super.center,
    super.cacheExtent,
    super.slivers,
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
  }) : super(anchor: 0);

  @override
  Widget buildViewport(
    BuildContext context,
    ViewportOffset offset,
    AxisDirection axisDirection,
    List<Widget> slivers,
  ) {
    return _Viewport(
      axisDirection: axisDirection,
      offset: offset,
      slivers: slivers,
      cacheExtent: cacheExtent,
      center: center,
      clipBehavior: clipBehavior,
    );
  }
}

class _Viewport extends Viewport {
  _Viewport({
    Key? key,
    super.axisDirection,
    required super.offset,
    required super.center,
    super.cacheExtent,
    super.clipBehavior,
    required super.slivers,
  }) : super(key: key, anchor: 0);

  @override
  RenderViewport createRenderObject(BuildContext context) {
    return _RenderViewport(
      axisDirection: axisDirection,
      crossAxisDirection: crossAxisDirection ??
          Viewport.getDefaultCrossAxisDirection(context, axisDirection),
      anchor: anchor,
      offset: offset,
      cacheExtent: cacheExtent,
      cacheExtentStyle: cacheExtentStyle,
      clipBehavior: clipBehavior,
    );
  }
}

class _RenderViewport extends RenderViewport {
  _RenderViewport({
    super.axisDirection,
    required super.crossAxisDirection,
    required super.offset,
    required super.anchor,
    super.cacheExtent,
    super.cacheExtentStyle,
    super.clipBehavior,
  });

  @override
  void performLayout() {
    super.performLayout();

    // Iteration order:
    //
    // --------- backward ----------
    // 0: debugTopListBoundary
    // 1: topPadding
    // 2: top
    // 3: topSliver
    // --------- forward ----------
    // 4: debugBottomListBoundary
    // 5: bottomPadding
    // 6: bottom
    // 7: bottomSliver
    // 8: centerSliver
    final iter = childrenInPaintOrder.iterator;
    double totalForwardScrollExtent = 0;
    double totalBackwardScrollExtent = 0;
    var i = 0;
    while (iter.moveNext()) {
      assert(i < 9, 'There must be exactly 9 slivers in the CustomScrollView');
      final sliverExtent = iter.current.geometry?.scrollExtent ?? 0;
      if (i < 4) {
        totalBackwardScrollExtent += sliverExtent;
      } else {
        totalForwardScrollExtent += sliverExtent;
      }
      i++;
    }
    (offset as ScrollPosition).correctToEnsureViewportIsFilled(
      totalForwardScrollExtent,
      totalBackwardScrollExtent,
    );
    super.performLayout();
  }
}

extension _OffsetAdjustment on ScrollPosition {
  void correctToEnsureViewportIsFilled(
    double forwardScrollExtent,
    double backwardScrollExtent,
  ) {
    if (!hasContentDimensions || !hasViewportDimension || !hasPixels) return;

    final totalScrollExtent = backwardScrollExtent + forwardScrollExtent;
    if (totalScrollExtent < viewportDimension) {
      final target = minScrollExtent;
      final correction = pixels - target;
      correctBy(-correction);
      return;
    }
    if (backwardScrollExtent < viewportDimension ||
        forwardScrollExtent < viewportDimension) {
      final adjustedMaxScrollExtent = forwardScrollExtent - viewportDimension;
      if (pixels > adjustedMaxScrollExtent) {
        final target = adjustedMaxScrollExtent;
        final correction = pixels - target;
        correctBy(-correction);
      }
    }
  }
}
