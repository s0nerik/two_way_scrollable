import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:two_way_scrollable/src/list_view/sliver_two_way_list.dart';

import '../util/reversed_list_view.dart';

typedef TwoWayListItemBuilder<T> = Widget Function(
  BuildContext context,
  int index,
  T item,
  Animation<double> anim,
);

@internal
typedef TwoWayListRemovedItemBuilder<T> = Widget Function(
  BuildContext context,
  Key key,
  int index,
  T item,
  Animation<double> anim,
);

class TwoWayListController<T> with ChangeNotifier {
  TwoWayListController({
    this.itemInsertDuration = const Duration(milliseconds: 500),
    this.itemRemoveDuration = const Duration(milliseconds: 500),
  });

  final Duration itemInsertDuration;
  final Duration itemRemoveDuration;

  @internal
  final topItemsSliverKey = GlobalKey<SliverItemsSectionState<T>>(
    debugLabel: 'TwoWayList.topItemsSliver',
  );

  @internal
  final topItemsAnimatedListSliverKey = GlobalKey<SliverAnimatedListState>(
    debugLabel: 'TwoWayList.topItemsAnimatedListSliver',
  );

  final centerSliverKey = GlobalKey(
    debugLabel: 'TwoWayList.centerSliver',
  );

  @internal
  final bottomItemsSliverKey = GlobalKey<SliverItemsSectionState<T>>(
    debugLabel: 'TwoWayList.bottomItemsSliver',
  );

  @internal
  final bottomItemsAnimatedListSliverKey = GlobalKey<SliverAnimatedListState>(
    debugLabel: 'TwoWayList.bottomItemsAnimatedListSliver',
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
  void insertAll(
    int index,
    Iterable<T> items, {
    Duration? duration,
    List<Duration>? durations,
  }) {
    assert(
      duration == null || durations == null,
      'Only one of `duration` and `durations` can be specified.',
    );
    assert(
      durations == null || durations.length == items.length,
      '''
        The length of `durations` must be equal to the length of `items`.
        Expected ${items.length} durations, but got ${durations.length}.
      ''',
    );
    if (items.isEmpty) return;

    Duration getDuration(int index) {
      if (durations != null) return durations[index];
      if (duration != null) return duration;
      return itemInsertDuration;
    }

    final adjustedIndex = index < 0 ? 0 : index;

    _items.insertAll(adjustedIndex, items);

    if (index < _center) {
      assert(
        topItemsAnimatedListSliverKey.currentState != null &&
            topItemsSliverKey.currentState != null,
        '''
          Tried to insert items into the top sliver, but the top sliver is not
          attached to the tree. Did you forget to include the
          `SliverTwoWayList.top` within `CustomScrollView.slivers`?
        ''',
      );
      _center += items.length;
      // Notify top sliver that items were added in reverse order
      final reversedItems = items.toList().reversed;
      var i = items.length - 1;
      for (final item in reversedItems) {
        _assignKey(item);
        topItemsAnimatedListSliverKey.currentState!.insertItem(
          _topIndex(adjustedIndex + i),
          duration: getDuration(i),
        );
        i--;
      }
    } else {
      assert(
        bottomItemsAnimatedListSliverKey.currentState != null &&
            bottomItemsSliverKey.currentState != null,
        '''
          Tried to insert items into the bottom sliver, but the bottom sliver is
          not attached to the tree. Did you forget to include the
          `SliverTwoWayList.bottom` within `CustomScrollView.slivers`?
        ''',
      );
      var i = 0;
      for (final item in items) {
        _assignKey(item);
        bottomItemsAnimatedListSliverKey.currentState!.insertItem(
          _bottomIndex(adjustedIndex + i),
          duration: getDuration(i),
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
    late final TwoWayListRemovedItemBuilder<T> removedItemBuilder;
    if (itemIndex < _center) {
      assert(
        topItemsAnimatedListSliverKey.currentState != null &&
            topItemsSliverKey.currentState != null,
        '''
          Tried to remove items from the top sliver, but the top sliver is not
          attached to the tree. Did you forget to include the
          `SliverTwoWayList.top` within `CustomScrollView.slivers`?
        ''',
      );
      sectionIndex = _topIndex(itemIndex);
      sliverKey = topItemsAnimatedListSliverKey;
      removedItemBuilder = topItemsSliverKey.currentState!.removedItemBuilder;
      _center--;
    } else {
      assert(
        bottomItemsAnimatedListSliverKey.currentState != null &&
            bottomItemsSliverKey.currentState != null,
        '''
          Tried to remove items from the bottom sliver, but the bottom sliver is
          not attached to the tree. Did you forget to include the
          `SliverTwoWayList.bottom` within `CustomScrollView.slivers`?
        ''',
      );
      sectionIndex = _bottomIndex(itemIndex);
      sliverKey = bottomItemsAnimatedListSliverKey;
      removedItemBuilder =
          bottomItemsSliverKey.currentState!.removedItemBuilder;
    }

    final key = _itemKeys[item]!;
    sliverKey.currentState?.removeItem(
      sectionIndex,
      (context, anim) =>
          removedItemBuilder(context, key, itemIndex, item, anim),
      duration: duration ?? itemRemoveDuration,
    );

    _unassignKey(item);
    notifyListeners();
  }
}
