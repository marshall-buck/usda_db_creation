import 'dart:io';

import 'package:test/test.dart';
import 'package:usda_db_creation/global_const.dart';

void main() {
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
      expect(foodCategories, fromCsv);
    });

    test('has no duplicate descriptions, so the reverse lookup is safe', () {
      expect(foodCategories.values.toSet().length, foodCategories.length);
    });

    test('covers every excluded category', () {
      for (final category in excludedCategories) {
        expect(foodCategories.values, contains(category));
      }
    });
  });
}
