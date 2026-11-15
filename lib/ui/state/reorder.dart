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
