import 'package:equatable/equatable.dart';

/// A single food in the generated database: its id, description, category
/// and nutrients.
class FoodModel extends Equatable {
  /// Creates a [FoodModel].
  const FoodModel({
    required this.id,
    required this.description,
    required this.categoryCode,
    required this.nutrientsMap,
  });

  /// The USDA food id, the `fdcId` of the source record.
  final int id;

  /// The parsed food description.
  final String description;

  /// The food's category code, a key of [foodCategories].
  final int categoryCode;

  /// Nutrient amounts, keyed by nutrient id.
  final Map<String, num> nutrientsMap;

  /// Serializes this food as `{'<id>': {d, c, n}}`.
  Map<String, dynamic> toJson() => {id.toString(): toJsonValue()};

  /// The value half of [toJson], `{d, c, n}`: description, category code and
  /// nutrients. The keys are single characters to keep `foods_db.json` small.
  ///
  /// The database is one big map keyed by id, so a caller building it already
  /// has the key and only needs this. Going through [toJson] there would
  /// allocate a single-entry map per food just to merge it away again.
  Map<String, dynamic> toJsonValue() {
    return {
      'd': description,
      'c': categoryCode,
      'n': nutrientsMap,
    };
  }

  @override
  List<Object?> get props => [id, description, categoryCode, nutrientsMap];

  /// USDA food categories, keyed by their code from `food_category.csv`.
  ///
  /// The code is the CSV's four digit string read as an int, so `0100` is
  /// `100`. Each food in `foods_db.json` carries one of these codes under `c`.
  /// Like `Nutrient.originalNutrientTableEdit`, the table is not written to a
  /// file; a consumer resolves a code with its own copy of this table.
  static const Map<int, String> foodCategories = {
    100: 'Dairy and Egg Products',
    200: 'Spices and Herbs',
    300: 'Baby Foods',
    400: 'Fats and Oils',
    500: 'Poultry Products',
    600: 'Soups, Sauces, and Gravies',
    700: 'Sausages and Luncheon Meats',
    800: 'Breakfast Cereals',
    900: 'Fruits and Fruit Juices',
    1000: 'Pork Products',
    1100: 'Vegetables and Vegetable Products',
    1200: 'Nut and Seed Products',
    1300: 'Beef Products',
    1400: 'Beverages',
    1410: 'Alcoholic Beverages',
    1500: 'Finfish and Shellfish Products',
    1600: 'Legumes and Legume Products',
    1700: 'Lamb, Veal, and Game Products',
    1800: 'Baked Products',
    1900: 'Sweets',
    2000: 'Cereal Grains and Pasta',
    2100: 'Fast Foods',
    2200: 'Meals, Entrees, and Side Dishes',
    2500: 'Snacks',
    2600: 'Quality Control Materials',
    3500: 'American Indian/Alaska Native Foods',
    3600: 'Restaurant Foods',
    4500: 'Branded Food Products Database',
  };
}
