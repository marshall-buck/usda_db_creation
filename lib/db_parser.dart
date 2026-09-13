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

  /// Creates the database data structure and writes it to a file,
  /// if [writeFile] is true.
  /// Returns the data structure if [returnData] is true.
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
      await dbParser.fileService.writeFileByType<Null, Map<String, dynamic>>(
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

      final foodModelJson = foodModel.toJson();

      foodsMap.addAll(foodModelJson);
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
      final originalNutrientUnit = Nutrient.originalNutrientTableEdit[nutrientId]!['unit']!;
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

  /// Creates a set of id's from the nutrients in hte original database.
  /// This is used to create the `nutrientIds] property
  /// in the 'global_const.dart' file.
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
        final nutrientJson = (nutrient as Map<dynamic, dynamic>)['nutrient'] as Map<dynamic, dynamic>;
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
