import "dart:io";

import "package:args/args.dart";
import "package:pub_semver/pub_semver.dart";

void main(Iterable<String> args) async {
  final parser = ArgParser()..addOption("version", mandatory: true);
  final parsed = parser.parse(args);
  final version = parsed.option("version")!;
  Version.parse(version);

  final pubspecFile = File("pubspec.yaml");

  String pubspecContent = await pubspecFile.readAsString();

  pubspecContent = pubspecContent.replaceFirst(
    pubspecVersionRegexp,
    "\nversion: $version\n",
  );

  await pubspecFile.writeAsString(pubspecContent);
}

const pubspecVersionPattern = r"\r?\nversion:\s(\d+)\.(\d+)\.(\d+)\r?\n";
final pubspecVersionRegexp = RegExp(pubspecVersionPattern);
