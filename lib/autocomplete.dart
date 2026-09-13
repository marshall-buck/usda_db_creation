import 'package:usda_db_creation/data_structure.dart';
import 'package:usda_db_creation/db_parser.dart';
import 'package:usda_db_creation/extensions/map_ext.dart';
import 'package:usda_db_creation/file_service.dart';

/// Class to represent the [AutoCompleteHashData]'s structure and methods.
/// This is the data structure that represents a substring tree, and a lookup table
/// for the substrings values.
///
/// Typically the data would be written to one json file.
/// and converted in to the data structure.
/// /*Cspell:disable
/// ```dart
///  {
/// substringHash = {
///   'aba': 0,
///   'abap': 0,
///   'abapp': 0,
///   'abappl': 1,
///   'abapple': 0, ...
///    },
///   indexHash = {
///     0: [3, 4],
///     1: [1, 2, 3, 4]
///    }
///   }
/// ```
///  /*Cspell:enable
class AutoCompleteHashData {
  /// Creates the autocomplete data from an already built substring and
  /// index hash.
  AutoCompleteHashData({required this.substringHash, required this.indexHash});

  /// Maps each substring to the key of its index list in [indexHash].
  final Map<String, int> substringHash;

  /// Maps a hash key to the list of description indexes it resolves to.
  final Map<int, List<int>> indexHash;

  /// Converts the properties to a `Map<String, dynamic>` for json serialization.
  Map<String, dynamic> toJson() {
    return {
      'substringHash': substringHash,
      'indexHash': indexHash.deepConvertMapKeyToString(),
    };
  }
}

/// Class to represent the [AutoCompleteHashTable]'s structure and methods.
/// This class implements the [DataStructure] interface.
///
/// The [AutoCompleteHashTable] is a data structure that represents a substring
/// tree and a lookup table for the substring values.
/// It is used to create and manipulate data for autocomplete functionality.
///
/// The data structure consists of two main properties:
/// - [_substringHash] A map that stores the hash values for each substring.
/// - [_indexHash] A map that stores the index values for each hash key.
///
/// The [unHashedSubstrings] parameter is used to initialize the data structure
/// with a map of un-hashed substrings and their corresponding index values.
///
/// The [createDataStructure] method is used to create the data structure and
/// optionally write the data to a file.
/// It takes a [DBParser] object as a parameter, which is used for file operations.
/// The `returnData` parameter determines whether the method should return the
/// created data or not.
/// The `writeFile` parameter determines whether the method should write the
/// data to a file or not.
///
/// The [_populateHashes] method is a private method that populates the [_substringHash]
/// and [_indexHash] properties from the [unHashedSubstrings] map.
/// It iterates over the entries of the [unHashedSubstrings] map and calculates
/// the hash key for each substring.
/// If the hash key is not found in the [_indexHash] map, it adds the index list
/// value to the [_indexHash] map and assigns the hash key to the substring in the [_substringHash] map.
/// If the hash key is found in the [_indexHash] map, it assigns the hash key to
/// the substring in the [_substringHash] map.
///
/// The [_lookupKeyFor] method is a static private method that builds the key
/// used to recognize an index list that has already been given a bucket in
/// [_indexHash].
///
//// *Cspell:disable
/// Example usage:
/// ```dart
/// final unHashedSubstrings = {
///   'aba': [3, 4],
///   'abap': [3, 4],
///   'abapp': [1, 2, 3, 4],
///   'abappl': [3, 4],
/// };
/// /*Cspell:enable
/// final autoCompleteHashTable = AutoCompleteHashTable(unHashedSubstrings);
/// final data = await autoCompleteHashTable.createDataStructure(
///   dbParser: dbParser,
///   returnData: true,
///   writeFile: true,
/// );
/// ```
///
/// Note: This class requires the 'usda_db_creation' package for the [DBParser],
/// [DataStructure], and [FileService] classes.
/// Make sure to import these packages before using this class.
///
/// See Also:
/// - [AutoCompleteHashData] The data structure that represents the substring
/// tree and lookup table.
/// - [DBParser] The class used for file operations.
/// - [DataStructure] The interface implemented by this class.
/// - [FileService] The class used for file operations.
class AutoCompleteHashTable implements DataStructure<AutoCompleteHashData?> {
  /// Creates the hash table from a map of un-hashed substrings.
  AutoCompleteHashTable(this.unHashedSubstrings);
  final Map<String, int> _substringHash = {};
  final Map<int, List<int>> _indexHash = {};

  /// The substrings to hash, each mapped to its list of description indexes.
  final Map<String, List<int>> unHashedSubstrings;

  /// Method to create the data and optionally write the files.
  @override
  Future<AutoCompleteHashData?> createDataStructure({
    required DBParser dbParser,
    bool returnData = true,
    bool writeFile = false,
  }) async {
    _populateHashes();

    final data = AutoCompleteHashData(
      substringHash: _substringHash,
      indexHash: _indexHash,
    );

    if (writeFile) {
      await dbParser.fileService.writeFileByType<Null, Map<String, dynamic>>(
        fileName: FileService.fileNameAutocompleteHash,
        convertKeysToStrings: false,
        mapContents: data.toJson(),
      );
    }

    return returnData ? data : null;
  }

  /// Populates the _indexHash and _substringMap properties from the given [unHashedSubstrings].
  /// /* Cspell: disable*/
  /// ```dart
  /// Map<String, List<int>> originalSubStringMap = {
  ///     'aba': [3, 4],
  ///     'abap': [3, 4],
  ///     'abapp': [1, 2, 3, 4],
  ///     'abappl': [3, 4], ...
  ///      };
  /// ```
  /// _substringHash = { 'aba': 0, 'abap': 0, 'abapp': 1, 'abappl': 0, ... }
  ///
  /// _indexHash = { 0: [3, 4], 1: [1, 2, 3, 4], ...  }
  /// /* Cspell: enable*/
  void _populateHashes() {
    final hashKeysByIndexList = <String, int>{};
    var count = 0;

    for (final element in unHashedSubstrings.entries) {
      final indexListValue = element.value;
      final lookupKey = _lookupKeyFor(indexListValue);
      final hashKey = hashKeysByIndexList[lookupKey];

      if (hashKey == null) {
        _indexHash[count] = indexListValue;
        hashKeysByIndexList[lookupKey] = count;
        _substringHash[element.key] = count;
        count++;
      } else {
        _substringHash[element.key] = hashKey;
      }
    }
  }

  /// Builds the [_indexHash] lookup key for [indexList].
  ///
  /// Two substrings share an [_indexHash] bucket only when their index lists
  /// are equal element for element and in the same order, so joining the list
  /// is enough to identify a bucket, and lets an existing bucket be found by
  /// lookup instead of by comparing against every bucket already created.
  static String _lookupKeyFor(List<int> indexList) => indexList.join(',');
}
