import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:path/path.dart' as p;
import 'package:test/test.dart';
import 'package:usda_db_creation/file_service.dart';

late final FileService fileService;

void main() {
  setUpAll(() => fileService = FileService());
  tearDown(() async {
    final testDirectory = Directory(p.join(fileService.pathToFiles, fileService.outputFolderName));
    if (testDirectory.existsSync()) {
      await testDirectory.delete(recursive: true);
    }
  });

  group('FileService class tests', () {
    group('writeFileByType() - ', () {
      test('should write list contents to a text file', () async {
        final listContents = ['item1', 'item2', 'item3'];

        await fileService.writeFileByType(
          fileName: 'testList',
          convertKeysToStrings: false,
          listContents: listContents,
        );

        final fileName = '${fileService.filePrefix}_testList.txt';

        final filePath = p.join(fileService.pathToFiles, fileService.outputFolderName, fileName);
        final file = File(filePath);

        expect(file.existsSync(), isTrue);
        expect(await file.readAsString(), listContents.join('\n'));
      });

      test('should write map contents to a json file', () async {
        final mapContents = {'key1': 'value1', 'key2': 'value2'};

        await fileService.writeFileByType(
          fileName: 'testJson',
          convertKeysToStrings: false,
          mapContents: mapContents,
        );
        final fileName = '${fileService.filePrefix}_testJson.json';

        final filePath = p.join(fileService.pathToFiles, fileService.outputFolderName, fileName);
        final file = File(filePath);

        expect(file.existsSync(), isTrue);
        expect(jsonDecode(await file.readAsString()), mapContents);
      });

      test('should throw ArgumentError when no contents are provided', () {
        expect(
          () => fileService.writeFileByType(
            fileName: 'testEmpty',
            convertKeysToStrings: false,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('readCsvFile method tests', () {
      test('should read CSV file and return its contents as a list of lists', () async {
        final filePath = p.join('test', 'test_files', 'test_file.csv');

        final result = await fileService.readCsvFile(filePath: filePath);

        const d = DeepCollectionEquality();
        expect(
          d.equals(result, [
            ['id', 'name', 'unit_name', 'nutrient_nbr', 'rank'],
            ['1002', 'Nitrogen', 'G', '202', '500'],
            ['1003', 'Protein', 'G', '203', '600'],
            ['1004', 'Total lipid (fat)', 'G', '204', '800'],
            ['1005', 'Carbohydrate, by difference', 'G', '205', '1110'],
          ]),
          true,
        );
      });
      test('should throw an exception when the file does not exist', () async {
        final filePath = p.join('test', 'test_files', 'non_existent_file.csv');

        expect(
          () async => await fileService.readCsvFile(filePath: filePath),
          throwsA(isA<FileSystemException>()),
        );
      });

      test('should return an empty list when the file is empty', () async {
        final filePath = p.join('test', 'test_files', 'empty_file.csv');

        final result = await fileService.readCsvFile(filePath: filePath);

        expect(result, isEmpty);
        expect(result, isA<List<List<String>>>());
      });
    });

    group('loadData method tests', () {
      test('should read file and return its contents as a string', () {
        final filePath = p.join('test', 'test_files', 'test_file.txt');
        const testContent = 'This is a test string.';

        final result = fileService.loadData(filePath: filePath);

        expect(result, testContent);
      });

      test('should throw an exception when the file does not exist', () {
        final filePath = p.join('test', 'test_files', 'non_existent_file.txt');

        expect(
          () => fileService.loadData(filePath: filePath),
          throwsA(isA<FileSystemException>()),
        );
      });

      test('should correctly load very large JSON files', () async {
        final filePath = p.join('test', 'test_files', 'largeFile.json');
        final file = File(filePath);
        final largeFileContent = {
          'key': 'a' * 300000000,
        };
        await file.writeAsString(jsonEncode(largeFileContent));

        final loadedContent = fileService.loadData(filePath: filePath);

        expect(loadedContent, isA<String>());
        file.deleteSync();
      });
    });

    group('checkAndCreateFolder method tests', () {
      test('should create folder if it does not exist', () {
        final folderPath = p.join(fileService.pathToFiles, fileService.outputFolderName);

        fileService.checkAndCreateFolder();

        expect(Directory(folderPath).existsSync(), isTrue);

        Directory(folderPath).deleteSync();
      });

      test('should not create folder if it already exists', () {
        final folderPath = p.join(fileService.pathToFiles, fileService.outputFolderName);
        Directory(folderPath).createSync();

        fileService.checkAndCreateFolder();

        expect(Directory(folderPath).existsSync(), isTrue);

        Directory(folderPath).deleteSync();
      });
    });
    group('outputFolderName tests', () {
      test('outputFolderName should not be empty', () {
        expect(fileService.outputFolderName, isNotEmpty);
      });

      test('outputFolderName should not contain any invalid characters', () {
        expect(
          fileService.outputFolderName.contains(RegExp(r'[\\/:*?"<>|\s]')),
          false,
        );
      });

      test('outputFolderName should not contain any invalid characters', () {
        expect(
          fileService.outputFolderName.contains(RegExp(r'[\\/:*?"<>|\s]')),
          isFalse,
        );
      });

      test('outputFolderName should be unique for each instance of FileService', () {
        final anotherFileService = FileService();
        expect(
          fileService.outputFolderName,
          isNot(equals(anotherFileService.outputFolderName)),
        );
      });
    });
  });
}
