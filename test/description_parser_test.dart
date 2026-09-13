import 'package:collection/collection.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'package:usda_db_creation/db_parser.dart';
import 'package:usda_db_creation/description_parser.dart';

import 'setup/mock_data.dart';
import 'setup/mock_db.dart';
import 'setup/setup.dart';

void main() {
  setUpAll(set_up_all);

  tearDown(tear_down);
  group('DescriptionParser class tests', () {
    group('createDataStructure()', () {
      test('coverts list of descriptions records to map', () async {
        when(() => mockFileLoaderService.loadData(filePath: 'fake')).thenReturn(mockUsdaFile);
        when(() => mockFileLoaderService.folderHash).thenReturn(DateTime.now().microsecondsSinceEpoch.toString());

        const expected = {
          167512: 'Pillsbury Golden Layer Buttermilk Biscuits, Artificial Flavor, refrigerated dough',
          167513: 'Pillsbury, Cinnamon Rolls with Icing, refrigerated dough',
          // excluded category
          // 167514:
          //     "Kraft Foods, Shake N Bake Original Recipe, Coating for Pork, dry"
        };

        final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);

        final descriptions = DescriptionParser();
        final res = await descriptions.createDataStructure(dbParser: dbParser);
        // print(res);
        const mapEquals = MapEquality<int, String>();
        expect(mapEquals.equals(expected, res), true);
        verifyNever(
          () => mockFileLoaderService.writeFileByType<List<DescriptionRecord>, Map<int, String>>(
            fileName: 'descriptions',
            convertKeysToStrings: true,
            mapContents: any<Map<int, String>>(named: 'mapContents'),
            listContents: any<List<DescriptionRecord>>(named: 'listContents'),
          ),
        );
      });

      test('fileLoader writeFileByType is called when writeFile is true', () async {
        when(() => mockFileLoaderService.loadData(filePath: 'fake')).thenReturn(mockUsdaFile);
        when(() => mockFileLoaderService.folderHash).thenReturn(DateTime.now().microsecondsSinceEpoch.toString());

        when(
          () => mockFileLoaderService.writeFileByType<List<DescriptionRecord>, Map<int, String>>(
            fileName: any<String>(
              named: 'fileName',
            ),
            convertKeysToStrings: true,
            listContents: any<List<DescriptionRecord>>(named: 'listContents'),
            mapContents: any<Map<int, String>>(named: 'mapContents'),
          ),
        ).thenAnswer((_) async {});

        final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);

        final descriptions = DescriptionParser();
        await descriptions.createDataStructure(
          dbParser: dbParser,
          returnData: false,
          writeFile: true,
        );

        verify(
          () => mockFileLoaderService.writeFileByType<List<DescriptionRecord>, Map<int, String>>(
            fileName: 'descriptions',
            convertKeysToStrings: true,
            mapContents: any<Map<int, String>>(named: 'mapContents'),
            listContents: any<List<DescriptionRecord>>(named: 'listContents'),
          ),
        ).called(1);
      });
      test('fileLoader methods are not called when writeFile is false', () async {
        when(() => mockFileLoaderService.loadData(filePath: 'fake')).thenReturn(mockUsdaFile);
        when(() => mockFileLoaderService.folderHash).thenReturn(DateTime.now().microsecondsSinceEpoch.toString());

        when(
          () => mockFileLoaderService.writeFileByType<List<DescriptionRecord>, Map<int, String>>(
            fileName: any<String>(
              named: 'fileName',
            ),
            convertKeysToStrings: true,
            listContents: any<List<DescriptionRecord>>(named: 'listContents'),
            mapContents: any<Map<int, String>>(named: 'mapContents'),
          ),
        ).thenAnswer((_) async {});

        final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);

        final descriptions = DescriptionParser();
        await descriptions.createDataStructure(
          dbParser: dbParser,
        );

        verifyNever(
          () => mockFileLoaderService.writeFileByType<List<DescriptionRecord>, Map<int, String>>(
            fileName: 'descriptions',
            convertKeysToStrings: true,
            mapContents: any<Map<int, String>>(named: 'mapContents'),
            listContents: any<List<DescriptionRecord>>(named: 'listContents'),
          ),
        );
      });

      test('Throws ArgumentError', () async {
        when(() => mockFileLoaderService.loadData(filePath: 'fake')).thenReturn(mockUsdaFile);
        when(() => mockFileLoaderService.folderHash).thenReturn(DateTime.now().microsecondsSinceEpoch.toString());
        final descriptions = DescriptionParser();
        final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);
        // await descriptions.createDataStructure(
        //   dbParser: dbParser,
        //   writeFile: false,
        //   returnStructure: false,
        // );
        // expect(() async => await yourAsyncFunction(),
        //     throwsA(isA<ArgumentError>()));

        expect(
          () async => await descriptions.createDataStructure(
            dbParser: dbParser,
            returnData: false,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
    group('createOriginalDescriptionRecords()', () {
      test('populates the correct records', () {
        const expectedResults = <DescriptionRecord>[
          (167512, 'Pillsbury Golden Layer Buttermilk Biscuits, Artificial Flavor, refrigerated dough'),
          (167513, 'Pillsbury, Cinnamon Rolls with Icing, refrigerated dough'),
          // Excluded category
          // (
          //   167514,
          //   'Kraft Foods, Shake N Bake Original Recipe, Coating for Pork, dry',
          // ),
        ];
        when(() => mockFileLoaderService.loadData(filePath: 'fake')).thenReturn(mockUsdaFile);

        final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);

        final res = DescriptionParser.createOriginalDescriptionRecords(
          originalFoodsList: dbParser.originalFoodsList,
        );

        const listEquals = ListEquality<DescriptionRecord>();
        expect(listEquals.equals(expectedResults, res), true);

        // expect(res, expectedResults);
      });
    });

    group('getLongestDescriptionRecord()--', () {
      test('returns length of longest string', () {
        final res = DescriptionParser.getLongestDescriptionRecord(
          descriptions: mockDescriptionRecords,
        );
        const d = DeepCollectionEquality();
        const expected = (
          91,
          (111114, "Apples, raw, red delicious, with skin (Includes foods for USDA's Food Distribution Program)")
        );
        expect(d.equals(res, expected), true);
      });
    });
    group('createRepeatedPhraseFrequencyMap()', () {
      test('returns duplicates from anywhere in sentence', () async {
        final res = await DescriptionParser.createRepeatedPhraseFrequencyMap(
          listOfRecords: mockDescriptionRecords,
          minPhraseLength: 28,
          minNumberOfDuplicatesToShow: 3,
          returnData: true,
        );

        final doesContainValue1 = res!.containsKey('this is a repeated phrase 28');
        expect(doesContainValue1, true);
      });
      test('writeByType is called', () async {
        when(() => mockFileLoaderService.loadData(filePath: 'fake')).thenReturn(mockUsdaFile);
        when(() => mockFileLoaderService.folderHash).thenReturn(DateTime.now().microsecondsSinceEpoch.toString());

        when(
          () => mockFileLoaderService.writeFileByType<Null, Map<String, int>>(
            fileName: any<String>(
              named: 'fileName',
            ),
            mapContents: any<Map<String, int>>(named: 'mapContents'),
            convertKeysToStrings: false,
          ),
        ).thenAnswer((_) async {});

        final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);
        final res = await DescriptionParser.createRepeatedPhraseFrequencyMap(
          listOfRecords: mockDescriptionRecords,
          minPhraseLength: 28,
          minNumberOfDuplicatesToShow: 3,
          dbParser: dbParser,
        );
        verify(
          () => mockFileLoaderService.writeFileByType<Null, Map<String, int>>(
            convertKeysToStrings: false,
            fileName: any<String>(
              named: 'fileName',
            ),
            mapContents: any<Map<String, int>>(named: 'mapContents'),
          ),
        ).called(1);

        expect(res, isNull);
      });
    });

    group('removeUnwantedPhrasesFromDescriptions()', () {
      test('removes unwanted descriptions', () {
        const expectedDescriptions = <DescriptionRecord>[
          (111111, 'George Weston Bakeries, Thomas English Muffins'),
          (111112, 'Pears, raw, green anjou '),
          (111113, 'Apples, raw, fuji, with skin '),
          (111114, 'Apples, raw, red delicious, with skin '),
          (123456, 'The quick brown fox jumps over the lazy dog. '),
          (234567, 'In a distant galaxy, stars shimmered like diamonds.'),
          (345678, 'A mysterious melody echoed through the ancient forest.'),
          (456789, 'Sunsets paint the sky in hues of orange and pink.'),
          (567890, 'Whispers of the past linger in the old mansion.'),
          (678901, 'Lightning danced across the stormy night sky.'),
          (789012, 'The clock struck midnight, and the world seemed to pause.'),
          (890123, 'Gentle waves lapped against the sandy shore.'),
          (901234, 'Ancient runes glowed on the mysterious artifact.'),
          (102345, 'A lone wolf howled under the full moon.'),
          (112346, 'The aroma of fresh coffee filled the morning air.'),
          (122347, 'In the heart of the city, life buzzed with energy.'),
          (132348, 'The library was a haven of knowledge and silence.'),
          (142349, 'Dreams weave tales of wonder and fear.'),
          (152340, 'Under the starry sky,  a campfire crackled.'),
          (162341, 'Majestic mountains towered over the serene valley '),
          (172342, 'The old clock tower chimed, marking the hour.'),
          (182343, 'Raindrops danced on the windowpane during the storm.'),
          (192344, 'The garden bloomed with a myriad of colors.'),
          (202345, 'Whispering winds carried secrets of the ancient forest.'),
          (212346, 'The mirror reflected a room long forgotten.'),
          (222347, 'A hidden path led to an enchanted waterfall.'),
          (232348, 'In the artists studio, creativity knew no  bounds.'),
          (242349, 'Stars twinkled like jewels in the night sky.'),
          (252340, 'A forgotten melody played on the old piano.'),
          (262341, 'The old book held tales of magic and adventure.'),
          (272342, 'Shadows played on the walls as night fell.'),
          (282343, 'Laughter echoed in the halls of the grand castle.'),
          (292344, 'The ancient tree stood tall, witnessing centuries.'),
          (302345, 'A mysterious figure appeared in the misty night.'),
          (312346, 'The gentle hum of the city was a song of life.'),
          (322347, 'A secret garden lay hidden behind the ivy-covered walls.'),
          (332348, 'The wise owl watched from its perch in the old oak.'),
          (342349, 'A rainbow arched across the sky after the rain.'),
          (352340, 'The wind whispered tales from distant lands.'),
          (362341, 'The full moon cast a silvery glow on the landscape.'),
          (372342, 'The old lighthouse stood guard over the stormy seas.'),
          (382343, 'Flickering candles cast shadows on the walls.'),
          (392344, 'The train whistled as it journeyed through the night.'),
          (402345, 'Mysterious footprints led through the snowy forest.'),
          (412346, 'The scent of pine filled the crisp mountain air.'),
          (422347, 'An old map revealed secrets of lost treasures.'),
          (432348, 'The night sky was ablaze with a spectacular meteor shower.'),
          (442349, 'A cozy fireplace crackled on a cold winters night.'),
          (452340, 'The ancient bridge spanned the tranquil river.'),
          (462341, 'A kaleidoscope of butterflies fluttered in the meadow.'),
          (472342, 'The quaint village was alive with festive celebrations.'),
          (482343, 'The stars and moon illuminated the desert night.'),
          (492344, 'Old legends spoke of dragons and mythical creatures.'),
          (502345, 'The sun rose, casting a golden light on the new day.'),
          (512346, 'Enchanted whispers echoed in the forgotten ruins.'),
        ];

        const listOfPhrasesToDelete = [
          "(Includes foods for USDA's Food Distribution Program)",
          'this is a repeated phrase 28',
        ];
        final res = DescriptionParser.removeUnwantedPhrasesFromDescriptions(
          descriptions: mockDescriptionRecords,
          unwantedPhrases: listOfPhrasesToDelete,
        );

        const listEquals = ListEquality<DescriptionRecord>();

        expect(listEquals.equals(expectedDescriptions, res), true);
      });
    });
  });

  group('parseDescriptionsFromTxtFile()', () {
    test('coverts list of descriptions records to map', () {
      when(() => mockFileLoaderService.loadData(filePath: 'fake')).thenReturn(mockDescriptionTxtFile);

      const expected = {
        167512: 'Pillsbury Golden Layer Buttermilk Biscuits, (Artificial Flavor,) refrigerated dough',
        167513: 'Pillsbury, Cinnamon Rolls with Icing, 100% refrigerated dough',
        167514: 'Kraft Foods, Shake N Bake Original Recipe, Coating for Pork, dry, 2% milk',
      };

      final res = DescriptionParser.parseDescriptionsFromTxtFile(
        filePath: 'fake',
        fileService: mockFileLoaderService,
      );
      const mapEquals = MapEquality<int, String>();
      expect(mapEquals.equals(expected, res), true);
    });
  });

  group('isExcludedCategory', () {
    test('returns true is foodItem has an excluded category', () {
      when(() => mockFileLoaderService.loadData(filePath: 'fake')).thenReturn(mockUsdaFile);
      final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);
      final originalFoodsList = dbParser.originalFoodsList;
      final foodItem = originalFoodsList[2] as Map<dynamic, dynamic>;
      final res = DescriptionParser.isExcludedCategory(foodItem: foodItem);
      expect(res, true);
    });
    test('returns false is foodItem has an excluded category', () {
      when(() => mockFileLoaderService.loadData(filePath: 'fake')).thenReturn(mockUsdaFile);
      final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);
      final originalFoodsList = dbParser.originalFoodsList;
      final foodItem = originalFoodsList[0] as Map<dynamic, dynamic>;
      final res = DescriptionParser.isExcludedCategory(foodItem: foodItem);
      expect(res, false);
    });
  });
}
