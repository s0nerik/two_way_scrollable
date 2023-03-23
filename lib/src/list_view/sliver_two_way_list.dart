import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';
import 'package:two_way_scrollable/src/list_view/two_way_list_controller.dart';

abstract class SliverTwoWayList {
  static Widget top<T>({
    required TwoWayListController<T> controller,
    required TwoWayListItemBuilder<T> itemBuilder,
  }) =>
      _SliverItemsSection<T>(
        key: controller.topItemsSliverKey,
        type: _SliverItemsSectionType.top,
        controller: controller,
        itemBuilder: itemBuilder,
      );

  static Widget center<T>({
    required TwoWayListController<T> controller,
    required Widget? centerSliver,
  }) =>
      KeyedSubtree(
        key: controller.centerSliverKey,
        child:
            centerSliver ?? const SliverToBoxAdapter(child: SizedBox.shrink()),
      );

  static Widget bottom<T>({
    required TwoWayListController<T> controller,
    required TwoWayListItemBuilder<T> itemBuilder,
  }) =>
      _SliverItemsSection<T>(
        key: controller.bottomItemsSliverKey,
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
  final TwoWayListController<T> controller;
  final TwoWayListItemBuilder<T> itemBuilder;

  @override
  State<_SliverItemsSection<T>> createState() => SliverItemsSectionState<T>._();
}

@internal
class SliverItemsSectionState<T> extends State<_SliverItemsSection<T>> {
  SliverItemsSectionState._();

  late final initialItemCount = items.length;

  List<T> get items {
    switch (widget.type) {
      case _SliverItemsSectionType.top:
        return widget.controller.top;
      case _SliverItemsSectionType.bottom:
        return widget.controller.bottom;
    }
  }

  int? _findChildIndexCallback(Key key) {
    final item = widget.controller.keyedItems[key];
    if (item == null) return null;
    return items.indexOf(item);
  }

  Widget _itemBuilder(
    BuildContext context,
    int index,
    Animation<double> animation,
  ) {
    final item = items[index];
    final key = widget.controller.itemKeys[item]!;

    final actualIndex = widget.type == _SliverItemsSectionType.bottom
        ? widget.controller.centerIndex + index
        : widget.controller.centerIndex - index - 1;

    return KeyedSubtree(
      key: key,
      child: widget.itemBuilder(context, actualIndex, item, animation),
    );
  }

  Widget removedItemBuilder(
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
          ? widget.controller.topItemsAnimatedListSliverKey
          : widget.controller.bottomItemsAnimatedListSliverKey,
      initialItemCount: initialItemCount,
      findChildIndexCallback: _findChildIndexCallback,
      itemBuilder: _itemBuilder,
    );
  }
}
