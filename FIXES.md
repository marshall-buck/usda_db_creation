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

✅ `lib/db_parser.dart:63` — `_originalDBMap?['SRLegacyFoods'] as List<dynamic>`
pairs `?.` with a non-null cast, yielding a confusing cast error instead of a
real message. The field is never null after `init`.

✅ `lib/db_parser.dart:133` — `nutrient.id != 9999` is dead; `_findNutrient(9999)`
already `continue`d above. The `9999` sentinel is a magic number with no purpose.wai

## Design smells

✅ `lib/usda_db.dart:87-128` — the two `if (extras)` branches (`87-109` and
`109-128`) are near-identical copies; the whole thing collapses to
`writeFile: extras`.

🔴 `bin/usda_db_creation.dart:29-30` — `getLongestDescription` and
`getShortestDescription` each re-parse the full 210 MB foods list, so the CLI
does the parse three times.

🔴 `lib/data_structure.dart:10` — the interface takes a whole `DBParser` only to
reach `.fileService`. `FileService` is the actual dependency.

🔴 `lib/file_service.dart:98` — `writeFileByType<T, U>` generics are decorative;
the method does `is List` / `is Map` at runtime anyway, and callers write
`<Null, Map<…>>` noise.

🔴 `lib/file_service.dart:89-92` — `folderHash`/`fileHash` is really
`DateTime.now()` microseconds sliced at the first `.`; it degenerates to `"000"`
when microseconds are zero, and `writeManifestFile` stores only that. "Hash" is
a misleading name.

🔴 `lib/file_service.dart:144` — `_writeJsonFile`'s `convertKeysToStrings` param
is never passed and duplicates the deep conversion the caller already did.

🔴 `lib/description_parser.dart:104` and `:185` — both build a `MapEntry` purely
to immediately destructure it. `putIfAbsent` would likewise replace the
side-effecting ternary at `lib/word_index.dart:88`.

🔴 `lib/food_model.dart:13` — `id` is `dynamic` though always an `int`, and
`toJson` allocates a one-entry map per food just for `addAll`.

🔴 `lib/description_parser.dart:212` / `:230` — `getLongestDescriptionRecord`
returns `(int, …)` while `getShortestDescriptionRecord` returns `(num, …)` for
the same shape of answer.

## Dead code

✅ `.gitignore` — lines 1–33 and 35–65 are the same block twice, and
`original_usda.json` (line 33) is subsumed by `lib/db` (line 63).

<!-- TODO: look for unused consts in file service -->
