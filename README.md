# usda_db_creation

A dart library made to create a json database and autocomplete lookup, from
the USDA SR Legacy database json download file.

## Source data

The pipeline reads `lib/db/do_not_delete/original_usda.json`, and that
`do_not_delete` folder also holds the nutrients files. All of `lib/db` is
gitignored, so the source file is already in place in a working copy that has
been set up before, but it will be missing from a fresh clone.

If it is missing, download the SR Legacy json, unzip it, and save it under that
name:

- Download page: <https://fdc.nal.usda.gov/download-datasets.html>
- Direct link:
  <https://fdc.nal.usda.gov/fdc-datasets/FoodData_Central_sr_legacy_food_json_2018-04.zip>

## Running it

```zsh
dart run
```

Every run writes to a new timestamped folder, `lib/db/<timestamp>/`, and each
file inside is prefixed with the microseconds portion of that timestamp, for
example `lib/db/2024-10-21_20_05_15.765190/765190_foods_db.json`. The
`file_manifest.txt` written beside them contains just that prefix.

`bin/usda_db_creation.dart` calls `createDBFiles` with `extras: true`, which
writes every file listed under [Behind the scenes](#behind-the-scenes). With
`extras: false` only `foods_db.json` and `autocomplete_hash.json` are written.

## The intended output is 2 json files

1. The foods and nutritional information.

   - The key is the food item's id.
   - The nutrients map is structured so that the key is the id of the
     nutrient and the value is the amount.
   - All keys are strings, since they are json object keys.

   ```text
   {
     '167512': {
       'description':
           'Pillsbury Golden Layer Buttermilk Biscuits, Artificial '
           'Flavor, refrigerated dough',
       'nutrients': {'1004': 13.2, '1003': 5.88, '1005': 41.2, '1008': 307, '1258': 2.94, ...}
     }, ...
   };
   ```

2. A lookup hash table of indexed words to search.

   - Each `substringHash` value is a key into `indexHash`.
   - Each `indexHash` value is the list of food ids whose descriptions contain
     that substring.
   - Substrings that resolve to the same list of food ids share one
     `indexHash` entry, which is the point of the indirection.

   <!-- CSpell: disable -->

   ```text
   {
     'substringHash': {
       '2%': 0,
       '21': 1,
       'ab': 1,
       'aba': 1,
       'abap': 1,
       'ap': 2,
       'app': 2,
       'appl': 2,
       'apple': 2, ...
     },
     'indexHash': {
       '0': [3],
       '1': [3, 4],
       '2': [1, 2, 3, 4]
     }
   };
   ```

   <!-- CSpell: enable -->

## Behind the scenes

The `1`-`4` in the examples below are placeholders standing in for food ids, not
real ones. The same four run through every step: `apple` appears in `1` and `2`,
`crabapple` and `21` in `3` and `4`, and `2%` in `3`.

1. Create a map of food descriptions `{id: description, ...}` from the original
   database, parsing the descriptions as necessary.

   - Foods in an `excludedCategories` category are dropped. As of now those are
     `Restaurant Foods`, `Fast Foods` and `Beverages`.
   - Each phrase in `unwantedPhrases` is stripped from the description.

   Both lists live in `global_const.dart`.

   The in-memory map is keyed by `int`; the written `descriptions.json` has
   string keys. A `descriptions.txt` is written alongside it with one
   `(id, description)` record per line.

2. Create the word index, written to `autocomplete_word_index.json`. *Although
   the hashes could have been made by skipping this step, its good to have a
   file to look at.*

   A word is indexed only if, after lowercasing and stripping unwanted
   characters, it is either all `a-z` and at least 3 characters long, or digits
   followed by a `%`. Words in `stopWords` are dropped.

   ```text
   {
     "apple": [1, 2],
     "crabapple": [3, 4],
     "2%": [3],
     "21": [3, 4],
   }
   ```

3. Create the substrings of the word index, written to `substrings.json`.

   Every substring of at least `minLength` (2) characters is generated, at every
   offset in the word. A word that is a plain number, or digits followed by a
   `%`, is kept whole instead of being broken up.

   <!-- CSpell: disable -->

   ```text
   {
     '2%': [3],
     '21': [3, 4],
     'ab': [3, 4],
     'aba': [3, 4],
     'abap': [3, 4],
     'abapp': [3, 4],
     'abappl': [3, 4],
     'abapple': [3, 4],
     'ap': [1, 2, 3, 4],
     'app': [1, 2, 3, 4],
     'appl': [1, 2, 3, 4],
     'apple': [1, 2, 3, 4],
     'ba': [3, 4],
     'bap': [3, 4],
     'bapp': [3, 4],
     'bappl': [3, 4],
     'bapple': [3, 4],
     'cr': [3, 4],
     'cra': [3, 4],
     'crab': [3, 4],
     'craba': [3, 4],
     'crabap': [3, 4],
     'crabapp': [3, 4],
     'crabappl': [3, 4],
     'crabapple': [3, 4],
     'le': [1, 2, 3, 4],
     'pl': [1, 2, 3, 4],
     'ple': [1, 2, 3, 4],
     'pp': [1, 2, 3, 4],
     'ppl': [1, 2, 3, 4],
     'pple': [1, 2, 3, 4],
     'ra': [3, 4],
     'rab': [3, 4],
     'raba': [3, 4],
     'rabap': [3, 4],
     'rabapp': [3, 4],
     'rabappl': [3, 4],
     'rabapple': [3, 4]
   };
   ```

   <!-- CSpell: enable -->

4. Create the hash tables, saved to `autocomplete_hash.json`.

   Each distinct list of food ids is assigned the next integer key in
   `indexHash`, and every substring resolving to that list points at it.

   <!-- CSpell: disable -->

   ```text
   {
     'substringHash': {
       '2%': 0,
       '21': 1,
       'ab': 1,
       'aba': 1,
       'abap': 1,
       'abapp': 1,
       'abappl': 1,
       'abapple': 1,
       'ap': 2,
       'app': 2,
       'appl': 2,
       'apple': 2,
       'ba': 1,
       'bap': 1,
       'bapp': 1,
       'bappl': 1,
       'bapple': 1,
       'cr': 1,
       'cra': 1,
       'crab': 1,
       'craba': 1,
       'crabap': 1,
       'crabapp': 1,
       'crabappl': 1,
       'crabapple': 1,
       'le': 2,
       'pl': 2,
       'ple': 2,
       'pp': 2,
       'ppl': 2,
       'pple': 2,
       'ra': 1,
       'rab': 1,
       'raba': 1,
       'rabap': 1,
       'rabapp': 1,
       'rabappl': 1,
       'rabapple': 1
     },
     'indexHash': {
       '0': [3],
       '1': [3, 4],
       '2': [1, 2, 3, 4]
     }
   };
   ```

   <!-- CSpell: enable -->

5. Create the food Database object, and convert to json, written to
   `foods_db.json`.

   Only the nutrient ids in `Nutrient.keepTheseNutrients` are kept, and a
   nutrient is only written if its amount is greater than zero, so a missing
   nutrient and an amount of zero are not distinguished in the output.

   ```text
   {
     '167512': {
       'description':
           'Pillsbury Golden Layer Buttermilk Biscuits, Artificial '
           'Flavor, refrigerated dough',
       'nutrients': {'1004': 13.2, '1003': 5.88, '1005': 41.2, '1008': 307, '1258': 2.94, ...}
     }, ...
   };
   ```
