## 2.0.0

- **BREAKING:** the keys inside each `foods_db.json` record are renamed to
  single characters: `description` is now `d` and `nutrients` is now `n`.
  Consumers of `foods_db.json` must read the new keys.
- Each food record has a new `c` key holding its USDA food category code as an
  int, for example `1800` for `Baked Products`.
- A new `food_categories.json` is written beside `foods_db.json`, mapping every
  category code to its name, for example `{"1800": "Baked Products", ...}`.

