import 'package:flutter/widgets.dart';
import 'package:two_way_scrollable/src/list_view/sliver_two_way_list_view.dart';

import '../two_way_custom_scroll_view.dart';
import 'two_way_list_view_controller.dart';

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
  }) : super(key: key);

  final TwoWayListViewController<T> controller;
  final TwoWayListViewItemBuilder<T> itemBuilder;
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

  @override
  Widget build(BuildContext context) {
    return TwoWayCustomScrollView(
      center: controller.centerSliverKey,
      reverse: anchor == TwoWayListViewAnchor.bottom,
      slivers: _buildSlivers(),
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
          SliverTwoWayListView.top(
            controller: controller,
            itemBuilder: itemBuilder,
          ),
          ...aboveCenterSlivers,
          SliverTwoWayListView.center(
            controller: controller,
            centerSliver: centerSliver,
          ),
          ...belowCenterSlivers,
          SliverTwoWayListView.bottom(
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
