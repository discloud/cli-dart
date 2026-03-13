import "dart:convert";
import "dart:io";

const _eString = "";
const _gStar = "**";
const _gSep = ",";
const _pSep = "/";
const _pattern = r"\s*#.*";
final _regExp = RegExp(_pattern);

String _gitignoreTextToGlobConverter(String content) {
  content = content.replaceAll(_regExp, _eString);

  final pattern = transformIterableToGlob(LineSplitter.split(content));

  return "{${pattern.join(_gSep)}}";
}

Iterable<String> transformIterableToGlob(Iterable<String> iterable) {
  return iterable
      .where((e) => e.isNotEmpty)
      .map((e) => e.endsWith(_pSep) ? "$e$_gStar" : "$e$_gSep$e$_pSep$_gStar");
}

Future<String> gitignoreFileToGlobConverter(File file) async {
  final content = await file.readAsString();
  return _gitignoreTextToGlobConverter(content);
}
