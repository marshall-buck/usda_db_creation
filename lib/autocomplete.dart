import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:usda_db_creation/description_parser.dart';
import 'package:usda_db_creation/global_const.dart';
import 'package:usda_db_creation/string_ext.dart';

// TODO: make the  parameters from the descriptions.
// abstract class AutoComplete {
//   Map<String, dynamic> createAutocompleteHashTable(
//       {required final Map<String, List<String>> originalSubStringMap});
// }

/// Class to handle the word index for the autocomplete search.
class AutocompleteHash {
  /// Minimum number of characters to use for the substring.
  static int minLength = 3;

  /// Creates a word index from the given [finalDescriptionMap].
  ///
  /// Parameters:
  /// [finalDescriptionMap] -  [DescriptionMap].
  ///
  /// Returns - [Map]
  ///  {..."apple": ["167782",..],
  ///      "apples": [ "173175", "174170",...],
  ///      "orange": [ "171686", "171687",...], ...}.
  static Map<String, List<String>> createAutocompleteWordIndexMap(
      {required final DescriptionMap finalDescriptionMap}) {
    final indexMap = SplayTreeMap<String, List<String>>(
        (final a, final b) => a.compareTo(b));

    for (final entry in finalDescriptionMap.entries) {
      final sanitizedList = entry.value.getWordsToIndex();
      if (sanitizedList.isNotEmpty) {
        for (String word in sanitizedList) {
          if (word.startsWith('(')) {
            word = word.substring(1);
          }
          if (word.endsWith(')')) {
            word = word.substring(0, word.length - 1);
          }
          if (word.isStopWord(stopWords) ||
              !word.isLowerCaseOrNumberWithPercent()) {
            continue;
          } else if (!word.isNumberWithPercent() && word.length < 3) {
            continue;
          } else {
            indexMap.containsKey(word)
                ? indexMap[word]!.add(entry.key.toString())
                : indexMap[word] = [entry.key.toString()];
          }
        }
      }
    }

    return indexMap;
  }

  /// Creates substrings from the given [wordIndex] and returns a map of
  /// substrings with a minimum of [minLength] length to a list of corresponding index's.
  ///
  /// Example usage:
  /// ```dart
  /// final autoCompleteMap = {
  ///   'apple': ['1', '2'],
  ///   'crabapple': ['3', '4'],
  /// };
  ///
  /// final substringMap = createSubstrings(autoCompleteMap: autoCompleteMap);
  /// ```
  /// { 'aba': ['3', '4'],
  ///   'abap': ['3', '4'],
  ///   'abapp': ['3', '4'],
  ///   'abappl': ['3', '4'],
  ///   'abapple': ['3', '4'], ...
  /// }
  /// ```
  static Map<String, List<String>> createOriginalSubstringMap(
      {required final Map<String, List<String>> wordIndex}) {
    final indexMap =
        SplayTreeMap<String, Set<String>>((final a, final b) => a.compareTo(b));

    for (final item in wordIndex.entries) {
      final String word = item.key;

      final List<String> wordIndexList = List<String>.from(item.value);
      // this inner loop will check for numbers and percents, for these
      // we will not enforce a minimum length.
      for (int i = 0; i < word.length; i++) {
        if (word[i] == '%' || word[i].isNumber()) {
          if (!indexMap.containsKey(word[i])) {
            indexMap[word[i]] = <String>{};
          }

          indexMap[word[i].toString()]!.addAll(wordIndexList);

          continue;
        }

        for (int j = i + minLength; j <= word.length; j++) {
          final String substring = word.substring(i, j);

          if (!indexMap.containsKey(substring)) {
            indexMap[substring] = <String>{};
          }

          indexMap[substring]!.addAll(wordIndexList);
        }
      }
    }

    return indexMap
        .map((final key, final value) => MapEntry(key, value.toList()..sort()));
  }

  /// Creates an indexHash table from the given [originalSubStringMap]  and
  /// rewrites the substring map with the new index values.
  ///
  /// This is the final step in creating the autocomplete hash table.
  /// Write this output to a file.
  ///
  /// Example usage:
  /// ```dart
  /// final originalSubStringMap = {
  ///     'aba': ['3', '4'],
  ///     'abap': ['3', '4'],
  ///     'abapp': ['3', '4'],
  ///     'abappl': ['3', '4'], ...
  ///      };
  ///
  /// final table = createAutocompleteHashTable(originalSubStringMap: originalSubStringMap);
  /// ```
  ///
  /// Returns -  {
  ///   'substrings': {
  ///   'aba': 0,
  ///   'abap': 0,
  ///   'abapp': 0,
  ///   'abappl': 0,
  ///   'abapple': 0, ...
  ///    },
  ///   'indexHash': {
  ///     0: ['3', '4'],
  ///     1: ['1', '2', '3', '4']
  ///    }
  ///   }
  /// ```

  Map<String, dynamic> createAutocompleteHashTable(
      {required final Map<String, List<String>> originalSubStringMap}) {
    final Map<String, int> newWordIndex = {};
    final Map<int, List<String>> hashTable = {};
    int count = 0;

    for (final element in originalSubStringMap.entries) {
      final List<String> indexListValue = element.value;
      final int hashKey = findHashKey(
          indexListFromSubstring: indexListValue, hashTable: hashTable);

      if (hashKey == -1) {
        hashTable[count] = indexListValue;
        newWordIndex[element.key] = count;
        count++;
      }

      if (hashKey >= 0) {
        newWordIndex[element.key] = hashKey;
      }
    }
// TODO: change index to numbers
    final Map<String, List<String>> stringKeyMap = hashTable
        .map((final key, final value) => MapEntry(key.toString(), value));

    return {"substrings": newWordIndex, "indexHash": stringKeyMap};
  }

  /// Finds the hash key for the given [indexListFromSubstring] and [hashTable].
  static int findHashKey(
      {required final List<String> indexListFromSubstring,
      required final Map<int, List<String>> hashTable}) {
    for (final element in hashTable.entries) {
      final int hashKey = element.key;

      final listEquals = ListEquality();
      if (listEquals.equals(element.value, indexListFromSubstring)) {
        return hashKey;
      }
    }
    return -1;
  }
}
