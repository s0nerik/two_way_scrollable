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
    List<Widget> slivers = const <Widget>[],
    super.semanticChildCount,
    super.dragStartBehavior,
    super.keyboardDismissBehavior,
    super.restorationId,
    super.clipBehavior,
  }) : super(
          anchor: 0,
          slivers: slivers + const [_SliverBottomBoundary()],
        );

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

class _SliverBottomBoundary extends SliverToBoxAdapter {
  const _SliverBottomBoundary({Key? key})
      : super(key: key, child: const SizedBox.shrink());

  @override
  _RenderSliverBottomBoundary createRenderObject(BuildContext context) =>
      _RenderSliverBottomBoundary();
}

class _RenderSliverBottomBoundary extends RenderSliverToBoxAdapter {}

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

    // `childrenInPaintOrder` iteration order example (based on TwoWayListView):
    //
    // --------- backward ----------
    // 0: debugTopListBoundary
    // 1: topPadding
    // 2: top
    // 3: topSliver
    // --------- forward ----------
    // 4: _SliverBottomBoundary
    // 5: debugBottomListBoundary
    // 6: bottomPadding
    // 7: bottom
    // 8: bottomSliver
    // 9: centerSliver
    final iter = childrenInPaintOrder.iterator;
    double totalForwardScrollExtent = 0;
    double totalBackwardScrollExtent = 0;
    var isBackward = true;
    while (iter.moveNext()) {
      final renderObject = iter.current;
      if (isBackward && renderObject is _RenderSliverBottomBoundary) {
        isBackward = false;
      }
      final sliverExtent = renderObject.geometry?.scrollExtent ?? 0;
      if (isBackward) {
        totalBackwardScrollExtent += sliverExtent;
      } else {
        totalForwardScrollExtent += sliverExtent;
      }
    }
    final layoutRequired =
        (offset as ScrollPosition).correctToEnsureViewportIsFilled(
      totalForwardScrollExtent,
      totalBackwardScrollExtent,
    );
    if (layoutRequired) {
      super.performLayout();
    }
  }
}

extension _OffsetAdjustment on ScrollPosition {
  /// Returns true if the position was corrected.
  bool correctToEnsureViewportIsFilled(
    double forwardScrollExtent,
    double backwardScrollExtent,
  ) {
    if (!hasContentDimensions || !hasViewportDimension || !hasPixels) {
      return false;
    }

    final totalScrollExtent = backwardScrollExtent + forwardScrollExtent;
    if (totalScrollExtent < viewportDimension) {
      final target = minScrollExtent;
      final correction = pixels - target;
      correctBy(-correction);
      return true;
    }
    if (backwardScrollExtent < viewportDimension ||
        forwardScrollExtent < viewportDimension) {
      final adjustedMaxScrollExtent = forwardScrollExtent - viewportDimension;
      if (pixels > adjustedMaxScrollExtent) {
        final target = adjustedMaxScrollExtent;
        final correction = pixels - target;
        correctBy(-correction);
        return true;
      }
    }
    return false;
  }
}
