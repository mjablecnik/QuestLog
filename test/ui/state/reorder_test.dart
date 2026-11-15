import 'package:glados/glados.dart';
import 'package:questlog/ui/state/reorder.dart';

void main() {
  group('moveWithinSubset examples', () {
    test('moves an item down', () {
      expect(moveWithinSubset([1, 2, 3, 4], 0, 3), [2, 3, 1, 4]);
    });

    test('moves an item to the very end with newIndex == length', () {
      expect(moveWithinSubset([1, 2, 3, 4], 0, 4), [2, 3, 4, 1]);
    });

    test('moves an item up', () {
      expect(moveWithinSubset([1, 2, 3, 4], 3, 1), [1, 4, 2, 3]);
    });

    test('dropping in place changes nothing', () {
      expect(moveWithinSubset([1, 2, 3], 1, 1), [1, 2, 3]);
      expect(moveWithinSubset([1, 2, 3], 1, 2), [1, 2, 3]);
    });

    test('a single element stays', () {
      expect(moveWithinSubset([7], 0, 0), [7]);
      expect(moveWithinSubset([7], 0, 1), [7]);
    });

    test('does not mutate its input', () {
      final input = [1, 2, 3];
      moveWithinSubset(input, 0, 3);
      expect(input, [1, 2, 3]);
    });

    test('rejects invalid indexes', () {
      expect(() => moveWithinSubset([1, 2], 2, 0), throwsRangeError);
      expect(() => moveWithinSubset([1, 2], -1, 0), throwsRangeError);
      expect(() => moveWithinSubset([1, 2], 0, 3), throwsRangeError);
      expect(() => moveWithinSubset([1, 2], 0, -1), throwsRangeError);
      expect(() => moveWithinSubset(<int>[], 0, 0), throwsRangeError);
    });
  });

  group('Property 1: reordering a subset preserves everything else', () {
    Glados3(any.positiveIntOrZero, any.positiveIntOrZero, any.positiveIntOrZero)
        .test('result is a permutation with the moved id at the target and the rest in order', (
      size,
      rawOld,
      rawNew,
    ) {
      final length = size % 40 + 1;
      final ids = [for (var i = 0; i < length; i++) i * 7 + 3];
      final oldIndex = rawOld % length;
      final newIndex = rawNew % (length + 1);

      final result = moveWithinSubset(ids, oldIndex, newIndex);

      final target = newIndex > oldIndex ? newIndex - 1 : newIndex;
      final moved = ids[oldIndex];
      expect(result.length, ids.length);
      expect([...result]..sort(), [...ids]..sort());
      expect(result[target], moved);
      expect(
        result.where((id) => id != moved).toList(),
        ids.where((id) => id != moved).toList(),
      );
    });
  });
}
