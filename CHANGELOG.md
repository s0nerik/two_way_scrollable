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
