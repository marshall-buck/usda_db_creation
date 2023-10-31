import 'package:collection/collection.dart';
import 'package:test/test.dart';
import 'package:usda_db_creation/db/create_reverse_index.dart';
import 'package:usda_db_creation/helpers/file_helpers.dart';

//  cSpell: disable
void main() {
  group('create reverse index tests', () {
    group('createSubstrings() - ', () {
      test('substrings popultes correctly', () async {
        final file = await readJsonFile('test/data/test_word_index.json');
        final res = createSubstrings(file);
        final deep = DeepCollectionEquality();
        // print(res);
        expect(deep.equals(res, indexRes), true);
      });
    });
    group('createHashTable() - ', () {
      test('returns correct list', () async {
        final res = createHashTable(indexRes);
        final d = DeepCollectionEquality();
        print(res);
        expect(d.equals(res, newIndex), true);
      });
    });
    // group('doesContainList() - ', () {
    //   test('returns true for included list', () async {
    //     expect(doesContainList(hashRes, ['3', '4']), true);
    //     expect(doesContainList(hashRes, ['1', '2', '3', '4']), true);
    //   });
    //   test('returns false for no list', () async {
    //     expect(doesContainList(hashRes, ['3', '4', '1']), false);
    //   });
    // });
  });
}

const Map<String, List<String>> indexRes = {
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
  'rabapple': ['3', '4'],
};

const Map<int, List<String>> hashRes = {
  0: ['3', '4'],
  1: ['1', '2', '3', '4']
};

const newIndex = {
  'newWordIndex': {
    'aba': 0,
    'abap': 0,
    'abapp': 0,
    'abappl': 0,
    'abapple': 0,
    'app': 1,
    'appl': 1,
    'apple': 1,
    'bap': 0,
    'bapp': 0,
    'bappl': 0,
    'bapple': 0,
    'cra': 0,
    'crab': 0,
    'craba': 0,
    'crabap': 0,
    'crabapp': 0,
    'crabappl': 0,
    'crabapple': 0,
    'ple': 1,
    'ppl': 1,
    'pple': 1,
    'rab': 0,
    'raba': 0,
    'rabap': 0,
    'rabapp': 0,
    'rabappl': 0,
    'rabapple': 0,
  },
  'hashTable': {
    0: ['3', '4'],
    1: ['1', '2', '3', '4']
  }
};