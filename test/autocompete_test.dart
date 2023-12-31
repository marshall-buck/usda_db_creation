import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:test/test.dart';
import 'package:usda_db_creation/autocomplete.dart';

import 'setup/mock_data.dart';
import 'setup/setup.dart';

void main() {
  setUpAll(() {
    set_up_all();
  });

  tearDown(() {
    tear_down();
  });

  group('Autocomplete class tests', () {
    group('createAutocompleteWordIndexMap()', () {
      test('createAutocompleteWordIndexMap should return the correct index map',
          () {
        const expectation = {
          '100%': ['167513'],
          '2%': ['167514'],
          'artificial': ['167512'],
          'bake': ['167514'],
          'biscuits': ['167512'],
          'buttermilk': ['167512'],
          'cinnamon': ['167513'],
          'coating': ['167514'],
          'dough': ['167512', '167513'],
          'dry': ['167514'],
          'flavor': ['167512'],
          'foods': ['167514'],
          'golden': ['167512'],
          'icing': ['167513'],
          'kraft': ['167514'],
          'layer': ['167512'],
          'milk': ['167514'],
          'original': ['167514'],
          'pillsbury': ['167512', '167513'],
          'pork': ['167514'],
          'recipe': ['167514'],
          'refrigerated': ['167512', '167513'],
          'rolls': ['167513'],
          'shake': ['167514']
        };

        final indexMap = AutocompleteHash.createAutocompleteWordIndexMap(
            finalDescriptionMap: mockDescriptionMap);

        final deepEquals = const DeepCollectionEquality();
        expect(deepEquals.equals(expectation, indexMap), true);
      });
      test('createAutocompleteIndexMap should handle empty description map',
          () {
        final Map<int, String> descriptionMap = {};

        final indexMap = AutocompleteHash.createAutocompleteWordIndexMap(
          finalDescriptionMap: descriptionMap,
        );

        expect(indexMap, isA<SplayTreeMap<String, List<String>>>());
        expect(indexMap.isEmpty, true);
      });

      test(
          'createAutocompleteIndexMap should handle description map with stop words',
          () {
        final descriptionMap = {
          167782: 'apple is a fruit',
          173175: 'apples are delicious',
          171686: 'orange being is a citrus fruit',
        };

        final indexMap = AutocompleteHash.createAutocompleteWordIndexMap(
          finalDescriptionMap: descriptionMap,
        );

        expect(indexMap, isA<SplayTreeMap<String, List<String>>>());
        expect(indexMap.length, 6);
        expect(indexMap['apple'], containsAll(['167782']));
        expect(indexMap['apples'], containsAll(['173175']));
        expect(indexMap['orange'], containsAll(['171686']));
        expect(indexMap['are'], isNull);
        expect(indexMap['being'], isNull);
      });
      test(
          'createAutocompleteIndexMap should strip remaining parentheses and numbers and /es',
          () {
        final descriptionMap = {
          167782: 'apple 18fat is a (fruit 1/8',
          173175: 'apples are delicious) 200 aa 11g',
          171686: 'orange being is a citrus/fruit 100%',
        };

        final indexMap = AutocompleteHash.createAutocompleteWordIndexMap(
          finalDescriptionMap: descriptionMap,
        );

        expect(indexMap, isA<SplayTreeMap<String, List<String>>>());
        expect(indexMap.length, 7);
        expect(indexMap['apple'], containsAll(['167782']));
        expect(indexMap['apples'], containsAll(['173175']));
        expect(indexMap['orange'], containsAll(['171686']));
        expect(indexMap['100%'], containsAll(['171686']));
        expect(indexMap['200'], isNull);
        expect(indexMap['(fruit'], isNull);
        expect(indexMap['delicious)'], isNull);
      });
    });
    group('createOriginalSubstringMap()', () {
      test('substrings populates correctly', () async {
        final res = AutocompleteHash.createOriginalSubstringMap(
            wordIndex: mockAutocompleteIndex);

        final deep = DeepCollectionEquality();

        expect(deep.equals(res, originalSubStringMap), true);
      });
      group('createAutocompleteHashTable() - ', () {
        test('hashes list correctly', () async {
          final autocomplete = AutocompleteHash();
          final res = autocomplete.createAutocompleteHashTable(
              originalSubStringMap: originalSubStringMap);
          final d = DeepCollectionEquality();

          expect(
              d.equals(res['substrings'], autoCompleteHashTable['substrings']),
              true);
          expect(d.equals(res['hashIndex'], autoCompleteHashTable['hashIndex']),
              true);
        });
      });
    });
  });
}

/* cSpell:disable */
const Map<String, List<String>> originalSubStringMap = {
  '%': ['3'],
  '1': ['3', '4'],
  '2': ['3', '4'],
  'aba': ['3', '4'],
  'abap': ['3', '4'],
  'abapp': ['3', '4'],
  'abappl': ['3', '4'],
  'abapple': ['3', '4'],
  'app': ['1', '2', '3', '4'],
  'appl': ['1', '2', '3', '4'],
  'apple': ['1', '2', '3', '4'],
  'bap': ['3', '4'],
  'bapp': ['3', '4'],
  'bappl': ['3', '4'],
  'bapple': ['3', '4'],
  'cra': ['3', '4'],
  'crab': ['3', '4'],
  'craba': ['3', '4'],
  'crabap': ['3', '4'],
  'crabapp': ['3', '4'],
  'crabappl': ['3', '4'],
  'crabapple': ['3', '4'],
  'ple': ['1', '2', '3', '4'],
  'ppl': ['1', '2', '3', '4'],
  'pple': ['1', '2', '3', '4'],
  'rab': ['3', '4'],
  'raba': ['3', '4'],
  'rabap': ['3', '4'],
  'rabapp': ['3', '4'],
  'rabappl': ['3', '4'],
  'rabapple': ['3', '4']
};

const Map<String, dynamic> autoCompleteHashTable = {
  'substrings': {
    '%': 0,
    '1': 1,
    '2': 1,
    'aba': 1,
    'abap': 1,
    'abapp': 1,
    'abappl': 1,
    'abapple': 1,
    'app': 2,
    'appl': 2,
    'apple': 2,
    'bap': 1,
    'bapp': 1,
    'bappl': 1,
    'bapple': 1,
    'cra': 1,
    'crab': 1,
    'craba': 1,
    'crabap': 1,
    'crabapp': 1,
    'crabappl': 1,
    'crabapple': 1,
    'ple': 2,
    'ppl': 2,
    'pple': 2,
    'rab': 1,
    'raba': 1,
    'rabap': 1,
    'rabapp': 1,
    'rabappl': 1,
    'rabapple': 1,
  },
  'indexHash': {
    0: ['3'],
    1: ['3', '4'],
    2: ['1', '2', '3', '4'],
  }
};
