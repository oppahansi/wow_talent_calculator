# WoW Talent Calculator  

A dart package for handling wow talent calculator logic and state.

## Features

- Supports Classic, The Burning Crusade and Wrath of the Lich King expansions.
- Investing points
- Removing points
- Resetting a spec
- Resetting all specs
- Setting spec states (e.g.: Loading saved states)
- Printing spec to console
- Talent sequence is kept saved in the background
- Printing all specs to console
- Printing talent sequence to console

## Usage

To use the wow talent calculator package, add `wow_talent_calculator` as a dependency in your pubspec.yaml file.

## Example

```dart
import 'package:wow_talent_calculator/wow_talent_calculator.dart';

void main() {
  var wtc = WowTalentCalculator(expansionId: 0, charClassId: 0);

  for (int i = 0; i < 4; i++) {
    wtc.investPointAt(0, 0);
  }

  wtc.investPointAt(0, 1);
  wtc.investPointAt(0, 2);

  for (int i = 0; i < 3; i++) {
    wtc.investPointAt(0, 4);
  }

  wtc.investPointAt(0, 0);
  wtc.investPointAt(0, 8);

  wtc.printSpec(0);
  wtc.printAllSpecs();
}

```

Console output:

```bash
______________
| 5  1--1    |
|            |
| 3  0  0  0 |
|    |       |
| 1  |  0  0 |
|    |       |
|    0  0    |
|            |
|    0  0    |
|    |       |
|    0       |
|            |
|    0       |
______________
__________________________________________
| 5  1--1    ||    0  0    ||    0  0    |
|            ||            ||            |
| 3  0  0  0 || 0  0  0    || 0  0  0    |
|    |       ||            || |          |
| 1  |  0  0 || 0  0  0--| || |  0  0  0 |
|    |       ||       |  | || |     |    |
|    0  0    || 0  0  0  0 || |  0  |  0 |
|            ||    |       || |  |  |    |
|    0  0    || 0  |  0    || 0  |  0  0 |
|    |       ||    |       ||    |       |
|    0       ||    0       ||    |  0    |
|            ||            ||    |       |
|    0       ||    0       ||    0       |
__________________________________________

```

## Additional info

### Expansions

```dart
enum Expansions {
  vanilla,
  tbc,
  wotlk,
}
```

### Character classes

```dart
enum CharClasses {
  druid,
  hunter,
  mage,
  paladin,
  priest,
  roque,
  shaman,
  warlock,
  warrior,
  dk,
}
```

### Initializing

By default the talent calculator initializes with the `expansionId: 0` and `charClassId: 0` when no parameters are provided.
Id values correspond to their enum indecies.

```dart
var wtc = WowTalentCalculator(expansionId: 0, charClassId: 0);
// is the same as
var wtcSame = WowTalentCalculator();
```
