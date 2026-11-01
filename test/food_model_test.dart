import 'dart:io';

import 'package:collection/collection.dart';
import 'package:test/test.dart';
import 'package:usda_db_creation/food_model.dart';
import 'package:usda_db_creation/global_const.dart';

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

    group('foodCategories', () {
      test('matches every code and description in food_category.csv', () {
        final rows = File('food_category.csv')
            .readAsLinesSync()
            .skip(1)
            .where((line) => line.trim().isNotEmpty)
            .map((line) {
          final match = RegExp(r'^"\d+","(\d+)","(.*)"$').firstMatch(line)!;
          return MapEntry(int.parse(match.group(1)!), match.group(2)!);
        });
        final fromCsv = Map.fromEntries(rows);

        expect(fromCsv.length, 28);
        expect(FoodModel.foodCategories, fromCsv);
      });

      test('has no duplicate descriptions, so the reverse lookup is safe', () {
        expect(
          FoodModel.foodCategories.values.toSet().length,
          FoodModel.foodCategories.length,
        );
      });

      test('covers every excluded category', () {
        for (final category in excludedCategories) {
          expect(FoodModel.foodCategories.values, contains(category));
        }
      });
    });
  });
}
