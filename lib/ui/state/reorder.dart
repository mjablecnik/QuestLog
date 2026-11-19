/// New id order for the shown subset after dragging [oldIndex] to [newIndex].
///
/// Follows Flutter's `ReorderableList` semantics: [newIndex] is the position
/// before the dragged item is removed, so it may equal `shownIds.length`.
/// Returns a new list; [shownIds] is not modified.
List<int> moveWithinSubset(List<int> shownIds, int oldIndex, int newIndex) {
  RangeError.checkValidIndex(oldIndex, shownIds, 'oldIndex');
  RangeError.checkValueInInterval(newIndex, 0, shownIds.length, 'newIndex');
  final result = List<int>.of(shownIds);
  final moved = result.removeAt(oldIndex);
  result.insert(newIndex > oldIndex ? newIndex - 1 : newIndex, moved);
  return result;
}

/// [items] arranged by [order] while a reorder is unconfirmed: ids in [order]
/// first, in that order (ids no longer present are skipped), then every other
/// item in its stream order.
List<T> applyOrder<T>(List<T> items, List<int>? order, int Function(T) idOf) {
  if (order == null) return items;
  final byId = <int, T>{for (final item in items) idOf(item): item};
  return <T>[
    for (final id in order)
      if (byId.remove(id) case final T item) item,
    ...byId.values,
  ];
}

/// True when [actual] (the order the stream reports) already shows [order]:
/// the ids of [order] that still exist appear in that relative order.
bool orderConfirmed(List<int> order, List<int> actual) {
  final present = actual.toSet();
  final expected = <int>[
    for (final id in order)
      if (present.contains(id)) id,
  ];
  if (expected.length != actual.length) return false;
  for (var i = 0; i < expected.length; i++) {
    if (expected[i] != actual[i]) return false;
  }
  return true;
}
