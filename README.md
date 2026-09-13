# usda_db_creation

A dart library made to create a json database and autocomplete lookup, from
the USDA SR Legacy database json download file.

## Link to download Page

<https://fdc.nal.usda.gov/download-datasets.html>

## Link to download

<https://fdc.nal.usda.gov/fdc-datasets/FoodData_Central_sr_legacy_food_json_2018-04.zip>

## The intended output is 2 json files

1. The foods and nutritional information. I

   - The key is the food items id.
   - The nutrients map is structured so that the key is the id of the
     nutrient and the value is the amount.

   ```text
   {
     '111111': {
       'description':
           'Pillsbury Golden Layer Buttermilk Biscuits, Artificial '
           'Flavor, refrigerated dough',
       'nutrients': {1004: 10, 1003: 5, 1005: 10, 1008: .589, 1258: 10, ...}
     }, ...
   };
   ```

2. A lookup hash table of indexed words to search.

   - Each substringHash.value is a lookup to the indexHash.key.
   - The indexHash.value is a list of all the food items descriptions

   <!-- CSpell: disable -->

   ```text
   {
     'substringHash': {
       '21': 0,
       '1%': 1,
       '2%': 1,
       'aba': 1,
       'abap': 1,
       'abapp': 1,
       'abappl': 1,
       'abapple': 1,
       'app': 2, ...
     }
     'indexHash': {
       '0': [3],
       '1': [3, 4],
       '2': [1, 2, 3, 4]
     }
   };
   ```

   <!-- CSpell: enable -->

## Behind the scenes

1. Create a map food descriptions `{id: description, ...}` from the original
   database. Parse descriptions as necessary.

2. Create the word index. *Although the hashes could have been made by
   skipping this step, its good to have a file to look at.*

   ```text
   {
     "apple": [1, 2],
     "crabapple": [3, 4],
     "2%": [3],
     "21": [3, 4],
   }
   ```

3. Create the substrings of the word index.

   <!-- CSpell: disable -->

   ```text
   {
     '%': [3],
     '1': [3, 4],
     '2': [3, 4],
     'aba': [3, 4],
     'abap': [3, 4],
     'abapp': [3, 4],
     'abappl': [3, 4],
     'abapple': [3, 4],
     'app': [1, 2, 3, 4],
     'appl': [1, 2, 3, 4],
     'apple': [1, 2, 3, 4],
     'bap': [3, 4],
     'bapp': [3, 4],
     'bappl': [3, 4],
     'bapple': [3, 4],
     'cra': [3, 4],
     'crab': [3, 4],
     'craba': [3, 4],
     'crabap': [3, 4],
     'crabapp': [3, 4],
     'crabappl': [3, 4],
     'crabapple': [3, 4],
     'ple': [1, 2, 3, 4],
     'ppl': [1, 2, 3, 4],
     'pple': [1, 2, 3, 4],
     'rab': [3, 4],
     'raba': [3, 4],
     'rabap': [3, 4],
     'rabapp': [3, 4],
     'rabappl': [3, 4],
     'rabapple': [3, 4]
   };
   ```

4. Create the hash tables, save this structure to a json file.

   ```text
   {
     'substringHash': {
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
       0: [3],
       1: [3, 4],
       2: [1, 2, 3, 4]
     }
   };
   ```

   <!-- CSpell: enable -->

5. Create the food Database object, and convert to json.

   ```text
   {
     111111: {
       'description':
           'Pillsbury Golden Layer Buttermilk Biscuits, Artificial '
           'Flavor, refrigerated dough',
       'nutrients': {1004: 10, 1003: 5, 1005: 10, 1008: .589, 1258: 10, ...}
     }, ...
   };
   ```

## The do_not_delete folder has the original db file, and the nutrients files
