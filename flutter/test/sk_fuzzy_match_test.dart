import 'package:flutter_test/flutter_test.dart';
import 'package:seakim_flutter/seakim_flutter.dart';

/// The candidate matcher for the searchable picker (decisions/0028). Locks the
/// ranking contract the picker will lean on: order-preserving subsequence,
/// misses score 0, and start-of-string / word-boundary / contiguity all rank
/// above a scattered match.
void main() {
  test('empty query matches everything with a flat score', () {
    expect(skFuzzyScore('', 'US Dollar'), 1);
    expect(skFuzzyScore('   ', 'Euro'), 1);
  });

  test('a char not present in order scores 0', () {
    expect(skFuzzyScore('zzz', 'US Dollar'), 0);
    expect(skFuzzyScore('due', 'US Dollar'), 0); // d, u, e not in order
  });

  test('case-insensitive subsequence matches', () {
    expect(skFuzzyScore('usd', 'USD US Dollar'), greaterThan(0));
    expect(skFuzzyScore('dlr', 'US Dollar'), greaterThan(0));
  });

  test('start-of-string beats a mid-string hit', () {
    expect(
      skFuzzyScore('us', 'US Dollar'),
      greaterThan(skFuzzyScore('us', 'Australian Dollar')),
    );
  });

  test('word-boundary hit beats a scattered one', () {
    // "ad" as the head of "Australian Dollar" (A..D word starts) outranks the
    // same letters buried inside a single word.
    expect(
      skFuzzyScore('ad', 'Australian Dollar'),
      greaterThan(skFuzzyScore('ad', 'Canadian')),
    );
  });

  test('contiguous run beats a split match', () {
    expect(
      skFuzzyScore('dol', 'Dollar'),
      greaterThan(skFuzzyScore('dol', 'Diamond of Lore')),
    );
  });
}
