import 'package:collection/collection.dart';
import 'package:test/test.dart';
import 'package:usda_db_creation/food_model.dart';

void main() {
  group('Food Model class tests', () {
    group('toJson()', () {
      test('toJson parses correctly', () {
        final nutrients = {'1004': 20, '1003': 10};

        final food = FoodModel(
          id: 111111,
          description: 'Food Item',
          categoryCode: 1800,
          nutrientsMap: nutrients,
        );

        final expectation = {
          '111111': {
            'd': 'Food Item',
            'c': 1800,
            'n': {'1004': 20, '1003': 10},
          },
        };

        final res = food.toJson();

        const d = DeepCollectionEquality();
        expect(d.equals(res, expectation), true);
      });
    });
    group('toJsonValue()', () {
      test('uses the single character keys d, c and n', () {
        const food = FoodModel(
          id: 111111,
          description: 'Food Item',
          categoryCode: 1800,
          nutrientsMap: {'1004': 20},
        );

        final res = food.toJsonValue();

        expect(res.keys, ['d', 'c', 'n']);
        expect(res['d'], 'Food Item');
        expect(res['c'], 1800);
        expect(res['n'], {'1004': 20});
      });
    });
    group('equality', () {
      test('foods differing only in categoryCode are not equal', () {
        const a = FoodModel(
          id: 1,
          description: 'Food Item',
          categoryCode: 1800,
          nutrientsMap: {'1004': 20},
        );
        const b = FoodModel(
          id: 1,
          description: 'Food Item',
          categoryCode: 1400,
          nutrientsMap: {'1004': 20},
        );

        expect(a, isNot(b));
      });
    });
  });
}
