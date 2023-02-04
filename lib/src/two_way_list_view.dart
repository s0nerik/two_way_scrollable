import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'reversed_list_view.dart';
import 'two_way_custom_scroll_view.dart';

typedef TwoWayListViewItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  Animation<double> anim,
);

typedef _ItemBuilder<T> = Widget Function(
  BuildContext context,
  Key key,
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

  final _topSliverKey = GlobalKey<SliverAnimatedListState>(
    debugLabel: 'TwoWayListView.topSliver',
  );
  final _centerSliverKey = GlobalKey(
    debugLabel: 'TwoWayListView.centerSliver',
  );
  final _bottomSliverKey = GlobalKey<SliverAnimatedListState>(
    debugLabel: 'TwoWayListView.bottomSliver',
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

  /// Inserts an item into the list.
  ///
  /// If [index] is smaller than [centerIndex], the item is guaranteed to be
  /// added to the top sliver.
  void insert(int index, T item) {
    final adjustedIndex = index < 0 ? 0 : index;

    _items.insert(adjustedIndex, item);
    _assignKey(item);

    if (index < _center) {
      _center++;
      final state = _topSliverKey.currentState!;
      final topIndex = _topIndex(adjustedIndex);
      state.insertItem(topIndex, duration: itemInsertDuration);
    } else {
      final state = _bottomSliverKey.currentState!;
      final bottomIndex = _bottomIndex(adjustedIndex);
      state.insertItem(bottomIndex, duration: itemInsertDuration);
    }

    notifyListeners();
  }

  void remove(T item) {
    final itemIndex = _items.indexOf(item);
    if (itemIndex < 0) return;

    _items.removeAt(itemIndex);

    late final GlobalKey<SliverAnimatedListState> sliverKey;
    late final int sectionIndex;
    if (itemIndex < _center) {
      sectionIndex = _topIndex(itemIndex);
      sliverKey = _topSliverKey;
      _center--;
    } else {
      sectionIndex = _bottomIndex(itemIndex);
      sliverKey = _bottomSliverKey;
    }

    final key = _itemKeys[item]!;
    sliverKey.currentState?.removeItem(
      sectionIndex,
      (context, anim) => _itemBuilder!(context, key, item, anim),
      duration: itemRemoveDuration,
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
    this.centerSliver,
    this.top,
    this.bottom,
    this.padding = EdgeInsets.zero,
    this.reverse = false,
    this.showDebugIndicators = false,
  }) : super(key: key);

  final TwoWayListViewController<T> controller;
  final TwoWayListViewItemBuilder<T> itemBuilder;
  final Widget? centerSliver;
  final Widget? top;
  final Widget? bottom;
  final EdgeInsetsGeometry padding;
  final bool reverse;
  final bool showDebugIndicators;

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
    T item,
    Animation<double> anim,
  ) {
    return KeyedSubtree(
      key: key,
      child: widget.itemBuilder(context, item, anim),
    );
  }

  @override
  Widget build(BuildContext context) {
    final directionality = Directionality.of(context);
    var padding = widget.padding.resolve(directionality);

    return TwoWayCustomScrollView(
      center: widget.controller._centerSliverKey,
      reverse: widget.reverse,
      slivers: [
        SliverToBoxAdapter(
          key: const Key('debugTopListBoundary'),
          child: widget.showDebugIndicators
              ? const _ListBoundaryDebugIndicator()
              : const SizedBox.shrink(),
        ),
        SliverToBoxAdapter(
          key: const Key('topPadding'),
          child: padding.top != 0
              ? SizedBox(height: padding.top)
              : const SizedBox.shrink(),
        ),
        SliverToBoxAdapter(
          key: const Key('top'),
          child: widget.top != null ? widget.top! : const SizedBox.shrink(),
        ),
        SliverAnimatedList(
          key: widget.controller._topSliverKey,
          findChildIndexCallback: (key) {
            final item = widget.controller._keyedItems[key];
            if (item == null) return null;
            return widget.controller._top.indexOf(item);
          },
          itemBuilder: (context, index, anim) {
            final item = widget.controller._top[index];
            final key = widget.controller._itemKeys[item]!;
            return _itemBuilder(context, key, item, anim);
          },
        ),
        KeyedSubtree(
          key: widget.controller._centerSliverKey,
          child: widget.centerSliver ??
              const SliverToBoxAdapter(child: SizedBox.shrink()),
        ),
        SliverAnimatedList(
          key: widget.controller._bottomSliverKey,
          findChildIndexCallback: (key) {
            final item = widget.controller._keyedItems[key];
            if (item == null) return null;
            return widget.controller._bottom.indexOf(item);
          },
          itemBuilder: (context, index, anim) {
            final item = widget.controller._bottom[index];
            final key = widget.controller._itemKeys[item]!;
            return _itemBuilder(context, key, item, anim);
          },
        ),
        SliverToBoxAdapter(
          key: const Key('bottom'),
          child:
              widget.bottom != null ? widget.bottom! : const SizedBox.shrink(),
        ),
        SliverToBoxAdapter(
          key: const Key('bottomPadding'),
          child: padding.bottom != 0
              ? SizedBox(height: padding.bottom)
              : const SizedBox.shrink(),
        ),
        SliverToBoxAdapter(
          key: const Key('debugBottomListBoundary'),
          child: widget.showDebugIndicators
              ? const _ListBoundaryDebugIndicator()
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _ListBoundaryDebugIndicator extends StatelessWidget {
  const _ListBoundaryDebugIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(height: 4, color: Colors.red);
  }
}
