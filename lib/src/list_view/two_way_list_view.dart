import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:two_way_scrollable/src/list_view/sliver_two_way_list.dart';

import '../two_way_custom_scroll_view.dart';
import 'two_way_list_controller.dart';

enum TwoWayListViewAnchor { top, bottom }

enum TwoWayListViewDirection { topToBottom, bottomToTop }

class TwoWayListView<T> extends StatelessWidget {
  const TwoWayListView({
    Key? key,
    required this.controller,
    required this.itemBuilder,
    this.anchor = TwoWayListViewAnchor.top,
    this.direction = TwoWayListViewDirection.topToBottom,
    this.topSlivers = const [],
    this.aboveCenterSlivers = const [],
    this.centerSliver,
    this.belowCenterSlivers = const [],
    this.bottomSlivers = const [],
    this.scrollController,
    this.primary,
    this.physics,
    this.scrollBehavior,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
  }) : super(key: key);

  final TwoWayListController<T> controller;
  final TwoWayListItemBuilder<T> itemBuilder;
  final TwoWayListViewAnchor anchor;
  final TwoWayListViewDirection direction;

  /// Slivers placed conceptually above items.
  final List<Widget> topSlivers;

  /// Slivers placed conceptually above the [centerSliver], but below the
  /// "above center" list items.
  final List<Widget> aboveCenterSlivers;

  /// Sliver placed in-between the "above center" and "below center" list items.
  final Widget? centerSliver;

  /// Slivers placed conceptually below the [centerSliver], but above the
  /// "below center" list items.
  final List<Widget> belowCenterSlivers;

  /// Slivers placed conceptually below items.
  final List<Widget> bottomSlivers;

  final ScrollController? scrollController;
  final bool? primary;
  final ScrollPhysics? physics;
  final ScrollBehavior? scrollBehavior;
  final double? cacheExtent;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    return TwoWayCustomScrollView(
      center: controller.centerSliverKey,
      reverse: anchor == TwoWayListViewAnchor.bottom,
      slivers: _buildSlivers(),
      controller: scrollController,
      primary: primary,
      physics: physics,
      scrollBehavior: scrollBehavior,
      cacheExtent: cacheExtent,
      dragStartBehavior: dragStartBehavior,
      keyboardDismissBehavior: keyboardDismissBehavior,
      restorationId: restorationId,
      clipBehavior: clipBehavior,
    );
  }

  List<Widget> _buildSlivers() {
    switch (direction) {
      case TwoWayListViewDirection.topToBottom:
        return _buildTopToBottomSlivers(anchor);
      case TwoWayListViewDirection.bottomToTop:
        return _buildBottomToTopSlivers(anchor);
    }
  }

  List<Widget> _buildTopToBottomSlivers(TwoWayListViewAnchor anchor) {
    switch (anchor) {
      case TwoWayListViewAnchor.top:
        return [
          ...topSlivers,
          SliverTwoWayList.top(
            controller: controller,
            itemBuilder: itemBuilder,
          ),
          ...aboveCenterSlivers,
          SliverTwoWayList.center(
            controller: controller,
            centerSliver: centerSliver,
          ),
          ...belowCenterSlivers,
          SliverTwoWayList.bottom(
            controller: controller,
            itemBuilder: itemBuilder,
          ),
          ...bottomSlivers,
        ];
      case TwoWayListViewAnchor.bottom:
        return _buildTopToBottomSlivers(TwoWayListViewAnchor.top)
            .reversed
            .toList();
    }
  }

  List<Widget> _buildBottomToTopSlivers(TwoWayListViewAnchor anchor) {
    switch (anchor) {
      case TwoWayListViewAnchor.top:
        return _buildTopToBottomSlivers(TwoWayListViewAnchor.bottom);
      case TwoWayListViewAnchor.bottom:
        return _buildTopToBottomSlivers(TwoWayListViewAnchor.top);
    }
  }
}
