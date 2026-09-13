import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:usda_db_creation/db_parser.dart';
import 'package:usda_db_creation/word_index.dart';

import 'setup/mock_data.dart';
import 'setup/mock_db.dart';
import 'setup/setup.dart';

void main() {
  setUpAll(set_up_all);

  tearDown(tear_down);
  group('WordIndexMap class tests', () {
    group('createDataStructure()', () {
      test('createDataStructure should return the correct index map', () async {
        const expectation = {
          '100%': [167513],
          '2%': [167514],
          'artificial': [167512],
          'bake': [167514],
          'biscuits': [167512],
          'buttermilk': [167512],
          'cinnamon': [167513],
          'coating': [167514],
          'dough': [167512, 167513],
          'dry': [167514],
          'flavor': [167512],
          'foods': [167514],
          'golden': [167512],
          'icing': [167513],
          'kraft': [167514],
          'layer': [167512],
          'milk': [167514],
          'original': [167514],
          'pillsbury': [167512, 167513],
          'pork': [167514],
          'recipe': [167514],
          'refrigerated': [167512, 167513],
          'rolls': [167513],
          'shake': [167514],
        };

        when(() => mockFileLoaderService.loadData(filePath: 'fake')).thenReturn(mockUsdaFile);
        when(() => mockFileLoaderService.outputFolderName)
            .thenReturn(DateTime.now().microsecondsSinceEpoch.toString());
        final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);
        final words = WordIndexMap(mockDescriptionMap);

        final indexMap = await words.createDataStructure(dbParser: dbParser);

        const deepEquals = DeepCollectionEquality();
        expect(deepEquals.equals(expectation, indexMap), true);
      });
      test('createDataStructure should handle empty description map', () async {
        when(() => mockFileLoaderService.loadData(filePath: 'fake')).thenReturn(mockUsdaFile);
        when(() => mockFileLoaderService.outputFolderName)
            .thenReturn(DateTime.now().microsecondsSinceEpoch.toString());
        final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);
        final descriptionMap = <int, String>{};
        final words = WordIndexMap(descriptionMap);

        final indexMap = await words.createDataStructure(dbParser: dbParser);

        expect(indexMap, isA<SplayTreeMap<String, List<int>>>());

        expect(indexMap!.isEmpty, true);
      });

      test('createDataStructure should handle description map with stop words', () async {
        final descriptionMap = {
          167782: 'apple is a fruit',
          173175: 'apples are delicious',
          171686: 'orange being is a citrus fruit',
        };
        when(() => mockFileLoaderService.loadData(filePath: 'fake')).thenReturn(mockUsdaFile);
        when(() => mockFileLoaderService.outputFolderName)
            .thenReturn(DateTime.now().microsecondsSinceEpoch.toString());
        final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);
        final words = WordIndexMap(descriptionMap);

        final indexMap = await words.createDataStructure(dbParser: dbParser);

        expect(indexMap, isA<SplayTreeMap<String, List<int>>>());
        expect(indexMap?.length, 6);
        expect(indexMap?['apple'], containsAll([167782]));
        expect(indexMap?['apples'], containsAll([173175]));
        expect(indexMap?['orange'], containsAll([171686]));
        expect(indexMap?['are'], isNull);
        expect(indexMap?['being'], isNull);
      });
      test('createDataStructure should strip remaining parentheses and numbers and /es', () async {
        final descriptionMap = {
          167782: 'apple 18fat is a (fruit 1/8',
          173175: 'apples are delicious) 200 aa 11g',
          171686: 'orange being is a citrus/fruit 100%',
        };

        when(() => mockFileLoaderService.loadData(filePath: 'fake')).thenReturn(mockUsdaFile);
        when(() => mockFileLoaderService.outputFolderName)
            .thenReturn(DateTime.now().microsecondsSinceEpoch.toString());
        final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);
        final words = WordIndexMap(descriptionMap);

        final indexMap = await words.createDataStructure(dbParser: dbParser);

        expect(indexMap, isA<SplayTreeMap<String, List<int>>>());
        expect(indexMap?.length, 7);
        expect(indexMap?['apple'], containsAll([167782]));
        expect(indexMap?['apples'], containsAll([173175]));
        expect(indexMap?['orange'], containsAll([171686]));
        expect(indexMap?['100%'], containsAll([171686]));
        expect(indexMap?['200'], isNull);
        expect(indexMap?['(fruit'], isNull);
        expect(indexMap?['delicious)'], isNull);
      });
      test('fileLoader writeFileByType is called when writeFile is true', () async {
        final descriptionMap = {
          167782: 'apple 18fat is a (fruit 1/8',
          173175: 'apples are delicious) 200 aa 11g',
          171686: 'orange being is a citrus/fruit 100%',
        };
        when(() => mockFileLoaderService.loadData(filePath: 'fake')).thenReturn(mockUsdaFile);
        when(() => mockFileLoaderService.outputFolderName)
            .thenReturn(DateTime.now().microsecondsSinceEpoch.toString());

        when(
          () => mockFileLoaderService.writeFileByType(
            fileName: any<String>(
              named: 'fileName',
            ),
            convertKeysToStrings: false,
            mapContents: any<SplayTreeMap<String, List<int>>>(named: 'mapContents'),
          ),
        ).thenAnswer((_) async {});

        final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);

        final words = WordIndexMap(descriptionMap);

        await words.createDataStructure(
          dbParser: dbParser,
          writeFile: true,
          returnData: false,
        );

        verify(
          () => mockFileLoaderService.writeFileByType(
            fileName: any<String>(named: 'fileName'),
            convertKeysToStrings: false,
            mapContents: any<SplayTreeMap<String, List<int>>>(named: 'mapContents'),
          ),
        ).called(1);
      });
      test('fileLoader methods are not called when writeFile is false', () async {
        final descriptionMap = {
          167782: 'apple 18fat is a (fruit 1/8',
          173175: 'apples are delicious) 200 aa 11g',
          171686: 'orange being is a citrus/fruit 100%',
        };
        when(() => mockFileLoaderService.loadData(filePath: 'fake')).thenReturn(mockUsdaFile);
        when(() => mockFileLoaderService.outputFolderName)
            .thenReturn(DateTime.now().microsecondsSinceEpoch.toString());

        when(
          () => mockFileLoaderService.writeFileByType(
            fileName: any<String>(
              named: 'fileName',
            ),
            convertKeysToStrings: false,
            mapContents: any<SplayTreeMap<String, List<int>>>(named: 'mapContents'),
          ),
        ).thenAnswer((_) async {});

        final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);

        final words = WordIndexMap(descriptionMap);

        await words.createDataStructure(
          dbParser: dbParser,
        );

        verifyNever(
          () => mockFileLoaderService.writeFileByType(
            fileName: any<String>(named: 'fileName'),
            convertKeysToStrings: false,
            mapContents: any<SplayTreeMap<String, List<int>>>(named: 'mapContents'),
          ),
        );
      });
      test('Throws ArgumentError', () async {
        final descriptionMap = {
          167782: 'apple 18fat is a (fruit 1/8',
          173175: 'apples are delicious) 200 aa 11g',
          171686: 'orange being is a citrus/fruit 100%',
        };
        when(() => mockFileLoaderService.loadData(filePath: 'fake')).thenReturn(mockUsdaFile);
        when(() => mockFileLoaderService.outputFolderName)
            .thenReturn(DateTime.now().microsecondsSinceEpoch.toString());

        final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);

        final words = WordIndexMap(descriptionMap);

        expect(
          () async => await words.createDataStructure(
            dbParser: dbParser,
            returnData: false,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
