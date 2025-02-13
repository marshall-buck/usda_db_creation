const unwantedPhrases = [
  "(Includes foods for USDA's Food Distribution Program)",
  // "separable lean and fat, ",
  // "separable lean only, "
];

const excludedCategories = ["Restaurant Foods", "Fast Foods", "Beverages"];

const List<String> stopWords = [
  "about",
  "above",
  "after",
  "again",
  "against",
  "all",
  "am",
  "an",
  "and",
  "are",
  "as",
  "at",
  "be",
  "because",
  "been",
  "before",
  "being",
  "below",
  "between",
  "both",
  "but",
  "by",
  "can",
  "could",
  "did",
  "do",
  "does",
  "doing",
  "down",
  "during",
  "each",
  "few",
  "for",
  "from",
  "had",
  "has",
  "have",
  "having",
  "how",
  "if",
  "in",
  "into",
  "is",
  "it",
  "its",
  "just",
  "made",
  "more",
  "most",
  "not",
  "now",
  "of",
  "off",
  "on",
  "once",
  "only",
  "or",
  "other",
  "our",
  "ours",
  "out",
  "over",
  "own",
  "same",
  "she",
  "should",
  "so",
  "some",
  "such",
  "than",
  "that",
  "the",
  "their",
  "them",
  "then",
  "there",
  "these",
  "they",
  "this",
  "those",
  "through",
  "to",
  "too",
  "under",
  "until",
  "up",
  "very",
  "was",
  "we",
  "were",
  "what",
  "when",
  "where",
  "which",
  "while",
  "who",
  "will",
  "with",
  "you",
  "your",
  "USDA's"
];

const Set<int> nutrientIds = {
  1003,
  1007,
  1062,
  1079,
  1089,
  1093,
  1253,
  1257,
  1258,
  1004,
  1005,
  1008,
  1051,
  2000,
  1104,
  1106,
  1162,
  1087,
  1105,
  1177,
  1265,
  1268,
  1269,
  1270,
  1292,
  1293,
  1190,
  1166,
  1178,
  1184,
  1185,
  1187,
  1210,
  1211,
  1215,
  1217,
  1107,
  1108,
  1120,
  1122,
  1127,
  1130,
  1131,
  1165,
  1009,
  1012,
  1013,
  1018,
  1075,
  1090,
  1091,
  1098,
  1101,
  1261,
  1263,
  1264,
  1272,
  1273,
  1274,
  1275,
  1278,
  1280,
  1300,
  1323,
  1333,
  1218,
  1222,
  1224,
  1225,
  1226,
  1246,
  1299,
  1313,
  1321,
  1325,
  1219,
  1220,
  1221,
  1223,
  1227,
  1242,
  1259,
  1260,
  1262,
  1266,
  1267,
  1271,
  1276,
  1277,
  1279,
  1010,
  1011,
  1014,
  1057,
  1058,
  1092,
  1095,
  1103,
  1109,
  1123,
  1125,
  1126,
  1128,
  1129,
  1167,
  1170,
  1175,
  1186,
  1212,
  1213,
  1214,
  1216,
  1110,
  1180,
  1114,
  1198,
  1314,
  1183,
  1411,
  1301,
  1312,
  1410,
  1228,
  1404,
  1329,
  1304,
  1310,
  1331,
  1406,
  1305,
  1306,
  1311,
  1303,
  1315,
  1316,
  1317,
  1405,
  1099,
  1112,
  1288,
  1286,
  1409,
  1285,
  1307,
  1332,
  1283,
  1408,
  1111,
  1412
};
