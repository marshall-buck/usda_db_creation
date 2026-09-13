import 'dart:convert';

import 'package:usda_db_creation/data_structure.dart';

import 'package:usda_db_creation/file_service.dart';
import 'package:usda_db_creation/food_model.dart';

import 'package:usda_db_creation/nutrient.dart';

/// Class to create the main database of food items and nutrient information.
/// The instance needs to be initialized with a map of
/// parsed descriptions [descriptionMap].
class DB implements DataStructure<Map<String, dynamic>?> {
  /// Creates a [DB] backed by the already parsed [descriptionMap].
  DB(this.descriptionMap);

  /// The parsed descriptions, keyed by food id.
  final Map<int, String> descriptionMap;

  /// Creates the foods database and, by default, writes it to a file.
  ///
  /// `dbParser` - the parser holding the decoded `original_usda.json`.
  ///
  /// `writeFile` - write the result to [FileService.fileNameFoodsDatabase].
  /// Defaults to `true`.
  ///
  /// `returnData` - return the built map instead of `null`. Defaults to
  /// `false`.
  ///
  /// Those defaults are deliberately the inverse of the [DataStructure]
  /// interface, and of the other implementations, which all default to
  /// `returnData: true, writeFile: false`. Those structures are intermediate:
  /// the descriptions feed the word index, the word index feeds the
  /// substrings, the substrings feed the autocomplete hash, so their callers
  /// want the value back and only sometimes want it on disk. This one is the
  /// end of the pipeline. Nothing consumes the foods map, and it is the
  /// largest structure the run produces, so the useful default is to write it
  /// and hand back nothing. That is why both call sites in
  /// `usda_db.dart.createDBFiles` are simply
  /// `db.createDataStructure(dbParser: dbParser)`.
  ///
  /// There is also no `!returnData && !writeFile` guard here, unlike
  /// `DescriptionParser`, `WordIndexMap` and `Substrings`. With these defaults
  /// that combination cannot be reached by accident - a caller has to pass
  /// both flags explicitly to ask for no work at all.
  @override
  Future<Map<String, dynamic>?> createDataStructure({
    required DBParser dbParser,
    bool returnData = false,
    bool writeFile = true,
  }) async {
    final foodsList = dbParser.originalFoodsList;

    final data = dbParser.createFoodsMapDB(
      getFoodsList: foodsList,
      finalDescriptionRecordsMap: descriptionMap,
    );

    if (writeFile) {
      await dbParser.fileService.writeFileByType(
        fileName: FileService.fileNameFoodsDatabase,
        convertKeysToStrings: false,
        mapContents: data,
      );
    }
    return returnData ? data : null;
  }
}

/// A class that represents a parser for the `original_usda.json` file.
/// It is used to extract information and perform various operations on the data.
/// The instance needs to be initialized with the `original_usda.json` file,
///  with [DBParser.init]
class DBParser {
  /// Opens `original_usda.json`  and creates a map.
  DBParser.init({required this.fileService, required String filePath}) {
    final file = fileService.loadData(filePath: filePath);
    _originalDBMap = jsonDecode(file) as Map<dynamic, dynamic>;
  }

  /// The service used to read the source file and write the generated files.
  FileService fileService;

  /// Always assigned by [DBParser.init], so it is never null once an instance
  /// exists.
  late final Map<dynamic, dynamic> _originalDBMap;

  /// [List] of foods from `original_usda.json`.
  ///
  /// Throws a [FormatException] if the source file has no `SRLegacyFoods` list,
  /// rather than failing with a bare cast error.
  List<dynamic> get originalFoodsList {
    final foods = _originalDBMap['SRLegacyFoods'];
    if (foods is! List) {
      throw FormatException(
        "Expected a 'SRLegacyFoods' list in the source file, "
        'found ${foods.runtimeType}',
      );
    }
    return foods;
  }

  /// Method to create the map that wil be used for the foods database.
  /// Returns:
  /// { id: { description,  nutrients }, ... }
  Map<String, dynamic> createFoodsMapDB({
    required List<dynamic> getFoodsList,
    required Map<int, String> finalDescriptionRecordsMap,
  }) {
    final foodsMap = <String, dynamic>{};

    for (final food in getFoodsList) {
      final foodItem = food as Map<dynamic, dynamic>;
      final foodId = foodItem['fdcId'] as int;
      if (!finalDescriptionRecordsMap.containsKey(foodId)) {
        continue;
      }

      final foodDescription = finalDescriptionRecordsMap[foodId]!;

      final foodNutrients = foodItem['foodNutrients'] as List<dynamic>;

      final nutrientsList = createNutrientsMap(listOfNutrients: foodNutrients);

      final foodModel = FoodModel(
        id: foodId,
        description: foodDescription,
        nutrientsMap: nutrientsList,
      );

      foodsMap[foodModel.id.toString()] = foodModel.toJsonValue();
    }

    return foodsMap;
  }

  /// Method to create the nutrients list that will be used for the foods database.
  ///
  /// Parameters:
  /// [listOfNutrients] - the list of nutrients from a food item.
  ///
  /// Returns: `Map<String, num>` where each key is a nutrient id and each
  /// value is the amount.
  ///
  /// Throws on a unit mismatch rather than skipping the row, and that is
  /// deliberate. The amounts are written bare, with the unit implied by
  /// [Nutrient.originalNutrientTableEdit], so a row whose `unitName` disagrees
  /// with the table would put a number in the database under the wrong unit,
  /// and mg against g is a 1000x error. Aborting the run beats publishing a
  /// database that is quietly wrong.
  ///
  /// Nutrients with an amount of zero are left out on purpose, so an absent key
  /// means "no meaningful amount" rather than "not measured". The source always
  /// supplies an `amount`, and 3,387 of the kept rows are an explicit zero, so
  /// dropping them keeps the published db smaller and the consumer treats a
  /// missing key as zero either way.
  Map<String, num> createNutrientsMap({
    required List<dynamic> listOfNutrients,
  }) {
    final nutrientsMap = <String, num>{};

    for (var i = 0; i < listOfNutrients.length; i++) {
      final originalNutrient = listOfNutrients[i] as Map<String, dynamic>;
      final nutrientJson = originalNutrient['nutrient'] as Map<String, dynamic>;

      final nutrientId = nutrientJson['id'] as int?;
      if (nutrientId == null || !_findNutrient(nutrientId)) continue;

      final unit = nutrientJson['unitName'] as String;
      final originalNutrientUnit = Nutrient.originalNutrientTableEdit[nutrientId]?['unit'];
      if (originalNutrientUnit == null) {
        throw StateError(
          'Nutrient id $nutrientId is in keepTheseNutrients but has no unit in '
          'Nutrient.originalNutrientTableEdit',
        );
      }
      if (unit.toLowerCase() != originalNutrientUnit.toLowerCase()) {
        throw Exception(
          'unit mismatch id: $nutrientId unit: $unit \n  originalNutrient: $originalNutrient',
        );
      }
      final amount = (originalNutrient['amount'] as num?) ?? 0.0;
      final nutrient = Nutrient(
        id: nutrientId,
        amount: amount,
      );

      if (nutrient.amount > 0) {
        nutrientsMap[nutrient.id.toString()] = nutrient.amount;
      }
    }

    return nutrientsMap;
  }

  /// Checks if nutrient is in [Nutrient.keepTheseNutrients].
  ///
  /// Parameters:
  /// [nutrientId] - the id of the nutrient to be included.
  ///
  /// Returns [bool].
  bool _findNutrient(int nutrientId) {
    return Nutrient.keepTheseNutrients.contains(nutrientId);
  }

  /// Creates a set of id's from the nutrients in the original database.
  /// This is used to create the `nutrientIds` property
  /// in the 'global_const.dart' file.
  ///
  /// Informational, and uncalled on purpose. It was run once to discover which
  /// nutrient ids the source actually contains, and it is kept so the list can
  /// be regenerated against a newer USDA download. Call it from a scratch
  /// `main` when that is needed; nothing in the pipeline should depend on it.
  ///
  /// See also [getFoodCategories], the other standalone research method.
  static Set<int> findAllNutrientIds({
    required Map<int, String> finalDescriptionRecordsMap,
    required List<dynamic> originalFoodsList,
  }) {
    final nutrientIds = <int>{};
    for (final food in originalFoodsList) {
      final foodItem = food as Map<dynamic, dynamic>;
      final foodId = foodItem['fdcId'] as int;
      if (!finalDescriptionRecordsMap.containsKey(foodId)) {
        continue;
      }
      final foodNutrients = foodItem['foodNutrients'] as List<dynamic>;
      for (final nutrient in foodNutrients) {
        final nutrientJson =
            (nutrient as Map<dynamic, dynamic>)['nutrient'] as Map<dynamic, dynamic>;
        nutrientIds.add(nutrientJson['id'] as int);
      }
    }
    return nutrientIds;
  }

  /******************************* Research Methods **************************/

  /// Retrieves the food categories from the database.
  /// Informational method
  /// Returns a [Map] containing the food categories as keys and their
  /// corresponding IDs as values. The second element of the
  /// returned record represents the total number of food categories.
  /// Returns:
  /// {"category1": 1, "category2": 2, ..., "total": 3}
  Map<String, int> getFoodCategories() {
    final categories = <String, int>{};
    var count = 0;
    for (final food in originalFoodsList) {
      final foodCategory = (food as Map<dynamic, dynamic>)['foodCategory'] as Map<dynamic, dynamic>;
      final foodCategoryDescription = foodCategory['description'] as String;
      if (categories.containsKey(foodCategoryDescription)) {
        categories[foodCategoryDescription] = categories[foodCategoryDescription]! + 1;
        count++;
      } else {
        categories[foodCategoryDescription] = 1;
        count++;
      }
    }
    categories['total'] = count;
    return categories;
  }
}
