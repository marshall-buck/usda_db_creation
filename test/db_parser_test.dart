import 'package:collection/collection.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:usda_db_creation/db_parser.dart';
import 'package:usda_db_creation/file_service.dart';

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
          final description = food['d'];
          final categoryCode = food['c'];
          final nutrientMap = food['n'];

          expect(nutrientMap, isA<Map<String, num>>());
          expect(description, isA<String>());
          expect(categoryCode, isA<int>());
          // print('entry value: ${entry.value} \n');
        }
        expect((res['167512'] as Map<String, dynamic>)['c'], 1800);
        expect((res['167514'] as Map<String, dynamic>)['c'], 1400);
      });
    });

    group('createFoodsMapDB() category - ', () {
      test('throws a StateError when a food category is not in FoodModel.foodCategories', () {
        final unknownCategoryFile = mockUsdaFile.replaceFirst(
          '"description": "Beverages"',
          '"description": "Not A Category"',
        );
        when(() => mockFileLoaderService.loadData(filePath: 'fake'))
            .thenReturn(unknownCategoryFile);
        final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);

        expect(
          () => dbParser.createFoodsMapDB(
            getFoodsList: dbParser.originalFoodsList,
            finalDescriptionRecordsMap: mockDescriptionMap,
          ),
          throwsStateError,
        );
      });

      test('does not check the category of foods missing from the description map', () {
        final unknownCategoryFile = mockUsdaFile.replaceFirst(
          '"description": "Beverages"',
          '"description": "Not A Category"',
        );
        when(() => mockFileLoaderService.loadData(filePath: 'fake'))
            .thenReturn(unknownCategoryFile);
        final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);

        final res = dbParser.createFoodsMapDB(
          getFoodsList: dbParser.originalFoodsList,
          finalDescriptionRecordsMap: {167512: mockDescriptionMap[167512]!},
        );

        expect(res.keys, ['167512']);
      });
    });

    group('DB.createDataStructure() - ', () {
      setUp(() {
        when(() => mockFileLoaderService.loadData(filePath: 'fake')).thenReturn(mockUsdaFile);
        when(
          () => mockFileLoaderService.writeFileByType(
            fileName: any(named: 'fileName'),
            convertKeysToStrings: any(named: 'convertKeysToStrings'),
            mapContents: any(named: 'mapContents'),
          ),
        ).thenAnswer((_) async {});
      });

      test('writes only foods_db by default', () async {
        final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);

        final res = await DB(mockDescriptionMap).createDataStructure(dbParser: dbParser);

        expect(res, isNull);
        verify(
          () => mockFileLoaderService.writeFileByType(
            fileName: FileService.fileNameFoodsDatabase,
            convertKeysToStrings: false,
            mapContents: any(named: 'mapContents'),
          ),
        ).called(1);
        verifyNever(
          () => mockFileLoaderService.writeFileByType(
            fileName: any(named: 'fileName', that: isNot(FileService.fileNameFoodsDatabase)),
            convertKeysToStrings: any(named: 'convertKeysToStrings'),
            mapContents: any(named: 'mapContents'),
          ),
        );
      });

      test('writes nothing when writeFile is false', () async {
        final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);

        final res = await DB(mockDescriptionMap).createDataStructure(
          dbParser: dbParser,
          writeFile: false,
          returnData: true,
        );

        expect(res!.length, 3);
        verifyNever(
          () => mockFileLoaderService.writeFileByType(
            fileName: any(named: 'fileName'),
            convertKeysToStrings: any(named: 'convertKeysToStrings'),
            mapContents: any(named: 'mapContents'),
          ),
        );
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
