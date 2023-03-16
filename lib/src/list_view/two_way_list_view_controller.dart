import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';

import '../util/reversed_list_view.dart';

typedef TwoWayListViewItemBuilder<T> = Widget Function(
  BuildContext context,
  int index,
  T item,
  Animation<double> anim,
);

@internal
typedef RemovedItemBuilder<T> = Widget Function(
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

  @internal
  RemovedItemBuilder<T>? removedItemBuilder;

  @internal
  final topItemsSliverKey = GlobalKey<SliverAnimatedListState>(
    debugLabel: 'TwoWayListView.topItemsSliver',
  );

  @internal
  final centerSliverKey = GlobalKey(
    debugLabel: 'TwoWayListView.centerSliver',
  );

  @internal
  final bottomItemsSliverKey = GlobalKey<SliverAnimatedListState>(
    debugLabel: 'TwoWayListView.bottomItemsSliver',
  );

  var _center = 0;
  int get centerIndex => _center;

  final _items = <T>[];

  @internal
  List<T> get top => ReversedListView(ListSlice(_items, 0, _center));
  @internal
  List<T> get bottom => ListSlice(_items, _center, _items.length);
  List<T> get items => UnmodifiableListView(_items);

  final _keyedItems = <Key, T>{};
  @internal
  Map<Key, T> get keyedItems => UnmodifiableMapView(_keyedItems);

  final _itemKeys = <T, Key>{};
  @internal
  Map<T, Key> get itemKeys => UnmodifiableMapView(_itemKeys);

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
        topItemsSliverKey.currentState!.insertItem(
          _topIndex(adjustedIndex + i),
          duration: duration ?? itemInsertDuration,
        );
        i--;
      }
    } else {
      var i = 0;
      for (final item in items) {
        _assignKey(item);
        bottomItemsSliverKey.currentState!.insertItem(
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
      sliverKey = topItemsSliverKey;
      _center--;
    } else {
      sectionIndex = _bottomIndex(itemIndex);
      sliverKey = bottomItemsSliverKey;
    }

    final key = _itemKeys[item]!;
    sliverKey.currentState?.removeItem(
      sectionIndex,
      (context, anim) =>
          removedItemBuilder!(context, key, itemIndex, item, anim),
      duration: duration ?? itemRemoveDuration,
    );

    _unassignKey(item);
    notifyListeners();
  }
}
