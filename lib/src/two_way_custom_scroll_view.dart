import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'util/delegated_viewport_offset.dart';

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
      offset: _ViewportOffset(offset as ScrollPosition),
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
  }) {
    (offset as _ViewportOffset).viewport = this;
  }

  @override
  void performLayout() {
    (offset as _ViewportOffset).viewport = this;
    super.performLayout();
  }
}

class _ViewportOffset extends DelegatedViewportOffset {
  _ViewportOffset(this.scrollPosition) : super(scrollPosition);

  final ScrollPosition scrollPosition;
  late _RenderViewport viewport;

  double _calculateForwardScrollableDimensionWithinViewport() {
    if (viewport.lastChild == null) return 0;

    var totalForwardScrollable = 0.0;

    var child = viewport.lastChild!;
    while (true) {
      totalForwardScrollable += child.geometry?.scrollExtent ?? 0;
      if (child == viewport.center) break;
      child = viewport.childBefore(child)!;
    }

    assert(totalForwardScrollable < scrollPosition.viewportDimension);
    return totalForwardScrollable;
  }

  @override
  bool applyContentDimensions(double minScrollExtent, double maxScrollExtent) {
    if (maxScrollExtent == 0) {
      final forwardScrollableDimension =
          _calculateForwardScrollableDimensionWithinViewport();

      final adjustedMaxScrollExtent =
          forwardScrollableDimension - scrollPosition.viewportDimension;
      final result = scrollPosition.applyContentDimensions(
        minScrollExtent,
        max(minScrollExtent, adjustedMaxScrollExtent),
      );

      final backwardScrollableHeight = -minScrollExtent;
      final totalScrollableHeight =
          backwardScrollableHeight + forwardScrollableDimension;
      if (totalScrollableHeight < scrollPosition.viewportDimension) {
        final diff = scrollPosition.pixels - minScrollExtent;
        if (diff != 0) {
          scrollPosition.correctBy(-diff);
          return false;
        }
      }
      return result;
    }
    return scrollPosition.applyContentDimensions(
      minScrollExtent,
      maxScrollExtent,
    );
  }
}
