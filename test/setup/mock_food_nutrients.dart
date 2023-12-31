import 'package:usda_db_creation/nutrient.dart';

const mockFoodNutrients = [
  {
    "type": "FoodNutrient",
    "id": 1283674,
    "nutrient": {
      "id": 1003,
      "number": "203",
      "name": "Protein",
      "rank": 600,
      "unitName": "g"
    },
    "dataPoints": 1,
    "foodNutrientDerivation": {
      "code": "MA",
      "description":
          "Manufacturer supplied(industry or trade association), Analytical data, incomplete documentation",
      "foodNutrientSource": {
        "id": 9,
        "code": "12",
        "description": "Manufacturer's analytical; partial documentation"
      }
    },
    "amount": 5.88
  },
  {
    "type": "FoodNutrient",
    "id": 1283675,
    "nutrient": {
      "id": 1007,
      "number": "207",
      "name": "Ash",
      "rank": 1000,
      "unitName": "g"
    },
    "dataPoints": 1,
    "foodNutrientDerivation": {
      "code": "MA",
      "description":
          "Manufacturer supplied(industry or trade association), Analytical data, incomplete documentation",
      "foodNutrientSource": {
        "id": 9,
        "code": "12",
        "description": "Manufacturer's analytical; partial documentation"
      }
    },
    "amount": 3.50
  },
  {
    "type": "FoodNutrient",
    "id": 1283676,
    "nutrient": {
      "id": 1062,
      "number": "268",
      "name": "Energy",
      "rank": 400,
      "unitName": "kJ"
    },
    "dataPoints": 0,
    "foodNutrientDerivation": {
      "code": "NC",
      "description": "Calculated",
      "foodNutrientSource": {
        "id": 2,
        "code": "4",
        "description": "Calculated or imputed"
      }
    },
    "amount": 1.29E+3
  },
  {
    "type": "FoodNutrient",
    "id": 1283677,
    "nutrient": {
      "id": 1079,
      "number": "291",
      "name": "Fiber, total dietary",
      "rank": 1200,
      "unitName": "g"
    },
    "dataPoints": 1,
    "foodNutrientDerivation": {
      "code": "MA",
      "description":
          "Manufacturer supplied(industry or trade association), Analytical data, incomplete documentation",
      "foodNutrientSource": {
        "id": 9,
        "code": "12",
        "description": "Manufacturer's analytical; partial documentation"
      }
    },
    "amount": 1.20
  },
  {
    "type": "FoodNutrient",
    "id": 1283678,
    "nutrient": {
      "id": 1089,
      "number": "303",
      "name": "Iron, Fe",
      "rank": 5400,
      "unitName": "mg"
    },
    "dataPoints": 1,
    "foodNutrientDerivation": {
      "code": "MA",
      "description":
          "Manufacturer supplied(industry or trade association), Analytical data, incomplete documentation",
      "foodNutrientSource": {
        "id": 9,
        "code": "12",
        "description": "Manufacturer's analytical; partial documentation"
      }
    },
    "amount": 2.12
  },
  {
    "type": "FoodNutrient",
    "id": 1283679,
    "nutrient": {
      "id": 1093,
      "number": "307",
      "name": "Sodium, Na",
      "rank": 5800,
      "unitName": "mg"
    },
    "dataPoints": 1,
    "foodNutrientDerivation": {
      "code": "MA",
      "description":
          "Manufacturer supplied(industry or trade association), Analytical data, incomplete documentation",
      "foodNutrientSource": {
        "id": 9,
        "code": "12",
        "description": "Manufacturer's analytical; partial documentation"
      }
    },
    "amount": 1.06E+3
  },
  {
    "type": "FoodNutrient",
    "id": 1283680,
    "nutrient": {
      "id": 1253,
      "number": "601",
      "name": "Cholesterol",
      "rank": 15700,
      "unitName": "mg"
    },
    "dataPoints": 1,
    "foodNutrientDerivation": {
      "code": "MA",
      "description":
          "Manufacturer supplied(industry or trade association), Analytical data, incomplete documentation",
      "foodNutrientSource": {
        "id": 9,
        "code": "12",
        "description": "Manufacturer's analytical; partial documentation"
      }
    },
    "amount": 0.000
  },
  {
    "type": "FoodNutrient",
    "id": 1283681,
    "nutrient": {
      "id": 1257,
      "number": "605",
      "name": "Fatty acids, total trans",
      "rank": 15400,
      "unitName": "g"
    },
    "dataPoints": 1,
    "foodNutrientDerivation": {
      "code": "MA",
      "description":
          "Manufacturer supplied(industry or trade association), Analytical data, incomplete documentation",
      "foodNutrientSource": {
        "id": 9,
        "code": "12",
        "description": "Manufacturer's analytical; partial documentation"
      }
    },
    "amount": 4.41
  },
  {
    "type": "FoodNutrient",
    "id": 1283682,
    "nutrient": {
      "id": 1258,
      "number": "606",
      "name": "Fatty acids, total saturated",
      "rank": 9700,
      "unitName": "g"
    },
    "dataPoints": 1,
    "foodNutrientDerivation": {
      "code": "MA",
      "description":
          "Manufacturer supplied(industry or trade association), Analytical data, incomplete documentation",
      "foodNutrientSource": {
        "id": 9,
        "code": "12",
        "description": "Manufacturer's analytical; partial documentation"
      }
    },
    "amount": 2.94
  },
  {
    "type": "FoodNutrient",
    "id": 1283683,
    "nutrient": {
      "id": 1004,
      "number": "204",
      "name": "Total lipid (fat)",
      "rank": 800,
      "unitName": "g"
    },
    "dataPoints": 1,
    "foodNutrientDerivation": {
      "code": "MA",
      "description":
          "Manufacturer supplied(industry or trade association), Analytical data, incomplete documentation",
      "foodNutrientSource": {
        "id": 9,
        "code": "12",
        "description": "Manufacturer's analytical; partial documentation"
      }
    },
    "amount": 13.2
  },
  {
    "type": "FoodNutrient",
    "id": 1283684,
    "nutrient": {
      "id": 1005,
      "number": "205",
      "name": "Carbohydrate, by difference",
      "rank": 1110,
      "unitName": "g"
    },
    "dataPoints": 0,
    "foodNutrientDerivation": {
      "code": "NC",
      "description": "Calculated",
      "foodNutrientSource": {
        "id": 2,
        "code": "4",
        "description": "Calculated or imputed"
      }
    },
    "amount": 41.2
  },
  {
    "type": "FoodNutrient",
    "id": 1283685,
    "nutrient": {
      "id": 1008,
      "number": "208",
      "name": "Energy",
      "rank": 300,
      "unitName": "kcal"
    },
    "dataPoints": 0,
    "foodNutrientDerivation": {
      "code": "NC",
      "description": "Calculated",
      "foodNutrientSource": {
        "id": 2,
        "code": "4",
        "description": "Calculated or imputed"
      }
    },
    "amount": 307
  },
  {
    "type": "FoodNutrient",
    "id": 1283686,
    "nutrient": {
      "id": 1051,
      "number": "255",
      "name": "Water",
      "rank": 100,
      "unitName": "g"
    },
    "dataPoints": 1,
    "foodNutrientDerivation": {
      "code": "MA",
      "description":
          "Manufacturer supplied(industry or trade association), Analytical data, incomplete documentation",
      "foodNutrientSource": {
        "id": 9,
        "code": "12",
        "description": "Manufacturer's analytical; partial documentation"
      }
    },
    "amount": 35.5
  },
  {
    "type": "FoodNutrient",
    "id": 1283687,
    "nutrient": {
      "id": 2000,
      "number": "269",
      "name": "Sugars, total including NLEA",
      "rank": 1510,
      "unitName": "g"
    },
    "dataPoints": 1,
    "foodNutrientDerivation": {
      "code": "MA",
      "description":
          "Manufacturer supplied(industry or trade association), Analytical data, incomplete documentation",
      "foodNutrientSource": {
        "id": 9,
        "code": "12",
        "description": "Manufacturer's analytical; partial documentation"
      }
    },
    "amount": 5.88
  }
];

const mockNutrientListResults = [
  Nutrient(
    id: 1003,
    amount: 5.88,
  ),
  Nutrient(
    id: 1079,
    amount: 1.2,
  ),
  Nutrient(
    id: 1258,
    amount: 2.94,
  ),
  Nutrient(
    id: 1004,
    amount: 13.2,
  ),
  Nutrient(
    id: 1005,
    amount: 41.2,
  ),
  Nutrient(
    id: 1008,
    amount: 307,
  ),
  Nutrient(
    id: 2000,
    amount: 5.88,
  )
];
