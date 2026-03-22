import "dart:io";

import "package:args/args.dart";
import "package:yaml/yaml.dart";

void main(Iterable<String> args) async {
  final parser = ArgParser()..addOption("version");
  final parsed = parser.parse(args);

  File? issFile;
  File? pubspecFile;
  await for (final entity in Directory.current.list()) {
    if (entity is! File) continue;
    final filename = entity.uri.pathSegments.last;

    final issFileIsNull = issFile == null;
    final pubspecFileIsNull = pubspecFile == null;

    if (issFileIsNull && filename.endsWith(issFileExtension)) {
      issFile = entity;
      if (!pubspecFileIsNull) break;
    }

    if (pubspecFileIsNull && filename == pubspecFilename) {
      pubspecFile = entity;
      if (!issFileIsNull) break;
    }
  }

  if (pubspecFile == null) throw Exception("pubspec.yaml not found.");
  if (issFile == null) throw Exception("iss file not found.");

  final issLines = await issFile.readAsLines();
  final pubspec = loadYaml(await pubspecFile.readAsString());

  final version = parsed.option("version") ?? pubspec["version"];

  String? section;
  bool appVersionWasSynced = false;
  bool versionInfoVersionWasSynced = false;
  for (int i = 0; i < issLines.length; i++) {
    if (appVersionWasSynced && versionInfoVersionWasSynced) break;

    final line = issLines[i];

    if (sectionRegExp.firstMatch(line) case final matched?) {
      section = matched.group(1);
      continue;
    }

    if (section == issSetupSectionName) {
      if (line.startsWith(issAppVersionLeft)) {
        issLines[i] = "$issAppVersionLeft$version";
        appVersionWasSynced = true;
        continue;
      }

      if (line.startsWith(issVersionInfoVersionLeft)) {
        issLines[i] = "$issVersionInfoVersionLeft$version.0";
        versionInfoVersionWasSynced = true;
        continue;
      }
    }
  }

  if (!appVersionWasSynced || !versionInfoVersionWasSynced) {
    throw Exception(
      "Please put AppVersion= and VersionInfoVersion= in Setup section",
    );
  }

  await issFile.writeAsString(issLines.join("\n"));
}

const issFileExtension = ".iss";
const issSetupSectionName = "Setup";
const issAppVersionLeft = "AppVersion=";
const issVersionInfoVersionLeft = "VersionInfoVersion=";
const pubspecFilename = "pubspec.yaml";
const sectionPattern = r"^\[(?<section>\w+)\]\s*$";
final sectionRegExp = RegExp(sectionPattern);
