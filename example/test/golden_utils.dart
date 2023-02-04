import 'dart:async';
import 'dart:io';

import 'package:example/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

Finder findByKey(String key) => find.byKey(Key(key));

/// "+" = add
/// "-" = remove
/// "t" = top
/// "m" = middle
/// "b" = bottom
/// "px" = scroll pixels
/// "[<frames / millis(with "ms" at the end)>]" = pump a frame after <millis> milliseconds of <frames> frames
/// "[+]" = pump and settle
/// "+1t [+] -10px [1] -2b [+]" = add 1 item to top, pump&settle, scroll by -10px, pump 1 frame, remove 2 items from bottom, pump&settle
@isTest
void goldenTest(String test) {
  final actions = test
      .split(' ')
      .where((e) => e != '!')
      .where((e) => e != '(rev)')
      .where((e) => e.isNotEmpty)
      .toList();

  final reverse = test.contains('(rev)');

  if (actions.isEmpty) {
    _goldenTestSandboxTwoWayListView(
      reverse ? '! empty (rev)' : '! empty',
      (tester) {},
      reverse: reverse,
    );
    return;
  }
  _goldenTestSandboxTwoWayListView(test, (tester) async {
    const fps = 60;
    const microsPerFrame = 1000000 ~/ fps;
    const frameDuration = Duration(microseconds: microsPerFrame);

    for (final action in actions) {
      if (action.startsWith('[') && action.endsWith(']')) {
        var frames = int.tryParse(action.substring(1, action.length - 1)) ?? 0;

        var millis = 0;
        if (action.endsWith('ms]')) {
          millis = int.tryParse(action.substring(1, action.length - 3)) ?? 0;
        }
        if (millis > 0) {
          final micros = millis * 1000;
          frames = micros ~/ microsPerFrame;
        }

        if (frames <= 0) {
          await tester.pumpAndSettle(frameDuration);
        } else {
          for (var i = 0; i < frames; i++) {
            await tester.pump(frameDuration);
          }
          // Needed to ensure that all animation frames for a given duration has
          // been handled. Without it, the result will always look like the
          // expected result for `frames - 1`.
          await tester.pump(frameDuration);
        }
        continue;
      }

      final type = action.substring(0, 1);
      final amount = action.substring(1);

      int? topItemsAmount;
      int? middleItemsAmount;
      int? bottomItemsAmount;
      int? scrollPixelsAmount;

      if (amount.endsWith('px')) {
        scrollPixelsAmount = int.parse(amount.substring(0, amount.length - 2));
      } else if (amount.endsWith('t')) {
        topItemsAmount = int.parse(amount.substring(0, amount.length - 1));
      } else if (amount.endsWith('m')) {
        middleItemsAmount = int.parse(amount.substring(0, amount.length - 1));
      } else if (amount.endsWith('b')) {
        bottomItemsAmount = int.parse(amount.substring(0, amount.length - 1));
      } else {
        throw Exception('Unknown action: $action');
      }

      if (type == '+') {
        if (topItemsAmount != null) {
          for (var i = 0; i < topItemsAmount; i++) {
            await tester.tap(findByKey('add-first'));
          }
        } else if (middleItemsAmount != null) {
          throw Exception('Not implemented');
        } else if (bottomItemsAmount != null) {
          for (var i = 0; i < bottomItemsAmount; i++) {
            await tester.tap(findByKey('add-last'));
          }
        } else if (scrollPixelsAmount != null) {
          await tester.drag(
            findByKey('TwoWayListView'),
            Offset(0, -scrollPixelsAmount.toDouble()),
          );
        }
      } else if (type == '-') {
        if (topItemsAmount != null) {
          for (var i = 0; i < topItemsAmount; i++) {
            await tester.tap(findByKey('remove-first'));
          }
        } else if (middleItemsAmount != null) {
          throw Exception('Not implemented');
        } else if (bottomItemsAmount != null) {
          for (var i = 0; i < bottomItemsAmount; i++) {
            await tester.tap(findByKey('remove-last'));
          }
        } else if (scrollPixelsAmount != null) {
          await tester.drag(
            findByKey('TwoWayListView'),
            Offset(0, scrollPixelsAmount.toDouble()),
          );
        }
      } else {
        throw Exception('Unknown action: $action');
      }
    }
  }, reverse: reverse);
}

void _goldenTestSandboxTwoWayListView(
  String name,
  FutureOr<void> Function(WidgetTester tester) body, {
  bool reverse = false,
}) {
  testWidgets(name, (tester) async {
    await tester.pumpWidget(
      SandboxApp(reverse: reverse),
    );
    await body(tester);
    await expectLater(
      findByKey('TwoWayListView'),
      matchesGoldenFile('goldens/$name.png'),
    );
    await tester.pumpAndSettle();
  });
}

@isTest
void expectSameGoldens(List<String> tests, {String? desc}) {
  final testDesc = tests.join(' == ');
  test(testDesc, () {
    final files = tests.map((e) => File('test/goldens/$e.png')).toList();
    final fileBytes = <File, Uint8List>{};
    for (final file in files) {
      fileBytes[file] = file.readAsBytesSync();
    }
    for (var i = 0; i < files.length; i++) {
      for (var j = i + 1; j < files.length; j++) {
        final f1 = files[i];
        final f2 = files[j];
        final f1Name = f1.uri.pathSegments.last.replaceAll('.png', '');
        final f2Name = f2.uri.pathSegments.last.replaceAll('.png', '');

        try {
          expect(fileBytes[f1], fileBytes[f2]);
        } catch (e) {
          if (desc != null) {
            fail('Failed: ${desc.trim().replaceAll(RegExp(r'\s{2,}'), ' ')}');
          } else {
            fail('"$f1Name" != "$f2Name"');
          }
        }
      }
    }
  });
}
