import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:random_color/random_color.dart';
import 'package:two_way_scrollable/two_way_scrollable.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
  runApp(const SandboxApp());
}

class SandboxApp extends StatelessWidget {
  const SandboxApp({
    super.key,
    this.reverse = false,
  });

  final bool reverse;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: _Content(
        fillCenterFirst: true,
        reverse: reverse,
      ),
    );
  }
}

class _Content extends StatefulWidget {
  const _Content({
    Key? key,
    required this.fillCenterFirst,
    required this.reverse,
  }) : super(key: key);

  final bool fillCenterFirst;
  final bool reverse;

  @override
  State<_Content> createState() => _ContentState();
}

class _ContentState extends State<_Content> {
  var ctrl = TwoWayListViewController<int>();

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
      title: const Text('CustomScrollView with `center`'),
      centerTitle: false,
      actions: [
        const Icon(Icons.add_circle),
        const SizedBox(width: 8),
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
          child: const Icon(Icons.arrow_upward),
        ),
        const SizedBox(width: 8),
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
          child: const Icon(Icons.arrow_downward),
        ),
        const SizedBox(width: 24),
        const Icon(Icons.remove_circle),
        const SizedBox(width: 8),
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
          child: const Icon(Icons.arrow_upward),
        ),
        const SizedBox(width: 8),
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
          child: const Icon(Icons.arrow_downward),
        ),
        const SizedBox(width: 24),
        InkResponse(
          key: const ValueKey('refresh'),
          onTap: () => setState(() {
            ctrl = TwoWayListViewController<int>();
          }),
          child: const Icon(Icons.refresh),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget buildListView() {
    return TwoWayListView(
      controller: ctrl,
      showDebugIndicators: true,
      padding: const EdgeInsets.symmetric(vertical: 16),
      reverse: widget.reverse,
      centerSliver: SliverToBoxAdapter(
        child: SizedBox(
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
        ),
      ),
      itemBuilder: (context, item, anim) =>
          _Item(ctrl: ctrl, item: item, animation: anim),
    );
  }
}

class _Item extends StatefulWidget {
  const _Item({
    Key? key,
    required this.ctrl,
    required this.item,
    required this.animation,
  }) : super(key: key);

  final TwoWayListViewController<int> ctrl;
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
