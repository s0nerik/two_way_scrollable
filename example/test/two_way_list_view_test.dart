import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'golden_utils.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  binding.window.physicalSizeTestValue = const Size(300, 600);
  binding.window.devicePixelRatioTestValue = 1.0;

  setUpAll(loadAppFonts);

  goldenTest('');
  goldenTest('! (rev)');
  goldenTest('! +1000px');

  goldenTest('! [1]');
  goldenTest('! [1] (rev)');

  goldenTest('+1b [15]');
  goldenTest('+1b [250ms]');
  expectSameGoldens([
    '+1b [15]',
    '+1b [250ms]',
  ], desc: '250ms of pumps == 15 pumps');

  goldenTest('! +1b [+]');
  goldenTest('! +1t [+]');

  goldenTest('! +1b [+] (rev)');
  goldenTest('! +1t [+] (rev)');

  goldenTest('+2b [+]');
  goldenTest('+2b +1t [+]');

  goldenTest('+3b [+]');
  goldenTest('+3t [+]');

  goldenTest('+2t +3b [+] -2000px [+]');
  goldenTest('+3t +3b [+] -2000px [+]');
  goldenTest('! +2t +3b [+] +2000px [+]');
  goldenTest('! +3t +3b [+] +2000px [+]');
  expectSameGoldens([
    '! +2t +3b [+] +2000px [+]',
    '! +3t +3b [+] +2000px [+]',
  ], desc: 'There is no extra space below "bottom" sliver content');

  goldenTest('! +4t +4b [+] -2000px [+]');
  goldenTest('! +4t +4b [+] +2000px [+]');

  goldenTest('! +4b [+]');
  goldenTest('! +4t [+]');

  goldenTest('! +4b [+] (rev)');
  goldenTest('! +4t [+] (rev)');

  goldenTest('+4b [+] +2t [+]');
  goldenTest('+4b [+] +2t [+] +1000px [+]');
  goldenTest('+4b [+] +2t [+] -1000px [+]');
  goldenTest('+4b [+] +2t [+] -3b [+]');
  goldenTest('+4b [+] +2t [+] -3b [+] +100px [+]');
  goldenTest('+4b [+] +2t [+] -4b [+]');
  goldenTest('+4b [+] +2t [+] -5b [+]');

  goldenTest('+100b [+] +100t [+]');
  goldenTest('+100t [+] +100b [+]');
}
