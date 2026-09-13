import 'package:equatable/equatable.dart';

/// A single food in the generated database: its id, description and nutrients.
class FoodModel extends Equatable {
  /// Creates a [FoodModel].
  const FoodModel({
    required this.id,
    required this.description,
    required this.nutrientsMap,
  });

  /// The USDA food id.
  final dynamic id;

  /// The parsed food description.
  final String description;

  /// Nutrient amounts, keyed by nutrient id.
  final Map<String, num> nutrientsMap;

  /// Serializes this food as `{'<id>': {description, nutrients}}`.
  Map<String, dynamic> toJson() {
    return {
      id.toString(): {
        'description': description,
        'nutrients': nutrientsMap,
      },
    };
  }

  // factory FoodModel.fromJson(final Map<int, dynamic> json) {
  //   final foodJson = json.values.first;
  //   final nutrientsJson = foodJson['nutrients'] as List<dynamic>;

  //   final nutrients = nutrientsJson
  //       .map((e) => Nutrient.fromJson(e as MapEntry<String, dynamic>))
  //       .toList();

  //   return FoodModel(
  //     id: json.keys.first,
  //     description: foodJson['description'],
  //     nutrients: nutrients,
  //   );
  // }
  @override
  List<Object?> get props => [id, description, nutrientsMap];
}
