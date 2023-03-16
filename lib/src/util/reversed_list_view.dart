import 'dart:collection';

class ReversedListView<T> extends ListBase<T>
    implements UnmodifiableListView<T> {
  ReversedListView(this._list);

  final List<T> _list;

  @override
  Iterator<T> get iterator => _ReverseListIterator(_list);

  @override
  int get length => _list.length;

  @override
  set length(int length) {
    _throw();
  }

  @override
  T operator [](int index) {
    final realIndex = _list.length - 1 - index;
    return _list[realIndex];
  }

  @override
  void operator []=(int index, T value) {
    _throw();
  }

  @override
  void clear() {
    _throw();
  }

  @override
  bool remove(Object? element) {
    _throw();
  }

  @override
  void removeWhere(bool Function(T) test) {
    _throw();
  }

  @override
  void retainWhere(bool Function(T) test) {
    _throw();
  }

  static Never _throw() {
    throw UnsupportedError('Cannot modify an unmodifiable List');
  }
}

class _ReverseListIterator<E> implements Iterator<E> {
  _ReverseListIterator(Iterable<E> iterable)
      : _iterable = iterable,
        _length = iterable.length {
    _index = _length - 1;
  }

  final Iterable<E> _iterable;
  final int _length;
  late int _index;
  E? _current;

  @override
  E get current => _current as E;

  @override
  @pragma('vm:prefer-inline')
  bool moveNext() {
    final length = _iterable.length;
    if (_length != length) {
      throw ConcurrentModificationError(_iterable);
    }
    if (_index < length) {
      _current = null;
      return false;
    }
    _current = _iterable.elementAt(_index);
    _index--;
    return true;
  }
}
