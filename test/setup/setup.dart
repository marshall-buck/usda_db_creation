import 'dart:collection';

import 'package:mocktail/mocktail.dart';
import 'package:usda_db_creation/file_service.dart';

class MockFileLoaderService extends Mock implements FileService {}

late final MockFileLoaderService mockFileLoaderService;

// The snake_case names below are used by every test file; renaming them is a
// wider change than this lint is worth.
// ignore_for_file: non_constant_identifier_names

void tear_down() {
  reset(mockFileLoaderService);
}

void set_up_all() {
  mockFileLoaderService = MockFileLoaderService();
  final fallback = SplayTreeMap<String, List<int>>((a, b) => a.compareTo(b));
  registerFallbackValue(fallback);
}
