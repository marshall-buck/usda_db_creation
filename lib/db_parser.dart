import 'dart:convert';

import 'package:usda_db_creation/file_loader_service.dart';

class DBParser {
  FileLoaderService fileLoader;
  Map<dynamic, dynamic>? _originalDBMap;

  /// [List] of foods from the database.
  List<dynamic> get originalFoodsList => _originalDBMap?['SRLegacyFoods'];

  DBParser({final FileLoaderService? fileLoader})
      : fileLoader = fileLoader ?? FileLoaderService();

  /// Populates the _dbMap
  void init(final String path) {
    final file = fileLoader.loadData(path);
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
}
// ({Baked Products: 517,
//Snacks: 176,
//Sweets: 358,
//Vegetables and Vegetable Products: 814,
//American Indian/Alaska Native Foods: 165,
//Restaurant Foods: 109,
//Beverages: 366,
//Fats and Oils: 216,
//Sausages and Luncheon Meats: 167,
//Dairy and Egg Products: 291,
//Baby Foods: 345,
//Poultry Products: 383,
//Pork Products: 336,
//Breakfast Cereals: 195,
//Legumes and Legume Products: 290,
//Finfish and Shellfish Products: 264,
//Fruits and Fruit Juices: 355,
//Cereal Grains and Pasta: 181,
//Nut and Seed Products: 137,
//Beef Products: 954,
//Meals, Entrees, and Side Dishes: 81,
//Fast Foods: 312,
//Spices and Herbs: 63,
//Soups, Sauces, and Gravies: 254,
//Lamb, Veal, and Game Products: 464},
// 7793)