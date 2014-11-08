library test_bot;

import 'dart:math' as math;
import 'package:bot/bot.dart';
import 'package:bot_test/bot_test.dart';
import 'package:unittest/unittest.dart';

import 'collection/_collection_test.dart' as collection;
import 'test_expand_stream.dart' as expand_stream;
import 'test_get_delayed_result.dart' as get_delayed_result;
import 'test_throttled_stream.dart' as throttled_stream;
import 'graph/topo_sort_test.dart' as topological;
import 'graph/tarjan_test.dart' as tarjan;

part 'test_tuple.dart';

part 'test_util.dart';
part 'math/test_coordinate.dart';
part 'math/test_vector.dart';
part 'math/test_affine_transform.dart';

part 'color/test_rgb_color.dart';
part 'color/test_hsl_color.dart';

void main() {
  group('bot', () {
    group('collection', collection.main);

    group('expandStream', expand_stream.main);
    group('getDelayedResult', get_delayed_result.main);
    group('ThrottledStream', throttled_stream.main);
    group('graph', () {
      group('topological', topological.main);
      group('tarjan', tarjan.main);
    });
    TestTuple.run();

    group('math', () {
      TestCoordinate.run();
      TestVector.run();
      TestAffineTransform.run();
    });

    TestUtil.run();

    TestRgbColor.run();
    TestHslColor.run();

    test('StringReader', _testStringReader);
  });
}

void _testStringReader() {
  _verifyValues('', [''], null);
  _verifyValues('Shanna', ['Shanna'], null);
  _verifyValues('Shanna\n', ['Shanna', ''], null);
  _verifyValues('\nShanna\n', ['', 'Shanna', ''], null);
  _verifyValues('\r\nShanna\n', ['', 'Shanna', ''], null);
  _verifyValues('\r\nShanna\r\n', ['', 'Shanna', ''], null);
  _verifyValues('\rShanna\r\n', ['\rShanna', ''], null);

  // a bit crazy. \r not before \n is not counted as a newline
  _verifyValues('\r\n\r\n\r\r\n\n', ['', '', '\r', '', ''], null);

  _verifyValues('line1\nline2\n\nthis\nis\the\rest\n', [
    'line1',
    'line2',
    ''
  ], 'this\nis\the\rest\n');
}

void _verifyValues(String input, List<String> output, String rest) {
  final sr = new StringLineReader(input);
  for (final value in output) {
    expect(sr.readNextLine(), value);
  }
  expect(sr.readToEnd(), rest, reason: 'rest did not match');
  expect(sr.readNextLine(), null, reason: 'future nextLines should be null');
  expect(sr.readToEnd(), null, reason: 'future readToEnd should be null');
}
