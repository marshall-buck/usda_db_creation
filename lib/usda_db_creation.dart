import 'package:usda_db_creation/db_parser.dart';
import 'package:usda_db_creation/description_parser.dart';
import 'package:usda_db_creation/file_loader_service.dart';

import 'dart:developer' as dev;

import 'package:usda_db_creation/paths.dart';

void createFiles() {
  // final foods = FoodsDB();
  // foods.createDB();
  print("createFiles from barrel file");
}
//****** Methods to handle Descriptions ***************/

/// Creates the duplicate phrases file and writes to [path].
Future<void> writeDuplicatePhrasesToFile(
    {final int minPhraseLength = 20,
    final minNumberOfDuplicatesToShow = 25,
    required final FileLoaderService fileLoader,
    required final DBParser dbParser}) async {
  final descriptionRecords = DescriptionParser.createOriginalDescriptionRecords(
      foodsDBMap: dbParser.foodsDBMap);

  final repeats = DescriptionParser.getRepeatedPhrases(
      listOfRecords: descriptionRecords,
      minPhraseLength: minPhraseLength,
      minNumberOfDuplicatesToShow: minNumberOfDuplicatesToShow);

  await fileLoader.writeJsonFile(relativeRepeatFile, repeats);
  print('Complete: ${repeats.length}');
}

Future<void> writeOriginalDescriptionsToFile(
    {required final DBParser dbParser,
    required FileLoaderService fileLoaderService}) async {
  final res = DescriptionParser.createOriginalDescriptionRecords(
      foodsDBMap: dbParser.foodsDBMap);
  // print(res);
  try {
    await fileLoaderService.writeTextFile(res, originalDescriptions);
  } catch (e, st) {
    dev.log(e.toString(), error: st);
  }
}

// The answer is 134 for the original descriptions.
int getLongestDescriptionLength(final DBParser dbParser) {
  final descriptions = DescriptionParser.createOriginalDescriptionRecords(
      foodsDBMap: dbParser.foodsDBMap);
  return DescriptionParser.getLongestDescription(descriptions: descriptions);
}
