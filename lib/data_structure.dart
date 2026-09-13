import 'package:usda_db_creation/db_parser.dart';

/// Abstract class for the database data structures.
/// All classes that create Objects for the Db must implement this method.
/// `dbParser` - The instance of the  [DBParser] class.
/// `returnData` - Whether to return the object created.
/// `writeFile` - Whether to write the data to a file.
abstract class DataStructure<T> {
  /// Builds this data structure, optionally writing it to a file.
  Future<T> createDataStructure({
    required DBParser dbParser,
    bool returnData = true,
    bool writeFile = false,
  });
}
