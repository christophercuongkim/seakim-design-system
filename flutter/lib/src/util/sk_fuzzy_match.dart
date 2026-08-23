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
/// higher score for a better one. Case- and accent-insensitive, so "zurich"
/// finds "Zürich" and "sao" finds "São" — the currency / country / timezone
/// lists this is built for are full of accented names. An empty query matches
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
  final String q = _fold(query.trim().toLowerCase());
  if (q.isEmpty) return 1;
  final String t = _fold(target.toLowerCase());

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
  // a-z, 0-9 (target is already lower-cased and folded to ASCII).
  return (c >= 0x61 && c <= 0x7a) || (c >= 0x30 && c <= 0x39);
}

/// Folds common Latin diacritics to their ASCII base, so a query typed without
/// accents still matches. Input is already lower-cased. Covers the Latin-1
/// Supplement and the common Latin Extended-A letters (ā, š, ł, …); a couple of
/// ligatures expand (æ→ae, ß→ss). Anything outside the table passes through
/// unchanged. Pure-ASCII strings — the common case — take a fast path and are
/// returned as-is.
String _fold(String s) {
  bool ascii = true;
  for (int i = 0; i < s.length; i++) {
    if (s.codeUnitAt(i) > 0x7f) {
      ascii = false;
      break;
    }
  }
  if (ascii) return s;

  final StringBuffer b = StringBuffer();
  for (final int r in s.runes) {
    b.write(_foldMap[r] ?? String.fromCharCode(r));
  }
  return b.toString();
}

const Map<int, String> _foldMap = <int, String>{
  0x00E0: 'a', 0x00E1: 'a', 0x00E2: 'a', 0x00E3: 'a', 0x00E4: 'a', 0x00E5: 'a',
  0x0101: 'a', 0x0103: 'a', 0x0105: 'a', 0x00E6: 'ae',
  0x00E7: 'c', 0x0107: 'c', 0x0109: 'c', 0x010B: 'c', 0x010D: 'c',
  0x00F0: 'd', 0x0111: 'd', 0x010F: 'd',
  0x00E8: 'e', 0x00E9: 'e', 0x00EA: 'e', 0x00EB: 'e',
  0x0113: 'e', 0x0115: 'e', 0x0117: 'e', 0x0119: 'e', 0x011B: 'e',
  0x011D: 'g', 0x011F: 'g', 0x0121: 'g', 0x0123: 'g',
  0x00EC: 'i', 0x00ED: 'i', 0x00EE: 'i', 0x00EF: 'i',
  0x0129: 'i', 0x012B: 'i', 0x012D: 'i', 0x012F: 'i', 0x0131: 'i',
  0x0135: 'j', 0x0137: 'k',
  0x0142: 'l', 0x013A: 'l', 0x013C: 'l', 0x013E: 'l',
  0x00F1: 'n', 0x0144: 'n', 0x0146: 'n', 0x0148: 'n',
  0x00F2: 'o', 0x00F3: 'o', 0x00F4: 'o', 0x00F5: 'o', 0x00F6: 'o', 0x00F8: 'o',
  0x014D: 'o', 0x014F: 'o', 0x0151: 'o', 0x0153: 'oe',
  0x0155: 'r', 0x0157: 'r', 0x0159: 'r',
  0x015B: 's', 0x015D: 's', 0x015F: 's', 0x0161: 's', 0x00DF: 'ss',
  0x0163: 't', 0x0165: 't', 0x0167: 't',
  0x00F9: 'u', 0x00FA: 'u', 0x00FB: 'u', 0x00FC: 'u',
  0x0169: 'u', 0x016B: 'u', 0x016D: 'u', 0x016F: 'u', 0x0171: 'u', 0x0173: 'u',
  0x00FD: 'y', 0x00FF: 'y',
  0x017A: 'z', 0x017C: 'z', 0x017E: 'z',
};
