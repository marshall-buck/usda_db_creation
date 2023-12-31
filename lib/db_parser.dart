import 'dart:convert';

import 'package:usda_db_creation/file_loader_service.dart';
import 'package:usda_db_creation/food_model.dart';
import 'package:usda_db_creation/global_const.dart';
import 'package:usda_db_creation/nutrient.dart';

class DBParser {
  FileLoaderService fileLoaderService;
  Map<dynamic, dynamic>? _originalDBMap;

  /// [List] of foods from the database.
  List<dynamic> get originalFoodsList => _originalDBMap?['SRLegacyFoods'];

  /// Populates the _dbMap
  DBParser.init(
      {required this.fileLoaderService, required final String filePath}) {
    final file = fileLoaderService.loadData(filePath: filePath);
    _originalDBMap = jsonDecode(file);
  }

  (Map<String, int>, int) getFoodCategories() {
    final Map<String, int> categories = {};
    int count = 0;
    for (final food in originalFoodsList) {
      final foodCategory = food['foodCategory'];
      final foodCategoryDescription = foodCategory['description'];
      if (categories.containsKey(foodCategoryDescription)) {
        categories[foodCategoryDescription] =
            categories[foodCategoryDescription]! + 1;
        count++;
      } else {
        categories[foodCategoryDescription] = 1;
        count++;
      }
    }

    return (categories, count);
  }

  /// Method to create the map that wil be used for the foods database.
  /// The map will be of the form:
  /// { id: { description, descriptionLength,  nutrients }, ... }
  ///
  Map<String, dynamic> createFoodsMapDB(
      {required final List<dynamic> getFoodsList,
      required final Map<int, String> finalDescriptionRecordsMap}) {
    final Map<String, dynamic> foodsMap = {};

    for (final food in getFoodsList) {
      final int foodId = food['fdcId'];
      if (!finalDescriptionRecordsMap.containsKey(foodId)) {
        continue;
      }

      final String foodDescription = finalDescriptionRecordsMap[foodId]!;

      final foodNutrients = food['foodNutrients'];

      final nutrientsList = createNutrientsList(listOfNutrients: foodNutrients);

      final foodModel = FoodModel(
          id: foodId, description: foodDescription, nutrients: nutrientsList);

      final Map<String, dynamic> foodModelJson = foodModel.toJson();

      foodsMap.addAll(foodModelJson);
    }

    return foodsMap;
  }

  /// Method to create the nutrients list that will be used for the foods database.
  List<Nutrient> createNutrientsList({
    required final List<dynamic> listOfNutrients,
  }) {
    final List<Nutrient> nutrients = [];

    for (int i = 0; i < listOfNutrients.length; i++) {
      final Map<String, dynamic> originalNutrient = listOfNutrients[i];
      // String name = originalNutrient['nutrient']['name'] ?? 'unknown';

      final int nutrientId = originalNutrient['nutrient']['id'] ?? 9999;
      if (!findNutrient(nutrientId)) continue;
      // name = Nutrient.switchNutrientName(nutrientId);

      // final unitName = originalNutrient['nutrient']['unitName'] ?? 'unknown';

      final num amount = originalNutrient['amount'] ?? 0.0;
      final nutrient = Nutrient(
        id: nutrientId,
        // name: name,
        amount: amount,
        // unit: unitName,
      );

      nutrients.add(nutrient);
    }

    return nutrients;
  }

  /// Checks if nutrient is in [keepTheseNutrients].
  ///
  /// Parameters:
  /// [nutrientId] - the id of the nutrient to be included.
  ///
  /// Returns [bool].
  bool findNutrient(final int nutrientId) {
    return keepTheseNutrients.contains(nutrientId);
  }

  /// Creates a set of id's from the nutrients in hte original database.
  /// This is used to create the `nutrientIds] property
  /// in the 'global_const.dart' file.
  static Set<int> findAllNutrientIds(
      {required final Map<int, String> finalDescriptionRecordsMap,
      required final List<dynamic> originalFoodsList}) {
    final Set<int> nutrientIds = {};
    for (final food in originalFoodsList) {
      final int foodId = food['fdcId'];
      if (!finalDescriptionRecordsMap.containsKey(foodId)) {
        continue;
      }
      final foodNutrients = food['foodNutrients'];
      for (final nutrient in foodNutrients) {
        final int nutrientId = nutrient['nutrient']['id'];
        nutrientIds.add(nutrientId);
      }
    }
    return nutrientIds;
  }
}
