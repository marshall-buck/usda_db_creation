import 'dart:collection';

import 'package:usda_db_creation/description_parser.dart';
import 'package:usda_db_creation/global_const.dart';
import 'package:usda_db_creation/string_ext.dart';

abstract class WordIndex {
  SplayTreeMap<String, List<int>> createAutocompleteWordIndexMap();
}

/// Class to create a [Map] of words to index, from teh Food descriptions.
/// Each key is a word that will be used in an autocomplete search.
/// the value of the word key is a list of [int]s of the food items id's.
/// Technically I could have skipped this step and created the autocomplete
/// hashes without this step, but it is useful to see a visual
/// representation of all the words and location's.
/// So this is needed for the step of creating the [AutoCompleteHashTable]
class WordIndexMap implements WordIndex {
  final DescriptionMap finalDescriptionMap;

  WordIndexMap(this.finalDescriptionMap);

  /// Creates a word index from the given [finalDescriptionMap].
  ///
  /// Parameters:
  /// [finalDescriptionMap] -  [DescriptionMap].
  ///
  /// Returns - [SplayTreeMap<String, List<int>>]
  ///  {..."apple": [167782,..],
  ///      "apples": [ 173175, 174170,...],
  ///      "orange": [ 171686, 171687,...], ...}.
  @override
  SplayTreeMap<String, List<int>> createAutocompleteWordIndexMap() {
    final indexMap =
        SplayTreeMap<String, List<int>>((final a, final b) => a.compareTo(b));

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
                ? indexMap[word]!.add(entry.key)
                : indexMap[word] = [entry.key];
          }
        }
      }
    }

    return indexMap;
  }
}