import 'package:flutter/widgets.dart';
import 'package:two_way_scrollable/src/list_view/two_way_list_view_controller.dart';

abstract class SliverTwoWayListView {
  static Widget top<T>({
    required TwoWayListViewController<T> controller,
    required TwoWayListViewItemBuilder<T> itemBuilder,
  }) =>
      _SliverItemsSection<T>(
        type: _SliverItemsSectionType.top,
        controller: controller,
        itemBuilder: itemBuilder,
      );

  static Widget center<T>({
    required TwoWayListViewController<T> controller,
    required Widget? centerSliver,
  }) =>
      KeyedSubtree(
        key: controller.centerSliverKey,
        child:
            centerSliver ?? const SliverToBoxAdapter(child: SizedBox.shrink()),
      );

  static Widget bottom<T>({
    required TwoWayListViewController<T> controller,
    required TwoWayListViewItemBuilder<T> itemBuilder,
  }) =>
      _SliverItemsSection<T>(
        type: _SliverItemsSectionType.bottom,
        controller: controller,
        itemBuilder: itemBuilder,
      );
}

enum _SliverItemsSectionType { top, bottom }

class _SliverItemsSection<T> extends StatefulWidget {
  const _SliverItemsSection({
    Key? key,
    required this.type,
    required this.controller,
    required this.itemBuilder,
  }) : super(key: key);

  final _SliverItemsSectionType type;
  final TwoWayListViewController<T> controller;
  final TwoWayListViewItemBuilder<T> itemBuilder;

  @override
  State<_SliverItemsSection<T>> createState() => _SliverItemsSectionState<T>();
}

class _SliverItemsSectionState<T> extends State<_SliverItemsSection<T>> {
  late final keyedItems = widget.controller.keyedItems;
  late final itemKeys = widget.controller.itemKeys;

  List<T> get items {
    switch (widget.type) {
      case _SliverItemsSectionType.top:
        return widget.controller.top;
      case _SliverItemsSectionType.bottom:
        return widget.controller.bottom;
    }
  }

  @override
  void initState() {
    super.initState();
    switch (widget.type) {
      case _SliverItemsSectionType.top:
        widget.controller.removedTopItemBuilder = _removedItemBuilder;
        break;
      case _SliverItemsSectionType.bottom:
        widget.controller.removedBottomItemBuilder = _removedItemBuilder;
        break;
    }
  }

  @override
  void dispose() {
    switch (widget.type) {
      case _SliverItemsSectionType.top:
        widget.controller.removedTopItemBuilder = null;
        break;
      case _SliverItemsSectionType.bottom:
        widget.controller.removedBottomItemBuilder = null;
        break;
    }
    super.dispose();
  }

  int? _findChildIndexCallback(Key key) {
    final item = keyedItems[key];
    if (item == null) return null;
    return items.indexOf(item);
  }

  Widget _itemBuilder(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) {
    final item = items[index];
    final key = itemKeys[item]!;
    return KeyedSubtree(
      key: key,
      child: widget.itemBuilder(context, index, item, animation),
    );
  }

  Widget _removedItemBuilder(
    BuildContext context,
    Key key,
    int index,
    T item,
    Animation<double> anim,
  ) =>
      KeyedSubtree(
        key: key,
        child: widget.itemBuilder(context, index, item, anim),
      );

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedList(
      key: widget.type == _SliverItemsSectionType.top
          ? widget.controller.topItemsSliverKey
          : widget.controller.bottomItemsSliverKey,
      findChildIndexCallback: _findChildIndexCallback,
      itemBuilder: _itemBuilder,
    );
  }
}
