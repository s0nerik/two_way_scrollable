import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'reversed_list_view.dart';
import 'two_way_custom_scroll_view.dart';

typedef TwoWayListViewItemBuilder<T> = Widget Function(
  BuildContext context,
  int index,
  T item,
  Animation<double> anim,
);

typedef _ItemBuilder<T> = Widget Function(
  BuildContext context,
  Key key,
  int index,
  T item,
  Animation<double> anim,
);

class TwoWayListViewController<T> with ChangeNotifier {
  TwoWayListViewController({
    this.itemInsertDuration = const Duration(milliseconds: 500),
    this.itemRemoveDuration = const Duration(milliseconds: 500),
  });

  final Duration itemInsertDuration;
  final Duration itemRemoveDuration;

  _ItemBuilder<T>? _itemBuilder;

  final _topItemsSliverKey = GlobalKey<SliverAnimatedListState>(
    debugLabel: 'TwoWayListView.topItemsSliver',
  );
  final _centerSliverKey = GlobalKey(
    debugLabel: 'TwoWayListView.centerSliver',
  );
  final _bottomItemsSliverKey = GlobalKey<SliverAnimatedListState>(
    debugLabel: 'TwoWayListView.bottomItemsSliver',
  );

  var _center = 0;
  int get centerIndex => _center;

  final _items = <T>[];

  List<T> get _top => ReversedListView(ListSlice(_items, 0, _center));
  List<T> get _bottom => ListSlice(_items, _center, _items.length);
  List<T> get items => UnmodifiableListView(_items);

  final _keyedItems = <Key, T>{};
  final _itemKeys = <T, Key>{};

  void _assignKey(T item) {
    final key = UniqueKey();
    _keyedItems[key] = item;
    _itemKeys[item] = key;
  }

  void _unassignKey(T item) {
    final key = _itemKeys[item];
    if (key != null) {
      _keyedItems.remove(key);
      _itemKeys.remove(item);
    }
  }

  // calculates index within the `_top` list
  int _topIndex(int index) {
    return _center - 1 - index;
  }

  // calculates index within the `_bottom` list
  int _bottomIndex(int index) {
    return index - _center;
  }

  /// Inserts items into the list.
  ///
  /// If [index] is smaller than [centerIndex], the item is guaranteed to be
  /// added to the top sliver.
  void insertAll(int index, Iterable<T> items, {Duration? duration}) {
    final adjustedIndex = index < 0 ? 0 : index;

    _items.insertAll(adjustedIndex, items);

    if (index < _center) {
      _center += items.length;
      // Notify top sliver that items were added in reverse order
      final reversedItems = items.toList().reversed;
      var i = items.length - 1;
      for (final item in reversedItems) {
        _assignKey(item);
        _topItemsSliverKey.currentState!.insertItem(
          _topIndex(adjustedIndex + i),
          duration: duration ?? itemInsertDuration,
        );
        i--;
      }
    } else {
      var i = 0;
      for (final item in items) {
        _assignKey(item);
        _bottomItemsSliverKey.currentState!.insertItem(
          _bottomIndex(adjustedIndex + i),
          duration: duration ?? itemInsertDuration,
        );
        i++;
      }
    }

    notifyListeners();
  }

  /// Same as [insertAll] but only inserts a single item.
  void insert(int index, T item, {Duration? duration}) {
    insertAll(index, [item], duration: duration);
  }

  void remove(T item, {Duration? duration}) {
    final itemIndex = _items.indexOf(item);
    if (itemIndex < 0) return;

    _items.removeAt(itemIndex);

    late final GlobalKey<SliverAnimatedListState> sliverKey;
    late final int sectionIndex;
    if (itemIndex < _center) {
      sectionIndex = _topIndex(itemIndex);
      sliverKey = _topItemsSliverKey;
      _center--;
    } else {
      sectionIndex = _bottomIndex(itemIndex);
      sliverKey = _bottomItemsSliverKey;
    }

    final key = _itemKeys[item]!;
    sliverKey.currentState?.removeItem(
      sectionIndex,
      (context, anim) => _itemBuilder!(context, key, itemIndex, item, anim),
      duration: duration ?? itemRemoveDuration,
    );

    _unassignKey(item);
    notifyListeners();
  }
}

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
  final bool reverse;

  @override
  State<TwoWayListView<T>> createState() => _TwoWayListViewState<T>();
}

class _TwoWayListViewState<T> extends State<TwoWayListView<T>> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(notifyListeners);
    widget.controller._itemBuilder = _itemBuilder;
  }

  @override
  void didUpdateWidget(covariant TwoWayListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller.removeListener(notifyListeners);
      widget.controller.addListener(notifyListeners);
    }
    if (widget.itemBuilder != oldWidget.itemBuilder) {
      widget.controller._itemBuilder = _itemBuilder;
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(notifyListeners);
    widget.controller._itemBuilder = null;
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
      center: widget.controller._centerSliverKey,
      reverse: widget.reverse,
      slivers: [
        ...widget.topSlivers,
        SliverAnimatedList(
          key: widget.controller._topItemsSliverKey,
          findChildIndexCallback: (key) {
            final item = widget.controller._keyedItems[key];
            if (item == null) return null;
            return widget.controller._top.indexOf(item);
          },
          itemBuilder: (context, index, anim) {
            final item = widget.controller._top[index];
            final key = widget.controller._itemKeys[item]!;
            return _itemBuilder(context, key, index, item, anim);
          },
        ),
        ...widget.aboveCenterSlivers,
        KeyedSubtree(
          key: widget.controller._centerSliverKey,
          child: widget.centerSliver ??
              const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),
        ...widget.belowCenterSlivers,
        SliverAnimatedList(
          key: widget.controller._bottomItemsSliverKey,
          findChildIndexCallback: (key) {
            final item = widget.controller._keyedItems[key];
            if (item == null) return null;
            return widget.controller._bottom.indexOf(item);
          },
          itemBuilder: (context, index, anim) {
            final item = widget.controller._bottom[index];
            final key = widget.controller._itemKeys[item]!;
            return _itemBuilder(context, key, index, item, anim);
          },
        ),
        ...widget.bottomSlivers,
      ],
    );
  }
}
