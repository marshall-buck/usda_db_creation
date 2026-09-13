import 'package:collection/collection.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:usda_db_creation/db_parser.dart';

import 'package:usda_db_creation/nutrient.dart';

import 'setup/mock_data.dart';
import 'setup/mock_db.dart';
import 'setup/mock_food_nutrients.dart';
import 'setup/setup.dart';

void main() {
  setUpAll(set_up_all);

  tearDown(tear_down);
  group('DBParser class tests', () {
    group('init() - ', () {
      test('loads USDA json file correctly, by populating _originalDBMap correctly', () {
        when(() => mockFileLoaderService.loadData(filePath: 'fake')).thenReturn(mockUsdaFile);
        final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);

        final res = dbParser.originalFoodsList;

        expect(res.length, 3);
      });
    });
    group('createNutrientsMap() - ', () {
      test('creates nutrients list correctly', () {
        when(() => mockFileLoaderService.loadData(filePath: 'fake')).thenReturn(mockUsdaFile);
        final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);
        final result = dbParser.createNutrientsMap(listOfNutrients: mockFoodNutrients);

        for (final entry in result.entries) {
          final nutrient = Nutrient.fromJsonEntry(MapEntry(entry.key, entry.value));
          expect(Nutrient.keepTheseNutrients.contains(nutrient.id), true);
          expect(nutrient.amount, greaterThan(0));
          expect(nutrient.id, isNot(9999));
        }
      });
    });
    group('createFoodsMap() - ', () {
      test('createFoodsMap correctly', () {
        when(() => mockFileLoaderService.loadData(filePath: 'fake')).thenReturn(mockUsdaFile);

        final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);

        final originalFoodsList = dbParser.originalFoodsList;

        final res = dbParser.createFoodsMapDB(
          getFoodsList: originalFoodsList,
          finalDescriptionRecordsMap: mockDescriptionMap,
        );
        // print(res);
        for (final entry in res.entries) {
          // expect(entry.key, isA<String>());
          final food = entry.value as Map<String, dynamic>;
          final description = food['description'];
          final nutrientMap = food['nutrients'];

          expect(nutrientMap, isA<Map<String, num>>());
          expect(description, isA<String>());
          // print('entry value: ${entry.value} \n');
        }
      });
    });

    group('getFoodCategories()', () {
      test('should return a map of food categories and their counts', () {
        when(() => mockFileLoaderService.loadData(filePath: 'fake')).thenReturn(mockUsdaFile);
        final expected = {'Baked Products': 2, 'Beverages': 1, 'total': 3};

        final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);
        const d = DeepCollectionEquality();
        final res = dbParser.getFoodCategories();
        expect(d.equals(res, expected), true);
      });
    });
  });
}
