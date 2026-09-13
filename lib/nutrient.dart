import 'package:equatable/equatable.dart';

/// A single nutrient measurement for a food, identified by its USDA id.
class Nutrient extends Equatable {
  /// Creates a [Nutrient] with the given [id] and [amount].
  const Nutrient({
    required this.id,
    // required this.name,
    required this.amount,
    //required this.unit
  });

  /// Creates a [Nutrient] from a `{'<id>': <amount>}` map entry.
  factory Nutrient.fromJsonEntry(MapEntry<String, num> json) {
    return Nutrient(
      id: int.parse(json.key),
      amount: json.value,
    );
  }

  /// The USDA nutrient id.
  final int id;
  // final String name;

  /// The amount of the nutrient, in the unit defined by the USDA for [id].
  final num amount;
  // final String unit;

  /// Where the key is the id and the value is the amount
  /// {'1004': 0.5}
  MapEntry<int, num> toEntry() => MapEntry(id, amount);

  @override
  List<Object?> get props => [id, amount];

  /// Converts an entry to be encoded to Json
  MapEntry<String, num> toJson() => MapEntry(id.toString(), amount);

  /// Given the string form a csv file, iterate and create the nutrient info map
  ///
  /// Returns:{ {"1004" : {"name": "Total Fat", "unit": "g"}, ...}

  // static Map<String, dynamic> createNutrientInfoMap(
  //     {required List<List<String>> csvLines}) {
  //   final Map<String, dynamic> nutrientsMap = {};

  //   for (int i = 1; i < csvLines.length; i++) {
  //     final line = csvLines[i];

  //     final key = line[0];
  //     if (!nutrientIds.contains(int.parse(key))) {
  //       continue;
  //     }
  //     final name = line[1];
  //     final unit = line[2].toLowerCase();

  //     nutrientsMap[key] = {"name": name, "unit": unit};
  //   }

  //   return nutrientsMap;
  // }

  static const keepTheseNutrients = [
    1003,
    1004,
    1005,
    1007,
    1008,
    1009,
    1010,
    1011,
    1012,
    1013,
    1014,
    1018,
    1051,
    1057,
    1058,
    1075,
    1079,
    1087,
    1089,
    1090,
    1091,
    1092,
    1093,
    1095,
    1098,
    1099,
    1101,
    1103,
    1104,
    1105,
    1106,
    1107,
    1108,
    1109,
    1110,
    1111,
    1112,
    1114,
    1120,
    1122,
    1123,
    1125,
    1126,
    1127,
    1128,
    1129,
    1130,
    1131,
    1162,
    1165,
    1166,
    1167,
    1170,
    1175,
    1177,
    1178,
    1180,
    1183,
    1184,
    1185,
    1186,
    1187,
    1190,
    1198,
    1210,
    1211,
    1212,
    1213,
    1214,
    1215,
    1216,
    1217,
    1218,
    1219,
    1220,
    1221,
    1222,
    1223,
    1224,
    1225,
    1226,
    1227,
    1228,
    1242,
    1246,
    1253,
    1257,
    1258,
    1292,
    1293,
    1329,
    1331,
    2000,
  ];
/*CSpell:disable*/
  /// Some names have been changed to be more user friendly.
  /// Not used anywehrer just here for reference.
  static const originalNutrientTableEdit = {
    1003: {'name': 'Protein', 'unit': 'g'},
    1004: {'name': 'Total Fat', 'unit': 'g'},
    1005: {'name': 'Total Carbohydrates', 'unit': 'g'},
    1007: {'name': 'Ash', 'unit': 'g'},
    1008: {'name': 'Calories', 'unit': 'kcal'},
    1009: {'name': 'Starch', 'unit': 'g'},
    1010: {'name': 'Sucrose', 'unit': 'g'},
    1011: {'name': 'Glucose (dextrose)', 'unit': 'g'},
    1012: {'name': 'Fructose', 'unit': 'g'},
    1013: {'name': 'Lactose', 'unit': 'g'},
    1014: {'name': 'Maltose', 'unit': 'g'},
    1018: {'name': 'Alcohol, ethyl', 'unit': 'g'},
    1051: {'name': 'Water', 'unit': 'g'},
    1057: {'name': 'Caffeine', 'unit': 'mg'},
    1058: {'name': 'Theobromine', 'unit': 'mg'},
    1075: {'name': 'Galactose', 'unit': 'g'},
    1079: {'name': 'Fiber, total dietary', 'unit': 'g'},
    1087: {'name': 'Calcium, Ca', 'unit': 'mg'},
    1089: {'name': 'Iron, Fe', 'unit': 'mg'},
    1090: {'name': 'Magnesium, Mg', 'unit': 'mg'},
    1091: {'name': 'Phosphorus, P', 'unit': 'mg'},
    1092: {'name': 'Potassium, K', 'unit': 'mg'},
    1093: {'name': 'Sodium, Na', 'unit': 'mg'},
    1095: {'name': 'Zinc, Zn', 'unit': 'mg'},
    1098: {'name': 'Copper, Cu', 'unit': 'mg'},
    1099: {'name': 'Fluoride, F', 'unit': 'µg'},
    1101: {'name': 'Manganese, Mn', 'unit': 'mg'},
    1103: {'name': 'Selenium, Se', 'unit': 'µg'},
    1104: {'name': 'Vitamin A, IU', 'unit': 'iu'},
    1105: {'name': 'Retinol', 'unit': 'µg'},
    1106: {'name': 'Vitamin A, RAE', 'unit': 'µg'},
    1107: {'name': 'Carotene, beta', 'unit': 'µg'},
    1108: {'name': 'Carotene, alpha', 'unit': 'µg'},
    1109: {'name': 'Vitamin E (alpha-tocopherol)', 'unit': 'mg'},
    1110: {'name': 'Vitamin D (D2 + D3), International Units', 'unit': 'iu'},
    1111: {'name': 'Vitamin D2 (ergocalciferol)', 'unit': 'µg'},
    1112: {'name': 'Vitamin D3 (cholecalciferol)', 'unit': 'µg'},
    1114: {'name': 'Vitamin D (D2 + D3)', 'unit': 'µg'},
    1120: {'name': 'Cryptoxanthin, beta', 'unit': 'µg'},
    1122: {'name': 'Lycopene', 'unit': 'µg'},
    1123: {'name': 'Lutein + zeaxanthin', 'unit': 'µg'},
    1125: {'name': 'Tocopherol, beta', 'unit': 'mg'},
    1126: {'name': 'Tocopherol, gamma', 'unit': 'mg'},
    1127: {'name': 'Tocopherol, delta', 'unit': 'mg'},
    1128: {'name': 'Tocotrienol, alpha', 'unit': 'mg'},
    1129: {'name': 'Tocotrienol, beta', 'unit': 'mg'},
    1130: {'name': 'Tocotrienol, gamma', 'unit': 'mg'},
    1131: {'name': 'Tocotrienol, delta', 'unit': 'mg'},
    1162: {'name': 'Vitamin C, total ascorbic acid', 'unit': 'mg'},
    1165: {'name': 'Thiamin', 'unit': 'mg'},
    1166: {'name': 'Riboflavin', 'unit': 'mg'},
    1167: {'name': 'Niacin', 'unit': 'mg'},
    1170: {'name': 'Pantothenic acid', 'unit': 'mg'},
    1175: {'name': 'Vitamin B-6', 'unit': 'mg'},
    1177: {'name': 'Folate, total', 'unit': 'µg'},
    1178: {'name': 'Vitamin B-12', 'unit': 'µg'},
    1180: {'name': 'Choline, total', 'unit': 'mg'},
    1183: {'name': 'Vitamin K (Menaquinone-4)', 'unit': 'µg'},
    1184: {'name': 'Vitamin K (Dihydrophylloquinone)', 'unit': 'µg'},
    1185: {'name': 'Vitamin K (phylloquinone)', 'unit': 'µg'},
    1186: {'name': 'Folic acid', 'unit': 'µg'},
    1187: {'name': 'Folate, food', 'unit': 'µg'},
    1190: {'name': 'Folate, DFE', 'unit': 'µg'},
    1198: {'name': 'Betaine', 'unit': 'mg'},
    1210: {'name': 'Tryptophan', 'unit': 'g'},
    1211: {'name': 'Threonine', 'unit': 'g'},
    1212: {'name': 'Isoleucine', 'unit': 'g'},
    1213: {'name': 'Leucine', 'unit': 'g'},
    1214: {'name': 'Lysine', 'unit': 'g'},
    1215: {'name': 'Methionine', 'unit': 'g'},
    1216: {'name': 'Cystine', 'unit': 'g'},
    1217: {'name': 'Phenylalanine', 'unit': 'g'},
    1218: {'name': 'Tyrosine', 'unit': 'g'},
    1219: {'name': 'Valine', 'unit': 'g'},
    1220: {'name': 'Arginine', 'unit': 'g'},
    1221: {'name': 'Histidine', 'unit': 'g'},
    1222: {'name': 'Alanine', 'unit': 'g'},
    1223: {'name': 'Aspartic acid', 'unit': 'g'},
    1224: {'name': 'Glutamic acid', 'unit': 'g'},
    1225: {'name': 'Glycine', 'unit': 'g'},
    1226: {'name': 'Proline', 'unit': 'g'},
    1227: {'name': 'Serine', 'unit': 'g'},
    1228: {'name': 'Hydroxyproline', 'unit': 'g'},
    1242: {'name': 'Vitamin E, added', 'unit': 'mg'},
    1246: {'name': 'Vitamin B-12, added', 'unit': 'µg'},
    1253: {'name': 'Cholesterol', 'unit': 'mg'},
    1257: {'name': 'Fatty acids, total trans', 'unit': 'g'},
    1258: {'name': 'Fatty acids, total saturated', 'unit': 'g'},
    1259: {'name': '4:0', 'unit': 'g'},
    1260: {'name': '6:0', 'unit': 'g'},
    1261: {'name': '8:0', 'unit': 'g'},
    1262: {'name': '10:0', 'unit': 'g'},
    1263: {'name': '12:0', 'unit': 'g'},
    1264: {'name': '14:0', 'unit': 'g'},
    1265: {'name': '16:0', 'unit': 'g'},
    1266: {'name': '18:0', 'unit': 'g'},
    1267: {'name': '20:0', 'unit': 'g'},
    1268: {'name': '18:1', 'unit': 'g'},
    1269: {'name': '18:2', 'unit': 'g'},
    1270: {'name': '18:3', 'unit': 'g'},
    1271: {'name': '20:4', 'unit': 'g'},
    1272: {'name': '22:6 n-3 (DHA)', 'unit': 'g'},
    1273: {'name': '22:0', 'unit': 'g'},
    1274: {'name': '14:1', 'unit': 'g'},
    1275: {'name': '16:1', 'unit': 'g'},
    1276: {'name': '18:4', 'unit': 'g'},
    1277: {'name': '20:1', 'unit': 'g'},
    1278: {'name': '20:5 n-3 (EPA)', 'unit': 'g'},
    1279: {'name': '22:1', 'unit': 'g'},
    1280: {'name': '22:5 n-3 (DPA)', 'unit': 'g'},
    1283: {'name': 'Phytosterols', 'unit': 'mg'},
    1285: {'name': 'Stigmasterol', 'unit': 'mg'},
    1286: {'name': 'Campesterol', 'unit': 'mg'},
    1288: {'name': 'Beta-sitosterol', 'unit': 'mg'},
    1292: {'name': 'Fatty acids, total monounsaturated', 'unit': 'g'},
    1293: {'name': 'Fatty acids, total polyunsaturated', 'unit': 'g'},
    1299: {'name': '15:0', 'unit': 'g'},
    1300: {'name': '17:0', 'unit': 'g'},
    1301: {'name': '24:0', 'unit': 'g'},
    1303: {'name': '16:1 t', 'unit': 'g'},
    1304: {'name': '18:1 t', 'unit': 'g'},
    1305: {'name': '22:1 t', 'unit': 'g'},
    1306: {'name': '18:2 t not further defined', 'unit': 'g'},
    1307: {'name': '18:2 i', 'unit': 'g'},
    1310: {'name': '18:2 t,t', 'unit': 'g'},
    1311: {'name': '18:2 CLAs', 'unit': 'g'},
    1312: {'name': '24:1 c', 'unit': 'g'},
    1313: {'name': '20:2 n-6 c,c', 'unit': 'g'},
    1314: {'name': '16:1 c', 'unit': 'g'},
    1315: {'name': '18:1 c', 'unit': 'g'},
    1316: {'name': '18:2 n-6 c,c', 'unit': 'g'},
    1317: {'name': '22:1 c', 'unit': 'g'},
    1321: {'name': '18:3 n-6 c,c,c', 'unit': 'g'},
    1323: {'name': '17:1', 'unit': 'g'},
    1325: {'name': '20:3', 'unit': 'g'},
    1329: {'name': 'Fatty acids, total trans-monoenoic', 'unit': 'g'},
    1331: {'name': 'Fatty acids, total trans-polyenoic', 'unit': 'g'},
    1332: {'name': '13:0', 'unit': 'g'},
    1333: {'name': '15:1', 'unit': 'g'},
    1404: {'name': '18:3 n-3 c,c,c (ALA)', 'unit': 'g'},
    1405: {'name': '20:3 n-3', 'unit': 'g'},
    1406: {'name': '20:3 n-6', 'unit': 'g'},
    1408: {'name': '20:4 n-6', 'unit': 'g'},
    1409: {'name': '18:3i', 'unit': 'g'},
    1410: {'name': '21:5', 'unit': 'g'},
    1411: {'name': '22:4', 'unit': 'g'},
    1412: {'name': '18:1-11 t (18:1t n-7)', 'unit': 'g'},
    2000: {'name': 'Total Sugars', 'unit': 'g'},
  };
}
