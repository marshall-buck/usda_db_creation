import 'package:collection/collection.dart';
import 'package:test/test.dart';
import 'package:usda_db_creation/extensions/map_ext.dart';

void main() {
  group('MapExtensions', () {
    group('convertMapKeyToString()', () {
      test('should convert int keys to string keys', () {
        final map = {
          1: 'one',
          2: 'two',
          3: {'4': 'four'},
        };
        final result = map.deepConvertMapKeyToString();

        // expect(result, isA<Map<String, dynamic>>());

        const deep = DeepCollectionEquality();
        expect(
          deep.equals(result, {
            '1': 'one',
            '2': 'two',
            '3': {'4': 'four'},
          }),
          true,
        );
        expect(
          deep.equals(result, {
            '1': 'one',
            '2': 'two',
            3: {'4': 'four'},
          }),
          false,
        );
      });

      test('should handle nested maps', () {
        final map = {
          1: 'one',
          2: {
            3: {
              4: [1, 2, 3, 4],
            },
          },
        };
        final result = map.deepConvertMapKeyToString();

        expect(result['2'], isA<Map<dynamic, dynamic>>());
        expect((result['2']! as Map<dynamic, dynamic>).keys, contains('3'));

        const deep = DeepCollectionEquality();
        expect(
          deep.equals(result, {
            '1': 'one',
            '2': {
              '3': {
                '4': [1, 2, 3, 4],
              },
            },
          }),
          true,
        );
        expect(
          deep.equals(result, {
            '1': 'one',
            '2': {
              '3': {
                4: [1, 2, 3, 4],
              },
            },
          }),
          false,
        );
      });
      // test('should skip keys value, but change the key', () {
      //   final map = {
      //     1: 'one',
      //     2: {
      //       3: {
      //         4: [1, 2, 3, 4],
      //         "5": 9
      //       }
      //     },
      //     '3': 'as'
      //   };
      //   final result = map.deepConvertMapKeyToString(
      //       keyMatch: ((key) => key == 3), changeKey: true);

      //   expect(result['2'], isA<Map<dynamic, dynamic>>());

      //   final deep = DeepCollectionEquality();
      //   expect(
      //       deep.equals(result, {
      //         '1': 'one',
      //         '2': {
      //           '3': {
      //             4: [1, 2, 3, 4],
      //             "5": 9
      //           }
      //         },
      //         '3': 'as'
      //       }),
      //       true);
      // });
      // test('should skip keys value, and not change the key', () {
      //   final map = {
      //     1: 'one',
      //     2: {
      //       3: {
      //         4: [1, 2, 3, 4],
      //         '5': 9
      //       }
      //     },
      //     '3': 'as',
      //     4: 0
      //   };
      //   final result = map.deepConvertMapKeyToString(
      //       keyMatch: ((key) => key == 3), changeKey: false);
      //   print('result: $result');

      //   // expect(result["2"], isA<Map<int, dynamic>>());
      //   print('result 2: ${result['2']}');

      //   final deep = DeepCollectionEquality();
      //   expect(
      //       deep.equals(result, {
      //         '1': 'one',
      //         '2': {
      //           3: {
      //             4: [1, 2, 3, 4],
      //             '5': 9
      //           }
      //         },
      //         '3': 'as',
      //         '4': 0
      //       }),
      //       true);
      // });
    });
    group('convertStringKeysToInts', () {
      test('should convert string keys to int keys', () {
        final map = {
          '1123': 'one',
          '2': 'two',
          '3': {'4': 'four'},
        };
        final result = map.deepConvertMapKeyToInt();
        const deep = DeepCollectionEquality();
        expect(
          deep.equals(result, {
            1123: 'one',
            2: 'two',
            3: {4: 'four'},
          }),
          true,
        );
      });

      test('should handle nested maps', () {
        final map = {
          '1': 'one',
          '2': {
            '3': {'4': 'four'},
          },
        };
        final result = map.deepConvertMapKeyToInt();
        const deep = DeepCollectionEquality();
        expect(
          deep.equals(result, {
            1: 'one',
            2: {
              3: {4: 'four'},
            },
          }),
          true,
        );
      });

      test('should ignore non-string keys', () {
        final map = {1: 'one', '2': 'two', '3': true};
        final result = map.deepConvertMapKeyToInt();
        const deep = DeepCollectionEquality();
        expect(deep.equals(result, {1: 'one', 2: 'two', 3: true}), true);
      });

      test('should ignore non-integer string keys', () {
        final map = {'a': 'alpha', '2': 'two', '3b': 'threeB'};
        final result = map.deepConvertMapKeyToInt();
        const deep = DeepCollectionEquality();
        expect(
          deep.equals(result, {'a': 'alpha', 2: 'two', '3b': 'threeB'}),
          true,
        );
      });
    });
  });
}
