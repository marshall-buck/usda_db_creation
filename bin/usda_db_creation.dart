// The imports below are kept so individual steps can be called ad hoc while
// tweaking the generation pipeline, and `print` is this CLI's real output.
// ignore_for_file: unused_import, avoid_print

import 'package:usda_db_creation/autocomplete.dart';
import 'package:usda_db_creation/db_parser.dart';
import 'package:usda_db_creation/description_parser.dart';

import 'package:usda_db_creation/file_service.dart';
import 'package:usda_db_creation/global_const.dart';
import 'package:usda_db_creation/substrings.dart';
import 'package:usda_db_creation/usda_db.dart' as runner;
import 'package:usda_db_creation/word_index.dart';

void main() async {
  final startTime = DateTime.now();
  final fileService = FileService();

  final dbParser = DBParser.init(
    filePath: fileService.fileNameOriginalDBFile,
    fileService: fileService,
  );
  await runner.createDBFiles(
    dbParser: dbParser,
    fileService: fileService,
    extras: true,
  );

  print(runner.getLongestDescription(dbParser: dbParser));
  print(runner.getShortestDescription(dbParser: dbParser));
  final endTime = DateTime.now();
  final duration = endTime.difference(startTime);
  print('Time taken: ${duration.inMilliseconds} milliseconds');
}
