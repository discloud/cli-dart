part of "glob_zipper.dart";

const _pattern = r"\s*#.*";
final _regExp = RegExp(_pattern);

String _gitignoreTextToGlobConverter(String content) {
  content = content.replaceAll(_regExp, _empty);

  final pattern = transformIterableToGlob(LineSplitter.split(content));

  return pattern.length > 1 ? "{${pattern.join(_gSep)}}" : pattern.join(_gSep);
}

Iterable<String> transformIterableToGlob(Iterable<String> iterable) {
  return iterable
      .where((e) => e.isNotEmpty)
      .map(
        (e) => e.endsWith(_pSep) ? "$e$_gStar" : "{$e$_gSep$e$_pSep$_gStar}",
      );
}

Future<String> gitignoreFileToGlobConverter(File file) async {
  final content = await file.readAsString();
  return _gitignoreTextToGlobConverter(content);
}
