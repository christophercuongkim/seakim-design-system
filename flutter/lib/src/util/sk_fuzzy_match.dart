// A tiny, dependency-free fuzzy matcher for filtering short in-app lists — the
// candidate default matcher for the searchable long-list picker proposed in
// decisions/0028-searchable-select.md. It ships as a util ahead of that
// primitive so consumers who must hand-roll a picker today (a currency /
// timezone / country list) share one ranking instead of each inventing their
// own. Shipped as a standalone function, not tied to a widget, so 0028 can
// adopt, replace, or reject it without churn.
//
// It's a scored subsequence match — fzf-lite — not full edit-distance: the
// query's characters must appear in order in the target, and the score rewards
// matches that start the string, start a word, or run contiguously, so the best
// hit floats up.

/// Fuzzy-match score of [query] against [target]. Returns 0 for no match and a
/// higher score for a better one. Case-insensitive. An empty query matches
/// everything with a flat score of 1 (callers keep their original order).
///
/// Typical use ranks a list and drops the misses:
///
///     final ranked = [
///       for (final item in items)
///         (item: item, score: skFuzzyScore(query, item.label)),
///     ]..removeWhere((e) => e.score == 0)
///       ..sort((a, b) => b.score.compareTo(a.score));
int skFuzzyScore(String query, String target) {
  final String q = query.trim().toLowerCase();
  if (q.isEmpty) return 1;
  final String t = target.toLowerCase();

  int score = 0;
  int from = 0;
  int prev = -2; // index of the previous matched char, for the contiguity bonus
  for (int qi = 0; qi < q.length; qi++) {
    final int ch = q.codeUnitAt(qi);
    int at = -1;
    for (int j = from; j < t.length; j++) {
      if (t.codeUnitAt(j) == ch) {
        at = j;
        break;
      }
    }
    if (at < 0) return 0; // a query char isn't present in order -> no match

    int bonus = 1;
    if (at == 0) {
      bonus += 4; // very start of the string
    } else if (!_isWordChar(t.codeUnitAt(at - 1))) {
      bonus += 3; // start of a word (after a space or separator)
    }
    if (at == prev + 1) bonus += 3; // contiguous with the previous match

    score += bonus;
    prev = at;
    from = at + 1;
  }
  return score;
}

bool _isWordChar(int c) {
  // a-z, 0-9 (target is already lower-cased).
  return (c >= 0x61 && c <= 0x7a) || (c >= 0x30 && c <= 0x39);
}
