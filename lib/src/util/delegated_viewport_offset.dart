import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

abstract class DelegatedViewportOffset implements ViewportOffset {
  DelegatedViewportOffset(this._delegate);

  final ViewportOffset _delegate;

  @override
  void addListener(VoidCallback listener) => _delegate.addListener(listener);

  @override
  bool get allowImplicitScrolling => _delegate.allowImplicitScrolling;

  @override
  Future<void> animateTo(
    double to, {
    required Duration duration,
    required Curve curve,
  }) =>
      _delegate.animateTo(to, duration: duration, curve: curve);

  @override
  bool applyContentDimensions(double minScrollExtent, double maxScrollExtent) =>
      _delegate.applyContentDimensions(minScrollExtent, maxScrollExtent);

  @override
  bool applyViewportDimension(double viewportDimension) =>
      _delegate.applyViewportDimension(viewportDimension);

  @override
  void correctBy(double correction) => _delegate.correctBy(correction);

  @override
  void debugFillDescription(List<String> description) =>
      _delegate.debugFillDescription(description);

  @override
  void dispose() => _delegate.dispose();

  @override
  bool get hasListeners => _delegate.hasListeners;

  @override
  bool get hasPixels => _delegate.hasPixels;

  @override
  void jumpTo(double pixels) => _delegate.jumpTo(pixels);

  @override
  Future<void> moveTo(
    double to, {
    Duration? duration,
    Curve? curve,
    bool? clamp,
  }) =>
      _delegate.moveTo(to, duration: duration, curve: curve, clamp: clamp);

  @override
  void notifyListeners() => _delegate.notifyListeners();

  @override
  double get pixels => _delegate.pixels;

  @override
  void removeListener(VoidCallback listener) =>
      _delegate.removeListener(listener);

  @override
  ScrollDirection get userScrollDirection => _delegate.userScrollDirection;
}
