import 'dart:convert';

import 'package:test/test.dart';
import 'package:usda_db_creation/nutrient.dart';

// import 'setup/mock_data.dart';

void main() {
  group('Nutrient class tests', () {
    group('toEntry()', () {
      test('Matches MapEntry<int, num>', () {
        const nutrient = Nutrient(id: 1004, amount: .55);

        final entry = nutrient.toEntry();
        expect(entry, isA<MapEntry<int, num>>());
      });
      test('Map equals entry', () {
        const nutrient = Nutrient(id: 1004, amount: .55);
        final entry = nutrient.toEntry();
        expect(entry.key, 1004);
        expect(entry.value, .55);
      });
    });
    group('toJson', () {
      test('Map entry will covert to json string without errors', () {
        const nutrient = Nutrient(id: 1004, amount: .55);
        const nutrient1 = Nutrient(id: 1005, amount: 10);
        final nutrientsMap = <String, num>{}..addEntries([nutrient.toJson(), nutrient1.toJson()]);

        final jsonString = jsonEncode(nutrientsMap);
        expect(jsonString, isA<String>());
      });
    });
    group('fromJsonEntry', () {
      test('Map entry will covert jsonEntry to Nutrient  ', () {
        final jsonEntries = {'1004': 0.55, '1005': 10}.entries;
        final e1 = jsonEntries.first;
        final e2 = jsonEntries.last;

        final nutrient = Nutrient.fromJsonEntry(e1);
        final nutrient1 = Nutrient.fromJsonEntry(e2);
        expect(nutrient.id, 1004);
        expect(nutrient.amount, 0.55);
        expect(nutrient1, isA<Nutrient>());
        expect(nutrient1.id, 1005);
        expect(nutrient1.amount, 10);
      });
    });
  });
}
