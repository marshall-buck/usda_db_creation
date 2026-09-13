/// Recursive key-conversion helpers used when serializing the generated maps.
extension MapExtensions on Map<dynamic, dynamic> {
  // TODO(marshall): Figure out how to handle optional params.
  /// Recursively traverses a map and converts [int] keys to  [String]
  Map<String, dynamic> deepConvertMapKeyToString({
    bool Function(dynamic key)? keyMatch,
    bool? changeKey,
  }) {
    final newMap = <String, dynamic>{};
    forEach((key, value) {
      final newKey = key is int ? key.toString() : key as String;
      newMap[newKey] = value is Map ? value.deepConvertMapKeyToString() : value;
    });
    return newMap;
  }

  /// Recursively traverses a map and converts [String] keys to  [int].
  /// Keys might not be parsable to ints, so return type is
  /// `Map<dynamic, dynamic>`.
  Map<dynamic, dynamic> deepConvertMapKeyToInt() {
    final newMap = <dynamic, dynamic>{};
    forEach((key, value) {
      if (key is String && int.tryParse(key) != null) {
        newMap[int.parse(key)] = value is Map ? value.deepConvertMapKeyToInt() : value;
      } else {
        newMap[key] = value is Map ? value.deepConvertMapKeyToInt() : value;
      }
    });
    return newMap;
  }
}
