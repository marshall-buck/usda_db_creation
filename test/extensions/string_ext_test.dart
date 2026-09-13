import 'package:collection/collection.dart';
import 'package:test/test.dart';
import 'package:usda_db_creation/extensions/string_ext.dart';

void main() {
  group('StringExtensions Unit Tests', () {
    group('removeUnwantedChars()', () {
      test(' removes unwanted characters', () {
        expect('he  llo!#!#'.removeUnwantedChars(), 'hello');
        expect('  hello-bob '.removeUnwantedChars(), 'hello-bob');
        expect('  hello)bob '.removeUnwantedChars(), 'hello)bob');
        expect('  hello(bob '.removeUnwantedChars(), 'hello(bob');
        expect('  (hello ) '.removeUnwantedChars(), '(hello)');
        expect(r'hello@$-!@#bob '.removeUnwantedChars(), 'hello-bob');
        expect('  hello '.removeUnwantedChars(), 'hello');
        expect('  hel  lo'.removeUnwantedChars(), 'hello');
        expect(''.removeUnwantedChars(), '');
        expect(' '.removeUnwantedChars(), '');
        expect('2%'.removeUnwantedChars(), '2%');
        expect('syrup/caramel'.removeUnwantedChars(), 'syrup/caramel');
      });
    });

    group('stripDashedAndParenthesisWord()', () {
      test(' separates words with dashes or parentheses', () {
        expect(
          'hello-there'.stripDashedAndParenthesisAndForwardSlashesWord(),
          ['hello', 'there'],
        );
        expect(
          'hello'.stripDashedAndParenthesisAndForwardSlashesWord(),
          ['hello'],
        );
        expect(
          'ready-to-bake'.stripDashedAndParenthesisAndForwardSlashesWord(),
          ['ready', 'to', 'bake'],
        );
        expect(
          '-to-bake'.stripDashedAndParenthesisAndForwardSlashesWord(),
          ['', 'to', 'bake'],
        );
        expect(
          '-to-bake-'.stripDashedAndParenthesisAndForwardSlashesWord(),
          ['', 'to', 'bake', ''],
        );
        expect(
          'syrup/caramel'.stripDashedAndParenthesisAndForwardSlashesWord(),
          ['syrup', 'caramel'],
        );
      });
    });

    group('getWordsToIndex()', () {
      test('Sentence should be stripped of all non alpha chars', () {
        const sentence1 = 'Doughnuts, yeast-Leavened, with jelly filling';
        expect(
          sentence1.getWordsToIndex(),
          {'doughnuts', 'yeast', 'leavened', 'with', 'jelly', 'filling'},
        );
        const sentence2 = 'Muffins, plain, prepared from recipe, made with low fat (2%) milk';

        expect(sentence2.getWordsToIndex(), {
          'muffins',
          'plain',
          'prepared',
          'from',
          'recipe',
          'made',
          'with',
          'low',
          'fat',
          '2%',
          'milk',
        });

        const sentence3 = 'Puff pastry, frozen, ready- -to-bake ';

        expect(
          sentence3.getWordsToIndex(),
          {'puff', 'pastry', 'frozen', 'ready', 'to', 'bake'},
        );
      });
    });

    group('isStopWord()', () {
      test('returns true if the word is a stop word', () {
        final stopWords = ['the', 'and', 'or'];
        const input1 = 'the';
        const input2 = 'apple';

        expect(input1.isStopWord(stopWords), isTrue);
        expect(input2.isStopWord(stopWords), isFalse);
      });
    });
    group('isLowerCaseOrNumberWithPercent()', () {
      test('returns true if the string is lowercase char or a number followed by percent', () {
        expect('a'.isLowerCaseOrNumberWithPercent(), true);
        expect('b'.isLowerCaseOrNumberWithPercent(), true);
        expect('1'.isLowerCaseOrNumberWithPercent(), false);
        expect('18g'.isLowerCaseOrNumberWithPercent(), false);
        expect('18%'.isLowerCaseOrNumberWithPercent(), true);
      });
    });
    group('isNumberWithPercent()', () {
      test('returns true is number followed by percent', () {
        const number = '2';
        const number1 = '20';
        const number2 = '200';
        const percent = '2%';
        const percent1 = '20%';
        const percent2 = '200%';
        const notNumber = '2%b';

        expect(number.isNumberWithPercent(), false);
        expect(number1.isNumberWithPercent(), false);
        expect(number2.isNumberWithPercent(), false);
        expect(percent.isNumberWithPercent(), true);
        expect(percent1.isNumberWithPercent(), true);
        expect(percent2.isNumberWithPercent(), true);
        expect(notNumber.isNumberWithPercent(), false);
      });
    });
    group('separateIntoPhrasesWithMinimumLength()', () {
      test('String greater than twice minLength returns correctly', () {
        const sentence49 = 'Quietly, an old oak stood, surrounded by natures.';
        const expectation = [
          'Quietly, an old oak stood,',
          'Quietly, an old oak stood, surrounded',
          'Quietly, an old oak stood, surrounded by',
          'Quietly, an old oak stood, surrounded by natures.',
          'an old oak stood, surrounded',
          'an old oak stood, surrounded by',
          'an old oak stood, surrounded by natures.',
          'old oak stood, surrounded',
          'old oak stood, surrounded by',
          'old oak stood, surrounded by natures.',
          'oak stood, surrounded',
          'oak stood, surrounded by',
          'oak stood, surrounded by natures.',
          'stood, surrounded by',
          'stood, surrounded by natures.',
          'surrounded by natures.',
        ];
        /* cSpell:enable */
        final res = sentence49.separateIntoPhrasesWithMinimumLength(
          minPhraseLength: 20,
        );

        const listEquals = ListEquality<String?>();

        expect(listEquals.equals(expectation, res), true);
      });
      test('String of equal length to minLength returns correctly', () {
        // 'Quietly, an old oak stood, surrounded by natures.'

        const expectation = [
          'Quietly, an old oak ',
        ];

        final res = 'Quietly, an old oak '.separateIntoPhrasesWithMinimumLength(
          minPhraseLength: 20,
        );

        const listEquals = ListEquality<String?>();
        expect(listEquals.equals(expectation, res), true);
      });
      test('String of equal length + 1 to minLength returns correctly', () {
        const expectation = ['Quietly, an old oaK T'];

        final res = 'Quietly, an old oaK T'.separateIntoPhrasesWithMinimumLength(
          minPhraseLength: 20,
        );

        const listEquals = ListEquality<String?>();
        expect(listEquals.equals(expectation, res), true);
      });
      test('String of equal length - 1 to minLength returns correctly', () {
        final res = 'Quietly, an old oak'.separateIntoPhrasesWithMinimumLength(
          minPhraseLength: 20,
        );
        const listEquals = ListEquality<String?>();
        expect(listEquals.equals([], res), true);
        expect(res.isEmpty, true);
      });
      test('String of less than to minLength returns correctly', () {
        // 'Quietly, an old oak stood, surrounded by natures.'

        final res = 'George Weston Bakeries, Thomas English Muffins'.separateIntoPhrasesWithMinimumLength(
          minPhraseLength: 48,
        );
        const listEquals = ListEquality<String?>();
        expect(listEquals.equals([], res), true);
        expect(res.isEmpty, true);
      });

      test('When the next space is always the last space', () {
        // 'Quietly, an old oak stood, surrounded by natures.'
        const expectation = [
          'In a distant galaxy, stars shimmered like diamonds.',
          'a distant galaxy, stars shimmered like diamonds.',
          'distant galaxy, stars shimmered like diamonds.',
        ];
        final res = 'In a distant galaxy, stars shimmered like diamonds.'.separateIntoPhrasesWithMinimumLength(
          minPhraseLength: 45,
        );

        const listEquals = ListEquality<String?>();
        expect(listEquals.equals(expectation, res), true);
      });
    });
  });
}
