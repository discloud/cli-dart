part of "glob_zipper.dart";

const _pattern = r"\s*#.*";
final _regExp = RegExp(_pattern);

String _gitignoreTextToGlobConverter(String content) {
  content = content.replaceAll(_regExp, _empty);

  final pattern = _transformIterableToGlob(LineSplitter.split(content));

  return _transformIterableGlobToGlobPattern(pattern);
}

Iterable<String> _transformIterableToGlob(Iterable<String> iterable) {
  return iterable
      .where((e) => e.isNotEmpty)
      .map(
        (e) => e.endsWith(_pSep) ? "$e$_gStar" : "{$e$_gSep$e$_pSep$_gStar}",
      );
}

String _transformIterableGlobToGlobPattern(Iterable<String> iterable) {
  return iterable.length > 1
      ? "{${iterable.join(_gSep)}}"
      : iterable.join(_gSep);
}

Future<String> _gitignoreFileToGlobConverter(File file) async {
  final content = await file.readAsString();
  return _gitignoreTextToGlobConverter(content);
}
