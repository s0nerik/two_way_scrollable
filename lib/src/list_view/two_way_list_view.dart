import 'package:flutter/widgets.dart';

import '../two_way_custom_scroll_view.dart';
import 'two_way_list_view_controller.dart';

class TwoWayListView<T> extends StatefulWidget {
  const TwoWayListView({
    Key? key,
    required this.controller,
    required this.itemBuilder,
    this.topSlivers = const [],
    this.aboveCenterSlivers = const [],
    this.centerSliver,
    this.belowCenterSlivers = const [],
    this.bottomSlivers = const [],
    this.reverse = false,
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
  State<TwoWayListView<T>> createState() => _TwoWayListViewState<T>();
}

class _TwoWayListViewState<T> extends State<TwoWayListView<T>> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(notifyListeners);
    widget.controller.removedItemBuilder = _itemBuilder;
  }

  @override
  void didUpdateWidget(covariant TwoWayListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(notifyListeners);
      widget.controller.addListener(notifyListeners);
    }
    if (widget.itemBuilder != oldWidget.itemBuilder) {
      widget.controller.removedItemBuilder = _itemBuilder;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(notifyListeners);
    widget.controller.removedItemBuilder = null;
    super.dispose();
  }

  void notifyListeners() => setState(() {});

  Widget _itemBuilder(
    BuildContext context,
    Key key,
    int index,
    T item,
    Animation<double> anim,
  ) {
    return KeyedSubtree(
      key: key,
      child: widget.itemBuilder(context, index, item, anim),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TwoWayCustomScrollView(
      center: widget.controller.centerSliverKey,
      reverse: widget.reverse,
      slivers: [
        ...widget.topSlivers,
        SliverAnimatedList(
          key: widget.controller.topItemsSliverKey,
          findChildIndexCallback: (key) {
            final item = widget.controller.keyedItems[key];
            if (item == null) return null;
            return widget.controller.top.indexOf(item);
          },
          itemBuilder: (context, index, anim) {
            final item = widget.controller.top[index];
            final key = widget.controller.itemKeys[item]!;
            return _itemBuilder(context, key, index, item, anim);
          },
        ),
        ...widget.aboveCenterSlivers,
        KeyedSubtree(
          key: widget.controller.centerSliverKey,
          child: widget.centerSliver ??
              const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),
        ...widget.belowCenterSlivers,
        SliverAnimatedList(
          key: widget.controller.bottomItemsSliverKey,
          findChildIndexCallback: (key) {
            final item = widget.controller.keyedItems[key];
            if (item == null) return null;
            return widget.controller.bottom.indexOf(item);
          },
          itemBuilder: (context, index, anim) {
            final item = widget.controller.bottom[index];
            final key = widget.controller.itemKeys[item]!;
            return _itemBuilder(context, key, index, item, anim);
          },
        ),
        ...widget.bottomSlivers,
      ],
    );
  }
}
