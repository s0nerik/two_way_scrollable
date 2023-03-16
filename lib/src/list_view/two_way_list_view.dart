import 'package:flutter/widgets.dart';
import 'package:two_way_scrollable/src/list_view/sliver_two_way_list_view.dart';

import '../two_way_custom_scroll_view.dart';
import 'two_way_list_view_controller.dart';

class TwoWayListView<T> extends StatelessWidget {
  const TwoWayListView({
    Key? key,
    required this.controller,
    required this.itemBuilder,
    this.reverse = false,
    this.topSlivers = const [],
    this.aboveCenterSlivers = const [],
    this.centerSliver,
    this.belowCenterSlivers = const [],
    this.bottomSlivers = const [],
  }) : super(key: key);

  final TwoWayListViewController<T> controller;
  final TwoWayListViewItemBuilder<T> itemBuilder;
  final bool reverse;

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
      reverse: reverse,
      slivers: [
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
      ],
    );
  }
}
