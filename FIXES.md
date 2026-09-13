# Fixes

Outstanding code smells from the review.
🔴 = open task.

## Correctness / performance

✅ `lib/autocomplete.dart:188` — `_findHashKey` linear-scans `_indexHash` for
every substring: 22,529 substrings × ~5,007 buckets ≈ 56M `ListEquality`
compares on the real DB. Key on a canonical string of the id list to make it
O(n).

✅ `lib/file_service.dart:213` — `loadData` calls `readAsStringSync` *before*
`existsSync`, so the `FileSystemException('File not found')` is unreachable.

✅ `lib/file_service.dart:132,144,162,190` — every writer swallows its exception
into `log()` and returns normally, so a failed or partial write reports success;
`dart:developer.log` is also invisible in a plain CLI run.

🔴 `lib/db_parser.dart:63` — `_originalDBMap?['SRLegacyFoods'] as List<dynamic>`
pairs `?.` with a non-null cast, yielding a confusing cast error instead of a
real message. The field is never null after `init`.

🔴 `lib/description_parser.dart:198` — `_parseDescriptionRecordFromString`
hardcodes `substring(1, 7)` / `substring(9, …)`, silently breaking on any
7-digit `fdcId`. Split on the first comma instead.

🔴 `lib/description_parser.dart:166` — phrase removal leaves orphaned whitespace
and commas behind (`"…green anjou "`), with no normalization pass.

🔴 `lib/db_parser.dart:133` — `nutrient.id != 9999` is dead; `_findNutrient(9999)`
already `continue`d above. The `9999` sentinel is a magic number with no purpose.

🔴 `lib/db_parser.dart:121` — `originalNutrientTableEdit[id]!['unit']!` plus a
bare `throw Exception` on unit mismatch aborts a multi-minute build over one row.

🔴 `lib/db_parser.dart:133` — the `amount > 0` filter conflates "0 g sodium" with
"sodium unknown" in the output.

🔴 `lib/substrings.dart:77` — the `isNumberWithPercent`/`isNumber` short-circuit
sits *inside* the `i` loop, so numeric tokens are re-added once per character.
Hoist it above the loop.

🔴 `lib/word_index.dart:83` — `isLowerCaseOrNumberWithPercent` is `^[a-z]+$`, so
any token containing a digit (`b12`, `2x4`) is dropped from the index entirely.

🔴 `lib/word_index.dart:98` — emits unsorted index lists while
`lib/substrings.dart:98` sorts, giving two output files inconsistent ordering.

## Design smells

🔴 `lib/db_parser.dart:13` — `DB` overrides `createDataStructure` with *inverted*
defaults (`returnData: false, writeFile: true`) versus the `DataStructure`
interface, and `lib/usda_db.dart:108` silently depends on that. `DB` also skips
the `!returnData && !writeFile` guard the other three implementations have.

🔴 `lib/usda_db.dart:87-128` — the two `if (extras)` branches are near-identical
copies; the whole thing collapses to `writeFile: extras`.

🔴 `bin/usda_db_creation.dart:29-30` — `getLongestDescription` and
`getShortestDescription` each re-parse the full 210 MB foods list, so the CLI
does the parse three times.

🔴 `lib/data_structure.dart:11` — the interface takes a whole `DBParser` only to
reach `.fileService`. `FileService` is the actual dependency.

🔴 `lib/file_service.dart:98` — `writeFileByType<T, U>` generics are decorative;
the method does `is List` / `is Map` at runtime anyway, and callers write
`<Null, Map<…>>` noise.

🔴 `lib/file_service.dart:89-92` — `folderHash`/`fileHash` is really
`DateTime.now()` microseconds sliced at the first `.`; it degenerates to `"000"`
when microseconds are zero, and `writeManifestFile` stores only that. "Hash" is
a misleading name.

🔴 `lib/file_service.dart:152` — `_writeJsonFile`'s `convertKeysToStrings` param
is never passed and duplicates the deep conversion the caller already did.

🔴 `lib/description_parser.dart:104` and `:185` — both build a `MapEntry` purely
to immediately destructure it. `putIfAbsent` would likewise replace the
side-effecting ternary at `lib/word_index.dart:88`.

🔴 `lib/food_model.dart:13` — `id` is `dynamic` though always an `int`, and
`toJson` allocates a one-entry map per food just for `addAll`.

🔴 `lib/description_parser.dart:205` / `:223` — `getLongestDescriptionRecord`
returns `(int, …)` while `getShortestDescriptionRecord` returns `(num, …)` for
the same shape of answer.

## Dead code

🔴 `lib/global_const.dart:117` — `nutrientIds` (150 entries) is unused;
`Nutrient.keepTheseNutrients` is the live list. Two overlapping id sets.

🔴 `lib/nutrients_vitamins.dart` — the entire file is unused.

🔴 `lib/nutrient.dart:160` — the comment "Not used anywehrer just here for
reference" is wrong (used at `db_parser.dart:121`) and misspelled.

🔴 `lib/nutrient.dart:43-61` — commented-out `createNutrientInfoMap`.

🔴 `lib/global_const.dart:113` — stop word `"USDA's"` can never match; the
apostrophe is stripped and the token lowercased to `usdas` before the check.

🔴 `lib/db_parser.dart:154` — `findAllNutrientIds` has no caller.

🔴 `lib/extensions/map_ext.dart:20` — `deepConvertMapKeyToInt` is test-only.

🔴 `pubspec.yaml:13` — `json_annotation` is unused.

🔴 `bin/usda_db_creation.dart:3` — `ignore_for_file: unused_import` masks five
genuinely unused imports.

🔴 `lib/file_service.dart:64` — `fileNameOriginalDescriptions` is the only
filename constant carrying its own `.txt`, so it would yield `…txt.txt`.

🔴 `.gitignore` — lines 1–33 and 35–65 are the same block twice, and
`original_usda.json` (line 33) is subsumed by `lib/db` (line 63).
