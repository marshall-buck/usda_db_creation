import 'package:usda_db_creation/data_structure.dart';
import 'package:usda_db_creation/db_parser.dart';
import 'package:usda_db_creation/extensions/string_ext.dart';
import 'package:usda_db_creation/file_service.dart';
import 'package:usda_db_creation/global_const.dart';

/// A single `(id, description)` pair parsed from the original foods list.
typedef DescriptionRecord = (int, String);

/// A map of food id to its parsed description.
typedef DescriptionMap = Map<int, String>;

/// A class that parses descriptions and creates a [DescriptionMap] from the
/// original foods list.
///
/// This class implements the [DataStructure] interface.
/// The [createDataStructure] method is the main method that needs to be called
/// to create the final description map.
/// All other methods are helper methods.
///
/// Example usage:
/// ```dart
/// final dbParser = DBParser();
/// final descriptionParser = DescriptionParser();
/// final descriptionMap = await descriptionParser.createDataStructure(
///   dbParser: dbParser,
///   returnData: true,
///   writeFile: true,
/// );
/// ```
///
/// The [createDataStructure] method takes the following parameters:
/// - `dbParser` An instance of [DBParser] used to parse the original foods list.
/// - `returnData` A boolean indicating whether to return the description map
/// or not. Default is `true`.
/// - `writeFile` A boolean indicating whether to write the description map to
/// a file or not. Default is `false`.
///
/// The [createDataStructure] method returns a [Future] of [DescriptionMap] or
/// `null` if `returnData` is `false`.
///
/// The [DescriptionParser] class also provides several helper methods:
/// - [createOriginalDescriptionRecords] Parses the original foods list to
/// create a list of [DescriptionRecord]s.
/// - [removeUnwantedPhrasesFromDescriptions] Removes unwanted phrases from
/// the descriptions.
/// - [parseDescriptionsFromTxtFile] Parses a description map from a text file.
/// - [_parseDescriptionRecordFromString] Helper method to parse a description
/// record from a line in a text file.
/// - [getLongestDescriptionRecord] Helper method to get the length of the longest
/// description in a list of [DescriptionRecord]s.
/// - [createRepeatedPhraseFrequencyMap] Helper method to create a frequency
/// map of repeated phrases in a list of descriptions.
/// - [isExcludedCategory] Helper method to check if a food item is in an
/// excluded category.
///
/// Note: The [DescriptionParser] class assumes the existence of a
/// [DescriptionRecord] class and a [DescriptionMap] type.
/// The [DescriptionRecord] class should have properties `$1` and `$2`
/// representing the id and description respectively.
/// The [DescriptionMap] type should be a [Map] with keys of type [int]
/// and values of type [String].

class DescriptionParser implements DataStructure<DescriptionMap?> {
  /// Creates [DescriptionMap] from the original foods list.
  ///
  /// This is the only method that needs to be called to create the final
  /// description map.
  /// All other methods are helper methods.
  /// ```dart
  /// final dbParser = DBParser();
  /// final descriptionParser = DescriptionParser();
  /// final descriptionMap = await descriptionParser.createDataStructure(
  ///  dbParser: dbParser,
  /// returnData: true,
  /// writeFile: true,
  /// )  =>
  /// { 167512: 'Pillsbury Golden Layer Buttermilk Biscuits, (Artificial Flavor,) refrigerated dough' ,
  ///   167513: 'Pillsbury, Cinnamon Rolls with Icing, 100% refrigerated dough',
  ///   167514: 'Kraft Foods, Shake N Bake Original Recipe, Coating for Pork, dry, 2% milk', ...}
  ///
  /// ```
  @override
  Future<DescriptionMap?> createDataStructure({
    required DBParser dbParser,
    bool returnData = true,
    bool writeFile = false,
  }) async {
    if (!returnData && !writeFile) {
      throw ArgumentError('Both returnStructure and writeFile are false');
    }
    final originalDescriptions = createOriginalDescriptionRecords(
      originalFoodsList: dbParser.originalFoodsList,
    );

    final parsedDescriptions = removeUnwantedPhrasesFromDescriptions(
      descriptions: originalDescriptions,
      unwantedPhrases: unwantedPhrases,
    );

    final descriptionMap = <int, String>{};

    for (final line in parsedDescriptions) {
      final entry = MapEntry<int, String>(line.$1, line.$2);

      descriptionMap[entry.key] = entry.value;
    }
    if (writeFile) {
      await dbParser.fileService.writeFileByType<List<DescriptionRecord>, Map<int, String>>(
        fileName: FileService.fileNameFinalDescriptions, //fileNameFinalDescriptions,
        convertKeysToStrings: true,
        listContents: parsedDescriptions,
        mapContents: descriptionMap,
      );
    }

    return returnData ? descriptionMap : null;
  }

  //************************ Helper Methods **********************************/

  /// Parses [originalFoodsList] to create a list of [DescriptionRecord]s.
  /// The descriptions will be unedited.
  /// This is the first method called in the process of creating the final database.
  ///
  /// The list will be filtered to remove any unwanted food categories,
  /// from the [excludedCategories] list.  The list is defined in `global_const.dart`.
  ///
  /// Parameters:
  /// [originalFoodsList] - the list of food items from the original_usda.json file.
  ///
  /// Returns: [DescriptionRecord]
  ///  [(id, description), ...]

  static List<DescriptionRecord> createOriginalDescriptionRecords({
    required List<dynamic> originalFoodsList,
  }) {
    return originalFoodsList
        .map((food) {
          final foodItem = food as Map<dynamic, dynamic>;
          assert(foodItem['fdcId'] != null, 'Food item is missing an fdcId');
          final id = foodItem['fdcId'] as int;

          if (!isExcludedCategory(foodItem: foodItem)) {
            return (id, foodItem['description'] as String);
          }
          // return null; // Add this line to handle the case where the return value may be null.
        })
        .whereType<DescriptionRecord>()
        .toList(); // Add this line to convert the nullable values to non-null values.
  }

  /// Removes unwanted phrases from the descriptions.
  /// This will return a new list.
  ///
  /// Returns:
  ///  [(id, description), ...]
  static List<DescriptionRecord> removeUnwantedPhrasesFromDescriptions({
    required List<DescriptionRecord> descriptions,
    required List<String> unwantedPhrases,
  }) {
    return descriptions.map((record) {
      var description = record.$2;
      for (final phrase in unwantedPhrases) {
        if (description.contains(phrase)) {
          description = description.replaceAll(phrase, '');
        }
      }
      return (record.$1, description);
    }).toList();
  }

  /// Helper method to create a [DescriptionMap] from a txt file at [filePath].
  /// The text file must be in the format of 1 (id, description) per line
  /// (167521, Pie Crust, Cookie-type, Chocolate, Ready Crust)
  static DescriptionMap parseDescriptionsFromTxtFile({
    required String filePath,
    required FileService fileService,
  }) {
    final fileContents = fileService.loadData(filePath: filePath);
    final lines = fileContents.split('\n')..removeWhere((line) => line.isEmpty);

    final descriptionMap = <int, String>{};
    for (final line in lines) {
      final entry = _parseDescriptionRecordFromString(line);

      descriptionMap[entry.key] = entry.value;
    }
    return descriptionMap;
  }

  /// Helper method to parse a description record from a line in a txt file.
  /// The line must be in the format of 1 (id, description) per line
  /// (167521, Pie Crust, Cookie-type, Chocolate, Ready Crust).
  ///
  /// The offsets are fixed on purpose. Every `fdcId` in the SR Legacy download
  /// is 6 digits, and the file being read back was written by this package from
  /// a [DescriptionRecord], so each line is always `(` + 6 digits + `, ` +
  /// description + `)`. That makes the id positions 1-6 and the description
  /// start position 9, and splitting on a comma is not an option since the
  /// descriptions themselves contain commas.
  static MapEntry<int, String> _parseDescriptionRecordFromString(
    String line,
  ) {
    final id = int.parse(line.substring(1, 7));
    final description = line.substring(9, line.length - 1);

    return MapEntry(id, description);
  }

  /// Helper Method to get the longest description in a list of [DescriptionRecord]s.
  static (int, DescriptionRecord?) getLongestDescriptionRecord({
    required List<DescriptionRecord> descriptions,
  }) {
    DescriptionRecord? longestRecord;
    var maxLength = 0;

    for (final currentRecord in descriptions) {
      final currentLength = currentRecord.$2.length;
      if (currentLength > maxLength) {
        maxLength = currentLength;
        longestRecord = currentRecord;
      }
    }

    return (maxLength, longestRecord);
  }

  /// Helper Method to get the shortest description in a list of [DescriptionRecord]s.
  static (num, DescriptionRecord?) getShortestDescriptionRecord({
    required List<DescriptionRecord> descriptions,
  }) {
    DescriptionRecord? shortestRecord;
    num maxLength = double.infinity;

    for (final currentRecord in descriptions) {
      final num currentLength = currentRecord.$2.length;
      if (currentLength < maxLength) {
        maxLength = currentLength;
        shortestRecord = currentRecord;
      }
    }

    return (maxLength, shortestRecord);
  }

  /// Helper method to create a frequency map of repeated phrases in a list of strings.
  ///
  /// Parameters:
  /// [listOfRecords] - the list of [DescriptionRecord]s.
  /// [minPhraseLength] - the minimum length of the phrase to be included in the map.
  /// [minNumberOfDuplicatesToShow] - the minimum number of duplicate phrases to be
  /// included in the map.
  /// [dbParser] - Optional [DBParser] instance, if included the output
  /// will write data to json file
  ///
  /// Returns:
  ///   {Lorem ipsum: 3,
  ///     Lorem ipsum dolor: 3,
  ///     Lorem ipsum dolor sit: 2,
  ///     Lorem ipsum dolor sit amet: 2,
  ///     ipsum dolor: 3,
  ///     ipsum dolor sit: 2, ...}
  ///

  static Future<Map<String, int>?> createRepeatedPhraseFrequencyMap({
    required List<DescriptionRecord> listOfRecords,
    required int minPhraseLength,
    required int minNumberOfDuplicatesToShow,
    DBParser? dbParser,
    bool returnData = false,
  }) async {
    final freqMap = <String, int>{};

    for (final record in listOfRecords) {
      final description = record.$2;
      final phrases = description.separateIntoPhrasesWithMinimumLength(
        minPhraseLength: minPhraseLength,
      );

      for (final phrase in phrases) {
        if (phrase!.isNotEmpty) {
          if (freqMap.containsKey(phrase)) {
            freqMap[phrase] = freqMap[phrase]! + 1;
          } else {
            freqMap[phrase] = 1;
          }
        }
      }
    }

    freqMap.removeWhere(
      (key, value) => value < minNumberOfDuplicatesToShow,
    );
    final sortedList = freqMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    final outPut = Map<String, int>.fromEntries(sortedList);

    if (dbParser != null) {
      await dbParser.fileService.writeFileByType<Null, Map<String, int>>(
        mapContents: outPut,
        fileName: FileService.fileNameDuplicatePhrases,
        convertKeysToStrings: false,
      );
    }
    return returnData ? outPut : null;
  }

  /// Helper method to check if a food item is in an excluded category.
  ///  [excludedCategories] can be found in `global_const.dart`.
  static bool isExcludedCategory({required Map<dynamic, dynamic> foodItem}) {
    final foodCategory = foodItem['foodCategory'] as Map<dynamic, dynamic>;
    final foodCategoryDescription = foodCategory['description'];
    return excludedCategories.contains(foodCategoryDescription);
  }
}
