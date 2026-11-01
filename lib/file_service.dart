import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:usda_db_creation/extensions/map_ext.dart';

/// A class that provides file-related services, such as reading and writing files.
///
/// This class handles various file operations, including writing different types of data to files,
/// reading data from files, and parsing CSV files.
///
/// The [FileService] class has the following properties:
/// - [pathToFiles] The path to the files directory.
/// - [fileNameOriginalDBFile] The file name for the original USDA database file.
/// - [fileNameNutrientsCsv] The file name for the nutrient CSV file.
/// - [fileNameNutrientsMap] The file name for the original nutrient CSV file.
/// - [fileNameDuplicatePhrases] The file name for the duplicate phrases file.
/// - [fileNameFinalDescriptions] The file name for the final descriptions file.
/// - [fileNameSubstrings] The file name for the substrings file.
/// - [fileNameAutocompleteWordIndex] The file name for the autocomplete word index file.
/// - [fileNameAutocompleteWordIndexKeys] The file name for the autocomplete word index keys file.
/// - [fileNameAutocompleteHash] The file name for the autocomplete hash file.
/// - [fileNameFoodsDatabase] The file name for the foods database file.
/// - [fileNameManifest] The file name for the file manifest file.
///
/// The [FileService] class provides the following methods:
/// - [writeFileByType] Writes the contents to files based on their types.
/// - [writeManifestFile] Writes the manifest file.
/// - [_writeJsonFile] Writes a JSON file.
/// - [_writeListToTxtFile] Writes a list to a text file.
/// - [checkAndCreateFolder] Checks if the specified folder path exists and creates it if it doesn't.
/// - [loadData] Loads the contents of a file.
/// - [readCsvFile] Reads a CSV file and returns its contents as a list of lists of strings.
/// - [_parseCsvLine] Parses a CSV line and returns a list of fields.
///
/// Example usage:
/// ```dart
/// final fileService = FileService();
/// await fileService.writeFileByType(
///   fileName: 'example',
///   convertKeysToStrings: true,
///   mapContents: {'key1': 'value1', 'key2': 'value2'},
/// );
/// ```
class FileService {
  /// The path to the files directory.
  final String pathToFiles = p.join('lib', 'db');

  /// The file name for the original USDA database file.
  late final String fileNameOriginalDBFile =
      p.join(pathToFiles, 'do_not_delete', 'original_usda.json');

  /// The file name for the nutrient CSV file.
  late final String fileNameNutrientsCsv = p.join(pathToFiles, 'do_not_delete', 'nutrient.csv');

  /// The file name for the original nutrient CSV file, converted to JSON.
  late final String fileNameNutrientsMap =
      p.join(pathToFiles, 'do_not_delete', 'original_nutrient_csv.json');

  /// The file name for the duplicate phrases file.
  static const fileNameDuplicatePhrases = 'duplicate_phrases';

  /// The file name for the final descriptions file.
  static const fileNameFinalDescriptions = 'descriptions';

  /// The file name for the substrings file.
  static const fileNameSubstrings = 'substrings';

  /// The file name for the autocomplete word index file.
  static const fileNameAutocompleteWordIndex = 'autocomplete_word_index';

  /// The file name for the autocomplete word index keys file.
  static const fileNameAutocompleteWordIndexKeys = 'autocomplete_word_index_keys';

  /// The file name for the autocomplete hash file.
  static const fileNameAutocompleteHash = 'autocomplete_hash';

  /// The file name for the foods database file.
  static const fileNameFoodsDatabase = 'foods_db';

  /// The file name for the file manifest file.
  static const fileNameManifest = 'file_manifest';

  /// The folder every file of this run is written into.
  ///
  /// `DateTime.now().toString()` with the characters a path cannot hold
  /// replaced by `_`, so it reads `2024-10-21_20_05_15.765190`. Set once when
  /// the instance is built so every file of a run lands together, and it is a
  /// timestamp rather than a hash - two runs in the same microsecond would
  /// collide.
  String outputFolderName = '${DateTime.now()}'.replaceAll(RegExp(r'[\\/:*?"<>|\s]'), '_');

  /// The sub-second part of [outputFolderName], used to prefix each file name.
  ///
  /// `765190` for the folder above. `DateTime.toString` prints six digits when
  /// there are microseconds and three when there are not, so this is `765` on a
  /// whole-microsecond tick and `000` on a whole-second one. That is fine: the
  /// prefix only has to be the same for every file in one folder, and
  /// [writeManifestFile] records it so a reader can rebuild the names.
  String get filePrefix => outputFolderName.substring(outputFolderName.indexOf('.') + 1);

// ************************** File Writers **************************

  /// Writes the contents to files based on their types.
  /// Appends a [outputFolderName] folder to the path.
  Future<void> writeFileByType({
    required String fileName,
    required bool convertKeysToStrings,
    List<dynamic>? listContents,
    Map<dynamic, dynamic>? mapContents,
  }) async {
    if (listContents == null && mapContents == null) {
      throw ArgumentError('No contents provided: writeFileByType');
    }

    checkAndCreateFolder();

    if (listContents != null) {
      final listFilePath = p.join(
        pathToFiles,
        outputFolderName,
        '${filePrefix}_$fileName.txt',
      ); // '$pathToFiles/$filePrefix/$fileName.txt';
      await _writeListToTxtFile(
        filePath: listFilePath,
        contents: listContents,
      );
    }

    if (mapContents != null) {
      final mapFilePath = p.join(
        pathToFiles,
        outputFolderName,
        '${filePrefix}_$fileName.json',
      ); //'$pathToFiles/$filePrefix/$fileName.json';
      final convertedMap =
          convertKeysToStrings ? mapContents.deepConvertMapKeyToString() : mapContents;
      await _writeJsonFile(filePath: mapFilePath, contents: convertedMap);
    }
  }

  /// Writes the manifest file, whose contents are the current [filePrefix].
  Future<void> writeManifestFile() async {
    final manifestFilePath = p.join(pathToFiles, outputFolderName);
    final file = File('$manifestFilePath/$fileNameManifest.txt');
    log('Writing manifest file to: $manifestFilePath', name: 'writeManifestFile');
    await file.writeAsString(filePrefix);
  }

  /// Writes [contents] as JSON.
  ///
  /// Keys are written as they arrive. [writeFileByType] has already applied
  /// `deepConvertMapKeyToString` when its `convertKeysToStrings` is set, and
  /// that conversion is the deep one, so there is nothing left to do here.
  Future<void> _writeJsonFile({
    required String filePath,
    required Map<dynamic, dynamic> contents,
  }) async {
    await File(filePath).writeAsString(jsonEncode(contents));
  }

  /// Takes a [List], and writes a file to given [filePath], creating a new
  ///  line for each list item.
  Future<void> _writeListToTxtFile({
    required String filePath,
    required List<dynamic> contents,
  }) async {
    final sink = File(filePath).openWrite();

    try {
      // Write the lines, if line is the last line, don't add \n
      for (var i = 0; i < contents.length; i++) {
        final line = contents[i];
        if (i == contents.length - 1) {
          sink.write(line);
        } else {
          sink.writeln(line);
        }
      }

      await sink.flush();
    } finally {
      // Close in a finally so a failed write does not leak the handle.
      await sink.close();
    }
  }

  /// Checks if the specified folder path exists and creates it if it doesn't.
  void checkAndCreateFolder() {
    final path = p.join(pathToFiles, outputFolderName);
    final directory = Directory(path);
    if (!directory.existsSync()) {
      try {
        directory.createSync(recursive: true);
      } on Exception catch (e, st) {
        throw Exception(
          'Failed to create folder in _checkAndCreateFolder: $path.  Error: $e, StackTrace: $st',
        );
      }
    }
  }

// ************************** File Readers **************************

  /// Synchronously opens a file from [filePath].  Returns the contents as a [String].
  String loadData({required String filePath}) {
    final file = File(filePath);
    if (!file.existsSync()) {
      throw FileSystemException('File not found', filePath);
    }
    return file.readAsStringSync();
  }

  /// Reads a CSV file from the given [filePath] and returns its contents as a
  /// list of lists of strings.
  ///
  /// Each inner list represents a row in the CSV file,
  /// and each string represents a cell value.
  /// [[cell1, cell2, cell3], [cell1, cell2, cell3]]
  Future<List<List<String>>> readCsvFile({
    required String filePath,
  }) async {
    final file = File(filePath);
    final csvData = <List<String>>[];

    if (!file.existsSync()) {
      throw FileSystemException('File not found', filePath);
    }
    final lines = await file.readAsLines();
    for (final line in lines) {
      csvData.add(_parseCsvLine(line));
    }

    return csvData;
  }

  /// Parses a CSV line and returns a list of fields.
  ///
  /// This is used for csv files
  ///
  /// The [line] parameter represents a single line of a CSV file.
  /// This method iterates over each character in the line and extracts
  /// the fields separated by commas.
  ///
  /// If a field is enclosed in double quotes,
  /// it is treated as a single field even if it contains commas.
  ///
  /// Returns a list of strings representing the fields in the CSV line.

  List<String> _parseCsvLine(String line) {
    final fields = <String>[];
    var inQuotes = false;
    final buffer = StringBuffer();

    for (var i = 0; i < line.length; i++) {
      if (line[i] == '"') {
        inQuotes = !inQuotes; // Toggle the inQuotes state
        continue;
      }

      if (line[i] == ',' && !inQuotes) {
        fields.add(buffer.toString());
        buffer.clear();
        continue;
      }

      buffer.write(line[i]);
    }

    // Add the last field
    fields.add(buffer.toString());

    return fields;
  }
}
