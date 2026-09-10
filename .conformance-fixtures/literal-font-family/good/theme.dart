// ThemeData.fontFamily takes no package argument: the token is interpolated into
// a package-prefixed string. Reads the token, so it passes.
final ThemeData t = ThemeData(fontFamily: 'packages/$skFontPackage/${SkFonts.sans}');
