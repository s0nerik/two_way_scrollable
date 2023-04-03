## 2.2.1

- Removed `@internal` annotation from `TwoWayListController.centerSliverKey`.

## 2.2.0

- Added many of `TwoWayCustomScrollView` params into a `TwoWayListView` constructor.

## 2.1.0

- Fixed `index` parameter value in `itemBuilder`
- Added ability to provide a list of durations to `TwoWayListController.insertAll`

## 2.0.0

#### Breaking changes
- `SliverTwoWayListView` -> `SliverTwoWayList`
- `TwoWayListViewController` -> `TwoWayListController`

#### Other changes
- Automatic `initalItemCount` handling for `SliverTwoWayList`.
- Added early-return to `TwoWayListController.insertAll` in case of adding an empty items list.

## 1.0.0

- `TwoWayCustomScrollView`:
  - optimized size calculation
  - eliminated a need for the second layout pass
  - no more interference with ScrollPhysics, overscroll works as expected
- `TwoWayListView`: added `anchor` and `direction` parameters.
- Added `SliverTwoWayListView`, which allows for customizing items' positioning within a `TwoWayCustomScrollView`/`CustomScrollView`.

## 0.1.1

- Removed unused debug parameter
- Updated README.md

## 0.1.0

- `TwoWayListView` now provides a way to specify slivers for every possible slot

## 0.0.2

- `TwoWayCustomScrollView` now accepts any amount of children

## 0.0.1

- First release
