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

  /// The food's category code, a key of `foodCategories` in `global_const.dart`.
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
}
