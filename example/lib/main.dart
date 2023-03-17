import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:random_color/random_color.dart';
import 'package:two_way_scrollable/two_way_scrollable.dart';
import 'package:window_size/window_size.dart';

const _macosTitlebarHeight = 22.0;
const _windowSize = Size(300, 600 + _macosTitlebarHeight);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  setWindowMinSize(_windowSize);
  setWindowMaxSize(_windowSize);
  runApp(const SandboxApp());
}

class SandboxApp extends StatelessWidget {
  const SandboxApp({
    super.key,
    this.anchor = TwoWayListViewAnchor.top,
    this.direction = TwoWayListViewDirection.topToBottom,
  });

  final TwoWayListViewAnchor anchor;
  final TwoWayListViewDirection direction;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _Content(
        anchor: anchor,
        direction: direction,
      ),
    );
  }
}

class _Content extends StatefulWidget {
  const _Content({
    Key? key,
    required this.anchor,
    required this.direction,
  }) : super(key: key);

  final TwoWayListViewAnchor anchor;
  final TwoWayListViewDirection direction;

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  var ctrl = TwoWayListController<int>();

  late var anchor = widget.anchor;
  late var direction = widget.direction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: RepaintBoundary(
        child: Stack(
          key: const Key('TwoWayListView'),
          children: [
            Container(color: Colors.white),
            buildListView(),
          ],
        ),
      ),
    );
  }

  AppBar buildAppBar() {
    return AppBar(
      centerTitle: false,
      actions: [
        const Icon(MdiIcons.plusBox),
        InkResponse(
          key: const ValueKey('add-first'),
          onTap: () {
            final first = ctrl.items.firstOrNull;
            ctrl.insert(-1, first != null ? first - 1 : -1);
          },
          onLongPress: () {
            final first = ctrl.items.firstOrNull ?? 0;
            final items = List.generate(10, (i) => first - i - 1);
            ctrl.insertAll(-1, items.reversed.toList());
          },
          child: const Icon(MdiIcons.triangleSmallUp),
        ),
        InkResponse(
          key: const ValueKey('add-last'),
          onTap: () {
            final last = ctrl.items.lastOrNull;
            ctrl.insert(ctrl.items.length, last != null ? last + 1 : 0);
          },
          onLongPress: () {
            final last = ctrl.items.lastOrNull ?? -1;
            final items = List.generate(10, (i) => last + i + 1);
            ctrl.insertAll(ctrl.items.length, items);
          },
          child: const Icon(MdiIcons.triangleSmallDown),
        ),
        const SizedBox(width: 8),
        const Icon(MdiIcons.minusBox),
        InkResponse(
          key: const ValueKey('remove-first'),
          onTap: () {
            final item = ctrl.items.firstOrNull;
            if (item == null) return;
            ctrl.remove(item);
          },
          onLongPress: () {
            for (var i = 0; i < 10; i++) {
              final item = ctrl.items.firstOrNull;
              if (item == null) return;
              ctrl.remove(item);
            }
          },
          child: const Icon(MdiIcons.triangleSmallUp),
        ),
        InkResponse(
          key: const ValueKey('remove-last'),
          onTap: () {
            final item = ctrl.items.lastOrNull;
            if (item == null) return;
            ctrl.remove(item);
          },
          onLongPress: () {
            for (var i = 0; i < 10; i++) {
              final item = ctrl.items.lastOrNull;
              if (item == null) return;
              ctrl.remove(item);
            }
          },
          child: const Icon(MdiIcons.triangleSmallDown),
        ),
        const SizedBox(width: 8),
        InkResponse(
          key: const ValueKey('anchor'),
          onTap: () => setState(() {
            _swapAnchor();
          }),
          child: anchor == TwoWayListViewAnchor.top
              ? const Icon(MdiIcons.alignVerticalTop)
              : const Icon(MdiIcons.alignVerticalBottom),
        ),
        const SizedBox(width: 8),
        InkResponse(
          key: const ValueKey('direction'),
          onTap: () => setState(() {
            _swapDirection();
          }),
          child: direction == TwoWayListViewDirection.topToBottom
              ? const Icon(MdiIcons.sortAscending)
              : const Icon(MdiIcons.sortDescending),
        ),
        const SizedBox(width: 8),
        InkResponse(
          key: const ValueKey('reverse'),
          onTap: () => setState(() {
            _swapAnchor();
            _swapDirection();
          }),
          child: const Icon(MdiIcons.swapVertical),
        ),
        const SizedBox(width: 8),
        InkResponse(
          key: const ValueKey('refresh'),
          onTap: () => setState(() {
            ctrl = TwoWayListController<int>();
            direction = TwoWayListViewDirection.topToBottom;
            anchor = TwoWayListViewAnchor.top;
          }),
          child: const Icon(MdiIcons.refresh),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  void _swapAnchor() {
    switch (anchor) {
      case TwoWayListViewAnchor.top:
        anchor = TwoWayListViewAnchor.bottom;
        break;
      case TwoWayListViewAnchor.bottom:
        anchor = TwoWayListViewAnchor.top;
        break;
    }
  }

  void _swapDirection() {
    switch (direction) {
      case TwoWayListViewDirection.topToBottom:
        direction = TwoWayListViewDirection.bottomToTop;
        break;
      case TwoWayListViewDirection.bottomToTop:
        direction = TwoWayListViewDirection.topToBottom;
        break;
    }
  }

  Widget buildListView() {
    return TwoWayListView(
      controller: ctrl,
      anchor: anchor,
      direction: direction,
      topSlivers: const [
        SliverToBoxAdapter(
          child: _DebugListBoundaryIndicator(),
        ),
        SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),
      ],
      centerSliver: const SliverToBoxAdapter(
        child: _DebugCenterIndicator(),
      ),
      bottomSlivers: const [
        SliverToBoxAdapter(
          child: SizedBox(height: 16),
        ),
        SliverToBoxAdapter(
          child: _DebugListBoundaryIndicator(),
        ),
      ],
      itemBuilder: (context, index, item, anim) =>
          _Item(ctrl: ctrl, item: item, animation: anim),
    );
  }
}

class _DebugCenterIndicator extends StatelessWidget {
  const _DebugCenterIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(child: Container(color: Colors.red)),
          Expanded(child: Container(color: Colors.orange)),
          Expanded(child: Container(color: Colors.yellow)),
          Expanded(child: Container(color: Colors.green)),
          Expanded(child: Container(color: Colors.lightBlue)),
          Expanded(child: Container(color: Colors.blue)),
          Expanded(child: Container(color: Colors.purple)),
        ],
      ),
    );
  }
}

class _DebugListBoundaryIndicator extends StatelessWidget {
  const _DebugListBoundaryIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(height: 4, color: Colors.red);
  }
}

class _Item extends StatefulWidget {
  const _Item({
    Key? key,
    required this.ctrl,
    required this.item,
    required this.animation,
  }) : super(key: key);

  final TwoWayListController<int> ctrl;
  final int item;
  final Animation<double> animation;

  @override
  State<_Item> createState() => _ItemState();
}

class _ItemState extends State<_Item> {
  var initialized = false;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() {
          initialized = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemIndex = widget.ctrl.items.indexOf(widget.item);
    final centerIndex = widget.ctrl.centerIndex;

    final rand = RandomColor(widget.item);
    late final Color color;
    if (itemIndex < 0) {
      color = Colors.grey[700]!;
    } else if (itemIndex < centerIndex) {
      color = rand.randomColor(
        colorHue: ColorHue.yellow,
        colorBrightness: ColorBrightness.veryLight,
        colorSaturation: ColorSaturation.mediumSaturation,
      );
    } else {
      color = rand.randomColor(
        colorHue: ColorHue.blue,
        colorBrightness: ColorBrightness.veryLight,
        colorSaturation: ColorSaturation.mediumSaturation,
      );
    }

    return SizeTransition(
      sizeFactor: widget.animation,
      axisAlignment: 0,
      child: Container(
        alignment: Alignment.center,
        color: color,
        height: 100 + widget.item % 4 * 60.0,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Item: ${widget.item}'),
            if (!initialized)
              Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.only(left: 16, right: 16),
                child: const CircularProgressIndicator(color: Colors.black),
              ),
            if (initialized)
              IconButton(
                key: ValueKey('remove:${widget.item}'),
                icon: const Icon(Icons.delete),
                onPressed: () => widget.ctrl.remove(widget.item),
              )
          ],
        ),
      ),
    );
  }
}
