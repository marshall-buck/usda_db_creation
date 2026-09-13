import 'package:collection/collection.dart';
import 'package:test/test.dart';
import 'package:usda_db_creation/food_model.dart';

void main() {
  group('Food Model class tests', () {
    group('toJson()', () {
      test('toJson parses correctly', () {
        final nutrients = {'1004': 20, '1003': 10};

        final food = FoodModel(
          id: 111111,
          description: 'Food Item',
          nutrientsMap: nutrients,
        );

        final expectation = {
          '111111': {
            'description': 'Food Item',
            'nutrients': {'1004': 20, '1003': 10},
          },
        };

        final res = food.toJson();

        const d = DeepCollectionEquality();
        expect(d.equals(res, expectation), true);
      });
    });
    // group('fromJson()', () {
    //   test('fromJson works correctly', () {
    //     final res = FoodModel.fromJson(mockFoodJson);

    //     expect(res.id, 111111);
    //     expect(res.description,
    //         'Pillsbury Golden Layer Buttermilk Biscuits, Artificial Flavor, refrigerated dough');

    //     expect(res.nutrients.length, 5);
    //     expect(res.nutrients[0].id, 1004);
    //     expect(res.nutrients[0].name, 'Total Fat');
    //     expect(res.nutrients[0].amount, 10);
    //     expect(res.nutrients[0].unit, 'g');

    //     expect(res.nutrients[1].id, 1003);
    //     expect(res.nutrients[1].name, 'Protein');
    //     expect(res.nutrients[1].amount, 5);
    //     expect(res.nutrients[1].unit, 'g');

    //     expect(res.nutrients[2].id, 1005);
    //     expect(res.nutrients[2].name, 'Total Carbohydrates');
    //     expect(res.nutrients[2].amount, 10);
    //     expect(res.nutrients[2].unit, 'g');

    //     expect(res.nutrients[3].id, 1008);
    //     expect(res.nutrients[3].name, 'Calories');
    //     expect(res.nutrients[3].amount, 80);
    //     expect(res.nutrients[3].unit, 'kcal');

    //     expect(res.nutrients[4].id, 1258);
    //     expect(res.nutrients[4].name, 'Fatty acids, total saturated');
    //     expect(res.nutrients[4].amount, 10);
    //     expect(res.nutrients[4].unit, 'g');
    //   });

    //   test('fromJson creates nutrients list as <List<Nutrient>>', () {
    //     final res = FoodModel.fromJson(mockFoodJson);
    //     expect(res.nutrients, isA<List<Nutrient>>());
    //   });
    // });
  });
}
