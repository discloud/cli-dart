import "dart:io";

import "package:args/args.dart";
import "package:interpolation/interpolation.dart";
import "package:pub_semver/pub_semver.dart";

void main(Iterable<String> args) async {
  final parser = ArgParser()..addOption("version", mandatory: true);
  final parsed = parser.parse(args);
  final version = parsed.option("version")!;
  Version.parse(version);

  final issFile = File("inno_setup.iss");
  final pubspecFile = File("pubspec.yaml");

  final interpolator = Interpolation(
    option: .new(prefix: "{{", suffix: "}}"),
  );

  String issContent = await issFile.readAsString();
  String pubspecContent = await pubspecFile.readAsString();

  issContent = interpolator.eval(issContent, {"version": version});
  pubspecContent = pubspecContent.replaceFirst(
    pubspecVersionRegexp,
    "\nversion: $version\n",
  );

  await issFile.writeAsString(issContent);
  await pubspecFile.writeAsString(pubspecContent);
}

const pubspecVersionPattern = r"\r?\nversion:\s\d+\.\d+\.\d+\r?\n";
final pubspecVersionRegexp = RegExp(pubspecVersionPattern);
