## two_way_scrollable

[![two_way_scrollable](https://img.shields.io/pub/v/two_way_scrollable)](https://pub.dev/packages/two_way_scrollable)
[![two_way_scrollable](https://img.shields.io/pub/likes/two_way_scrollable)](https://pub.dev/packages/two_way_scrollable)
[![two_way_scrollable](https://img.shields.io/pub/points/two_way_scrollable)](https://pub.dev/packages/two_way_scrollable)
[![two_way_scrollable](https://img.shields.io/pub/popularity/two_way_scrollable)](https://pub.dev/packages/two_way_scrollable)

A set of two-way growable widgets for Flutter that properly fill the viewport even if there is not enough content.

## Example

![example](doc/images/example.gif)

## Features

- `TwoWayCustomScrollView` - a `CustomScrollView` replacement that properly grows in both directions.
- `TwoWayListView` - an `AnimatedListView` analog that properly grows in both directions. Based on `TwoWayCustomScrollView` and `SliverTwoWayList`.
- `SliverTwoWayList` - a set of `Sliver` widgets that can be used with `TwoWayCustomScrollView`/`CustomScrollView` to achieve any positioning in a list.

Note: `TwoWayCustomScrollView` and `TwoWayListView` only allow anchoring to the top or bottom, but not in the middle.

## Getting started

```shell
flutter pub add two_way_scrollable
```

## Usage

https://github.com/s0nerik/two_way_scrollable/blob/07f2dcdcd31c0f3d0dc4ff35fb15ebf35d389801/example/lib/main.dart#L148
