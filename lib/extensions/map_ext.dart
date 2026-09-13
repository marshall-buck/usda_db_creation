/// Recursive key conversion used when serializing the generated maps.
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
}
