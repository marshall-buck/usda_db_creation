// This file is where the methods live that will be used in the
// bin/usda_db_creation.dart  file.
// The bin/usda_db_creation.dart is called when the user runs the command
// 'dart run'. Not all methods in this file are used in the bin/usda_db_creation.dart
// at the same time.

import 'dart:io' show IOException;

import 'package:usda_db_creation/autocomplete.dart';
import 'package:usda_db_creation/db_parser.dart';
import 'package:usda_db_creation/description_parser.dart';
import 'package:usda_db_creation/file_service.dart';

import 'package:usda_db_creation/substrings.dart';
import 'package:usda_db_creation/word_index.dart';

/// Returns the length of the longest description in the provided DBParser object.
///
/// Takes a [DBParser] object as a parameter which contains the original foods list.
/// Returns the length of the longest description.
///
/// [dbParser] The [DBParser] object containing the original foods list.
(int, DescriptionRecord?) getLongestDescription({
  required DBParser dbParser,
}) {
  final descriptions = DescriptionParser.createOriginalDescriptionRecords(
    originalFoodsList: dbParser.originalFoodsList,
  );
  return DescriptionParser.getLongestDescriptionRecord(
    descriptions: descriptions,
  );
}

/// Returns the length of the shortest description in the provided DBParser object.
///
/// Takes a [DBParser] object as a parameter which contains the original foods list.
/// Returns the length of the shortest description.
///
/// [dbParser] The [DBParser] object containing the original foods list.
(int, DescriptionRecord?) getShortestDescription({
  required DBParser dbParser,
}) {
  final descriptions = DescriptionParser.createOriginalDescriptionRecords(
    originalFoodsList: dbParser.originalFoodsList,
  );
  return DescriptionParser.getShortestDescriptionRecord(
    descriptions: descriptions,
  );
}

/// Creates the necessary database files based on the provided [DBParser] object.
///
/// This function generates the required files for the database creation process.
///  It takes a [DBParser] object as a parameter, which contains the original foods list.
/// Additionally, it requires a [FileService] object for file operations and an
/// optional boolean parameter [extras] to indicate whether to include extra files.
///
/// If [extras] is set to true, the function generates additional files including
/// description records, word index map, substring map, autocomplete hash table,
/// and the database itself. These files are written to disk.
///
/// If [extras] is set to false, the function generates only the necessary files
/// for the database creation process, excluding the additional files.
/// These files are not written to disk.
///
/// Note: The [DBParser] object must be properly initialized before calling this function.
///
/// Example usage:
/// ```dart
/// final dbParser = DBParser();
/// final fileService = FileService();
/// await createDBFiles(dbParser: dbParser, fileService: fileService, extras: true);
/// ```
///
/// [dbParser] The [DBParser] object containing the original foods list.
/// [fileService] The [FileService] object for file operations.
/// [extras] A boolean value indicating whether to include extra files. Defaults to false.
///
/// Throws a [FormatException] if the [DBParser] object is not properly initialized.
/// Throws an [IOException] if there is an error during file operations.

Future<void> createDBFiles({
  required DBParser dbParser,
  required FileService fileService,
  bool extras = false,
}) async {
  // [extras] only decides whether the three intermediate structures are also
  // written to disk. They are built and chained the same way either way, and
  // the hash table and the database are always written.
  final descriptions = DescriptionParser();
  final desMap = await descriptions.createDataStructure(
    dbParser: dbParser,
    writeFile: extras,
  );

  final wordIndex = WordIndexMap(desMap!);
  final wordIndexMap = await wordIndex.createDataStructure(
    dbParser: dbParser,
    writeFile: extras,
  );

  final substring = Substrings(wordIndexMap!);
  final substringMap = await substring.createDataStructure(
    dbParser: dbParser,
    writeFile: extras,
  );

  final hashTable = AutoCompleteHashTable(substringMap!);
  await hashTable.createDataStructure(dbParser: dbParser, writeFile: true);

  final db = DB(desMap);
  await db.createDataStructure(dbParser: dbParser);

  await fileService.writeManifestFile();
}
