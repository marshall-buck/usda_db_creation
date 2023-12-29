import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:usda_db_creation/db_parser.dart';

import 'setup/mock_db.dart';
import 'setup/setup.dart';

void main() {
  setUpAll(() {
    set_up_all();
  });

  tearDown(() {
    tear_down();
  });
  group('DBParser class tests', () {
    group('init() - ', () {
      test('loads file correctly', () {
        when(() => mockFileLoaderService.loadData('fake'))
            .thenReturn(mockUsdaFile);
        final dbParser = DBParser.init(
            path: 'fake', fileLoaderService: mockFileLoaderService);
        // dbParser.init('fake');
        final res = dbParser.originalFoodsList;

        expect(res.length, 3);
      });
    });
  });
}
