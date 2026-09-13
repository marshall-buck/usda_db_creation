import 'package:collection/collection.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:usda_db_creation/db_parser.dart';
import 'package:usda_db_creation/substrings.dart';

import 'setup/mock_data.dart';
import 'setup/mock_db.dart';
import 'setup/setup.dart';

void main() {
  setUpAll(set_up_all);

  tearDown(tear_down);
  group('Substrings class tests', () {
    group('createDataStructure()', () {
      test('substrings populates correctly', () async {
        when(() => mockFileLoaderService.loadData(filePath: 'fake')).thenReturn(mockUsdaFile);
        when(() => mockFileLoaderService.outputFolderName)
            .thenReturn(DateTime.now().microsecondsSinceEpoch.toString());

        final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);

        final sub = Substrings(mockWordIndexMap);
        final res = await sub.createDataStructure(dbParser: dbParser);
        // print(res);
        const deep = DeepCollectionEquality();

        expect(deep.equals(res, mockUnHashedSubstrings), true);
      });
      test('fileLoader writeFileByType is called when writeFile is true', () async {
        when(() => mockFileLoaderService.loadData(filePath: 'fake')).thenReturn(mockUsdaFile);
        when(() => mockFileLoaderService.outputFolderName)
            .thenReturn(DateTime.now().microsecondsSinceEpoch.toString());

        when(
          () => mockFileLoaderService.writeFileByType(
            fileName: any<String>(
              named: 'fileName',
            ),
            convertKeysToStrings: false,
            mapContents: any<Map<String, List<int>>>(named: 'mapContents'),
          ),
        ).thenAnswer((_) async {});

        final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);

        final substring = Substrings(mockWordIndexMap);
        await substring.createDataStructure(
          dbParser: dbParser,
          writeFile: true,
          returnData: false,
        );

        verify(
          () => mockFileLoaderService.writeFileByType(
            fileName: any<String>(named: 'fileName'),
            convertKeysToStrings: false,
            mapContents: any<Map<String, List<int>>>(named: 'mapContents'),
          ),
        ).called(1);
      });
      test('fileLoader methods are not called when writeFile is false', () async {
        when(() => mockFileLoaderService.loadData(filePath: 'fake')).thenReturn(mockUsdaFile);
        when(() => mockFileLoaderService.outputFolderName)
            .thenReturn(DateTime.now().microsecondsSinceEpoch.toString());

        when(
          () => mockFileLoaderService.writeFileByType(
            fileName: any<String>(
              named: 'fileName',
            ),
            convertKeysToStrings: false,
            mapContents: any<Map<String, List<int>>>(named: 'mapContents'),
          ),
        ).thenAnswer((_) async {});

        final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);

        final substring = Substrings(mockWordIndexMap);
        await substring.createDataStructure(
          dbParser: dbParser,
        );

        verifyNever(
          () => mockFileLoaderService.writeFileByType(
            fileName: any<String>(named: 'fileName'),
            convertKeysToStrings: false,
            mapContents: any<Map<String, List<int>>>(named: 'mapContents'),
          ),
        );
      });
      test('Throws ArgumentError', () async {
        when(() => mockFileLoaderService.loadData(filePath: 'fake')).thenReturn(mockUsdaFile);
        when(() => mockFileLoaderService.outputFolderName)
            .thenReturn(DateTime.now().microsecondsSinceEpoch.toString());

        final dbParser = DBParser.init(filePath: 'fake', fileService: mockFileLoaderService);

        final substring = Substrings(mockWordIndexMap);

        expect(
          () async => await substring.createDataStructure(
            dbParser: dbParser,
            returnData: false,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });
  });
}
