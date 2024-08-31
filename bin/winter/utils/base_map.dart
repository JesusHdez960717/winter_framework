class BaseMap<T, V> implements Map<T, V> {
  final Map<T, V> _inner;

  BaseMap({Map<T, V>? map}) : _inner = map ?? {};

  @override
  V? operator [](Object? key) => _inner[key];

  @override
  void operator []=(T key, V value) => _inner[key] = value;

  @override
  void addAll(Map<T, V> other) => _inner.addAll(other);

  @override
  void addEntries(Iterable<MapEntry<T, V>> newEntries) =>
      _inner.addEntries(newEntries);

  @override
  Map<RK, RV> cast<RK, RV>() => _inner.cast<RK, RV>();

  @override
  void clear() => _inner.clear();

  @override
  bool containsKey(Object? key) => _inner.containsKey(key);

  @override
  bool containsValue(Object? value) => _inner.containsValue(value);

  @override
  Iterable<MapEntry<T, V>> get entries => _inner.entries;

  @override
  void forEach(void Function(T key, V value) action) => _inner.forEach(action);

  @override
  bool get isEmpty => _inner.isEmpty;

  @override
  bool get isNotEmpty => _inner.isNotEmpty;

  @override
  Iterable<T> get keys => _inner.keys;

  @override
  int get length => _inner.length;

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(T key, V value) convert) =>
      _inner.map(convert);

  @override
  V putIfAbsent(T key, V Function() ifAbsent) =>
      _inner.putIfAbsent(key, ifAbsent);

  @override
  V? remove(Object? key) => _inner.remove(key);

  @override
  void removeWhere(bool Function(T key, V value) test) =>
      _inner.removeWhere(test);

  @override
  V update(T key, V Function(V value) update, {V Function()? ifAbsent}) =>
      _inner.update(key, update);

  @override
  void updateAll(V Function(T key, V value) update) => _inner.updateAll(update);

  @override
  Iterable<V> get values => _inner.values;
}
