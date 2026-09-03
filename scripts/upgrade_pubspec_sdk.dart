// dart scripts/upgrade_pubspec_sdk.dart

import "dart:io";

import "package:path/path.dart";
import "package:pub_semver/pub_semver.dart";

const _pubspecFilename = "pubspec.yaml";
const _pubspecSdkPattern =
    r"(\r?\nenvironment:\s*\r?\n[\w\W]*\s+sdk:\s*\^)(\d+\.\d+\.\d+\S*)((?:\r?\n)+)";
final _pubspecSdkRegexp = RegExp(_pubspecSdkPattern);
final Version _dartVersion = .parse(
  Platform.version.replaceFirst(RegExp(r"\s+.+"), ""),
);

void _noop(Object _, StackTrace _) {}

void main() async {
  final Directory modules = .new("modules");

  await for (final entity in modules.list(recursive: true).handleError(_noop)) {
    if (entity is! File || basename(entity.path) != _pubspecFilename) continue;
    await _upgradePubspecVersion(entity);
  }
}

Future<void> _upgradePubspecVersion(File pubspecFile) async {
  String content = await pubspecFile.readAsString();
  final matched = _pubspecSdkRegexp.firstMatch(content);
  final pubspecVersion = Version.parse(matched!.group(2)!);

  if (_dartVersion <= pubspecVersion) return;

  content = content.replaceFirst(
    _pubspecSdkRegexp,
    "${matched.group(1)}$_dartVersion${matched.group(3)}",
  );

  await pubspecFile.writeAsString(content);
}
